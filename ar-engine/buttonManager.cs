using UnityEngine;
using UnityEngine.UI;

public class buttonManager : MonoBehaviour
{
    private Button btn;
    public GameObject furniture;
    // Start is called once before the first execution of Update after the MonoBehaviour is created
    void Start()
    {
        btn = GetComponent<Button>();
        // Connect this UI button to prefab selection in dataHandler.
        btn.onClick.AddListener(selectObject);
    }

    // Update is called once per frame
    void Update()
    {
        
    }

    void selectObject() {
        // Marks this prefab as the active furniture choice.
        dataHandler.Instance.SetPrefabSelection(furniture);
    }
}
