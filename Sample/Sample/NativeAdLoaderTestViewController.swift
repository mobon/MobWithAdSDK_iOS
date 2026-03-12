//
//  NativeAdLoaderTestViewController.swift
//  Sample
//
//  Created by Enliple on 2023/02/15.
//


import UIKit

import MobWithADSDKFramework


class NativeAdLoaderTestViewController: UIViewController {
    
    let NativeADCellID: String = "NativeADCell"
    
    
    @IBOutlet weak var tableView: UITableView!
    
    let mediaCodes:[String] = [
        "할당 받은 지면번호 1",
        "할당 받은 지면번호 2",
        "할당 받은 지면번호 3",
        "할당 받은 지면번호 4",
        "할당 받은 지면번호 5"
    ]
    
    lazy var nativeAdLoader:MobWithNativeAdLoader = MobWithNativeAdLoader(unitIds: mediaCodes, nibName: "NativeAdLoaderView", bundle: nil)
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nativeAdLoader.nativeAdLoaderDelegate = self
        
        tableView.register(UINib(nibName: "NativeAdListCell", bundle: nil), forCellReuseIdentifier: NativeAdListCell.ID)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: NativeADCellID)
        
        
        tableView.reloadData()
    }
    
    
    @IBAction func backButtonClicked(_ sender: Any) {
        dismiss(animated: true)
    }
    
}

//MARK: - AD Delegate

extension NativeAdLoaderTestViewController: MobWithNativeAdLoaderDelegate {
    
    
    func mobWithNativeAdViewDidReceivedAd(At index: IndexPath?) {
        if let indexPath = index {
            print("[TEST] mobWithNativeAdViewDidReceivedAd - \(indexPath.section):\(indexPath.row)")
        }
        else {
            print("[TEST] mobWithNativeAdViewDidReceivedAd - uknown")
        }
        
        tableView.reloadData()
    }
    
    func mobWithNativeAdViewDidFailToReceiveAd(At index: IndexPath?) {
        if let indexPath = index {
            print("[TEST] mobWithNativeAdViewDidFailToReceiveAd - \(indexPath.section):\(indexPath.row)")
        }
        else {
            print("[TEST] mobWithNativeAdViewDidFailToReceiveAd - uknown")
        }
    }
    
    
    func mobWithNativeAdViewClickedAd() {
    }
    
}



//MARK: - TableView DataSource & Delegate

extension NativeAdLoaderTestViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 500
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row % 5 == 4, nativeAdLoader.isLoadedAd(At: indexPath) {
            return NativeAdLoaderView.needHeight;
        }
        else {
            return UITableView.automaticDimension
        }
    }
    
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (indexPath.row % 5 == 4) {
            let cell:UITableViewCell? = tableView.dequeueReusableCell(withIdentifier: NativeADCellID, for: indexPath)
            
            print("[TEST] cellForRowAt - \(indexPath.section):\(indexPath.row)")
            if let adView = nativeAdLoader.loadAd(At: indexPath), nativeAdLoader.isLoadedAd(At: indexPath) {
                cell?.addSubview(adView)
                
                adView.translatesAutoresizingMaskIntoConstraints = false
                cell?.widthAnchor.constraint(equalTo: adView.widthAnchor).isActive = true
                cell?.heightAnchor.constraint(equalTo: adView.heightAnchor).isActive = true
                cell?.centerXAnchor.constraint(equalTo: adView.centerXAnchor).isActive = true
                cell?.centerYAnchor.constraint(equalTo: adView.centerYAnchor).isActive = true
                print("[TEST] Add Ad View - \(indexPath.section):\(indexPath.row)")
            }
            else {
                
                if nativeAdLoader.isFailLoadAd(At: indexPath) {
                    nativeAdLoader.retryLoadAd(At: indexPath)
                }
                
                cell?.subviews.forEach({ view in
                    (view as? NativeAdLoaderView)?.removeFromSuperview()
                })
            }
            
            
            return cell ?? UITableViewCell.init()
            
        }
        else {
            let cell:NativeAdListCell? = tableView.dequeueReusableCell(withIdentifier: NativeAdListCell.ID, for: indexPath) as? NativeAdListCell
            cell?.setTitle(With: indexPath)
            
            return cell ?? UITableViewCell.init()
        }
    }
    
    
}
