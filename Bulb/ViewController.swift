//
//  ViewController.swift
//  Bulb
//
//  Created by Brian Michel on 7/30/14.
//  Copyright (c) 2014 Brian Michel. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    
    private let cameraManager: CameraManager! = CameraManager()
    
    public var array: [Int] = [Int]()
                            
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for object: Int in array {
            
        }
        
        if  let previewLayer = cameraManager.previewLayer {
            previewLayer.frame = self.view.bounds
            
            self.view.layer.addSublayer(previewLayer)
            
            var tap = UITapGestureRecognizer(target: self, action: "didTap:")
            self.view.addGestureRecognizer(tap)
        }
        else {
            print("Can't get a preview layer")
        }
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    func didTap(gesture: UITapGestureRecognizer!) {
        if gesture.state == UIGestureRecognizerState.Ended {
            if let position: CaptureDevicePosition = cameraManager.position {
                switch position {
                case .Back:
                    cameraManager.switchCamera(CaptureDevicePosition.Front)
                case .Front:
                    cameraManager.switchCamera(CaptureDevicePosition.Back)
                case .Unspecified:
                    println("Can't switch from Unspecified")
                }
            }
        }
    }

}

