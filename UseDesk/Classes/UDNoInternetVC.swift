//
//  UDNoInternetVC.swift
//  UseDesk_SDK_Swift-UseDesk
//

import Foundation
import UIKit

class UDNoInternetVC: UIViewController {
    
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var iconImageWC: NSLayoutConstraint!
    @IBOutlet weak var iconImageHC: NSLayoutConstraint!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var titleLabelTopC: NSLayoutConstraint!
    @IBOutlet weak var titleLabelLC: NSLayoutConstraint!
    @IBOutlet weak var titleLabelTC: NSLayoutConstraint!
    @IBOutlet weak var titleLabelBC: NSLayoutConstraint!
    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var textLabelLC: NSLayoutConstraint!
    @IBOutlet weak var textLabelTC: NSLayoutConstraint!
    
    weak var usedesk: UseDeskSDK?
    
    convenience init() {
        let nibName: String = "UDNoInternetVC"
        self.init(nibName: nibName, bundle: BundleId.bundle(for: nibName))
    }
    
    public func setViews() {
        guard usedesk != nil else {return}
        let noInternetStyle = usedesk!.configurationStyle.noInternetStyle
        view.backgroundColor = noInternetStyle.backgroundColor
        iconImageView.image = noInternetStyle.iconImage
        iconImageWC.constant = noInternetStyle.iconImageSize.width
        iconImageHC.constant = noInternetStyle.iconImageSize.height
        titleLabel.text = usedesk!.model.stringFor("NotInternet")
        titleLabel.font = noInternetStyle.titleFont
        titleLabel.textColor = noInternetStyle.titleColor
        titleLabelTopC.constant = noInternetStyle.titleMargin.top
        titleLabelLC.constant = noInternetStyle.titleMargin.left
        titleLabelTC.constant = noInternetStyle.titleMargin.right
        titleLabelBC.constant = noInternetStyle.titleMargin.bottom
        textLabel.text = usedesk!.model.stringFor("NotInternetCheck")
        textLabel.font = noInternetStyle.textFont
        textLabel.textColor = noInternetStyle.textColor
        textLabelLC.constant = noInternetStyle.textMargin.left
        textLabelTC.constant = noInternetStyle.textMargin.right
    }
    
}

