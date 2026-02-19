using UnityEngine;

public class menueLogic : MonoBehaviour
{
    // a simple script made for opening and closng menus

    public GameObject menu;
    
    void Start()
    {
        menu.SetActive(false);
    }

    public void openMenu() {
        bool isActive = menu.activeSelf;
        menu.SetActive(!isActive);
    }
}
