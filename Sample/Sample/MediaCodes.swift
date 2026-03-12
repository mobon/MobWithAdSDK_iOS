//
//  MediaCodes.swift
//  Sample
//
//  Created by DHLee on 2024/03/29
//  Copyright ⓒ 2024 DHLee. All rights reserved.
//
    

import Foundation


enum MediaCodes: String {
    case mediaCode320x50 = "{ 할당 받은 320x50용 지면번호 }"
    case mediaCode320x100 = "{ 할당 받은 320x100용 지면번호 }"
    case mediaCode300x250 = "{ 할당 받은 300x250용 지면번호 }"
    case mediaCodeInterstitial = "{ 할당 받은 전면광고용 지면번호 }"
    case mediaCodeRewardAd = "{ 할당 받은 리워드용 지면번호 }"
    
    var string: String {
        return self.rawValue
    }
}
