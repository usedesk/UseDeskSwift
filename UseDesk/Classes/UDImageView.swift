//
//  UDImageView.swift


import Foundation
import UIKit
import AVKit

protocol UDImageViewDelegate: class {
    func close()
}

class UDImageView: UIViewController, UIScrollViewDelegate {

    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var viewimage: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    weak var delegate: UDImageViewDelegate?
    
    convenience init() {
        let nibName: String = "UDImageView"
        self.init(nibName: nibName, bundle: BundleId.bundle(for: nibName))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 6.0
        scrollView.delegate = self
        scrollView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.handleSingleTap(_:))))
    }
    
    func showImage(image: UIImage) {
        scrollView.alpha = 1
        viewimage.image = image
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.viewimage
    }
    
    @objc func handleSingleTap(_ sender: UITapGestureRecognizer?) {
        delegate?.close()
    }
    
}

