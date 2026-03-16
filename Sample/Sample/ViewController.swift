//
//  ViewController.swift
//  Sample
//
//  Created by Enliple on 2022/09/23.
//

import UIKit
import MobWithADSDKFramework
import AdFitSDK

import AdSupport
import AppTrackingTransparency


class ViewController: UIViewController {
    
    private let coupangSubID:String = "testios1"
    
    var mobWithAdView:MobWithAdView?
    
    var interstitialAd: MobWithInterstitailAd?
    var rewardAd: MobWithRewardAd?
    
    
    @IBOutlet weak var segmentAdType: UISegmentedControl!
    @IBOutlet weak var segmentFullMode: UISegmentedControl!
    @IBOutlet weak var idfaLabel: UILabel!
    @IBOutlet weak var versionLabel: UILabel!
    
    @IBOutlet weak var textFieldUnitID: UITextField!
    
    
    
    let dateFormatter:DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatter.locale = Locale.current
        return formatter
    }()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let version:String = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
        versionLabel.text = "App Version : \(version)"
        
        idfaLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tappedIdfaLabel(gesture:))))
        
        MobWithADSDK.standard.enableLog(true)
        MobWithADSDK.standard.setLevelPlaySDKAppKey("22180584d") //200aec285, 20196aec5. 22180584d
        MobWithADSDK.standard.setPangleAppId(appId: "8705357")    //8705357, 8659257
        MobWithADSDK.standard.setDTExchangeAppID(appId: "220419")
        MobWithADSDK.standard.setInMobiAccountId(accountId: "88ede8a9e7294a59b605b109444c2a9f")
        
        MobWithADSDK.standard.enableLog(true)
        
        
        
        segmentAdType.selectedSegmentIndex = 0

        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(excuteTapBackgroundView)))
        
        interstitialAd = MobWithInterstitailAd.init()
        interstitialAd?.rootViewController = self
        interstitialAd?.adDelegate = self
        interstitialAd?.unitId = MediaCodes.mediaCode300x250.rawValue
        
        
        rewardAd = MobWithRewardAd.init()
        rewardAd?.rootViewController = self
        rewardAd?.adDelegate = self
        rewardAd?.unitId = MediaCodes.mediaCodeRewardAd.rawValue
        
        
        loadAd()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if #available(iOS 14, *) {
            if ATTrackingManager.trackingAuthorizationStatus == .notDetermined {
                ATTrackingManager.requestTrackingAuthorization { status in
                    self.setIdfa()
                }
            }
            else {
                self.setIdfa()
            }
        }
        else {
            self.setIdfa()
        }
        
    }
    
    func loadAd() {
        DispatchQueue.global().async {
            self.mobWithAdView?.loadAd()
        }
    }
    
    
    func setIdfa() {
        DispatchQueue.main.async {
            self.idfaLabel.text = ASIdentifierManager.shared().advertisingIdentifier.uuidString
        }
    }
    
    
    func createAdViewAndLoad() {
        
//        BizBoardTemplate.defaultEdgeInset = UIEdgeInsets.init(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
        
        let customUnitID: String = textFieldUnitID.text ?? ""
        let positionY:CGFloat = 130.0
        
        if let _ = mobWithAdView {
            switch segmentAdType.selectedSegmentIndex {
            case 1:     // 300x250배너로 동작
                let width:CGFloat = 300
                mobWithAdView?.frame = CGRect(x: (UIScreen.main.bounds.width - width) / 2.0, y: positionY, width: width, height: 250)
                mobWithAdView?.bannerType = .BANNER_300x250
                mobWithAdView?.bannerUnitID = (customUnitID.isEmpty ? MediaCodes.mediaCode300x250.string : customUnitID)
                break
                
            case 2:
                let width = UIScreen.main.bounds.width
                mobWithAdView?.frame = CGRect(x: 0, y: positionY, width: width, height: 150)
                mobWithAdView?.bannerType = .BANNER_320x100
                mobWithAdView?.bannerUnitID = (customUnitID.isEmpty ? MediaCodes.mediaCode320x100.string : customUnitID)
                break
                
            default:    // case 0을 포함, 320x50배너로 동작
                let width = UIScreen.main.bounds.width
                mobWithAdView?.frame = CGRect(x: 0, y: positionY, width: width, height: 61)
                mobWithAdView?.bannerType = .BANNER_320x50
                mobWithAdView?.bannerUnitID = (customUnitID.isEmpty ? MediaCodes.mediaCode320x50.string : customUnitID)
                break
            }
        }
        else {
            switch segmentAdType.selectedSegmentIndex {
            case 1:     // 300x250배너로 동작
                let width:CGFloat = 300
                mobWithAdView = MobWithAdView.init(CGRect(x: (UIScreen.main.bounds.width - width) / 2.0, y: positionY, width: width, height: 250),
                                                   type: .BANNER_300x250,
                                                   bannerUnitId: (customUnitID.isEmpty ? MediaCodes.mediaCode300x250.string : customUnitID))
                break
                
            case 2:
                let width = UIScreen.main.bounds.width
                mobWithAdView = MobWithAdView.init(CGRect(x: 0, y: positionY, width: width, height: 150),
                                                   type: .BANNER_320x100,
                                                   bannerUnitId: (customUnitID.isEmpty ? MediaCodes.mediaCode320x100.string : customUnitID))
                break
                
            default:    // case 0을 포함, 320x50배너로 동작
                let width = UIScreen.main.bounds.width
                mobWithAdView = MobWithAdView.init(CGRect(x: 0, y: positionY, width: width, height: 61),
                                                   type: .BANNER_320x50,
                                                   bannerUnitId: (customUnitID.isEmpty ? MediaCodes.mediaCode320x50.string : customUnitID))
                
                break
            }
            
            mobWithAdView?.clipsToBounds = true
            mobWithAdView?.adDelegate = self
            mobWithAdView?.rootViewController = self
            mobWithAdView?.backgroundColor = UIColor.init(white: 1.0, alpha: 0.5)
            
            // 불상사 방지...
            guard let mobWithAdView = mobWithAdView else {
                return
            }
            
            self.view.addSubview(mobWithAdView)
        }
        
//        mobWithAdView?.interval = 10
//
//        mobWithAdView?.stop()
//        mobWithAdView?.restart()
        
        mobWithAdView?.fillMode = (segmentFullMode.selectedSegmentIndex == 0)
        loadAd()
    }
    
    @objc func excuteTapBackgroundView() {
        self.view.endEditing(true)
    }
    
    
    func printLog(_ message: Any) {
        print("[\(dateFormatter.string(from: Date()))][Sample] \(message)")
    }
    
}



