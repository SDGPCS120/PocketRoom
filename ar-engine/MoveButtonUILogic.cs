using UnityEngine;
using UnityEngine.UI;
using TMPro;

public class MoveButtonUILogic : MonoBehaviour
{
    public Button button;
    public inputMannager inputManager;
    public TMP_Text buttonText;

    private bool isMoveMode = true;

    void Start()
    {
        button.onClick.AddListener(OnButtonClick);
        buttonText.text = "Move";
    }

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
