# Azure Communication Calling iOS API Samples

<!-- Note: We may want to add a section for terminology explanation. Eg. what's CallClient vs CallAgent etc. -->

## Overview
- ### [Start with CallClient and CallAgent](#start-with-callclient-and-callagent)
- ### [Call Basics](#call-basics)
- ### [Video Basics](#video-basics)
- ### [Device Management](#device-management)
- ### [Push Notification](#push-notification)
- ### [Remote Participant Management](#remote-participant-management)

## Start with CallClient and CallAgent
<!--Start Start with CallClient and CallAgent-->
### Initialization
Create a CallClient instance and call createCallAgent api to get CallAgent instance. Make sure you have imported "AzureCommunication.framework" and "AzureCore.framework"

* Create CommunicationTokenCredential object so that SDK can fetch token
```swift
    import AzureCommunication

    let tokenString = "token_string";
    var userCredential: CommunicationTokenCredential?
    do {
        userCredential = try CommunicationTokenCredential(with: CommunicationTokenRefreshOptions(initialToken: token, 
                                                                    refreshProactively: true,
                                                                    tokenRefresher: self.fetchTokenSync))
    } catch {
        print("Failed to create CommunicationTokenCredential object")
    }

    self.tokenProvider = ContosoTokenProvider()
    /*self.tokenProvider is Contoso's internal implementation that fetches token from Contoso server*/
    public func fetchTokenSync(then onCompletion: TokenRefreshOnCompletion) {
        let newToken = self.tokenProvider.getToken()
        onCompletion(newToken, nil)
    }
```

* Pass CommunicationUserCredential object created above to CallClient
```swift
public class CallingApp : NSObject, CallAgentDelegate, IncomingCallDelegate
{
    var callClient: CallClient?
    var callAgent: CallAgent?
    var callObserver: CallObserver?
    var deviceManager: DeviceManager?

    func init()
    {
        self.callClient = CallClient()
        let options = CallAgentOptions()!
        options.displayName = displayName
        self.callClient!.createCallAgent(
            userCredential: userCredential!, 
            options: options) { (callAgent, error) in
                if error != nil {
                    print("Create agent succeeded")
                    self.callAgent = callAgent
                    self.callClient!.getDeviceManager { (deviceManager, error) in
                            if (error == nil) {
                                print("Got device manager instance")
                                self.deviceManager = deviceManager
                            } else {
                                print("Failed to get device manager instance")
                            }
                } else {
                    print("Create agent failed")
                }
            })
        self.callObserver = CallObserver()
    }

    // Event raised to get notified when call collection on CallAgent is added/removed
    public func onCallsUpdated(_ callAgent: CallAgent!, args: CallsUpdatedEventArgs!) {
        // Add application logic when call is added
        args.addedCalls?.forEach { call in }

        // Add application logic when call is removed
        args.removedCalls?.forEach { call in }
    }

    // Event raised when there is an incoming call
    public func onIncomingCall(_ callAgent: CallAgent!, incomingcall: IncomingCall!) {
        self.incomingCall = incomingcall
        // Subscribe to get OnCallEnded event
        self.incomingCall?.delegate = self
    }

    // Event raised when incoming call was not answered
    public func onCallEnded(_ incomingCall: IncomingCall!, args: PropertyChangedEventArgs!) {
        self.incomingCall = nil
    }
}
```
<!--End Start with CallClient and CallAgent-->

## Call Basics
<!--Start Call Basics-->
### Call Properties
Call object has various properties
```swift
// [String] caller identity
self.call?.id

// CallStateNone = 0,CallStateEarlyMedia = 1,CallStateIncoming = 2,CallStateConnecting = 3,CallStateRinging = 4,CallStateConnected = 5,CallStateHold = 6,CallStateDisconnecting = 7,CallStateDisconnected = 8
self.call?.state

// CallDirectionOutgoing = 1, CallDirectionIncoming = 2
self.call?.callDirection

// [Bool] isMicrophoneMuted - is local audio muted
self.call?.isMicrophoneMuted

// [Errror] callEndReason - containing code/subcode/message indicating how call ended
self.call?.callEndReason

// String[] localVideoStreams - collection of video streams send to other participants in a call
self.call?.localVideoStreams

// RemoteParticipant[] remoteParticipants - collection of remote participants participating in this call
self.call?.remoteParticipants

// Indicates if the call is currently being recorded or not
self.call?.isRecordingActive;
```

