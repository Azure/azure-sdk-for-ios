//+-----------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
//
// Module name : ACSRenderer.h
//
//------------------------------------------------------------------------------

#import "ACSRendererView.h"
#import "ACSStreamSize.h"

@class ACSLocalVideoStream;
@class ACSRenderingOptions;
@class ACSRemoteVideoStream;

@class ACSVideoStreamRenderer;

NS_SWIFT_NAME(RendererDelegate)
@protocol ACSRendererDelegate <NSObject>
- (void)rendererFailedToStart:(ACSVideoStreamRenderer* _Nonnull) renderer NS_SWIFT_NAME( videoStreamRenderer(didFailToStartRenderer:));
@optional
- (void)onFirstFrameRendered:(ACSVideoStreamRenderer* _Nonnull) renderer NS_SWIFT_NAME( videoStreamRenderer(didRenderFirstFrame:));
@end

NS_SWIFT_NAME(VideoStreamRenderer)
@interface ACSVideoStreamRenderer : NSObject
-(nonnull instancetype)init NS_UNAVAILABLE;
-(instancetype _Nonnull)initWithLocalVideoStream:(ACSLocalVideoStream*_Nonnull) localVideoStream
                                       withError:(NSError*_Nullable*_Nonnull) error __attribute__((swift_error(nonnull_error)))
        NS_SWIFT_NAME( init(localVideoStream:));
-(instancetype _Nonnull)initWithRemoteVideoStream:(ACSRemoteVideoStream*_Nonnull) remoteVideoStream
                                        withError:(NSError*_Nullable*_Nonnull) error __attribute__((swift_error(nonnull_error)))
        NS_SWIFT_NAME( init(remoteVideoStream:));
-(ACSRendererView* _Nonnull)createView:(NSError*_Nullable*_Nonnull) error __attribute__((swift_error(nonnull_error)))
        NS_SWIFT_NAME( createView());
-(ACSRendererView* _Nonnull)createViewWithOptions:(ACSRenderingOptions*_Nullable) options
                                        withError:(NSError*_Nullable*_Nonnull) error __attribute__((swift_error(nonnull_error)))
        NS_SWIFT_NAME( createView(with:));
-(void)dispose;

@property(readonly, nonnull) ACSStreamSize* size;
@property(nonatomic, assign, nullable) id<ACSRendererDelegate> delegate;

@end
