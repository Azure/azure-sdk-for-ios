// ACSCallingShared
// This file was auto-generated from ACSCallingModel.cs.

#import <Foundation/Foundation.h>

#import <AzureCommunication/AzureCommunication-Swift.h>
//#import <AzureCore/AzureCore-Swift.h>
#import "ACSRenderer.h"
#import "ACSRendererView.h"
#import "ACSStreamSize.h"

// Enumerations.
/// Additional failed states for Azure Communication Services
typedef NS_OPTIONS(NSInteger, ACSCallingCommunicationErrors)
{
    /// No errors
    ACSCallingCommunicationErrorsNone = 0,
    /// No Audio permissions available.
    ACSCallingCommunicationErrorsNoAudioPermission = 1,
    /// No Video permissions available.
    ACSCallingCommunicationErrorsNoVideoPermission = 2,
    /// No Video and Audio permissions available.
    ACSCallingCommunicationErrorsNoAudioAndVideoPermission = 3,
    /// Failed to process push notification payload.
    ACSCallingCommunicationErrorsReceivedInvalidPushNotificationPayload = 4,
    /// Recieved empty/invalid notification payload.
    ACSCallingCommunicationErrorsFailedToProcessPushNotificationPayload = 8,
    /// Recieved invalid group Id.
    ACSCallingCommunicationErrorsInvalidGuidGroupId = 16,
    /// Push notification device registration token is invalid.
    ACSCallingCommunicationErrorsInvalidPushNotificationDeviceRegistrationToken = 32,
    /// Cannot create multiple renderers for same device or stream.
    ACSCallingCommunicationErrorsMultipleRenderersNotSupported = 64,
    /// Renderer doesn't support creating multiple views.
    ACSCallingCommunicationErrorsMultipleViewsNotSupported = 128
} NS_SWIFT_NAME(CallingCommunicationErrors);

/// Direction of the camera
typedef NS_ENUM(NSInteger, ACSCameraFacing)
{
    /// Unknown
    ACSCameraFacingUnknown = 0,
    /// External device
    ACSCameraFacingExternal = 1,
    /// Front camera
    ACSCameraFacingFront = 2,
    /// Back camera
    ACSCameraFacingBack = 3,
    /// Panoramic camera
    ACSCameraFacingPanoramic = 4,
    /// Left front camera
    ACSCameraFacingLeftFront = 5,
    /// Right front camera
    ACSCameraFacingRightFront = 6
} NS_SWIFT_NAME(CameraFacing);

/// Describes the video device type
typedef NS_ENUM(NSInteger, ACSVideoDeviceType)
{
    /// Unknown type of video device
    ACSVideoDeviceTypeUnknown = 0,
    /// USB Camera Video Device
    ACSVideoDeviceTypeUsbCamera = 1,
    /// Capture Adapter Video Device
    ACSVideoDeviceTypeCaptureAdapter = 2,
    /// Virtual Video Device
    ACSVideoDeviceTypeVirtual = 3
} NS_SWIFT_NAME(VideoDeviceType);

/// Local and Remote Video Stream types
typedef NS_ENUM(NSInteger, ACSMediaStreamType)
{
    /// Video
    ACSMediaStreamTypeVideo = 0,
    /// Screen share
    ACSMediaStreamTypeScreenSharing = 1
} NS_SWIFT_NAME(MediaStreamType);

/// State of a participant in the call
typedef NS_ENUM(NSInteger, ACSParticipantState)
{
    /// Idle
    ACSParticipantStateIdle = 0,
    /// Early Media
    ACSParticipantStateEarlyMedia = 1,
    /// Connecting
    ACSParticipantStateConnecting = 2,
    /// Connected
    ACSParticipantStateConnected = 3,
    /// On Hold
    ACSParticipantStateHold = 4,
    /// In Lobby
    ACSParticipantStateInLobby = 5,
    /// Disconnected
    ACSParticipantStateDisconnected = 6,
    /// Ringing
    ACSParticipantStateRinging = 7
} NS_SWIFT_NAME(ParticipantState);

/// State of a call
typedef NS_ENUM(NSInteger, ACSCallState)
{
    /// None - disposed or applicable very early in lifetime of a call
    ACSCallStateNone = 0,
    /// Early Media
    ACSCallStateEarlyMedia = 1,
    /// Call is being connected
    ACSCallStateConnecting = 3,
    /// Call is ringing
    ACSCallStateRinging = 4,
    /// Call is connected
    ACSCallStateConnected = 5,
    /// Call held by local participant
    ACSCallStateLocalHold = 6,
    /// Call is being disconnected
    ACSCallStateDisconnecting = 7,
    /// Call is disconnected
    ACSCallStateDisconnected = 8,
    /// In Lobby
    ACSCallStateInLobby = 9,
    /// Call held by a remote participant
    ACSCallStateRemoteHold = 10
} NS_SWIFT_NAME(CallState);

