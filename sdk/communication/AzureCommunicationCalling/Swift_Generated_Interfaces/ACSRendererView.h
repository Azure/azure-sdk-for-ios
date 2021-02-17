//+-----------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
//
// Module name : ACSRendererView.h
//
//------------------------------------------------------------------------------

import Foundation
import UIKit

// Forward declaration as importing here causes cyclic dependency

open class RendererView : UIView {

    
    open func update(scalingMode: ScalingMode)

    open func dispose()

    open func isRendering() -> Bool
}
