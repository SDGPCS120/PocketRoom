using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Threading.Tasks;
using TMPro;
using UnityEngine;
using UnityEngine.Networking;
using UnityEngine.UI;
#if FIREBASE_FIRESTORE
using Firebase;
using Firebase.Firestore;
#endif

public class RuntimeGlbCartLoader : MonoBehaviour
{
    [Header("Firestore")]
    [SerializeField] private string collectionName = "products";

    [Header("Cart Menu UI")]
    [SerializeField] private Transform cartContentRoot;
    [SerializeField] private GameObject cartItemButtonPrefab;
    [SerializeField] private TMP_Text selectedNameText;
    [SerializeField] private TMP_Text statusText;

    [SerializeField] private bool loadOnStart = true;

#if FIREBASE_FIRESTORE
    private FirebaseFirestore firestore;
#endif
    private readonly Dictionary<string, CatalogItem> catalogById = new Dictionary<string, CatalogItem>();

    private class CatalogItem
    {
        public string Id;
        public string Name;
        public string GlbUrl;
        public string ImageUrl;
        public string PriceText;
        public int SortOrder;
    }

    //this auto-loads cart items on startup when loadOnStart is enabled.
    private async void Start()
    {
        if (loadOnStart)
        {
            await RefreshCartAsync();
        }
    }

    //this connects to Firebase, reads products, and builds the cart UI.
    public async Task RefreshCartAsync()
    {
#if !FIREBASE_FIRESTORE
        // Keeps compile/runtime stable when Firebase SDK or define is missing.
        SetStatus("Enable FIREBASE_FIRESTORE + Firebase SDK");
        Debug.LogError("RuntimeGlbCartLoader requires Firebase Firestore SDK. Add Firebase Firestore package and define FIREBASE_FIRESTORE.");
        await Task.CompletedTask;
        return;
#else
        SetStatus("Checking Firebase...");

        var dependencyStatus = await FirebaseApp.CheckAndFixDependenciesAsync();
        if (dependencyStatus != DependencyStatus.Available)
        {
            SetStatus("Firebase dependency error");
            Debug.LogError($"Firebase dependencies not available: {dependencyStatus}");
            return;
        }

        try
        {
            firestore = FirebaseFirestore.DefaultInstance;
        }
        catch (Exception e)
        {
            var desktopCfg = Path.Combine(Application.streamingAssetsPath, "google-services-desktop.json");
            var mobileCfg = Path.Combine(Application.streamingAssetsPath, "google-services.json");
            SetStatus("Missing or invalid Firebase config");
            Debug.LogError(
                "Firebase initialization failed. Ensure google-services.json is valid and imported via Assets root. " +
                $"Looked for: {desktopCfg} and {mobileCfg}. Exception: {e.Message}"
            );
            return;
        }

        ClearCartButtons();
        catalogById.Clear();

        SetStatus("Loading catalog...");

        QuerySnapshot snapshot;
        try
        {
            snapshot = await firestore.Collection(collectionName).GetSnapshotAsync();
        }
        catch (Exception e)
        {
            SetStatus("Failed to load catalog");
            Debug.LogError($"Firestore read failed: {e}");
            return;
        }

        var items = ParseCatalog(snapshot).OrderBy(i => i.SortOrder).ThenBy(i => i.Name).ToList();
        if (items.Count == 0)
        {
            SetStatus("No items found");
            return;
        }

        foreach (var item in items)
        {
            catalogById[item.Id] = item;
            CreateCartButton(item.Id, item.Name, item.PriceText, item.ImageUrl);
        }

        SetStatus($"Loaded {items.Count} items");
#endif
    }

#if FIREBASE_FIRESTORE
    //this converts Firestore documents into catalog items used by the UI.
    private List<CatalogItem> ParseCatalog(QuerySnapshot snapshot)
    {
        var items = new List<CatalogItem>();

        foreach (var doc in snapshot.Documents)
        {
            if (!doc.Exists)
            {
                continue;
            }

            string name = doc.TryGetValue("name", out string nameValue) ? nameValue : doc.Id;
            // Supports both current field name (modelURL) and legacy field name (glbUrl).
            string glbUrl = doc.TryGetValue("modelURL", out string modelUrlValue)
                ? modelUrlValue
                : (doc.TryGetValue("glbUrl", out string legacyUrlValue) ? legacyUrlValue : string.Empty);
            int sort = doc.TryGetValue("sortOrder", out int sortValue) ? sortValue : int.MaxValue;
            bool enabled = doc.TryGetValue("enabled", out bool enabledValue) ? enabledValue : true;

            if (!enabled || string.IsNullOrWhiteSpace(glbUrl))
            {
                continue;
            }

            items.Add(new CatalogItem
            {
                Id = doc.Id,
                Name = name,
                GlbUrl = glbUrl,
                ImageUrl = GetImageUrl(doc),
                PriceText = GetPriceText(doc),
                SortOrder = sort
            });
        }

        return items;
    }

    //this reads the price field and formats it as a display string with $.
    private static string GetPriceText(DocumentSnapshot doc)
    {
        if (!doc.TryGetValue("price", out object rawPrice) || rawPrice == null)
        {
            return string.Empty;
        }

        if (rawPrice is long longPrice)
        {
            return $"${longPrice}";
        }

        if (rawPrice is double doublePrice)
        {
            return $"${doublePrice:0.##}";
        }

        string text = rawPrice.ToString();
        if (string.IsNullOrWhiteSpace(text)) return string.Empty;
        return text.TrimStart().StartsWith("$", StringComparison.Ordinal) ? text : $"${text}";
    }

