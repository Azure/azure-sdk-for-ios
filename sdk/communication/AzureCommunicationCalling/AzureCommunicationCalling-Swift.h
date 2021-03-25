// ACSCallingShared
// This file was auto-generated from ACSCallingModel.cs.

import Foundation

import AzureCommunication
//#import <AzureCore/AzureCore-Swift.h>

// Enumerations.
/// Additional failed states for Azure Communication Services
public struct CallingCommunicationErrors : OptionSet {

    public init(rawValue: Int)

    
    /// No Audio permissions available.
    public static var noAudioPermission: CallingCommunicationErrors { get }

    /// No Video permissions available.
    public static var noVideoPermission: CallingCommunicationErrors { get }

    /// No Video and Audio permissions available.
    public static var noAudioAndVideoPermission: CallingCommunicationErrors { get }

    /// Failed to process push notification payload.
    public static var receivedInvalidPushNotificationPayload: CallingCommunicationErrors { get }

    /// Recieved empty/invalid notification payload.
    public static var failedToProcessPushNotificationPayload: CallingCommunicationErrors { get }

    /// Recieved invalid group Id.
    public static var invalidGuidGroupId: CallingCommunicationErrors { get }

    /// Push notification device registration token is invalid.
    public static var invalidPushNotificationDeviceRegistrationToken: CallingCommunicationErrors { get }

    /// Cannot create multiple renderers for same device or stream.
    public static var multipleRenderersNotSupported: CallingCommunicationErrors { get }

    /// Renderer doesn't support creating multiple views.
    public static var multipleViewsNotSupported: CallingCommunicationErrors { get }
}

/// Direction of the camera
public enum CameraFacing : Int {

    
    /// Unknown
    case unknown = 0

    /// External device
    case external = 1

    /// Front camera
    case front = 2

    /// Back camera
    case back = 3

    /// Panoramic camera
    case panoramic = 4

    /// Left front camera
    case leftFront = 5

    /// Right front camera
    case rightFront = 6
}

/// Describes the video device type
public enum VideoDeviceType : Int {

    
    /// Unknown type of video device
    case unknown = 0

    /// USB Camera Video Device
    case usbCamera = 1

    /// Capture Adapter Video Device
    case captureAdapter = 2

    /// Virtual Video Device
    case virtual = 3
}

/// Local and Remote Video Stream types
public enum MediaStreamType : Int {

    
    /// Video
    case video = 0

    /// Screen share
    case screenSharing = 1
}

/// State of a participant in the call
public enum ParticipantState : Int {

    
    /// Idle
    case idle = 0

    /// Early Media
    case earlyMedia = 1

    /// Connecting
    case connecting = 2

    /// Connected
    case connected = 3

    /// On Hold
    case hold = 4

    /// In Lobby
    case inLobby = 5

    /// Disconnected
    case disconnected = 6

    /// Ringing
    case ringing = 7
}

/// State of a call
public enum CallState : Int {

    
    /// None - disposed or applicable very early in lifetime of a call
    case none = 0

    /// Early Media
    case earlyMedia = 1

    /// Call is being connected
    case connecting = 3

    /// Call is ringing
    case ringing = 4

    /// Call is connected
    case connected = 5

    /// Call held by local participant
    case localHold = 6

    /// Call is being disconnected
    case disconnecting = 7

    /// Call is disconnected
    case disconnected = 8

    /// In Lobby
    case inLobby = 9

    /// Call held by a remote participant
    case remoteHold = 10
}

/// Direction of a Call
public enum CallDirection : Int {

    
    /// Outgoing call
    case outgoing = 1

    /// Incoming call
    case incoming = 2
}

/// DTMF (Dual-Tone Multi-Frequency) tone for PSTN calls
public enum DtmfTone : Int {

    
    /// Zero
    case zero = 0

    /// One
    case one = 1

    /// Two
    case two = 2

    /// Three
    case three = 3

    /// Four
    case four = 4

    /// Five
    case five = 5