### Call Operations
* ### Make Outgoing Call

To create and start a call you need to call one of the APIs on CallAgent
```swift
public class CallManager : NSObject, CallDelegate
{
    public func placeCall(names: [CommunicationIdentifier])
    {
        let callOptions = StartCallOptions()!
        // Using the CallAgent received from the factory method
        // and returns a Call object
        let audioOptions = AudioOptions()
        audioOptions!.muted = true // Start the call in mute state
        callOptions.audioOptions = audioOptions
        let call = self.callAgent?.startCall(participants: names,
                                            options: callOptions)
        call?.delegate = self.callObserver
    }

    public func placeVideoCall(names: [CommunicationIdentifier])
    {
        let camera = self.deviceManager!.cameras!.first
        let localVideoStream = LocalVideoStream(camera: camera)
        let videoOptions = VideoOptions(localVideoStream: localVideoStream)
        
        let callOptions = StartCallOptions()
        callOptions?.videoOptions = videoOptions

        let call = self.callAgent?.startCall(participants: names,
                                                options: callOptions)
        call!.delegate = self.callObserver
    }

    // Following is one event which is part of CallDelegate
    public func OnStateChanged(_ call: Call!,
                                args: PropertyChangedEventArgs!)
    {
        let state = CallObserver.callStateToString(state: call.state)
        print("Call state changed to %@", state)
    }
}

```

* ### Accept Incoming Call

To accept a call you need to call one of the APIs on CallAgent
```swift
public class CallManager : NSObject
{
    public func acceptCall()
    {
        let acceptCallOptions = AcceptCallOptions()!
        let camera = self.deviceManager?.cameras!.first
        let localVideoStream = LocalVideoStream(camera: camera)
        let videoOptions = VideoOptions(localVideoStream: localVideoStream)
        acceptCallOptions.videoOptions = videoOptions
        self.incomingCall?.accept(options: acceptCallOptions) { (call, error) in
            if(error == nil) {
                self.call = call
                self.callObserver = CallObserver(view:self)
                self.call!.delegate = self.callObserver
            } else {
                print("[IncomingCall] Accepting call failed")
            }
        }
    }

    public func rejectCall()
    {
        self.incomingCall?.reject { (error) in
            if (error == nil) {
                print("Incoming call reject was successfull")
            } else {
                print("Incoming call reject failed")
            }
        }
    }
}
```

* ### Join Call

To join a call you need to call one of the APIs on CallClient
```swift
public class CallManager : NSObject
{
    public func joinCall(threadId: String)
    {
        let options = JoinCallOptions()!
        self.localVideoStream = LocalVideoStream(camera: self.deviceManager!.cameras!.first)
        options.videoOptions = VideoOptions(localVideoStream: self.localVideoStream!)!
        let audioOptions = AudioOptions()!
        audioOptions.muted = true // Join group call muted
        options.audioOptions = audioOptions
        if (threadId.starts(with: "http")) {
            // Join a meeting with link
            let teamsMeetingLinkLocator = TeamsMeetingLinkLocator(meetingLink: threadId)!;
            self.call = self.callAgent?.join(with: teamsMeetingLinkLocator, joinCallOptions: options)
        } else {
            let groupCallLocator = GroupCallLocator(groupId: UUID(uuidString: threadId))!
            self.call = self.callAgent?.join(with: groupCallLocator, joinCallOptions: options)
        }
        // Get updates on the call
        self.call.delegate = self.callObserver
    }
}
```

* ### Mute/Unmute

[Asynchronous] Local mute

```swift
self.call?.mute { (error) in
    if error == nil {
        print("Successfully muted")
    } else {
        print("Failed to mute")
    }
})

```
[Asynchronous] Local unmute

