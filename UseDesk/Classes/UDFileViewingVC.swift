//
//  UDFileViewingVC.swift


import Foundation
import UIKit
import AVKit

enum UDTypeFile {
    case image
    case video
    case file
}

class UDFileViewingVC: UIViewController, UIScrollViewDelegate {
    
    @IBOutlet weak var viewimage: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var videoView: UIView!
    @IBOutlet weak var videoPreviousImage: UIImageView!
    @IBOutlet weak var fileView: UIView!
    @IBOutlet weak var fileNameLabel: UILabel!
    @IBOutlet weak var fileSizeLabel: UILabel!
    @IBOutlet weak var bottomViewHC: NSLayoutConstraint!

    var filePath: String?
    var typeFile: UDTypeFile = .image
    var videoImage: UIImage?
    var fileName: String = ""
    var fileSize: String = ""
    
    private let playerVC = AVPlayerViewController()
    
    convenience init() {
        let nibName: String = "UDFileViewingVC"
        self.init(nibName: nibName, bundle: BundleId.bundle(for: nibName))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 6.0
        scrollView.delegate = self
    }
    
    func updateState() {
        if videoImage == nil {
            videoImage = UIImage.named("udVideoDefault") 
        }
        switch typeFile {
        case .image:
            scrollView.alpha = 1
            viewimage.alpha = 1
            videoView.alpha = 0
            fileView.alpha = 0
        case .video:
            scrollView.alpha = 0
            viewimage.alpha = 0
            videoView.alpha = 1
            fileView.alpha = 0
            videoPreviousImage.image = videoImage!
        case .file:
            scrollView.alpha = 0
            viewimage.alpha = 0
            videoView.alpha = 0
            fileView.alpha = 1
            fileNameLabel.text = fileName
            fileSizeLabel.text = fileSize
        }
    }
    
    func setBottomViewHC(_ safeAreaInsetsBottom :CGFloat) {
        bottomViewHC.constant = 44 + safeAreaInsetsBottom
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.viewimage
    }
    
    @IBAction func shareButtonAction(_ sender: Any) {
        guard filePath != nil else {return}
        let activityVC = UIActivityViewController(activityItems: [URL(fileURLWithPath: filePath!)], applicationActivities: nil)
        activityVC.popoverPresentationController?.sourceView = self.view
        activityVC.popoverPresentationController?.sourceRect = CGRect(x: 0, y: self.view.frame.height, width: self.view.frame.width, height: 0)
        self.present(activityVC, animated: true, completion: nil)
    }
    
    @IBAction func playVideo(_ sender: Any) {
        guard filePath != nil else {return}
        let videoURL = URL(fileURLWithPath: filePath!)
        let player = AVPlayer(url: videoURL)
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        self.present(playerViewController, animated: true) {
            playerViewController.player?.play()
        }
    }
}