    /// Six
    case six = 6

    /// Seven
    case seven = 7

    /// Eight
    case eight = 8

    /// Nine
    case nine = 9

    /// Star
    case star = 10

    /// Pound
    case pound = 11

    /// A
    case A = 12

    /// B
    case B = 13

    /// C
    case C = 14

    /// D
    case D = 15

    /// Flash
    case flash = 16
}

/// Local and Remote Video scaling mode
public enum ScalingMode : Int {

    
    /// Cropped
    case crop = 1

    /// Fitted
    case fit = 2
}

public enum HandleType : Int {

    
    case unknown = 0

    case groupCallLocator = 1

    case teamsMeetingCoordinatesLocator = 2

    case teamsMeetingLinkLocator = 3
}

// MARK: Forward declarations.


/**
 * A set of methods that are called by ACSCallAgent in response to important events.
 */
public protocol CallAgentDelegate : NSObjectProtocol {

    
    optional func callAgent(_ callAgent: CallAgent!, didUpdateCalls args: CallsUpdatedEventArgs!)

    optional func callAgent(_ callAgent: CallAgent!, didRecieveIncomingCall incomingcall: IncomingCall!)
}


/**
 * A set of methods that are called by ACSCall in response to important events.
 */
public protocol CallDelegate : NSObjectProtocol {

    
    optional func call(_ call: Call!, didChangeId args: PropertyChangedEventArgs!)

    optional func call(_ call: Call!, didChangeState args: PropertyChangedEventArgs!)

    optional func call(_ call: Call!, didUpdateRemoteParticipant args: ParticipantsUpdatedEventArgs!)

    optional func call(_ call: Call!, didUpdateLocalVideoStreams args: LocalVideoStreamsUpdatedEventArgs!)

    optional func call(_ call: Call!, didChangeRecordingState args: PropertyChangedEventArgs!)

    optional func call(_ call: Call!, didChangeTranscriptionState args: PropertyChangedEventArgs!)
}


/**
 * A set of methods that are called by ACSRemoteParticipant in response to important events.
 */
public protocol RemoteParticipantDelegate : NSObjectProtocol {

    
    optional func remoteParticipant(_ remoteParticipant: RemoteParticipant!, didChangeState args: PropertyChangedEventArgs!)

    optional func remoteParticipant(_ remoteParticipant: RemoteParticipant!, didChangeMuteState args: PropertyChangedEventArgs!)

    optional func remoteParticipant(_ remoteParticipant: RemoteParticipant!, didChangeSpeakingState args: PropertyChangedEventArgs!)

    optional func remoteParticipant(_ remoteParticipant: RemoteParticipant!, didChangeDisplayName args: PropertyChangedEventArgs!)

    optional func remoteParticipant(_ remoteParticipant: RemoteParticipant!, didUpdateVideoStreams args: RemoteVideoStreamsEventArgs!)
}


/**
 * A set of methods that are called by ACSIncomingCall in response to important events.
 */
public protocol IncomingCallDelegate : NSObjectProtocol {

    
    optional func incomingCall(_ incomingCall: IncomingCall!, didEndCall args: PropertyChangedEventArgs!)
}


/**
 * A set of methods that are called by ACSDeviceManager in response to important events.
 */
public protocol DeviceManagerDelegate : NSObjectProtocol {

    
    optional func deviceManager(_ deviceManager: DeviceManager!, didUpdateCameras args: VideoDevicesUpdatedEventArgs!)
}


/// Property bag class for Video Options. Use this class to set video options required during a call (start/accept/join)
open class VideoOptions : NSObject {

    public init(localVideoStream: LocalVideoStream!)

    
    /// Deallocates the memory occupied by this object.
    open func dealloc()

    
    /// The video stream that is used to render the video on the UI surface
    open var localVideoStream: LocalVideoStream!
}


/// Local video stream information
open class LocalVideoStream : NSObject {