/// Direction of a Call
typedef NS_ENUM(NSInteger, ACSCallDirection)
{
    /// Outgoing call
    ACSCallDirectionOutgoing = 1,
    /// Incoming call
    ACSCallDirectionIncoming = 2
} NS_SWIFT_NAME(CallDirection);

/// DTMF (Dual-Tone Multi-Frequency) tone for PSTN calls
typedef NS_ENUM(NSInteger, ACSDtmfTone)
{
    /// Zero
    ACSDtmfToneZero = 0,
    /// One
    ACSDtmfToneOne = 1,
    /// Two
    ACSDtmfToneTwo = 2,
    /// Three
    ACSDtmfToneThree = 3,
    /// Four
    ACSDtmfToneFour = 4,
    /// Five
    ACSDtmfToneFive = 5,
    /// Six
    ACSDtmfToneSix = 6,
    /// Seven
    ACSDtmfToneSeven = 7,
    /// Eight
    ACSDtmfToneEight = 8,
    /// Nine
    ACSDtmfToneNine = 9,
    /// Star
    ACSDtmfToneStar = 10,
    /// Pound
    ACSDtmfTonePound = 11,
    /// A
    ACSDtmfToneA = 12,
    /// B
    ACSDtmfToneB = 13,
    /// C
    ACSDtmfToneC = 14,
    /// D
    ACSDtmfToneD = 15,
    /// Flash
    ACSDtmfToneFlash = 16
} NS_SWIFT_NAME(DtmfTone);

/// Local and Remote Video scaling mode
typedef NS_ENUM(NSInteger, ACSScalingMode)
{
    /// Cropped
    ACSScalingModeCrop = 1,
    /// Fitted
    ACSScalingModeFit = 2
} NS_SWIFT_NAME(ScalingMode);

typedef NS_ENUM(NSInteger, ACSHandleType)
{
    ACSHandleTypeUnknown = 0,
    ACSHandleTypeGroupCallLocator = 1,
    ACSHandleTypeTeamsMeetingCoordinatesLocator = 2,
    ACSHandleTypeTeamsMeetingLinkLocator = 3
} NS_SWIFT_NAME(HandleType);

// MARK: Forward declarations.
@class ACSVideoOptions;
@class ACSLocalVideoStream;
@class ACSVideoDeviceInfo;
@class ACSAudioOptions;
@class ACSJoinCallOptions;
@class ACSAcceptCallOptions;
@class ACSStartCallOptions;
@class ACSAddPhoneNumberOptions;
@class ACSJoinMeetingLocator;
@class ACSGroupCallLocator;
@class ACSTeamsMeetingCoordinatesLocator;
@class ACSTeamsMeetingLinkLocator;
@class ACSCallerInfo;
@class ACSPushNotificationInfo;
@class ACSCallAgentOptions;
@class ACSCallAgent;
@class ACSCall;
@class ACSRemoteParticipant;
@class ACSCallEndReason;
@class ACSRemoteVideoStream;
@class ACSPropertyChangedEventArgs;
@class ACSRemoteVideoStreamsEventArgs;
@class ACSParticipantsUpdatedEventArgs;
@class ACSLocalVideoStreamsUpdatedEventArgs;
@class ACSHangUpOptions;
@class ACSCallsUpdatedEventArgs;
@class ACSIncomingCall;
@class ACSCallClient;
@class ACSDeviceManager;
@class ACSVideoDevicesUpdatedEventArgs;
@class ACSRenderingOptions;
@protocol ACSCallAgentDelegate;
@protocol ACSCallDelegate;
@protocol ACSRemoteParticipantDelegate;
@protocol ACSIncomingCallDelegate;
@protocol ACSDeviceManagerDelegate;

/**
 * A set of methods that are called by ACSCallAgent in response to important events.
 */
NS_SWIFT_NAME(CallAgentDelegate)
@protocol ACSCallAgentDelegate <NSObject>
@optional
- (void)onCallsUpdated:(ACSCallAgent *)callAgent :(ACSCallsUpdatedEventArgs *)args NS_SWIFT_NAME( callAgent(_:didUpdateCalls:));
- (void)onIncomingCall:(ACSCallAgent *)callAgent :(ACSIncomingCall *)incomingcall NS_SWIFT_NAME( callAgent(_:didRecieveIncomingCall:));
@end

