//
//  CaptureSessionProcessor.swift
//  Bulb
//
//  Created by Brian Michel on 7/30/14.
//  Copyright (c) 2014 Brian Michel. All rights reserved.
//

import Foundation
import AVFoundation
import CoreMedia

public typealias ProcessorCallback = ((CaptureSessionProcessor, Dictionary<String, AnyObject>?) -> ())?

public protocol CaptureSessionProcessor : AVCaptureVideoDataOutputSampleBufferDelegate {
    
    var processorQueue: dispatch_queue_t! { get }
    
    var processorName: String! { get }
    
    var callback: ProcessorCallback { get set }
}

class LuminosityProcessor : NSObject, CaptureSessionProcessor {
    
    public enum CallbackKeys : String {
        case Lux = "lux"
        case Buffer = "buffer"
    }
    
    var processorName: String! {
        return "luminosity"
    }

    var processorQueue: dispatch_queue_t! = dispatch_queue_create("com.bsm.processor.luminosity", DISPATCH_QUEUE_SERIAL)
    
    var callback: ProcessorCallback
    
    init() {
        
    }
    
    func captureOutput(captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, fromConnection connection: AVCaptureConnection!)  {
        if let callbackClosure = self.callback? {
            dispatch_async(self.processorQueue, {
                var description = CMSampleBufferGetFormatDescription(sampleBuffer)
                
                var format = CMSampleBufferGetFormatDescription(sampleBuffer)
                
                callbackClosure(self, nil)
            })
        }
    }
    
}