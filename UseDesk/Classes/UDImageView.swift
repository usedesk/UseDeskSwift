//
//  UDImageView.swift


import Foundation
import UIKit

protocol UDImageViewDelegate: class {
    func close()
}

class UDImageView: UIViewController, UIScrollViewDelegate {

    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var viewimage: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    weak var delegate: UDImageViewDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

//        let singleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.handleSingleTap(_:)))
//        singleTapGestureRecognizer.numberOfTapsRequired = 1
//        backView.addGestureRecognizer(singleTapGestureRecognizer)
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 6.0
        scrollView.delegate = self
        scrollView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.handleSingleTap(_:))))
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.viewimage
    }
    
    //********** VIEW TAPPED **********
    @objc func handleSingleTap(_ sender: UITapGestureRecognizer?) {
        delegate?.close()
    }
    
    
}

