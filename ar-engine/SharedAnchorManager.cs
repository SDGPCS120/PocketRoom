using UnityEngine;
using Photon.Pun;
using UnityEngine.XR.ARFoundation;
using UnityEngine.XR.ARSubsystems;
using System.Collections.Generic;

public class SharedAnchorManager : MonoBehaviourPun
{
    public ARRaycastManager raycastManager;
    public Transform arSessionOrigin;

    static List<ARRaycastHit> hits = new List<ARRaycastHit>();

    public static Transform sharedAnchor;

    void Update()
    {
        if (sharedAnchor != null) return;

        if (Input.touchCount == 1 && Input.GetTouch(0).phase == TouchPhase.Began)
        {
            if (raycastManager.Raycast(Input.GetTouch(0).position, hits, TrackableType.Planes))
            {
                Pose pose = hits[0].pose;
                CreateAndShareAnchor(pose);
            }
        }
    }

    void CreateAndShareAnchor(Pose pose)// creates a local anchor and synchronizes its position and rotation across all connected players
    {
        GameObject anchorObj = new GameObject("SharedAnchor");
        anchorObj.transform.SetParent(arSessionOrigin);
        anchorObj.transform.localPosition = pose.position;
        anchorObj.transform.localRotation = pose.rotation;

        sharedAnchor = anchorObj.transform;

        photonView.RPC(
            "ReceiveAnchor",
            RpcTarget.AllBuffered,
            pose.position,
            pose.rotation
        );
    }

    [PunRPC]//this code will run while using the unity editor
    void ReceiveAnchor(Vector3 position, Quaternion rotation)
    {
        if (sharedAnchor != null) return;

        GameObject anchorObj = new GameObject("SharedAnchor");
        anchorObj.transform.SetParent(arSessionOrigin);
        anchorObj.transform.localPosition = position;
        anchorObj.transform.localRotation = rotation;

        sharedAnchor = anchorObj.transform;
    }
}

