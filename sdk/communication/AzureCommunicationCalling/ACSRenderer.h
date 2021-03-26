//+-----------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
//
// Module name : ACSRenderer.h
//
//------------------------------------------------------------------------------

public protocol RendererDelegate : NSObjectProtocol {

    func videoStreamRenderer(didFailToStart renderer: VideoStreamRenderer)

    
    optional func videoStreamRenderer(didRenderFirstFrame renderer: VideoStreamRenderer)
}

open class VideoStreamRenderer : NSObject {

    
    public init(localVideoStream: LocalVideoStream) throws

    public init(remoteVideoStream: RemoteVideoStream) throws

    open func createView() throws -> RendererView

    open func createView(withOptions options: RenderingOptions?) throws -> RendererView

    open func dispose()

    
    open var size: StreamSize { get }

    unowned(unsafe) open var delegate: RendererDelegate?
}
