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

    private List<ARRaycastHit> hits = new List<ARRaycastHit>();
    private Pose pose;

    void Update()
    {
        CrossHairCalculation();

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
        if (IsCrosshairOverObject())
        {
            Debug.Log("Blocked: Crosshair is over an existing object.");
            return;
        }

        if (dataHandler.Instance.furniture == null)
        {
            Debug.LogWarning("Furniture prefab is not assigned.");
            return;
        }

        PhotonNetwork.Instantiate(
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

    bool IsCrosshairOverObject()// checking if the crosshair is in the furniture layer so objects wont spawn
    {
        float checkRadius = 0.1f; // search radius around the pointer, adjust if needed

        Collider[] hits = Physics.OverlapSphere(
            pose.position,
            checkRadius
        );

        foreach (Collider col in hits)
        {
            if (col.CompareTag("furniture"))
            {
                return true;
            }
        }

        return false;
    }

}