/**
 * A set of methods that are called by ACSCall in response to important events.
 */
NS_SWIFT_NAME(CallDelegate)
@protocol ACSCallDelegate <NSObject>
@optional
- (void)onIdChanged:(ACSCall *)call :(ACSPropertyChangedEventArgs *)args NS_SWIFT_NAME( call(_:didChangeId:));
- (void)onStateChanged:(ACSCall *)call :(ACSPropertyChangedEventArgs *)args NS_SWIFT_NAME( call(_:didChangeState:));
- (void)onRemoteParticipantsUpdated:(ACSCall *)call :(ACSParticipantsUpdatedEventArgs *)args NS_SWIFT_NAME( call(_:didUpdateRemoteParticipant:));
- (void)onLocalVideoStreamsChanged:(ACSCall *)call :(ACSLocalVideoStreamsUpdatedEventArgs *)args NS_SWIFT_NAME( call(_:didUpdateLocalVideoStreams:));
- (void)onIsRecordingActiveChanged:(ACSCall *)call :(ACSPropertyChangedEventArgs *)args NS_SWIFT_NAME( call(_:didChangeRecordingState:));
- (void)onIsTranscriptionActiveChanged:(ACSCall *)call :(ACSPropertyChangedEventArgs *)args NS_SWIFT_NAME( call(_:didChangeTranscriptionState:));
@end

/**
 * A set of methods that are called by ACSRemoteParticipant in response to important events.
 */
NS_SWIFT_NAME(RemoteParticipantDelegate)
@protocol ACSRemoteParticipantDelegate <NSObject>
@optional
- (void)onStateChanged:(ACSRemoteParticipant *)remoteParticipant :(ACSPropertyChangedEventArgs *)args NS_SWIFT_NAME( remoteParticipant(_:didChangeState:));
- (void)onIsMutedChanged:(ACSRemoteParticipant *)remoteParticipant :(ACSPropertyChangedEventArgs *)args NS_SWIFT_NAME( remoteParticipant(_:didChangeMuteState:));
- (void)onIsSpeakingChanged:(ACSRemoteParticipant *)remoteParticipant :(ACSPropertyChangedEventArgs *)args NS_SWIFT_NAME( remoteParticipant(_:didChangeSpeakingState:));
- (void)onDisplayNameChanged:(ACSRemoteParticipant *)remoteParticipant :(ACSPropertyChangedEventArgs *)args NS_SWIFT_NAME( remoteParticipant(_:didChangeDisplayName:));
- (void)onVideoStreamsUpdated:(ACSRemoteParticipant *)remoteParticipant :(ACSRemoteVideoStreamsEventArgs *)args NS_SWIFT_NAME( remoteParticipant(_:didUpdateVideoStreams:));
@end

/**
 * A set of methods that are called by ACSIncomingCall in response to important events.
 */
NS_SWIFT_NAME(IncomingCallDelegate)
@protocol ACSIncomingCallDelegate <NSObject>
@optional
- (void)onCallEnded:(ACSIncomingCall *)incomingCall :(ACSPropertyChangedEventArgs *)args NS_SWIFT_NAME( incomingCall(_:didEndCall:));
@end

/**
 * A set of methods that are called by ACSDeviceManager in response to important events.
 */
NS_SWIFT_NAME(DeviceManagerDelegate)
@protocol ACSDeviceManagerDelegate <NSObject>
@optional
- (void)onCamerasUpdated:(ACSDeviceManager *)deviceManager :(ACSVideoDevicesUpdatedEventArgs *)args NS_SWIFT_NAME( deviceManager(_:didUpdateCameras:));
@end

/// Property bag class for Video Options. Use this class to set video options required during a call (start/accept/join)
NS_SWIFT_NAME(VideoOptions)
@interface ACSVideoOptions : NSObject
-(nonnull instancetype)init:(ACSLocalVideoStream *)localVideoStream NS_SWIFT_NAME( init(localVideoStream:));

-(nullable instancetype)init NS_UNAVAILABLE;
/// Deallocates the memory occupied by this object.
-(void)dealloc;

/// The video stream that is used to render the video on the UI surface
@property (retain) ACSLocalVideoStream * localVideoStream;

@end

/// Local video stream information
NS_SWIFT_NAME(LocalVideoStream)
@interface ACSLocalVideoStream : NSObject
-(nonnull instancetype)init:(ACSVideoDeviceInfo *)camera NS_SWIFT_NAME( init(camera:));

