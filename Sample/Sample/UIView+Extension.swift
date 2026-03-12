//
//  UIView+Extension.swift
//  KeyboardSDKCore
//
//  Created by enlipleIOS1 on 2021/07/08.
//

import UIKit


extension UIView {
    
    public func showDHToast(message : String, showIcon:Bool = false, _ callback:(() -> Void)? = nil) {
        if let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
            let keyWindow = scene.windows.first(where: { $0.isKeyWindow })
            keyWindow?.rootViewController?.view.makeDHToast(message, callback)
        }
    }
    
    
    func makeDHToast(_ message: String,
                     font: UIFont = UIFont.systemFont(ofSize: 14.0, weight: .regular),
                     backgroundColor:UIColor = UIColor.black.withAlphaComponent(0.6),
                     _ callback:(() -> Void)? = nil)
    {
        let toastLabel = DHPaddedLabel(frame: .zero)
        toastLabel.backgroundColor = .clear
        toastLabel.textColor = UIColor.white
        toastLabel.font = font
        toastLabel.textAlignment = .left
        toastLabel.text = message
        toastLabel.numberOfLines = 0
        
        
        let toastView:UIView = UIView.init(frame: .zero)
        toastView.backgroundColor = backgroundColor
        toastView.layer.cornerRadius = 5.0
        toastView.clipsToBounds = true
        
        
        let contentView:UIView = UIView.init(frame: .zero)
        contentView.alpha = 1.0
        contentView.backgroundColor = .clear
        
        toastView.addSubview(toastLabel)
        contentView.addSubview(toastView)
        
        self.addSubview(contentView)
        
        
        toastView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        toastLabel.translatesAutoresizingMaskIntoConstraints = false
        
        var allConstraints: [NSLayoutConstraint] = []
        let views: [String: Any] = [
            "toastView": toastView,
            "contentView": contentView,
            "toastLabel": toastLabel
        ]
        
        let vPointLabelConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|[toastLabel]|", metrics: nil, views: views)
        let hPointLabelConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|-20-[toastLabel]-20-|", metrics: nil, views: views)
        let hPointLabelConstraints2 = NSLayoutConstraint.constraints(withVisualFormat: "H:|[toastView]|", metrics: nil, views: views)
        let vPointLabelConstraints2 = NSLayoutConstraint.constraints(withVisualFormat: "V:|[toastView(>=56)]|", metrics: nil, views: views)
        
        allConstraints += vPointLabelConstraints
        allConstraints += hPointLabelConstraints
        allConstraints += vPointLabelConstraints2
        allConstraints += hPointLabelConstraints2
        NSLayoutConstraint.activate(allConstraints)

        contentView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        contentView.widthAnchor.constraint(lessThanOrEqualToConstant: self.frame.width - 48).isActive = true
        contentView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -1 * (20.0 + self.layoutMargins.bottom)).isActive = true
        
        
                
        
        UIView.animate(withDuration: 0.5, delay: 1.5, options: .curveEaseOut, animations: {
            contentView.alpha = 0.0
        },
        completion: {(isCompleted) in
            contentView.removeFromSuperview()
            toastView.removeFromSuperview()
            toastLabel.removeFromSuperview()
            
            callback?()
        })
    }
    
}
