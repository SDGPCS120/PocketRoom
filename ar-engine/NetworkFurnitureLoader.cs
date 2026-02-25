using System;
using System.Threading.Tasks;
using GLTFast;
using GLTFast.Logging;
using Photon.Pun;
using UnityEngine;

public class NetworkFurnitureLoader : MonoBehaviourPun, IPunInstantiateMagicCallback
{
    [SerializeField] private bool tagAsFurniture = true;
    [SerializeField] private string modelUrl;
    [SerializeField] private string modelName;

    private bool hasStarted;

    public void OnPhotonInstantiate(PhotonMessageInfo info)
    {
        if (photonView.InstantiationData == null || photonView.InstantiationData.Length == 0) return;

        modelUrl = photonView.InstantiationData[0] as string;
        if (photonView.InstantiationData.Length > 1)
        {
            modelName = photonView.InstantiationData[1] as string;
        }
    }

    public void InitializeFromSelection(string url, string name)
    {
        modelUrl = url;
        modelName = name;
    }

    private async void Start()
    {
        if (hasStarted) return;
        hasStarted = true;

        if (string.IsNullOrWhiteSpace(modelUrl))
        {
            Debug.LogError("NetworkFurnitureLoader missing model URL.");
            return;
        }

        await LoadModelAsync();
    }

    private async Task LoadModelAsync()
    {
        var import = new GltfImport(logger: new ConsoleLogger());
        bool loaded;
        try
        {
            loaded = await import.Load(modelUrl);
        }
        catch (Exception e)
        {
            Debug.LogError($"Failed to load GLB from URL: {modelUrl}. {e.Message}");
            return;
        }

        if (!loaded)
        {
            Debug.LogError($"GLB load returned false: {modelUrl}");
            return;
        }

        var modelRoot = new GameObject(string.IsNullOrWhiteSpace(modelName) ? "RuntimeModel" : modelName);
        modelRoot.transform.SetParent(transform, false);

        bool instantiated;
        try
        {
            var instantiator = new GameObjectInstantiator(import, modelRoot.transform);
            instantiated = await import.InstantiateMainSceneAsync(instantiator);
        }
        catch (Exception e)
        {
            Destroy(modelRoot);
            Debug.LogError($"Failed to instantiate GLB scene: {e.Message}");
            return;
        }

        if (!instantiated)
        {
            Destroy(modelRoot);
            Debug.LogError("GLB scene instantiation returned false.");
            return;
        }

        if (tagAsFurniture)
        {
            SetTagRecursively(transform, "furniture");
        }

        RefreshRootBoxCollider(gameObject);
    }

    private static void SetTagRecursively(Transform root, string tagName)
    {
        root.tag = tagName;
        for (int i = 0; i < root.childCount; i++)
        {
            SetTagRecursively(root.GetChild(i), tagName);
        }
    }

    private static void RefreshRootBoxCollider(GameObject root)
    {
        var existing = root.GetComponent<BoxCollider>();
        if (existing != null)
        {
            Destroy(existing);
        }

        Renderer[] renderers = root.GetComponentsInChildren<Renderer>(true);
        BoxCollider box = root.AddComponent<BoxCollider>();
        if (renderers.Length == 0)
        {
            box.center = Vector3.zero;
            box.size = Vector3.one * 0.2f;
            return;
        }

        Bounds worldBounds = renderers[0].bounds;
        for (int i = 1; i < renderers.Length; i++)
        {
            worldBounds.Encapsulate(renderers[i].bounds);
        }

        Vector3 localCenter = root.transform.InverseTransformPoint(worldBounds.center);
        Vector3 lossy = root.transform.lossyScale;
        Vector3 safeLossy = new Vector3(
            Mathf.Max(Mathf.Abs(lossy.x), 0.0001f),
            Mathf.Max(Mathf.Abs(lossy.y), 0.0001f),
            Mathf.Max(Mathf.Abs(lossy.z), 0.0001f)
        );
        Vector3 localSize = new Vector3(
            worldBounds.size.x / safeLossy.x,
            worldBounds.size.y / safeLossy.y,
            worldBounds.size.z / safeLossy.z
        );

        box.center = localCenter;
        box.size = localSize;
    }
}
