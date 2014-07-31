//
//  CameraManager.swift
//  Bulb
//
//  Created by Brian Michel on 7/30/14.
//  Copyright (c) 2014 Brian Michel. All rights reserved.
//

import Foundation
import AVFoundation

class CameraManager : NSObject {
    private let captureSession: CaptureSession = CaptureSession()
    
    init() {
        super.init()
        
        var luminosity: LuminosityProcessor = LuminosityProcessor()
        
        luminosity.callback = {
            [unowned self] (processor: CaptureSessionProcessor, values: Dictionary<String, AnyObject>?) -> () in
            println(values)
        }
        
        captureSession.addProcessor(luminosity)
    }
    
    public var previewLayer : AVCaptureVideoPreviewLayer! {
        return captureSession.newPreviewLayer
    }
    
    public var position: CaptureDevicePosition? {
        return captureSession.position
    }
    
    public func switchCamera(position: CaptureDevicePosition) {
        captureSession.switchCameraInput(position) 
    }
    
}