    public init(camera: VideoDeviceInfo!)

    
    /// Deallocates the memory occupied by this object.
    open func dealloc()

    
    /// Video device to use as source for local video.
    open var source: VideoDeviceInfo! { get }

    
    /// Sets to True when the local video stream is being sent on a call.
    open var isSending: Bool { get }

    
    /// MediaStream type being used for the current local video stream (Video or ScreenShare).
    open var mediaStreamType: MediaStreamType { get }

    
    // Class extension begins for LocalVideoStream.
    open func switchSource(camera: VideoDeviceInfo!, completionHandler: ((Error?) -> Void)!)
}

// Class extension ends for LocalVideoStream.


/// Information about a video device
open class VideoDeviceInfo : NSObject {

    
    /// Deallocates the memory occupied by this object.
    open func dealloc()

    
    /// Get the name of this video device.
    open var name: String! { get }

    
    /// Get Name of this audio device.
    open var id: String! { get }

    
    /// Direction of the camera
    open var cameraFacing: CameraFacing { get }

    
    /// Get the Device Type of this video device.
    open var deviceType: VideoDeviceType { get }
}


/// Property bag class for Audio Options. Use this class to set audio settings required during a call (start/join)
open class AudioOptions : NSObject {

    public init()

    
    /// Deallocates the memory occupied by this object.
    open func dealloc()

    
    /// Start an outgoing or accept incoming call muted (true) or un-muted(false)
    open var muted: Bool
}


/// Options to be passed when joining a call
open class JoinCallOptions : NSObject {

    public init()

    
    /// Deallocates the memory occupied by this object.
    open func dealloc()

    
    /// Video options when placing a call
    open var videoOptions: VideoOptions!

    
    /// Audio options when placing a call
    open var audioOptions: AudioOptions!
}


/// Options to be passed when accepting a call
open class AcceptCallOptions : NSObject {

    public init()

    
    /// Deallocates the memory occupied by this object.
    open func dealloc()

    
    /// Video options when accepting a call
    open var videoOptions: VideoOptions!
}


/// Options to be passed when starting a call
open class StartCallOptions : NSObject {

    public init()

    
    /// Deallocates the memory occupied by this object.
    open func dealloc()

    
    /// Video options when starting a call
    open var videoOptions: VideoOptions!

    
    /// Audio options when starting a call
    open var audioOptions: AudioOptions!

    
    // Class extension begins for StartCallOptions.
    open var alternateCallerID: PhoneNumberIdentifier
}

// Class extension ends for StartCallOptions.


/// Options when making an outgoing PSTN call
open class AddPhoneNumberOptions : NSObject {

    public init()

    
    /// Deallocates the memory occupied by this object.
    open func dealloc()

    
    // Class extension begins for AddPhoneNumberOptions.
    open var alternateCallerID: PhoneNumberIdentifier
}

// Class extension ends for AddPhoneNumberOptions.


/// JoinMeetingLocator super type, locator for joining meetings
open class JoinMeetingLocator : NSObject {

    
    /// Deallocates the memory occupied by this object.
    open func dealloc()
}


/// Options for joining a group call
open class GroupCallLocator : JoinMeetingLocator {

    public init(groupId: UUID!)

    
    /// The unique identifier for the group conversation
    open var groupId: UUID!
}


/// Options for joining a Teams meeting using Coordinates locator
open class TeamsMeetingCoordinatesLocator : JoinMeetingLocator {

    public init(withThreadId threadId: String!, organizerId: UUID!, tenantId: UUID!, messageId: String!)

    
    /// The thread identifier of meeting
    open var threadId: String! { get }

    
    /// The organizer identifier of meeting
    open var organizerId: UUID!

    
    /// The tenant identifier of meeting
    open var tenantId: UUID!

    
    /// The message identifier of meeting
    open var messageId: String! { get }
}


/// Options for joining a Teams meeting using Link locator
open class TeamsMeetingLinkLocator : JoinMeetingLocator {

    public init(meetingLink: String!)

    
    /// The URI of the meeting
    open var meetingLink: String! { get }
}