-(nullable instancetype)init NS_UNAVAILABLE;
/// Deallocates the memory occupied by this object.
-(void)dealloc;

/// Video device to use as source for local video.
@property (retain, readonly) ACSVideoDeviceInfo * source;

/// Sets to True when the local video stream is being sent on a call.
@property (readonly) BOOL isSending;

/// MediaStream type being used for the current local video stream (Video or ScreenShare).
@property (readonly) ACSMediaStreamType mediaStreamType;

// Class extension begins for LocalVideoStream.
-(void)switchSource:(ACSVideoDeviceInfo *)camera withCompletionHandler:(void (^)(NSError *error))completionHandler NS_SWIFT_NAME( switchSource(camera:completionHandler:));
// Class extension ends for LocalVideoStream.

@end

/// Information about a video device
NS_SWIFT_NAME(VideoDeviceInfo)
@interface ACSVideoDeviceInfo : NSObject
-(nullable instancetype)init NS_UNAVAILABLE;
/// Deallocates the memory occupied by this object.
-(void)dealloc;

/// Get the name of this video device.
@property (retain, readonly) NSString * name;

/// Get Name of this audio device.
@property (retain, readonly) NSString * id;

/// Direction of the camera
@property (readonly) ACSCameraFacing cameraFacing;

/// Get the Device Type of this video device.
@property (readonly) ACSVideoDeviceType deviceType;

@end

/// Property bag class for Audio Options. Use this class to set audio settings required during a call (start/join)
NS_SWIFT_NAME(AudioOptions)
@interface ACSAudioOptions : NSObject
-(nonnull instancetype)init;

/// Deallocates the memory occupied by this object.
-(void)dealloc;

/// Start an outgoing or accept incoming call muted (true) or un-muted(false)
@property BOOL muted;

@end

/// Options to be passed when joining a call
NS_SWIFT_NAME(JoinCallOptions)
@interface ACSJoinCallOptions : NSObject
-(nonnull instancetype)init;

/// Deallocates the memory occupied by this object.
-(void)dealloc;

/// Video options when placing a call
@property (retain) ACSVideoOptions * videoOptions;

/// Audio options when placing a call
@property (retain) ACSAudioOptions * audioOptions;

@end

/// Options to be passed when accepting a call
NS_SWIFT_NAME(AcceptCallOptions)
@interface ACSAcceptCallOptions : NSObject
-(nonnull instancetype)init;

/// Deallocates the memory occupied by this object.
-(void)dealloc;

/// Video options when accepting a call
@property (retain) ACSVideoOptions * videoOptions;

@end

/// Options to be passed when starting a call
NS_SWIFT_NAME(StartCallOptions)
@interface ACSStartCallOptions : NSObject
-(nonnull instancetype)init;

/// Deallocates the memory occupied by this object.
-(void)dealloc;

/// Video options when starting a call
@property (retain) ACSVideoOptions * videoOptions;

/// Audio options when starting a call
@property (retain) ACSAudioOptions * audioOptions;

// Class extension begins for StartCallOptions.
@property(nonatomic, nonnull) PhoneNumberIdentifier* alternateCallerID;
// Class extension ends for StartCallOptions.

@end

/// Options when making an outgoing PSTN call
NS_SWIFT_NAME(AddPhoneNumberOptions)
@interface ACSAddPhoneNumberOptions : NSObject
-(nonnull instancetype)init;

/// Deallocates the memory occupied by this object.
-(void)dealloc;

// Class extension begins for AddPhoneNumberOptions.
@property(nonatomic, nonnull) PhoneNumberIdentifier* alternateCallerID;
// Class extension ends for AddPhoneNumberOptions.

@end

/// JoinMeetingLocator super type, locator for joining meetings
NS_SWIFT_NAME(JoinMeetingLocator)
@interface ACSJoinMeetingLocator : NSObject
-(nullable instancetype)init NS_UNAVAILABLE;
/// Deallocates the memory occupied by this object.
-(void)dealloc;

@end

/// Options for joining a group call
NS_SWIFT_NAME(GroupCallLocator)
@interface ACSGroupCallLocator : ACSJoinMeetingLocator
-(nonnull instancetype)init:(NSUUID *)groupId NS_SWIFT_NAME( init(groupId:));

-(nullable instancetype)init NS_UNAVAILABLE;
/// The unique identifier for the group conversation
@property NSUUID *groupId;

@end

