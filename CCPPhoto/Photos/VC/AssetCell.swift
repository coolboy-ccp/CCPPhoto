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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectImgV.layer.cornerRadius = 20
        selectImgV.layer.masksToBounds = true
        selectedNumLabel.layer.cornerRadius = 20
        selectedNumLabel.layer.masksToBounds = true
    }
    
    func setupContent(_ model: AssetModel) {

    }

}