/// Describes the Caller Information
open class CallerInfo : NSObject {

    
    /// Deallocates the memory occupied by this object.
    open func dealloc()

    
    /// The display name of the caller
    open var displayName: String! { get }

    
    // Class extension begins for CallerInfo.
    open var identifier: CommunicationIdentifier { get }
}

// Class extension ends for CallerInfo.


/// Describes an incoming call
open class PushNotificationInfo : NSObject {

    
    /// Deallocates the memory occupied by this object.
    open func dealloc()

    
    /// The display name of the caller
    open var fromDisplayName: String! { get }

    
    /// Indicates whether the incoming call has a video or not
    open var incomingWithVideo: Bool { get }

    
    // Class extension begins for PushNotificationInfo.
    open var from: CommunicationIdentifier! { get }

    open var to: CommunicationIdentifier! { get }

    open var callId: UUID { get }

    open class func fromDictionary(_ payload: [AnyHashable : Any]!) -> PushNotificationInfo!
}

// Class extension ends for PushNotificationInfo.


/// Options for creating CallAgent
open class CallAgentOptions : NSObject {

    public init()

    
    /// Deallocates the memory occupied by this object.
    open func dealloc()

    
    /// Specify the display name of the local participant for all new calls
    open var displayName: String!
}


/// Call agent created by the CallClient factory method createCallAgent It bears the responsibility of managing calls on behalf of the authenticated user
open class CallAgent : NSObject {

    
    /// Deallocates the memory occupied by this object.
    open func dealloc()

    
    /// Returns the list of all active calls.
    open var calls: [Call]! { get }

    
    /**
     * The delegate that will handle events from the ACSCallAgent.
     */
    unowned(unsafe) open var delegate: CallAgentDelegate!

    
    /// Handle the push notification. If successful, will raise appropriate incoming call event.
    open func handlePush(notification: PushNotificationInfo!, completionHandler: @escaping (Error?) -> Void)

    
    /// Unregister all previously registered devices from receiving incoming calls push notifications.
    open func unregisterPushNotification(completionHandler: @escaping (Error?) -> Void)

    
    // Class extension begins for CallAgent.
    open func startCall(participants: [CommunicationIdentifier]!, options: StartCallOptions!) -> Call!

    open func join(with meetingLocator: JoinMeetingLocator!, joinCallOptions: JoinCallOptions!) -> Call!

    open func registerPushNotifications(deviceToken: Data!, completionHandler: ((Error?) -> Void)!)
}

// Class extension ends for CallAgent.


/// Describes a call
open class Call : NSObject {

    
    /// Deallocates the memory occupied by this object.
    open func dealloc()

    
    /// Get a list of remote participants in the current call.
    open var remoteParticipants: [RemoteParticipant]! { get }

    
    /// Id of the call
    open var id: String! { get }

    
    /// Current state of the call
    open var state: CallState { get }

    
    /// Containing code/subcode indicating how a call has ended
    open var callEndReason: CallEndReason! { get }

    
    /// Outgoing or Incoming depending on the Call Direction
    open var callDirection: CallDirection { get }

    
    /// Whether the local microphone is muted or not.
    open var isMicrophoneMuted: Bool { get }

    
    /// The identity of the caller
    open var callerInfo: CallerInfo! { get }

    
    /// Get a list of local video streams in the current call.
    open var localVideoStreams: [LocalVideoStream]! { get }

    
    /// Indicates if recording is active in current call
    open var isRecordingActive: Bool { get }

    
    /// Indicates if transcription is active in current call
    open var isTranscriptionActive: Bool { get }

    
    /**
     * The delegate that will handle events from the ACSCall.
     */
    unowned(unsafe) open var delegate: CallDelegate!

    
    /// Mute local microphone.
    open func mute(completionHandler: @escaping (Error?) -> Void)

    
    /// Unmute local microphone.
    open func unmute(completionHandler: @escaping (Error?) -> Void)

    
    /// Send DTMF tone
    open func sendDtmf(tone: DtmfTone, completionHandler: @escaping (Error?) -> Void)

    
    /// Start sharing video stream to the call
    open func startVideo(stream: LocalVideoStream!, completionHandler: @escaping (Error?) -> Void)

    
    /// Stop sharing video stream to the call
    open func stopVideo(stream: LocalVideoStream!, completionHandler: @escaping (Error?) -> Void)

    
    /// HangUp a call
    open func hangUp(options: HangUpOptions!, completionHandler: @escaping (Error?) -> Void)

    
    /// Remove a participant from a call
    open func remove(participant: RemoteParticipant!, completionHandler: @escaping (Error?) -> Void)

    
    /// Hold this call
    open func hold(completionHandler: @escaping (Error?) -> Void)

    
    /// Resume this call
    open func resume(completionHandler: @escaping (Error?) -> Void)

    
    // Class extension begins for Call.
    open func add(participant: CommunicationIdentifier!) -> RemoteParticipant!