/// Options for joining a Teams meeting using Coordinates locator
NS_SWIFT_NAME(TeamsMeetingCoordinatesLocator)
@interface ACSTeamsMeetingCoordinatesLocator : ACSJoinMeetingLocator
-(nonnull instancetype)initWithThreadId:(NSString *)threadId organizerId:(NSUUID *)organizerId tenantId:(NSUUID *)tenantId messageId:(NSString *)messageId NS_SWIFT_NAME( init(withThreadId:organizerId:tenantId:messageId:));

-(nullable instancetype)init NS_UNAVAILABLE;
/// The thread identifier of meeting
@property (retain, readonly) NSString * threadId;

/// The organizer identifier of meeting
@property NSUUID *organizerId;

/// The tenant identifier of meeting
@property NSUUID *tenantId;

/// The message identifier of meeting
@property (retain, readonly) NSString * messageId;

@end

/// Options for joining a Teams meeting using Link locator
NS_SWIFT_NAME(TeamsMeetingLinkLocator)
@interface ACSTeamsMeetingLinkLocator : ACSJoinMeetingLocator
-(nonnull instancetype)init:(NSString *)meetingLink NS_SWIFT_NAME( init(meetingLink:));

-(nullable instancetype)init NS_UNAVAILABLE;
/// The URI of the meeting
@property (retain, readonly) NSString * meetingLink;

@end

/// Describes the Caller Information
NS_SWIFT_NAME(CallerInfo)
@interface ACSCallerInfo : NSObject
-(nullable instancetype)init NS_UNAVAILABLE;
/// Deallocates the memory occupied by this object.
-(void)dealloc;

/// The display name of the caller
@property (retain, readonly) NSString * displayName;

// Class extension begins for CallerInfo.
@property(nonatomic, readonly, nonnull) id<CommunicationIdentifier> identifier;
// Class extension ends for CallerInfo.

@end

/// Describes an incoming call
NS_SWIFT_NAME(PushNotificationInfo)
@interface ACSPushNotificationInfo : NSObject
-(nullable instancetype)init NS_UNAVAILABLE;
/// Deallocates the memory occupied by this object.
-(void)dealloc;

/// The display name of the caller
@property (retain, readonly) NSString * fromDisplayName;

/// Indicates whether the incoming call has a video or not
@property (readonly) BOOL incomingWithVideo;

// Class extension begins for PushNotificationInfo.
@property (retain, readonly) id<CommunicationIdentifier> from;
@property (retain, readonly) id<CommunicationIdentifier> to;
@property (nonatomic, nonnull, readonly) NSUUID* callId;
+(ACSPushNotificationInfo*) fromDictionary:(NSDictionary *)payload;
// Class extension ends for PushNotificationInfo.

@end

/// Options for creating CallAgent
NS_SWIFT_NAME(CallAgentOptions)
@interface ACSCallAgentOptions : NSObject
-(nonnull instancetype)init;

/// Deallocates the memory occupied by this object.
-(void)dealloc;

/// Specify the display name of the local participant for all new calls
@property (retain) NSString * displayName;

@end

/// Call agent created by the CallClient factory method createCallAgent It bears the responsibility of managing calls on behalf of the authenticated user
NS_SWIFT_NAME(CallAgent)
@interface ACSCallAgent : NSObject
-(nullable instancetype)init NS_UNAVAILABLE;
/// Deallocates the memory occupied by this object.
-(void)dealloc;

/// Returns the list of all active calls.
@property (copy, readonly) NSArray<ACSCall *> * calls;

/**
 * The delegate that will handle events from the ACSCallAgent.
 */
@property(nonatomic, assign) id<ACSCallAgentDelegate> delegate;

/// Handle the push notification. If successful, will raise appropriate incoming call event.
-(void)handlePushNotification:(ACSPushNotificationInfo *)notification withCompletionHandler:(void (^ _Nonnull )(NSError * _Nullable error))completionHandler NS_SWIFT_NAME( handlePush(notification:completionHandler:));

/// Unregister all previously registered devices from receiving incoming calls push notifications.
-(void)unregisterPushNotificationWithCompletionHandler:(void (^ _Nonnull )(NSError * _Nullable error))completionHandler NS_SWIFT_NAME( unregisterPushNotification(completionHandler:));

// Class extension begins for CallAgent.
-(ACSCall *)startCall:(NSArray<id<CommunicationIdentifier>> *)participants
            options:(ACSStartCallOptions *)options NS_SWIFT_NAME( startCall(participants:options:));
-(ACSCall *)joinWithMeetingLocator:(ACSJoinMeetingLocator *)meetingLocator
            joinCallOptions:(ACSJoinCallOptions *)joinCallOptions NS_SWIFT_NAME( join(with:joinCallOptions:));