    //this reads the imageUrl field from a Firestore document.
    private static string GetImageUrl(DocumentSnapshot doc)
    {
        if (!doc.TryGetValue("imageUrl", out string imageUrl))
        {
            return string.Empty;
        }
        return imageUrl ?? string.Empty;
    }
#endif

    //this creates one cart button and fills its title, price, and thumbnail.
    private void CreateCartButton(string itemId, string itemName, string priceText, string imageUrl)
    {
        if (cartContentRoot == null || cartItemButtonPrefab == null)
        {
            Debug.LogError("Cart UI references are missing.");
            return;
        }

        var itemButtonObj = Instantiate(cartItemButtonPrefab, cartContentRoot);
        var button = itemButtonObj.GetComponent<Button>();
        TMP_Text[] labels = itemButtonObj.GetComponentsInChildren<TMP_Text>(true);
        TMP_Text titleLabel = FindLabelByName(labels, "title");
        TMP_Text priceLabel = FindLabelByName(labels, "price");

        // Fallbacks keep old prefabs working even if label objects are not named.
        if (titleLabel == null && labels.Length > 0) titleLabel = labels[0];
        if (priceLabel == null && labels.Length > 1) priceLabel = labels[1];

        if (titleLabel != null) titleLabel.text = itemName;
        if (priceLabel != null) priceLabel.text = priceText;

        // Finds image slot by name ("image") first, then falls back to first child Image.
        var imageSlot = FindImageByName(itemButtonObj.GetComponentsInChildren<Image>(true), "image");
        if (imageSlot != null && !string.IsNullOrWhiteSpace(imageUrl))
        {
            // Loads thumbnail from Firestore URL at runtime.
            StartCoroutine(LoadImageIntoSlot(imageUrl, imageSlot));
        }

        // Backward compatibility: disable legacy prefab assignment for runtime catalog items.
        var legacyButtonManager = itemButtonObj.GetComponent<buttonManager>();
        if (legacyButtonManager != null)
        {
            // Prevent legacy click listener from overwriting runtime selection with null prefab.
            legacyButtonManager.furniture = null;
            legacyButtonManager.enabled = false;
        }

        if (button != null)
        {
            button.onClick.AddListener(() => OnCartItemSelected(itemId, itemName));
        }
    }

    //this stores the selected model so the user can place it in AR.
    private void OnCartItemSelected(string itemId, string itemName)
    {
        if (!catalogById.TryGetValue(itemId, out var item))
        {
            SetStatus("Item not loaded");
            return;
        }

        // Selection stores only metadata; the model is loaded later by NetworkFurnitureLoader.
        dataHandler.Instance.SetRuntimeModelSelection(item.GlbUrl, item.Name);

        if (selectedNameText != null)
        {
            selectedNameText.text = item.Name;
        }
    }

    //this clears old cart buttons before rebuilding the list.
    private void ClearCartButtons()
    {
        if (cartContentRoot == null)
        {
            return;
        }

        for (int i = cartContentRoot.childCount - 1; i >= 0; i--)
        {
            Destroy(cartContentRoot.GetChild(i).gameObject);
        }
    }

    //this updates the status text shown in the UI.
    private void SetStatus(string message)
    {
        if (statusText != null)
        {
            statusText.text = message;
        }
    }

    //this finds a TMP label by name keyword like "title" or "price".
    private static TMP_Text FindLabelByName(TMP_Text[] labels, string keyword)
    {
        for (int i = 0; i < labels.Length; i++)
        {
            if (labels[i] == null) continue;
            string n = labels[i].gameObject.name;
            if (!string.IsNullOrWhiteSpace(n) &&
                n.IndexOf(keyword, StringComparison.OrdinalIgnoreCase) >= 0)
            {
                return labels[i];
            }
        }
        return null;
    }

    //this finds an Image component by name keyword like "image".
    private static Image FindImageByName(Image[] images, string keyword)
    {
        for (int i = 0; i < images.Length; i++)
        {
            if (images[i] == null) continue;
            string n = images[i].gameObject.name;
            if (!string.IsNullOrWhiteSpace(n) &&
                n.IndexOf(keyword, StringComparison.OrdinalIgnoreCase) >= 0)
            {
                return images[i];
            }
        }

        // Skip the root button Image when possible and use the first child image as fallback.
        for (int i = 0; i < images.Length; i++)
        {
            if (images[i] == null) continue;
            if (images[i].transform.parent != null) return images[i];
        }

        return images.Length > 0 ? images[0] : null;
    }

    //this downloads an image from URL and assigns it to the target UI Image.
    private static System.Collections.IEnumerator LoadImageIntoSlot(string imageUrl, Image targetImage)
    {
        using (var request = UnityWebRequestTexture.GetTexture(imageUrl))
        {
            yield return request.SendWebRequest();

            if (request.result != UnityWebRequest.Result.Success)
            {
                Debug.LogWarning($"Image load failed: {imageUrl} ({request.error})");
                yield break;
            }

            Texture2D texture = DownloadHandlerTexture.GetContent(request);
            if (texture == null || targetImage == null) yield break;

            var sprite = Sprite.Create(
                texture,
                new Rect(0, 0, texture.width, texture.height),
                new Vector2(0.5f, 0.5f)
            );
            targetImage.sprite = sprite;
            targetImage.preserveAspect = true;
        }
    }
}