    open func add(participant: PhoneNumberIdentifier!, options: AddPhoneNumberOptions!) -> RemoteParticipant!
}

// Class extension ends for Call.


/// Describes a remote participant on a call
open class RemoteParticipant : NSObject {

    
    /// Deallocates the memory occupied by this object.
    open func dealloc()

    
    /// Private Preview Only: Display Name of the remote participant
    open var displayName: String! { get }

    
    /// True if the remote participant is muted
    open var isMuted: Bool { get }

    
    /// True if the remote participant is speaking
    open var isSpeaking: Bool { get }

    
    /// Reason why participant left the call, contains code/subcode.
    open var callEndReason: CallEndReason! { get }

    
    /// Current state of the remote participant
    open var state: ParticipantState { get }

    
    /// Remote Video streams part of the current call
    open var videoStreams: [RemoteVideoStream]! { get }

    
    /**
     * The delegate that will handle events from the ACSRemoteParticipant.
     */
    unowned(unsafe) open var delegate: RemoteParticipantDelegate!

    
    // Class extension begins for RemoteParticipant.
    open var identifier: CommunicationIdentifier { get }
}

// Class extension ends for RemoteParticipant.


/// Describes the reason for a call to end
open class CallEndReason : NSObject {

    
    /// Deallocates the memory occupied by this object.
    open func dealloc()

    
    /// The code
    open var code: Int32 { get }

    
    /// The subcode
    open var subcode: Int32 { get }
}


/// Video stream on remote participant (NOT SUPPORTED)
open class RemoteVideoStream : NSObject {

    
    /// Deallocates the memory occupied by this object.
    open func dealloc()

    
    /// True when remote video stream is available.
    open var isAvailable: Bool { get }

    
    /// MediaStream type of the current remote video stream (Video or ScreenShare).
    open var mediaStreamType: MediaStreamType { get }

    
    /// Unique Identifier of the current remote video stream.
    open var id: Int32 { get }
}


/// Describes a PropertyChanged event data
open class PropertyChangedEventArgs : NSObject {

    
    /// Deallocates the memory occupied by this object.
    open func dealloc()
}


/// Information about remote video streams added or removed (NOT SUPPORTED)
open class RemoteVideoStreamsEventArgs : NSObject {

    
    /// Deallocates the memory occupied by this object.
    open func dealloc()

    
    /// Remote video streams that have been added to the current call
    open var addedRemoteVideoStreams: [RemoteVideoStream]! { get }

    
    /// Remote video streams that are no longer part of the current call
    open var removedRemoteVideoStreams: [RemoteVideoStream]! { get }
}


/// Describes a ParticipantsUpdated event data
open class ParticipantsUpdatedEventArgs : NSObject {

    
    /// Deallocates the memory occupied by this object.
    open func dealloc()

    
    /// List of Participants that were added
    open var addedParticipants: [RemoteParticipant]! { get }

    
    /// List of Participants that were removed
    open var removedParticipants: [RemoteParticipant]! { get }
}