-(void)registerPushNotifications: (NSData *)deviceToken withCompletionHandler:(void (^)(NSError *error))completionHandler NS_SWIFT_NAME( registerPushNotifications(deviceToken:completionHandler:));
// Class extension ends for CallAgent.

@end

/// Describes a call
NS_SWIFT_NAME(Call)
@interface ACSCall : NSObject
-(nullable instancetype)init NS_UNAVAILABLE;
/// Deallocates the memory occupied by this object.
-(void)dealloc;

/// Get a list of remote participants in the current call.
@property (copy, readonly) NSArray<ACSRemoteParticipant *> * remoteParticipants;

/// Id of the call
@property (retain, readonly) NSString * id;

/// Current state of the call
@property (readonly) ACSCallState state;

/// Containing code/subcode indicating how a call has ended
@property (retain, readonly) ACSCallEndReason * callEndReason;

/// Outgoing or Incoming depending on the Call Direction
@property (readonly) ACSCallDirection callDirection;

/// Whether the local microphone is muted or not.
@property (readonly) BOOL isMicrophoneMuted;

/// The identity of the caller
@property (retain, readonly) ACSCallerInfo * callerInfo;

/// Get a list of local video streams in the current call.
@property (copy, readonly) NSArray<ACSLocalVideoStream *> * localVideoStreams;

/// Indicates if recording is active in current call
@property (readonly) BOOL isRecordingActive;

/// Indicates if transcription is active in current call
@property (readonly) BOOL isTranscriptionActive;

/**
 * The delegate that will handle events from the ACSCall.
 */
@property(nonatomic, assign) id<ACSCallDelegate> delegate;

/// Mute local microphone.
-(void)muteWithCompletionHandler:(void (^ _Nonnull )(NSError * _Nullable error))completionHandler NS_SWIFT_NAME( mute(completionHandler:));

/// Unmute local microphone.
-(void)unmuteWithCompletionHandler:(void (^ _Nonnull )(NSError * _Nullable error))completionHandler NS_SWIFT_NAME( unmute(completionHandler:));

/// Send DTMF tone
-(void)sendDtmf:(ACSDtmfTone)tone withCompletionHandler:(void (^ _Nonnull )(NSError * _Nullable error))completionHandler NS_SWIFT_NAME( sendDtmf(tone:completionHandler:));

/// Start sharing video stream to the call
-(void)startVideo:(ACSLocalVideoStream *)stream withCompletionHandler:(void (^ _Nonnull )(NSError * _Nullable error))completionHandler NS_SWIFT_NAME( startVideo(stream:completionHandler:));

/// Stop sharing video stream to the call
-(void)stopVideo:(ACSLocalVideoStream *)stream withCompletionHandler:(void (^ _Nonnull )(NSError * _Nullable error))completionHandler NS_SWIFT_NAME( stopVideo(stream:completionHandler:));

/// HangUp a call
-(void)hangUp:(ACSHangUpOptions *)options withCompletionHandler:(void (^ _Nonnull )(NSError * _Nullable error))completionHandler NS_SWIFT_NAME( hangUp(options:completionHandler:));

/// Remove a participant from a call
-(void)removeParticipant:(ACSRemoteParticipant *)participant withCompletionHandler:(void (^ _Nonnull )(NSError * _Nullable error))completionHandler NS_SWIFT_NAME( remove(participant:completionHandler:));

/// Hold this call
-(void)holdWithCompletionHandler:(void (^ _Nonnull )(NSError * _Nullable error))completionHandler NS_SWIFT_NAME( hold(completionHandler:));

/// Resume this call
-(void)resumeWithCompletionHandler:(void (^ _Nonnull )(NSError * _Nullable error))completionHandler NS_SWIFT_NAME( resume(completionHandler:));

// Class extension begins for Call.
-(ACSRemoteParticipant *)addParticipant:(id<CommunicationIdentifier>)participant NS_SWIFT_NAME( add(participant:));
-(ACSRemoteParticipant *)addParticipant:(PhoneNumberIdentifier*) participant options:(ACSAddPhoneNumberOptions *)options NS_SWIFT_NAME( add(participant:options:));
// Class extension ends for Call.

@end

/// Describes a remote participant on a call
NS_SWIFT_NAME(RemoteParticipant)
@interface ACSRemoteParticipant : NSObject
-(nullable instancetype)init NS_UNAVAILABLE;
/// Deallocates the memory occupied by this object.
-(void)dealloc;

/// Private Preview Only: Display Name of the remote participant
@property (retain, readonly) NSString * displayName;

/// True if the remote participant is muted
@property (readonly) BOOL isMuted;