```swift
self.call?.unmute { (error) in
    if error == nil {
        print("Successfully unmuted")
    } else {
        print("Failed to unmute")
    }
})
```

* ### HangUp Call
To hangUp the call:
```swift
var hangUpOptions = HangUpOptions()!
hangUpOptions.forEveryOne = true
self.call.hangUp(hangUpOptions) { (error) in
    if (error == nil) {
        print("HangUp successfull")
    } else {
        print("HangUp failed, try again")
    }
}
print(CallObserver.callStateToString(state:call.state)) // => Disconnecting -> Disconnected
```

### Call Event Handling

#### Event model
Most of properties and collections can change it's value.
To subscribe to these changes you can use following:
* ##### Properties
Application should implement the delegate to get notfied for change in properties
```swift
    self.call.delegate = CallObserver()
    // Get the property of the call state by doing get on the call's state member
    public func OnStateChanged(_ call: Call!,
                                args: PropertyChangedEventArgs!)
    {
        print("Callback from SDK when the call state changes, current state: " + CallObserver.callStateToString(state:call.state))
    }
```

* ##### Collections
To subscribe to collection updated event also delegate needs to be implemented
to get notfified when there is a change in collection
```swift
    self.call.delegate = self
    // Collection contains the streams that were added or removed only
    public func onLocalVideoStreamsChanged(_ call: Call!,
                                           args: LocalVideoStreamsUpdatedEventArgs!)
    {
        print(args.addedStreams.count);
        print(args.removedStreams.count);
    }
```

To unsubscribe:
```swift
self.call?.delegate = nil // Will not recieve anymore call updates
self.callClient?.delegate = nil // Will not get incoming call notification
self.incomingCall?.delegate = nil // Will not get when incoming call end notification
```

#### Examples
Call event handler for call object created when incoming call is answered or when placing an outgoing call succeeds

```swift
public class CallObserver : NSObject, CallDelegate
{
    public static func callStateToString(state: CallState) -> String {
        switch state {
            case .connected: return "Connected"
            case .connecting: return "Connecting"
            case .disconnected: return "Disconnected"
            case .disconnecting: return "Disconnecting"
            case .earlyMedia: return "EarlyMedia"
            case .localHold: return "LocalHold"
            case .remoteHold: return "RemoteHold"
            case .none: return "None"
            case .ringing: return "Ringing"
            case .inLobby: return "InLobby"
            default: return "Unknown"
        }
    }

    public func OnStateChanged(_ call: Call!,
                                args: PropertyChangedEventArgs!)
    {
        print("Call state changed to: " + callStateToString(state:call.state));
    }

    public func onRemoteParticipantsUpdated(_ call: Call!,
                                                args: ParticipantsUpdatedEventArgs!)
    {
        print(args.addedParticipants.count);
        print(args.removedParticipants.count);
    }

    public func onVideoStreamsUpdated(_ remoteParticipant: RemoteParticipant!,
                                        args: RemoteVideoStreamsEventArgs!)
    {
        print(args.addedStreams.count);
        print(args.removedStreams.count);
    }

    public func onIsRecordingActiveChanged(_ call: Call!, args: PropertyChangedEventArgs!) {
        print("Call recording state changed to " + call.isRecordingActive)
    }

    public func onLocalVideoStreamsChanged(_ call: Call!, args: LocalVideoStreamsUpdatedEventArgs!) {
        print("Added streams count: " + args.addedStreams)
        print("Removed streams count: " + args.addedStreams)
    }

    public func onIdChanged:(_ call: Call!, args: PropertyChangedEventArgs!) {
        print("Call id has changed: oldValue: \(self.call.id), newValue: \(call.id)")
    }
}
```

* list existing ongoing calls that local user is part of
```swift
for call in self.callClient.calls { print(call); } // [Call, Call, Call...]
```
* subscribe to added/removed call
```swift
self.callObserver = CallObserver()

public func onCallsUpdated(_ callAgent: CallAgent!,
                           args: CallsUpdatedEventArgs!)
{
    for addedCall in args.addedCalls { print(addedCall); }
    for removedCall in args.removedCalls { print(removedCall); }
}

```

