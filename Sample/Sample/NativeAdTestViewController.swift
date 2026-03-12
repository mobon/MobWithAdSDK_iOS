//
//  NativeAdTestViewController.swift
//  Sample
//
//  Created by Enliple on 2023/01/10.
//


import UIKit
import MobWithADSDKFramework



class NativeAdTestViewController: UIViewController {
    
    @IBOutlet weak var adContainerView: UIView!
    
    @IBOutlet weak var nativeAdRootView: UIView!
    
    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var infoLogoImageView: UIImageView!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var goButton: UIButton!
    
    @IBOutlet weak var unitIdTextField: UITextField!
    
    var nativeAdView:MMNativeAdView?
    
    let mediaCode:String = "{ 할당 받은 지면번호 }"
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        unitIdTextField.text = mediaCode
        
        nativeAdView = MMNativeAdView(bannerUnitId: mediaCode,
                                      adContainerView: adContainerView,
                                      nativeAdRootView: nativeAdRootView,
                                      adImageView: thumbnailImageView,
                                      logoImageView: logoImageView,
                                      titleLabel: titleLabel,
                                      descriptionLabel: descLabel,
                                      gotoSiteButton: goButton,
                                      infoLogoImageView: infoLogoImageView)
        nativeAdView?.rootViewController = self
        nativeAdView?.adDelegate = self
        
        self.view.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(touchedTextFieldOutSides(gesture: ))))
    }
    
    
    @objc func touchedTextFieldOutSides(gesture: UITapGestureRecognizer) {
        unitIdTextField.endEditing(true)
    }
}




//MARK: - Actions

extension NativeAdTestViewController {
    
    @IBAction func backButtonClicked(_ sender: Any) {
        dismiss(animated: true)
    }
    
    @IBAction func loadAdButtonClicked(_ sender: Any) {
        self.view.endEditing(true)
        self.titleLabel.text = "{Load Ad - Start}"
        
        nativeAdView?.bannerUnitID = unitIdTextField.text ?? mediaCode
        nativeAdView?.loadAd()
    }
    
}



//MARK: - AD Delegate

extension NativeAdTestViewController: MobWithADViewDelegate {
    
    func mobWithAdViewDidReceivedAd() {
        print(#function)
    }

    func mobWithAdViewDidFailToReceiveAd() {
        self.titleLabel.text = "{Load Ad - Fail}"
    }
    
    func mobWithAdViewClickedAd() {
        print(#function)
    }
    
}
