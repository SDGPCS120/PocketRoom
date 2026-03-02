using UnityEngine;

public class menueLogic : MonoBehaviour
{
    // a simple script made for opening and closng menus

    public GameObject menu;
    
    //this hides the assigned menu object when the scene starts.
    void Start()
    {
        if (menu != null)
        {
            menu.SetActive(false);
        }
    }

    //this toggles either the main menu or CartMenu depending on setup.
    public void openMenu() {
        Canvas canvas = GetComponentInParent<Canvas>(true);

        //this is specificly for closing the cart menu when an object is selected
        if(menu==null){
            Transform cartMenu = canvas.transform.Find("CartMenu");
            bool isActive = cartMenu.gameObject.activeSelf;
            cartMenu.gameObject.SetActive(!isActive);

        //this is for opening and closing the main menu when the menu button is pressed
        }else{
            bool isActive = menu.activeSelf;
            menu.SetActive(!isActive);
        }
    }
}