### Call Options
* Different call options, you can pass additional options when call is created and started to control 
which audio/video streams that will be used to start a call. (Devices have to obtained by enumerating devices using deviceManager)
```swift
var startCallOptions = StartCallOptions()
var joinCallOptions = JoinCallOptions()
var acceptCallOptions = AcceptCallOptions()

var videoOptions = VideoOptions()
var audioOptions = AudioOptions()

// start with selected camera
videoOptions.camera = deviceManager?.cameras?.first
// start call muted
audioOptions.muted = true
```

* State transition when call starts
```swift
// => None -> Connecting -> Ringing -> Connected
print(CallObserver.callStateToString(state:self.call?.state))
// every remote participant state will transition idependently: Idle -> Connecting -> Connected
for remoteParticipant in self.call?.remoteParticipants { print(CallObserver.callStateToString(state: remoteParticipant.state)) }

```
<!--End Call Basics-->

## Video Basics
<!--Start Video Basics-->
### Start / Stop Video
* [Asynchronous] Start/stop video using the call object
```swift
let firstCamera: VideoDeviceInfo? = self.deviceManager?.cameras?.first
let localVideoStream = LocalVideoStream(camera: firstCamera)
let videoOptions = VideoOptions(localVideoStream: localVideoStream)

self.call?.startVideo(stream: localVideoStream) { (error) in
    if (error == nil) {
        print("Local video started successfully")
    } else {
        print("Local video failed to start")
    }
}

self.call?.stopVideo(stream: localVideoStream!) { (error) in
    if (error == nil) {
        print("Local video stopped successfully")
    } else {
        print("Local video failed to stop")
    }
}
```

### Local Video Preview
You can use Renderer to start render stream from your local camera, this stream won't be send to other participants, it's local preview feed
* [Synchronous] Start local video preview
```swift
let firstCamera: VideoDeviceInfo? = self.deviceManager?.cameras?.first
let localVideoStream = LocalVideoStream(camera: firstCamera)
let previewRenderer = try! Renderer(localVideoStream: localVideoStream)
let previewView = try! previewRenderer!.createView(with: RenderingOptions(scalingMode:scalingMode))

rendererObserver = RendererObserver(view: self)
previewView!.delegate = rendererObserver
```

```swift
public class RendererObserver: NSObject, RendererDelegate {
    let view: View
    init(view: View) {
        self.view = view
    }

    public func onFirstFrameRendered() {
        print("Size of frame is " + view.renderer!.size)
    }

    public func rendererFailedToStart() {
        print("Rederer failed to start")
    }
}
```

Renderer has set of properties and methods that allows you to control it:
```swift
// Constructor can take in LocalVideoStream or RemoteVideoStream
let localRenderer = Renderer(localVideoStream:localVideoStream)
let remoteRenderer = Renderer(remoteVideoStream:remoteVideoStream)

// [StreamSize] size of the rendering view
renderer?.size

// [RendererDelegate] an object you provide to receive events from this Renderer instance
renderer?.delegate

// [Synchronous] create view with rendering options
renderer?.createView(with: RenderingOptions(scalingMode:ScalingMode.crop));
// [Synchronous] dispose rendering view
renderer?.dispose();
```

### Switch Video Source
* [Asynchronous] Switch local video, pass localVideoStream you got from call.startVideo() API call
```swift
// get camera
var firstCamera = self.deviceManager?.cameras?.first

localVideoStream?.switchSource(camera: firstCamera) { (error) in
    if (error == nil) {
        print("Successfully switched to new source")
    } else {
        print("Failed to switch to new source")
    }
})
```
<!--End Video Basics-->

## Device Management
<!--Start Device Management-->
### Microphone / Speaker
Device mananager allows you to set device that will be used when starting a call
If not  will fallback to OS defaults

#### Get / Set Devices
```swift
// get microphone
var firstMicrophone = self.deviceManager?.microphones?.first

// get speaker
var firstSpeaker = self.deviceManager?.speakers?.first

// [Synchronous] set microphone
self.deviceManager?.setMicrophone(microphoneDevice: firstMicrophone)

// [Synchronous] set speaker
self.deviceManager?.setSpeaker(speakerDevice: firstSpeaker)
```