/// True if the remote participant is speaking
@property (readonly) BOOL isSpeaking;

/// Reason why participant left the call, contains code/subcode.
@property (retain, readonly) ACSCallEndReason * callEndReason;

/// Current state of the remote participant
@property (readonly) ACSParticipantState state;

/// Remote Video streams part of the current call
@property (copy, readonly) NSArray<ACSRemoteVideoStream *> * videoStreams;

/**
 * The delegate that will handle events from the ACSRemoteParticipant.
 */
@property(nonatomic, assign) id<ACSRemoteParticipantDelegate> delegate;

// Class extension begins for RemoteParticipant.
@property(nonatomic, readonly, nonnull) id<CommunicationIdentifier> identifier;
// Class extension ends for RemoteParticipant.

@end

/// Describes the reason for a call to end
NS_SWIFT_NAME(CallEndReason)
@interface ACSCallEndReason : NSObject
-(nullable instancetype)init NS_UNAVAILABLE;
/// Deallocates the memory occupied by this object.
-(void)dealloc;

/// The code
@property (readonly) int code;

/// The subcode
@property (readonly) int subcode;

@end

/// Video stream on remote participant (NOT SUPPORTED)
NS_SWIFT_NAME(RemoteVideoStream)
@interface ACSRemoteVideoStream : NSObject
-(nullable instancetype)init NS_UNAVAILABLE;
/// Deallocates the memory occupied by this object.
-(void)dealloc;

/// True when remote video stream is available.
@property (readonly) BOOL isAvailable;

/// MediaStream type of the current remote video stream (Video or ScreenShare).
@property (readonly) ACSMediaStreamType mediaStreamType;

/// Unique Identifier of the current remote video stream.
@property (readonly) int id;


@end

/// Describes a PropertyChanged event data
NS_SWIFT_NAME(PropertyChangedEventArgs)
@interface ACSPropertyChangedEventArgs : NSObject
-(nullable instancetype)init NS_UNAVAILABLE;
/// Deallocates the memory occupied by this object.
-(void)dealloc;

@end

/// Information about remote video streams added or removed (NOT SUPPORTED)
NS_SWIFT_NAME(RemoteVideoStreamsEventArgs)
@interface ACSRemoteVideoStreamsEventArgs : NSObject
-(nullable instancetype)init NS_UNAVAILABLE;
/// Deallocates the memory occupied by this object.
-(void)dealloc;

/// Remote video streams that have been added to the current call
@property (copy, readonly) NSArray<ACSRemoteVideoStream *> * addedRemoteVideoStreams;

/// Remote video streams that are no longer part of the current call
@property (copy, readonly) NSArray<ACSRemoteVideoStream *> * removedRemoteVideoStreams;

@end

/// Describes a ParticipantsUpdated event data
NS_SWIFT_NAME(ParticipantsUpdatedEventArgs)
@interface ACSParticipantsUpdatedEventArgs : NSObject
-(nullable instancetype)init NS_UNAVAILABLE;
/// Deallocates the memory occupied by this object.
-(void)dealloc;

/// List of Participants that were added
@property (copy, readonly) NSArray<ACSRemoteParticipant *> * addedParticipants;

/// List of Participants that were removed
@property (copy, readonly) NSArray<ACSRemoteParticipant *> * removedParticipants;

@end

/// Describes a LocalVideoStreamsUpdated event data
NS_SWIFT_NAME(LocalVideoStreamsUpdatedEventArgs)
@interface ACSLocalVideoStreamsUpdatedEventArgs : NSObject
-(nullable instancetype)init NS_UNAVAILABLE;
/// Deallocates the memory occupied by this object.
-(void)dealloc;

/// List of LocalVideoStream that were added
@property (copy, readonly) NSArray<ACSLocalVideoStream *> * addedStreams;

/// List of LocalVideoStream that were removed
@property (copy, readonly) NSArray<ACSLocalVideoStream *> * removedStreams;

@end

/// Property bag class for hanging up a call
NS_SWIFT_NAME(HangUpOptions)
@interface ACSHangUpOptions : NSObject
-(nonnull instancetype)init;

/// Deallocates the memory occupied by this object.
-(void)dealloc;

/// Use to determine whether the current call should be terminated for all participant on the call or not
@property BOOL forEveryone;

@end

/// Describes a CallsUpdated event
NS_SWIFT_NAME(CallsUpdatedEventArgs)
@interface ACSCallsUpdatedEventArgs : NSObject
-(nullable instancetype)init NS_UNAVAILABLE;
/// Deallocates the memory occupied by this object.
-(void)dealloc;

