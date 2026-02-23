using Photon.Pun;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.EventSystems;
using UnityEngine.XR.ARFoundation;
using UnityEngine.XR.ARSubsystems;

public class inputMannager : MonoBehaviour
{
    [SerializeField] private Camera arCam;
    [SerializeField] private ARRaycastManager raycastManager;
    [SerializeField] private GameObject crossHair;
    [SerializeField] private float rotationStep = 15f; //rotation degrees per click

    public bool isMovingObject = false;
    public bool isOverObject = false;

    private GameObject obj;
    private GameObject selectedObject;
    private List<ARRaycastHit> hits = new List<ARRaycastHit>();
    private Pose pose;

    void Update()
    {
        CrossHairCalculation();

        if (isMovingObject && selectedObject != null)
        {
            MoveSelectedObject();
        }
        //Debug.Log("isMovingObject: " + isMovingObject);


#if UNITY_EDITOR //if in unity editor in pc use mouse input
        HandleMouseInput();
#else //else use touch inputs for mobile
        HandleTouchInput();
#endif
    }

    // -------------------- SPAWN IN MOBILE -------------------- spawning logic for mobile
    void HandleTouchInput()
    {
        if (Input.touchCount == 0) return;

        Touch touch = Input.GetTouch(0);

        if (touch.phase != TouchPhase.Began) return;
        if (IsPointerOverUI(touch.position)) return;

        SpawnObject();
    }

    // -------------------- SPAWN IN EDITOR -------------------- spawning logic for PC
    void HandleMouseInput()
    {
        if (!Input.GetMouseButtonDown(0)) return;
        if (IsPointerOverUI(Input.mousePosition)) return;

        SpawnObject();
    }

    void SpawnObject() // object spawning logic
    {
        if (GetObjectUnderCrosshair() != null)
        {
            Debug.Log("Blocked: Crosshair is over an existing object.");
            return;
        }

        if (isMovingObject)
        {
            Debug.Log("Cannot spawn while moving object");
            return;
        }

        if (dataHandler.Instance.furniture == null)
        {
            Debug.LogWarning("Furniture prefab is not assigned.");
            return;
        }

        PhotonNetwork.Instantiate(//actual spawning happens here
            dataHandler.Instance.furniture.name,
            pose.position,
            pose.rotation
        );
    }

    bool IsPointerOverUI(Vector2 position) //checks if the user is touching/clicking on a UI element instead of the AR world
    {
        PointerEventData eventData = new PointerEventData(EventSystem.current);
        eventData.position = position;

        List<RaycastResult> results = new List<RaycastResult>();
        EventSystem.current.RaycastAll(eventData, results);

        return results.Count > 0;
    }

    void CrossHairCalculation() //calculates where the center of the screen hits a real world AR plane and moves your crosshair there.
    {
        Vector3 centerScreen = new Vector3(Screen.width / 2f, Screen.height / 2f);
        Ray ray = arCam.ScreenPointToRay(centerScreen);

        if (raycastManager.Raycast(ray, hits, TrackableType.PlaneWithinPolygon))
        {
            foreach (var hit in hits)
            {
                ARPlane plane = hit.trackable as ARPlane;

                if (plane.alignment == PlaneAlignment.HorizontalUp)
                {
                    pose = hit.pose;
                    crossHair.transform.position = pose.position;
                    crossHair.transform.rotation = Quaternion.Euler(90, 0, 0);
                    break;
                }
            }
        }
    }

    GameObject GetObjectUnderCrosshair()
    {
        float checkRadius = 0.1f;

        Collider[] hits = Physics.OverlapSphere(
            pose.position,
            checkRadius
        );

        foreach (Collider col in hits)
        {
            if (col.CompareTag("furniture"))
            {
                PhotonView pv = col.GetComponentInParent<PhotonView>();

                if (pv != null)
                {
                    return pv.gameObject; //this returns the parent networked object
                }
            }
        }

        return null;
    }

    public void OnMoveButtonPressed()
    {
        Debug.Log("Move button pressed");

        if (isMovingObject) return;

        obj = GetObjectUnderCrosshair();

        if (obj != null)
        {
            selectedObject = obj;

            PhotonView pv = selectedObject.GetComponent<PhotonView>();

            if (pv != null)
            {
                pv.RequestOwnership();
            }

            isMovingObject = true;
        }
        else
        {
            Debug.Log("No furniture under crosshair");
        }
    }

    public void OnPlaceButtonPressed()
    {
        if (!isMovingObject) return;

        isMovingObject = false;
        selectedObject = null;

        Debug.Log("Object placed");
    }

    void MoveSelectedObject()
    {
        if (selectedObject == null) return;

        PhotonView pv = selectedObject.GetComponent<PhotonView>();
        if (pv == null) return;

        if (!pv.IsMine)
            pv.RequestOwnership();

        if (pv.IsMine)
        {
            selectedObject.transform.position = pose.position;
        }
    }

    public void RotateLeft()//public becaues private wont show up in OnClick() event in the inspector
    {
        if (selectedObject == null) return;

        PhotonView pv = selectedObject.GetComponent<PhotonView>();
        if (pv == null) return;

        if (!pv.IsMine)
            pv.RequestOwnership();

        if (pv.IsMine)
        {
            selectedObject.transform.Rotate(0f, -rotationStep, 0f);
        }
    }

    public void RotateRight()//public becaues private wont show up in OnClick() event in the inspector
    {
        if (selectedObject == null) return;

        PhotonView pv = selectedObject.GetComponent<PhotonView>();
        if (pv == null) return;

        if (!pv.IsMine)
            pv.RequestOwnership();

        if (pv.IsMine)
        {
            selectedObject.transform.Rotate(0f, rotationStep, 0f);
        }
    }

}

