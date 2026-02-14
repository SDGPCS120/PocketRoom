using UnityEngine;

public class dataHandler : MonoBehaviour
{
    public GameObject furniture;
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

    void CreateButton() {
    
    }
}
