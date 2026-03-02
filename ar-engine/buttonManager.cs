using UnityEngine;
using UnityEngine.UI;

public class buttonManager : MonoBehaviour
{
    private Button btn;
    public GameObject furniture;
    // Start is called once before the first execution of Update after the MonoBehaviour is created
    //this wires the button click to prefab selection.
    void Start()
    {
        btn = GetComponent<Button>();
        // Connect this UI button to prefab selection in dataHandler.
        btn.onClick.AddListener(selectObject);
    }

    // Update is called once per frame
    //this frame update is currently unused.
    void Update()
    {
        
    }

    //this sets the clicked prefab as the active furniture choice.
    void selectObject() {
        // Marks this prefab as the active furniture choice.
        dataHandler.Instance.SetPrefabSelection(furniture);
    }
}