/// New calls being tracked by the library
@property (copy, readonly) NSArray<ACSCall *> * addedCalls;

/// Calls that are no longer tracked by the library
@property (copy, readonly) NSArray<ACSCall *> * removedCalls;

@end

/// Describes an incoming call
NS_SWIFT_NAME(IncomingCall)
@interface ACSIncomingCall : NSObject
-(nullable instancetype)init NS_UNAVAILABLE;
/// Deallocates the memory occupied by this object.
-(void)dealloc;

/// Describe the reason why a call has ended
@property (retain, readonly) ACSCallEndReason * callEndReason;

/// Information about the caller
@property (retain, readonly) ACSCallerInfo * callerInfo;

/// Id of the call
@property (retain, readonly) NSString * id;

/// Is inoming video enabled
@property (readonly) BOOL isVideoEnabled;

/**
 * The delegate that will handle events from the ACSIncomingCall.
 */
@property(nonatomic, assign) id<ACSIncomingCallDelegate> delegate;

/// Accept an incoming call
-(void)accept:(ACSAcceptCallOptions *)options withCompletionHandler:(void (^ _Nonnull )(ACSCall * _Nullable  value, NSError * _Nullable error))completionHandler NS_SWIFT_NAME( accept(options:completionHandler:));

/// Reject this incoming call
-(void)rejectWithCompletionHandler:(void (^ _Nonnull )(NSError * _Nullable error))completionHandler NS_SWIFT_NAME( reject(completionHandler:));

@end

/// This is the main class representing the entrypoint for the Calling SDK.
NS_SWIFT_NAME(CallClient)
@interface ACSCallClient : NSObject
-(nonnull instancetype)init;

/// Deallocates the memory occupied by this object.
-(void)dealloc;

/// Gets a device manager object that can be used to enumerates audio and video devices available for calls.
-(void)getDeviceManagerWithCompletionHandler:(void (^ _Nonnull )(ACSDeviceManager * _Nullable  value, NSError * _Nullable error))completionHandler NS_SWIFT_NAME( getDeviceManager(completionHandler:));

// Class extension begins for CallClient.
-(void)createCallAgentWithOptions:(CommunicationTokenCredential *) userCredential
                callAgentOptions:(ACSCallAgentOptions*) callAgentOptions
                withCompletionHandler:(void (^)(ACSCallAgent *clientAgent, NSError *error))completionHandler NS_SWIFT_NAME( createCallAgent(userCredential:options:completionHandler:));

-(void)createCallAgent:(CommunicationTokenCredential *) userCredential
                withCompletionHandler:(void (^)(ACSCallAgent *clientAgent,
                                                NSError * _Nullable error))completionHandler NS_SWIFT_NAME( createCallAgent(userCredential:completionHandler:));

@property (retain, nonnull) CommunicationTokenCredential* communicationCredential;
// Class extension ends for CallClient.

@end

/// Device manager
NS_SWIFT_NAME(DeviceManager)
@interface ACSDeviceManager : NSObject
-(nullable instancetype)init NS_UNAVAILABLE;
/// Deallocates the memory occupied by this object.
-(void)dealloc;

/// Get the list of currently connected video devices
@property (copy, readonly) NSArray<ACSVideoDeviceInfo *> * cameras;

/**
 * The delegate that will handle events from the ACSDeviceManager.
 */
@property(nonatomic, assign) id<ACSDeviceManagerDelegate> delegate;

@end

/// Describes a VideoDevicesUpdated event data
NS_SWIFT_NAME(VideoDevicesUpdatedEventArgs)
@interface ACSVideoDevicesUpdatedEventArgs : NSObject
-(nullable instancetype)init NS_UNAVAILABLE;
/// Deallocates the memory occupied by this object.
-(void)dealloc;

/// Video devicesRemote video streams that have been added to the current call
@property (copy, readonly) NSArray<ACSVideoDeviceInfo *> * addedVideoDevices;

/// Remote video streams that have been added to the current call
@property (copy, readonly) NSArray<ACSVideoDeviceInfo *> * removedVideoDevices;

@end

/// Options to be passed when rendering a Video
NS_SWIFT_NAME(RenderingOptions)
@interface ACSRenderingOptions : NSObject
-(nonnull instancetype)init:(ACSScalingMode)scalingMode NS_SWIFT_NAME( init(scalingMode:));

-(nullable instancetype)init NS_UNAVAILABLE;
/// Deallocates the memory occupied by this object.
-(void)dealloc;

/// Scaling mode for rendering the video.
@property ACSScalingMode scalingMode;

@end

