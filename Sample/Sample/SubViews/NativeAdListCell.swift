//
//  NativeAdListCell.swift
//  Sample
//
//  Created by Enliple on 2023/02/16.
//

import UIKit

class NativeAdListCell: UITableViewCell {
    
    static let ID:String = "NativeAdListCell"
    
    @IBOutlet weak var labelTitle: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
 
    
    func setTitle(With index: IndexPath) {
        labelTitle.text = "Item Index : \(index.section)_\(index.row)"
    }
    
}