/// Describes a LocalVideoStreamsUpdated event data
open class LocalVideoStreamsUpdatedEventArgs : NSObject {

    
    /// Deallocates the memory occupied by this object.
    open func dealloc()

    
    /// List of LocalVideoStream that were added
    open var addedStreams: [LocalVideoStream]! { get }

    
    /// List of LocalVideoStream that were removed
    open var removedStreams: [LocalVideoStream]! { get }
}


/// Property bag class for hanging up a call
open class HangUpOptions : NSObject {

    public init()

    
    /// Deallocates the memory occupied by this object.
    open func dealloc()

    
    /// Use to determine whether the current call should be terminated for all participant on the call or not
    open var forEveryone: Bool
}


/// Describes a CallsUpdated event
open class CallsUpdatedEventArgs : NSObject {

    
    /// Deallocates the memory occupied by this object.
    open func dealloc()

    
    /// New calls being tracked by the library
    open var addedCalls: [Call]! { get }

    
    /// Calls that are no longer tracked by the library
    open var removedCalls: [Call]! { get }
}


/// Describes an incoming call
open class IncomingCall : NSObject {

    
    /// Deallocates the memory occupied by this object.
    open func dealloc()

    
    /// Describe the reason why a call has ended
    open var callEndReason: CallEndReason! { get }

    
    /// Information about the caller
    open var callerInfo: CallerInfo! { get }

    
    /// Id of the call
    open var id: String! { get }

    
    /// Is inoming video enabled
    open var isVideoEnabled: Bool { get }

    
    /**
     * The delegate that will handle events from the ACSIncomingCall.
     */
    unowned(unsafe) open var delegate: IncomingCallDelegate!

    
    /// Accept an incoming call
    open func accept(options: AcceptCallOptions!, completionHandler: @escaping (Call?, Error?) -> Void)

    
    /// Reject this incoming call
    open func reject(completionHandler: @escaping (Error?) -> Void)
}


/// This is the main class representing the entrypoint for the Calling SDK.
open class CallClient : NSObject {

    public init()

    
    /// Deallocates the memory occupied by this object.
    open func dealloc()

    
    /// Gets a device manager object that can be used to enumerates audio and video devices available for calls.
    open func getDeviceManager(completionHandler: @escaping (DeviceManager?, Error?) -> Void)

    
    // Class extension begins for CallClient.
    open func createCallAgent(userCredential: CommunicationTokenCredential!, options callAgentOptions: CallAgentOptions!, completionHandler: ((CallAgent?, Error?) -> Void)!)

    
    open func createCallAgent(userCredential: CommunicationTokenCredential!, completionHandler: ((CallAgent?, Error?) -> Void)!)

    
    open var communicationCredential: CommunicationTokenCredential
}

// Class extension ends for CallClient.


/// Device manager
open class DeviceManager : NSObject {

    
    /// Deallocates the memory occupied by this object.
    open func dealloc()

    
    /// Get the list of currently connected video devices
    open var cameras: [VideoDeviceInfo]! { get }

    
    /**
     * The delegate that will handle events from the ACSDeviceManager.
     */
    unowned(unsafe) open var delegate: DeviceManagerDelegate!
}


/// Describes a VideoDevicesUpdated event data
open class VideoDevicesUpdatedEventArgs : NSObject {

    
    /// Deallocates the memory occupied by this object.
    open func dealloc()

    
    /// Video devicesRemote video streams that have been added to the current call
    open var addedVideoDevices: [VideoDeviceInfo]! { get }

    
    /// Remote video streams that have been added to the current call
    open var removedVideoDevices: [VideoDeviceInfo]! { get }
}


/// Options to be passed when rendering a Video
open class RenderingOptions : NSObject {

    public init(scalingMode: ScalingMode)

    
    /// Deallocates the memory occupied by this object.
    open func dealloc()

    
    /// Scaling mode for rendering the video.
    open var scalingMode: ScalingMode
}
