//
//  CaptureSession.swift
//  Bulb
//
//  Created by Brian Michel on 7/30/14.
//  Copyright (c) 2014 Brian Michel. All rights reserved.
//

import Foundation
import AVFoundation
import CoreMedia

public typealias CaptureDevicePosition = AVCaptureDevicePosition

class CaptureSession : NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    private let captureSessionQueue: dispatch_queue_t = dispatch_queue_create("com.bsm.bulb.capture_session", DISPATCH_QUEUE_SERIAL)
        
    private let captureSession: AVCaptureSession = AVCaptureSession()
    
    private var captureInput: AVCaptureDeviceInput?
    
    private var _connection: AVCaptureConnection?
    
    private var _processors: [String : CaptureSessionProcessor] = Dictionary<String, CaptureSessionProcessor>()
    
    public var connection: AVCaptureConnection? {
        return _connection
    }
    
    public var position: CaptureDevicePosition? {
        return captureInput?.device.position
    }
    
    public var newPreviewLayer: AVCaptureVideoPreviewLayer! {
        return AVCaptureVideoPreviewLayer(session: captureSession)
    }
    
    
    init()  {
        super.init()
        
        configureSession();
    }
    
    public func addProcessor(processor: CaptureSessionProcessor!) {
        _processors[processor.processorName] = processor;
    }
    
    public func removeProcessor(processor: CaptureSessionProcessor!) {
        _processors.removeValueForKey(processor.processorName)
    }
    
    public func switchCameraInput(position: CaptureDevicePosition!) -> Bool! {
        
        var didSwitchInputs: Bool = false
        
        if let device = AVCaptureDevice.captureDevice(position) as? AVCaptureDevice {
            if let input = self.videoInput(device) as? AVCaptureDeviceInput {
                self.captureSession.configure {
                    self.captureSession.removeInputs(AVMediaTypeVideo)
                    didSwitchInputs = self.captureSession.addInputIfPossible(input)
                    
                    if didSwitchInputs {
                        self.captureInput = input
                    }
                }
            }
        }
        
        return didSwitchInputs
    }
    
    //MARK: - Private -
    
    private func configureSession() {
        if switchCameraInput(CaptureDevicePosition.Back) {
            
            var output: AVCaptureVideoDataOutput = AVCaptureVideoDataOutput()
            output.videoSettings = [ kCVPixelBufferPixelFormatTypeKey : kCVPixelFormatType_32BGRA ]
            output.setSampleBufferDelegate(self, queue: captureSessionQueue)
            
            if captureSession.addOutputIfPossible(output) {
                _connection = output.connectionWithMediaType(AVMediaTypeVideo)
                captureSession.startRunning()
            }
            else {
                assert(false, "Unable to add video output")
            }
        }
        else {
            assert(false, "Unable to initialize capture session")
        }
    }
    
    private func videoInput(device: AVCaptureDevice!) -> AVCaptureDeviceInput? {
        var error: NSError?
        
        if let input = AVCaptureDeviceInput(device: device, error: &error) as AVCaptureDeviceInput? {
            return input
        }
        else {
            print(error)
            return nil
        }
    }
    
    //MARK: - AVCaptureVideoDataOutputSampleBufferDelegate
    func captureOutput(captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, fromConnection connection: AVCaptureConnection!)  {
        for (_, processor) in _processors {
            processor.captureOutput!(captureOutput, didOutputSampleBuffer: sampleBuffer, fromConnection: connection)
        }
    }
}

extension AVCaptureDevice {
    
    class var frontDevice: AVCaptureDevice? {
        return AVCaptureDevice.captureDevice(AVCaptureDevicePosition.Front)
    }
    
    class var backDevice: AVCaptureDevice? {
        return AVCaptureDevice.captureDevice(AVCaptureDevicePosition.Back)
    }
    
    class func captureDevice(position: AVCaptureDevicePosition) -> AVCaptureDevice? {
        var devices: [AnyObject]! = AVCaptureDevice.devicesWithMediaType(AVMediaTypeVideo)
        
        for device in devices {
            var captureDevice: AVCaptureDevice! = device as AVCaptureDevice
            if (captureDevice.position == position) {
                return captureDevice
            }
        }
        return nil
    }
    
}

extension AVCaptureSession {
    func addInputIfPossible(input: AVCaptureInput!) -> Bool {
        if self.canAddInput(input) {
            self.addInput(input)
            
            return true
        }
        
        return false
    }
    
    func addOutputIfPossible(output: AVCaptureOutput!) -> Bool {
        if self.canAddOutput(output) {
            self.addOutput(output)
            
            return true
        }
        
        return false
    }
    
    func configure(safeConfigurationClosure: () -> ()) {
        self.beginConfiguration()
        safeConfigurationClosure()
        self.commitConfiguration()
    }
    
    func removeInputs(mediaType: NSString!) {
        self.configure {
            for input in self.inputs {
                if let mediaInput = input as? AVCaptureInput {
                    for port in mediaInput.ports {
                        if let mediaPort = port as? AVCaptureInputPort {
                            if mediaPort.mediaType == mediaType {
                                self.removeInput(mediaInput)
                                break;
                            }
                        }
                    }
                }
            }
        }
    }
}

