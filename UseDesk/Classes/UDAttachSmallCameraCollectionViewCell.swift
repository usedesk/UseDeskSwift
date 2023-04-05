//
//  UDAttachSmallCameraCollectionViewCell.swift
//  UseDesk_SDK_Swift
//

import UIKit
import AVFoundation

class UDAttachSmallCameraCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var cameraPreviewView: UIView!
    
    public var orientation: AVCaptureVideoOrientation = .portrait
    
    private var session: AVCaptureSession?
    private var device: AVCaptureDevice?
    private var input: AVCaptureDeviceInput?
    private var output: AVCaptureMetadataOutput?
    private var prevLayer: AVCaptureVideoPreviewLayer?
    
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
                    prevLayer?.connection?.videoOrientation = orientation
                    cameraPreviewView.layer.addSublayer(prevLayer!)
                    DispatchQueue.global(qos: .background).async {
                        self.session?.startRunning()
                    }
                } catch {}
            }
        } else {
            prevLayer?.connection?.videoOrientation = orientation
            prevLayer?.frame.size = cameraPreviewView.frame.size
            self.setNeedsLayout()
            self.layoutIfNeeded()
        }
    }
    
    func stopSession() {
        session?.stopRunning()
    }
}

