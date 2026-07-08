//
//  DirectNativeAdView.swift
//  Sample
//
//  Created by Enliple on 2026/07/02.
//

import UIKit
import MobWithADSDKFramework

class DirectNativeAdView: UIView {
    
    @IBOutlet weak var infoLogoImageView: UIImageView!   
    @IBOutlet weak var mediaView: UIView!
}




extension DirectNativeAdView: MobwithNativeAdViewRender {
    func getMediaView() -> UIView? {
        return mediaView
    }
    
    func getInfoLogoImageView() -> UIImageView? {
        return infoLogoImageView
    }
    
}
