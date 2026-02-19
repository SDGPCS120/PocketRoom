using Photon.Pun;
using Photon.Realtime;
using TMPro;
using UnityEngine;

public class RoomManager : MonoBehaviourPunCallbacks
{
    [Header("UI")]
    public TMP_Text roomCodeText;//Current users own room code
    public TMP_InputField joinInputField;
    public TMP_Text statusText;//Current room user is in code
    public bool isConnected = false;

    private bool pendingCreateRoom = false;
    private bool pendingJoinRoom = false;
    private string pendingRoomCode = "";
    string roomCode;

    //////////////////////////////////////////////////////////////
    /*Photon is Asynchronous ans you cant just join and create
    room whenever you want, these things needs to happen
    in steps that is why methods such as
    
    CreateRoom()/CreateRoomNow()
    JoinRoom()/JoinRoomNow()

    exist
    */
    //////////////////////////////////////////////////////////////

    void Start()
    {
        PhotonNetwork.ConnectUsingSettings();
    }

    public override void OnConnectedToMaster()// a debug code to check if user is connected to master server
    {
        Debug.Log("Connected to Master Server");
        isConnected = true;
        PhotonNetwork.JoinLobby();
    }

    public override void OnJoinedLobby()
    {
        Debug.Log("Joined Lobby");

        // Handle pending room creation
        if (pendingCreateRoom)
        {
            pendingCreateRoom = false;
            CreateRoomNow(pendingRoomCode);
        }

        // Handle pending room join
        else if (pendingJoinRoom)
        {
            pendingJoinRoom = false;
            JoinRoomNow(pendingRoomCode);
        }
    }

   
    public void CreateRoom()// this checks if the user is ready to create a room (!!THIS DOES NOT CREATE THE ROOM!!)
    {
        if (!PhotonNetwork.IsConnectedAndReady)
        {
            statusText.text = "Connecting to server...";
            return;
        }

        roomCode = GenerateRoomCode();
        Debug.Log("Room code: "+ roomCode);

        
        if (PhotonNetwork.InRoom)// If already in a room, leave first
        {
            pendingCreateRoom = true;
            pendingRoomCode = roomCode;
            PhotonNetwork.LeaveRoom();
            statusText.text = "Leaving current room...";
            return;
        }

        
        if (!PhotonNetwork.InLobby)// If not in lobby, wait for it
        {
            pendingCreateRoom = true;
            pendingRoomCode = roomCode;
            statusText.text = "Preparing...";
            return;
        }

        CreateRoomNow(roomCode);
    }

    private void CreateRoomNow(string roomCode)// once the user is ready to create a room, it will create a room
    {
        RoomOptions options = new RoomOptions
        {
            MaxPlayers = 5,
            IsVisible = false,
            EmptyRoomTtl = 0,
            PlayerTtl = 0
        };

        PhotonNetwork.CreateRoom(roomCode, options);
        roomCodeText.text = "Room Code: " + roomCode;
        statusText.text = "Creating room...";
    }

    public void JoinRoom()// this checks in the user is ready to join a room (!!THIS DOES NOT JOIN THE USER TO A ROOM!!)
    {
        string code = joinInputField.text.Trim();

        if (string.IsNullOrEmpty(code))// checks if enterd room code is empty
        {
            statusText.text = "Please enter a room code";
            return;
        }

        if (!PhotonNetwork.IsConnectedAndReady)
        {
            statusText.text = "Connecting to server...";
            return;
        }

        
        if (PhotonNetwork.InRoom)// checks if already in a room, if so leave first
        {
            pendingJoinRoom = true;
            pendingRoomCode = code;
            PhotonNetwork.LeaveRoom();
            statusText.text = "Leaving current room...";
            return;
        }

        JoinRoomNow(code);
    }

    private void JoinRoomNow(string code)// once the user is ready to join a room, it will join the user
    {
        bool joinRequestSent = PhotonNetwork.JoinRoom(code);
        if (!joinRequestSent)
        {
            statusText.text = "Failed to send join request";
        }
        else
        {
            statusText.text = "Joining room...";
        }
    }

    public void LeaveRoom()// for leaving a room
    {
        if (PhotonNetwork.InRoom)
        {
            PhotonNetwork.LeaveRoom();
            statusText.text = "Leaving room...";
        }
    }

    public override void OnJoinedRoom()// for debugging
    {
        statusText.text = "Connected to room "+roomCode;
        roomCodeText.text = "Room Code: " + PhotonNetwork.CurrentRoom.Name;
        Debug.Log("Joined room: " + PhotonNetwork.CurrentRoom.Name);
    }

    public override void OnLeftRoom()
    {
        Debug.Log("Left room - rejoining lobby");
        statusText.text = "Left room";
        roomCodeText.text = "Room Code: ----";

        if (PhotonNetwork.IsConnectedAndReady && !PhotonNetwork.InLobby) // rejoins the user to the lobby after leaving room
        {
            PhotonNetwork.JoinLobby();
        }
    }

    public override void OnJoinRoomFailed(short returnCode, string message)// for debugging
    {
        pendingJoinRoom = false;
        statusText.text = "Room not found";
        Debug.LogWarning("JoinRoom failed: " + message);
    }

    public override void OnCreateRoomFailed(short returnCode, string message)// for debugging
    {
        pendingCreateRoom = false;
        statusText.text = "Failed to create room";
        Debug.LogError("CreateRoom failed: " + message);
    }

    string GenerateRoomCode()// this generates the room code
    {
        int roomCode = Random.Range(0, 10000);
        string roomName = roomCode.ToString("D4");//this formats to 4 digits like 0001
        return roomName;

    }

    void OnApplicationQuit()
    {
        if (PhotonNetwork.InRoom)
        {
            PhotonNetwork.LeaveRoom();
        }
    }
}