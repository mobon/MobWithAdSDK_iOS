//
//  NativeAdLoaderView.swift
//  Sample
//
//  Created by Enliple on 2023/02/16.
//

import UIKit
import MobWithADSDKFramework

class NativeAdLoaderView: UIView {
    static let needHeight:CGFloat = 347.0
    
    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var infoLogoImageView: UIImageView!
    
    @IBOutlet weak var adTitleLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var goButton: UIButton!
    
    
}




extension NativeAdLoaderView: MobwithNativeAdViewRender {
    
    func getAdImageView() -> UIImageView? {
        return thumbnailImageView
    }
    
    func getAdLogoImageView() -> UIImageView? {
        return logoImageView
    }
    
    func getAdTitleLabel() -> UILabel? {
        return adTitleLabel
    }
    
    func getAdDescriptionLabel() -> UILabel? {
        return descLabel
    }
    
    func getGoToSiteButton() -> UIButton? {
        return goButton
    }
    
    func getInfoLogoImageView() -> UIImageView? {
        return infoLogoImageView
    }
    
}
