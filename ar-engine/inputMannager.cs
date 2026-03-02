using System;
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
    [SerializeField] private float spawnYOffset = 0.290f;//this is so that the object spawns slightly above the plane, preventing clipping issues
    [SerializeField] private string networkFurnitureHostPrefabName = "NetworkFurnitureHost";

    public bool isMovingObject = false;
    public bool isOverObject = false;

    private GameObject obj;
    private GameObject selectedObject;
    private List<ARRaycastHit> hits = new List<ARRaycastHit>();
    private Pose pose;

    //this updates crosshair tracking and handles current input mode each frame.
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

        bool useRuntimeNetworkModel = dataHandler.Instance.useRuntimeNetworkModel &&
                                      !string.IsNullOrWhiteSpace(dataHandler.Instance.selectedModelUrl);

        if (!useRuntimeNetworkModel && dataHandler.Instance.furniture == null)
        {
            Debug.LogWarning("Furniture prefab is not assigned.");
            return;
        }

        Vector3 spawnPosition = pose.position + new Vector3(0f, spawnYOffset, 0f);

        if (useRuntimeNetworkModel)
        {
            // Runtime GLB flow: spawn a Photon host and let each client load the same URL locally.
            SpawnRuntimeNetworkModel(spawnPosition, pose.rotation);
            return;
        }

        GameObject selectedFurniture = dataHandler.Instance.furniture;

        GameObject spawned = PhotonNetwork.Instantiate(//actual spawning happens here
            selectedFurniture.name,
            spawnPosition,
            pose.rotation
        );
        EnsureBoxColliders(spawned);
    }

    //this spawns the network host object and passes model metadata to all clients.
    void SpawnRuntimeNetworkModel(Vector3 spawnPosition, Quaternion spawnRotation)
    {
        string modelUrl = dataHandler.Instance.selectedModelUrl;
        string modelName = dataHandler.Instance.selectedModelName;

        if (PhotonNetwork.InRoom)
        {
            // Model URL/name are sent once through Photon instantiation data.
            GameObject spawned = PhotonNetwork.Instantiate(
                networkFurnitureHostPrefabName,
                spawnPosition,
                spawnRotation,
                0,
                new object[] { modelUrl, modelName }
            );
            EnsureBoxColliders(spawned);
            return;
        }

        GameObject hostPrefab = Resources.Load<GameObject>(networkFurnitureHostPrefabName);
        if (hostPrefab == null)
        {
            Debug.LogError($"Missing Resources prefab: {networkFurnitureHostPrefabName}");
            return;
        }

        GameObject localHost = Instantiate(hostPrefab, spawnPosition, spawnRotation);
        NetworkFurnitureLoader loader = localHost.GetComponent<NetworkFurnitureLoader>();
        if (loader != null)
        {
            // Local fallback path when testing without an active Photon room.
            loader.InitializeFromSelection(modelUrl, modelName);
        }
        EnsureBoxColliders(localHost);
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
        // Primary: raycast from screen center to detect furniture directly under crosshair.
        Vector3 centerScreen = new Vector3(Screen.width / 2f, Screen.height / 2f);
        Ray centerRay = arCam.ScreenPointToRay(centerScreen);
        if (Physics.Raycast(centerRay, out RaycastHit rayHit, 20f))
        {
            Collider col = rayHit.collider;
            if (IsFurnitureCollider(col))
            {
                PhotonView pv = col.GetComponentInParent<PhotonView>();
                if (pv != null)
                {
                    return pv.gameObject;
                }
            }
        }

        // Fallback: overlap around spawn pose (accounts for y offset above plane).
        float checkRadius = 0.35f;
        Vector3 checkCenter = pose.position + new Vector3(0f, spawnYOffset, 0f);
        Collider[] hits = Physics.OverlapSphere(checkCenter, checkRadius);

        foreach (Collider col in hits)
        {
            if (!IsFurnitureCollider(col)) continue;

            PhotonView pv = col.GetComponentInParent<PhotonView>();
            if (pv != null)
            {
                return pv.gameObject;
            }
        }

        return null;
    }

    //this selects furniture under the crosshair and starts move mode.
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
                bool isLocalOnlyView = pv.ViewID == 0;
                // ViewID 0 means local-only object, so ownership requests are not applicable.
                if (!isLocalOnlyView)
                {
                    pv.RequestOwnership();
                }
            }

            isMovingObject = true;
        }
        else
        {
            Debug.Log("No furniture under crosshair");
        }
    }

    //this ends move mode and drops the currently selected object in place.
    public void OnPlaceButtonPressed()
    {
        if (!isMovingObject) return;

        isMovingObject = false;
        selectedObject = null;

        Debug.Log("Object placed");
    }

    //this moves the selected object to the current crosshair pose while in move mode.
    void MoveSelectedObject()
    {
        if (selectedObject == null) return;

        PhotonView pv = selectedObject.GetComponent<PhotonView>();
        if (pv == null) return;

        bool isLocalOnlyView = pv.ViewID == 0;

        if (!pv.IsMine && !isLocalOnlyView)
            pv.RequestOwnership();

        if (pv.IsMine || isLocalOnlyView)
        {
            selectedObject.transform.position = pose.position + new Vector3(0f, spawnYOffset, 0f);
        }
    }

    public void RotateLeft()//public becaues private wont show up in OnClick() event in the inspector
    {
        if (selectedObject == null) return;

        PhotonView pv = selectedObject.GetComponent<PhotonView>();
        if (pv == null) return;

        bool isLocalOnlyView = pv.ViewID == 0;

        if (!pv.IsMine && !isLocalOnlyView)
            pv.RequestOwnership();

        if (pv.IsMine || isLocalOnlyView)
        {
            selectedObject.transform.Rotate(0f, -rotationStep, 0f);
        }
    }

    public void RotateRight()//public becaues private wont show up in OnClick() event in the inspector
    {
        if (selectedObject == null) return;

        PhotonView pv = selectedObject.GetComponent<PhotonView>();
        if (pv == null) return;

        bool isLocalOnlyView = pv.ViewID == 0;

        if (!pv.IsMine && !isLocalOnlyView)
            pv.RequestOwnership();

        if (pv.IsMine || isLocalOnlyView)
        {
            selectedObject.transform.Rotate(0f, rotationStep, 0f);
        }
    }

    //this ensures the network root has a box collider for hit detection and selection.
    void EnsureBoxColliders(GameObject root)
    {
        if (root == null) return;

        PhotonView pv = root.GetComponentInParent<PhotonView>();
        GameObject target = pv != null ? pv.gameObject : root;

        if (target.GetComponent<Collider>() != null) return;

        Renderer[] renderers = target.GetComponentsInChildren<Renderer>(true);
        BoxCollider box = target.AddComponent<BoxCollider>();

        if (renderers.Length == 0)
        {
            box.center = Vector3.zero;
            box.size = Vector3.one * 0.2f;
            return;
        }

        Bounds worldBounds = renderers[0].bounds;
        for (int i = 1; i < renderers.Length; i++)
        {
            worldBounds.Encapsulate(renderers[i].bounds);
        }

        Vector3 localCenter = target.transform.InverseTransformPoint(worldBounds.center);
        Vector3 lossy = target.transform.lossyScale;
        Vector3 safeLossy = new Vector3(
            Mathf.Max(Mathf.Abs(lossy.x), 0.0001f),
            Mathf.Max(Mathf.Abs(lossy.y), 0.0001f),
            Mathf.Max(Mathf.Abs(lossy.z), 0.0001f)
        );
        Vector3 localSize = new Vector3(
            worldBounds.size.x / safeLossy.x,
            worldBounds.size.y / safeLossy.y,
            worldBounds.size.z / safeLossy.z
        );

        box.center = localCenter;
        box.size = localSize;
    }

    //this checks if a collider belongs to a furniture object in the hierarchy.
    bool IsFurnitureCollider(Collider col)
    {
        if (col == null) return false;
        if (col.CompareTag("furniture")) return true;

        Transform taggedParent = col.transform.root;
        if (taggedParent != null && taggedParent.CompareTag("furniture")) return true;

        Transform parent = col.GetComponentInParent<Transform>();
        return parent != null && parent.CompareTag("furniture");
    }

}




