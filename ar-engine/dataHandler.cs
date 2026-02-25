using System;
using UnityEngine;

public class dataHandler : MonoBehaviour
{
    public GameObject furniture;
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
        furniture = prefab;
        useRuntimeNetworkModel = false;
        selectedModelUrl = string.Empty;
        selectedModelName = string.Empty;
    }

    public void SetRuntimeModelSelection(string modelUrl, string modelName)
    {
        furniture = null;
        useRuntimeNetworkModel = !string.IsNullOrWhiteSpace(modelUrl);
        selectedModelUrl = modelUrl;
        selectedModelName = modelName;
    }
}