//MARK: - Actions

extension ViewController {
    
    @IBAction func clickedLoadAdButton(_ sender: Any) {
        createAdViewAndLoad()
    }
    
    @IBAction func clickedNextButton(_ sender: Any) {
//        loadAd()
        mobWithAdView?.showNextAd()
    }
    
    @IBAction func clickedTestNativeADViewButton(_ sender: Any) {
        let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "NativeAdTestViewController")
        vc.modalPresentationStyle = .overCurrentContext
        self.present(vc, animated: true)
    }
    
    @IBAction func clickedTestNativeADLoaderButton(_ sender: Any) {
        let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "NativeAdLoaderTestViewController")
        vc.modalPresentationStyle = .overCurrentContext
        self.present(vc, animated: true)
    }
    
    
    @IBAction func loadInterstitialButton(_ sender: Any) {
        let customUnitID: String = textFieldUnitID.text ?? ""
        if customUnitID.isEmpty {
            interstitialAd?.unitId = MediaCodes.mediaCodeInterstitial.rawValue
        }
        else {
            interstitialAd?.unitId = customUnitID
        }
        interstitialAd?.loadAd()
    }
    
    @IBAction func showInterstitialButton(_ sender: Any) {
        if interstitialAd?.isLoaded() ?? false {
            interstitialAd?.show()
        }
    }
    
    
    @IBAction func loadRewardAdButton(_ sender: Any) {
        let customUnitID: String = textFieldUnitID.text ?? ""
        if customUnitID.isEmpty {
            rewardAd?.unitId = MediaCodes.mediaCodeRewardAd.rawValue
        }
        else {
            rewardAd?.unitId = customUnitID
        }
        
        rewardAd?.loadAd()
    }
    
    @IBAction func showRewardAdButton(_ sender: Any) {
        if rewardAd?.isLoaded() ?? false {
            rewardAd?.show()
        }
    }
    
    
    
    
    @objc func tappedIdfaLabel(gesture: UITapGestureRecognizer) {
        UIPasteboard.general.string = self.idfaLabel.text
    }
    
}


