//
//  AssetCell.swift
//  CCPPhoto
//
//  Created by 储诚鹏 on 2018/12/18.
//  Copyright © 2018 储诚鹏. All rights reserved.
//

import UIKit

class AssetCell: UICollectionViewCell {
    @IBOutlet weak var contenImgV: UIImageView!
    @IBOutlet weak var selectImgV: UIImageView!
    @IBOutlet weak var selectedNumLabel: UILabel!
    
    var selectedIdx: Int = 0 {
        didSet {
            selectedNumLabel.isHidden = selectedIdx == 0
            selectedNumLabel.text = "\(selectedIdx)"
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectImgV.layer.cornerRadius = 12
        selectImgV.layer.masksToBounds = true
        selectedNumLabel.layer.cornerRadius = 12
        selectedNumLabel.layer.masksToBounds = true
    }
    
    func setupContent(_ model: AssetModel) {
        model.asset.image(self.bounds.width) { (image, info) in
            self.contenImgV.image = image
        }
    }

}
