//+-----------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
//
// Module name : ACSRenderer.h
//
//------------------------------------------------------------------------------

public protocol RendererDelegate : NSObjectProtocol {

    func rendererFailedToStart()

    
    optional func onFirstFrameRendered()
}

open class Renderer : NSObject {

    
    public init(localVideoStream: LocalVideoStream) throws

    public init(remoteVideoStream: RemoteVideoStream) throws

    open func createView() throws -> RendererView

    open func createView(with options: RenderingOptions?) throws -> RendererView

    open func dispose()

    
    open var size: StreamSize { get }

    unowned(unsafe) open var delegate: RendererDelegate?
}
