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
        btn.onClick.AddListener(selectObject);
    }

    // Update is called once per frame
    void Update()
    {
        
    }

    void selectObject() {
        dataHandler.Instance.SetPrefabSelection(furniture);
    }
}
