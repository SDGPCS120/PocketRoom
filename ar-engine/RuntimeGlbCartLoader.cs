using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Threading.Tasks;
using TMPro;
using UnityEngine;
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
        public int SortOrder;
    }

    private async void Start()
    {
        if (loadOnStart)
        {
            await RefreshCartAsync();
        }
    }

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
            CreateCartButton(item.Id, item.Name);
        }

        SetStatus($"Loaded {items.Count} items");
#endif
    }

#if FIREBASE_FIRESTORE
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
                SortOrder = sort
            });
        }

        return items;
    }
#endif

    private void CreateCartButton(string itemId, string itemName)
    {
        if (cartContentRoot == null || cartItemButtonPrefab == null)
        {
            Debug.LogError("Cart UI references are missing.");
            return;
        }

        var itemButtonObj = Instantiate(cartItemButtonPrefab, cartContentRoot);
        var button = itemButtonObj.GetComponent<Button>();
        var nameLabel = itemButtonObj.GetComponentInChildren<TMP_Text>(true);
        if (nameLabel != null)
        {
            nameLabel.text = itemName;
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

    private void OnCartItemSelected(string itemId, string itemName)
    {
        if (!catalogById.TryGetValue(itemId, out var item))
        {
            SetStatus("Item not loaded");
            return;
        }

        dataHandler.Instance.SetRuntimeModelSelection(item.GlbUrl, item.Name);

        if (selectedNameText != null)
        {
            selectedNameText.text = item.Name;
        }

        SetStatus($"Selected: {item.Name}");
    }

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

    private void SetStatus(string message)
    {
        if (statusText != null)
        {
            statusText.text = message;
        }
    }
}
