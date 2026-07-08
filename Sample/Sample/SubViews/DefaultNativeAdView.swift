//
//  DefaultNativeAdView.swift
//  Sample
//
//  Created by Enliple on 2026/07/02.
//

import UIKit
import MobWithADSDKFramework

class DefaultNativeAdView: UIView {
    
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var infoLogoImageView: UIImageView!
    
    @IBOutlet weak var mediaView: UIView!
    
    
    @IBOutlet weak var adTitleLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var goButton: UIButton!
}


extension DefaultNativeAdView: MobwithNativeAdViewRender {
    
    func getMediaView() -> UIView? {
        return mediaView
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
