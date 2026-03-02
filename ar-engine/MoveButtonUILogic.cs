using UnityEngine;
using UnityEngine.UI;
using TMPro;

public class MoveButtonUILogic : MonoBehaviour
{
    public Button button;
    public inputMannager inputManager;
    public TMP_Text buttonText;

    private bool isMoveMode = true;

    //this initializes the move/place button state and click listener.
    void Start()
    {
        button.onClick.AddListener(OnButtonClick);
        buttonText.text = "Move";
    }

    //this toggles between selecting an object to move and placing it.
    void OnButtonClick()
    {
        // UI mode flag decides whether this click starts move or confirms placement.
        bool temp = inputManager.isMovingObject;

        if (isMoveMode)
        {
            inputManager.OnMoveButtonPressed();
            buttonText.text = "Place";
        }
        else
        {
            inputManager.OnPlaceButtonPressed();
            buttonText.text = "Move";
        }

        isMoveMode = !isMoveMode;
    }
}
