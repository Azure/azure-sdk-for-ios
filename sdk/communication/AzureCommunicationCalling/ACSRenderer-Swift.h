//+-----------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
//
// Module name : ACSRenderer.h
//
//------------------------------------------------------------------------------

public protocol RendererDelegate : NSObjectProtocol {

    func videoStreamRenderer(didFailToStartRenderer renderer: VideoStreamRenderer)

    
    optional func videoStreamRenderer(didRenderFirstFrame renderer: VideoStreamRenderer)
}

open class VideoStreamRenderer : NSObject {

    
    public init(localVideoStream: ACSLocalVideoStream) throws

    public init(remoteVideoStream: ACSRemoteVideoStream) throws

    open func createView() throws -> RendererView

    open func createView(with options: ACSRenderingOptions?) throws -> RendererView

    open func dispose()

    
    open var size: StreamSize { get }

    unowned(unsafe) open var delegate: RendererDelegate?
}