AudioDeviceInfo has a set of properties:
```swift
var audioDeviceInfo = self.deviceManager?.microphones?.first

// [NSString] name of the audio device
audioDeviceInfo?.name

// [NSString] id of the audio device
audioDeviceInfo?.id

// [BOOL] true if device is a system default
audioDeviceInfo?.isSystemDefault

// [AudioDeviceType] type of the audio device
audioDeviceInfo?.deviceType
```

#### Enumerate Local Devices
Enumeration is synchronous
```swift
// enumerate local cameras
var localCameras = self.deviceManager?.cameras // [VideoDeviceInfo, VideoDeviceInfo...]
// enumerate local cameras
var localMicrophones = self.deviceManager?.microphones // [AudioDeviceInfo, AudioDeviceInfo...]
// enumerate local cameras
var localSpeakers = self.deviceManager?.speakers // [AudioDeviceInfo, AudioDeviceInfo...]

```

<!--End Device Management-->

## Push Notification
<!--Start Push Notification-->

### Push Notification APIs

#### Register for Push Notification

- In order to register for push notification, call registerPushNotification() on a *CallAgent* instance with a device registration token.

```swift
let deviceToken: Data = pushRegistry?.pushToken(for: PKPushType.voIP)
self.callAgent?.registerPushNotifications(deviceToken: deviceToken) { (error) in
                    if(error == nil) {
                        print("Successfully register to push notification.")
                    } else {
                        print("Failed to register push notification.")
                    }
                })
```

#### Push Notification Handling
- In order to receive incoming calls push notifications, call *handlePushNotification()* on a *CallAgent* instance with a dictionary payload.

```swift

let callNotification = IncomingCallPushNotification.from(payload: pushPayload?.dictionaryPayload)

self.callAgent?.handlePush(notification: callNotification) { (error) in
            if (error != nil) {
                print("Handling of push notification failed")
            } else {
                print("Handling of push notification was successful")
            }
        }
```

#### Unregister Push Notification

- Applications can unregister push notification at any time. Simply call the `unregisterPushNotification()` method on *CallAgent*.

```swift
self.callAgent?.unRegisterPushNotifications { (error) in
    if (error != nil) {
        print("Unregister of push notification failed, please try again")
    } else {
        print("Unregister of push notification was successfull")
    }
})
```
<!--End Push Notification-->

## Remote Participant Management
<!--Start Remote Participant Management-->

### Remote Participants Properties
Remote participant has set of properties

```swift
// [RemoteParticipantDelegate] delegate - an object you provide to receive events from this RemoteParticipant instance
var remoteParticipantDelegate = remoteParticipant?.delegate

// [CommunicationIdentifier] identity - same as the one used to provision token for another user
var identity = remoteParticipant?.identity;

// ParticipantStateIdle = 0, ParticipantStateEarlyMedia = 1, ParticipantStateConnecting = 2, ParticipantStateConnected = 3, ParticipantStateOnHold = 4, ParticipantStateInLobby = 5, ParticipantStateDisconnected = 6
var state = remoteParticipant?.state;

// [Error] callEndReason - reason why participant left the call, contains code/subcode/message
var callEndReason = remoteParticipant?.callEndReason

// [Bool] isMuted - indicating if participant is muted
var isMuted = remoteParticipant?.isMuted;

// [Bool] isSpeaking - indicating if participant is currently speaking
var isSpeaking = remoteParticipant?.isSpeaking;

// RemoteVideoStream[] - collection of video streams this participants has
var videoStreams = remoteParticipant?.videoStreams; // [RemoteVideoStream, RemoteVideoStream, ...]

// RemoteVideoStream[] - collection of screen sharing streams this participants has
var screenSharingStreams = remoteParticipant?.screenSharingStreams; // [RemoteVideoStream, RemoteVideoStream, ...]
```

### Call Operations for Remote Participant
#### Add Participant to a Call
* [Synchronous] Add participant to a call
```swift
let remoteParticipantAdded: RemoteParticipant = self.call.add(participant: CommunicationUserIdentifier(identifier: "8:echo123"))
```

