using System;
using UnityEngine;

public class dataHandler : MonoBehaviour
{
    // Used for Resources/Photon prefab-based placement.
    public GameObject furniture;
    // Used for runtime GLB network-host placement.
    public bool useRuntimeNetworkModel;
    public string selectedModelUrl;
    public string selectedModelName;
    [SerializeField]private buttonManager buttonManager;
    [SerializeField] private GameObject buttonContainer;

    private static dataHandler instance;

    public static dataHandler Instance {

        get {
            if (instance == null) {
                instance = FindObjectOfType<dataHandler>();
            }
            return instance;
        }
    }

    public void SetPrefabSelection(GameObject prefab)
    {
        // Switching to prefab mode clears runtime model metadata.
        furniture = prefab;
        useRuntimeNetworkModel = false;
        selectedModelUrl = string.Empty;
        selectedModelName = string.Empty;
    }

    public void SetRuntimeModelSelection(string modelUrl, string modelName)
    {
        // Switching to runtime mode clears direct prefab selection.
        furniture = null;
        useRuntimeNetworkModel = !string.IsNullOrWhiteSpace(modelUrl);
        selectedModelUrl = modelUrl;
        selectedModelName = modelName;
    }
}
