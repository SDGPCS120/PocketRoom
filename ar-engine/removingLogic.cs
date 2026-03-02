using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.XR.ARFoundation;
using UnityEngine.XR.ARSubsystems;

public class removingLogic : MonoBehaviour
{
    //a simple script to remove all objects in a scene

    public ARPlaneManager PlaneManager;
    //this finds all furniture objects and removes them from the scene.
    public void removeAllObjects() {
        GameObject[] allObjs = GameObject.FindGameObjectsWithTag("furniture");

        foreach (GameObject obj in allObjs) {
            Destroy(obj);
            Debug.Log("Object removed");
        }
    }
}