//MARK: - MobWithADViewDelegate

extension ViewController: MobWithADViewDelegate {

    func mobWithAdViewDidReceivedAd() {
        // 광고 수신 성공
        printLog(#function)
    }

    func mobWithAdViewDidFailToReceiveAd() {
        // 광고 수신 실패
        printLog(#function)
        self.view.showDHToast(message: "배너 광고 수신 실패")
    }
    
    func mobWithAdViewClickedAd() {
        // 광고 배너 클릭시 발생
        printLog(#function)
    }
    
    func mobWithAdViewDidOpend() {
        // 전면배너 광고 오픈시 발생
        printLog(#function)
    }
}



extension ViewController: MobWithIntersitialAdDelegate {
    
    func mobWithIntersitialAdDidReceived(_ interstitialAd: MobWithInterstitailAd?) {
        // 광고 수신 성공
        printLog(#function)
        self.view.showDHToast(message: "전면 광고 수신 성공 - \(interstitialAd?.unitId ?? "")")
    }

    func mobWithIntersitialAdDidFailToReceive(_ interstitialAd: MobWithInterstitailAd?) {
        // 광고 수신 실패
        printLog(#function)
        self.view.showDHToast(message: "전면 광고 수신 실패 - \(interstitialAd?.unitId ?? "")")
    }

    func mobWithIntersitialAdClicked(_ interstitialAd: MobWithInterstitailAd?) {
        // 광고 클릭시 발생
        printLog(#function)
    }

    func mobWithIntersitialAdDidOpend(_ interstitialAd: MobWithInterstitailAd?) {
        // 전면광고 화면에 출력될때 발생
        printLog(#function)
    }
    
    func mobWithIntersitialAdDidClosed(_ interstitialAd: MobWithInterstitailAd?) {
        printLog(#function)
    }
    
    func mobWithIntersitialAdDidOpenFailed(_ interstitialAd: MobWithInterstitailAd?) {
        printLog(#function)
    }
}




extension ViewController: MobWithRewardAdDelegate {
    
    
    
    func mobWithRewardAdDidReceived(_ rewardAd: MobWithRewardAd?) {
        printLog(#function)
        self.view.showDHToast(message: "리워드 광고 수신 성공 - \(rewardAd?.unitId ?? "")")
    }
    
    func mobWithRewardAdDidFailToReceive(_ rewardAd: MobWithRewardAd?) {
        printLog(#function)
        self.view.showDHToast(message: "리워드 광고 수신 실패 - \(rewardAd?.unitId ?? "")")
    }
    
    func mobWithRewardAdDidOpend(_ rewardAd: MobWithRewardAd?) {
        printLog(#function)
    }
    
    
    func mobWithRewardAdDidOpenFailed(_ rewardAd: MobWithRewardAd?) {
        printLog(#function)
    }
    
    func mobWithRewardAdClicked(_ rewardAd: MobWithRewardAd?) {
        printLog(#function)
    }
    
    
    func mobWithRewardAdCanReward(_ rewardAd: MobWithRewardAd?) {
        printLog(#function)
    }
    
    func mobWithRewardAdClosed(_ rewardAd: MobWithRewardAd?) {
        printLog(#function)
    }
    
}