#### Add Phone Number to a Call
* [Synchronous] Add phone number to a call
```swift
let remoteParticipantAdded: RemoteParticipant = self.call.add(participant: PhoneNumberIdentifier(phoneNumber: "+14243333"))
```

#### Remove Participant from a Call
* [Asynchronous] Remove participant from a call
```swift
self.call?.remove(participant: remoteParticipantAdded) { (error) in
    if (error == nil) {
        print("Successfully removed participant")
    } else {
        print("Failed to remove participant")
    }
}
```

#### List Participants in a Call
List all participants in a call
```swift
for remoteParticipant in self.call?.remoteParticipants { print(remoteParticipant); } // [RemoteParticipant1, RemoteParticipant2...]
```

```swift
public class RemoteParticipantObserver : NSObject, RemoteParticipantDelegate
{
    public func onRemoteParticipantsUpdated(_ call: Call!,
                                            args: ParticipantsUpdatedEventArgs!)
    {
        for participant in args.addedParticipants {
            participant.delegate = self
            self.remoteParticipants.append(participant)
        }
    }

    public func OnStateChanged(_ remoteParticipant: RemoteParticipant!,
                                args: PropertyChangedEventArgs!)
    {
        print("Remote participant " + remoteParticipant.displayName + 
                " state has changed to " + CallObserver.callStateToString(state: remoteParticipant.state))
    }

    public func onVideoStreamsUpdated(_ remoteParticipant: RemoteParticipant!,
                                      args: RemoteVideoStreamsEventArgs!)
    {
        print("Status of video stream for participant " + remoteParticipant.displayName)
        print(args.addedRemoteVideoStreams.count) // Array of added streams
        print(args.removedRemoteVideoStreams.count) // Array of removed streams
    }

    public func onIsMuteChanged(_ remoteParticipant: RemoteParticipant!,
                                      args: PropertyChangedEventArgs!)
    {
        print("Remote participant: " + remoteParticipant.displayName + ", is muted: " + remoteParticipant.isMuted)
    }

    public func onIsSpeakingChanged(_ remoteParticipant: RemoteParticipant!,
                                      args: PropertyChangedEventArgs!)
    {
        print("Remote participant: " + remoteParticipant.displayName + ", is speaking: " + remoteParticipant.isSpeaking)
    }

    public func onDisplayNameChanged(_ remoteParticipant: RemoteParticipant!,
                                      args: PropertyChangedEventArgs!)
    {
        print("Remote participant new display name: " + remoteParticipant.displayName)
    }
}
```

### Video / Screen Sharing Streams for Remote Participants

To list streams of remote participants inspect his videoStreams or screenSharingStreams collections
```swift
var videoStreams: [RemoteVideoStream] = remoteParticipant.videoStreams; // [RemoteVideoStream, RemoteVideoStream ...]
```

#### RemoteVideoStream
RemoteVideoStream represents remote video or screen sharing stream that this participant sends in a call
```swift
var remoteParticipantVideoStream: RemoteVideoStream  = self.call?.remoteParticipants[0]?.videoStreams[0];
```

It has following properties:
```swift
var type: MediaStreamType = remoteParticipantVideoStream.type; // 'MediaStreamTypeVideo' | 'MediaStreamTypeScreenSharing';

var isAvailable: Bool = remoteParticipantVideoStream.isAvailable; // indicates if remote stream is available

var id: Int = remoteParticipantVideoStream.id // id of remoteParticipantStream
```


#### Render Remote Participant Stream
* [Synchronous] To start rendering remote participant stream
```swift
let renderer: Renderer? = Renderer(remoteVideoStream: remoteParticipantVideoStream)
let targetRemoteParicipantView: RendererView? = renderer?.createView(with: RenderingOptions(ScalingMode.crop))
```

* Subscribe to events 
You can subscribe to one of following events:
  * 'OnStateChanged'
  * 'onVideoStreamsUpdated'
  * 'onIsMutedChanged'
  * 'onIsSpeakingChanged'
  * 'onDisplayNameChanged'
<!--End Remote Participant Management-->
