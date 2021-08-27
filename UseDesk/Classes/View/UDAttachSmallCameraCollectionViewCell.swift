//
//  UDAttachSmallCameraCollectionViewCell.swift
//  UseDesk_SDK_Swift
//

import UIKit
import AVFoundation

class UDAttachSmallCameraCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var cameraPreviewView: UIView!
    
    var session: AVCaptureSession?
    var device: AVCaptureDevice?
    var input: AVCaptureDeviceInput?
    var output: AVCaptureMetadataOutput?
    var prevLayer: AVCaptureVideoPreviewLayer?
    
    func createSession() {
        if !(session?.isRunning ?? false) {
            session = AVCaptureSession()
            device = AVCaptureDevice.default(for: .video)
            
            if let _ = device,
                let _ = session {
                do {
                    input = try AVCaptureDeviceInput(device: device!)
                    session?.addInput(input!)
                    prevLayer = AVCaptureVideoPreviewLayer(session: session!)
                    prevLayer?.frame.size = cameraPreviewView.frame.size
                    prevLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
                    cameraPreviewView.layer.addSublayer(prevLayer!)
                    session?.startRunning()
                } catch {
                    print(error)
                }
            }
        } else {
            prevLayer?.frame.size = cameraPreviewView.frame.size
        }
    }
    
    func stopSession() {
        session?.stopRunning()
    }
}

