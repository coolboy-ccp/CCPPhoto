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
    @IBOutlet weak var selectedNumLabel: UILabel!
    
    private var model: AssetModel?
    var selectedIdx: Int = 0 {
        didSet {
            selectedNumLabel.isHidden = selectedIdx == 0
            selectedNumLabel.text = "\(selectedIdx)"
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectedNumLabel.layer.cornerRadius = 12
        selectedNumLabel.layer.masksToBounds = true
        selectedIdx = 0
        NotificationCenter.default.addObserver(self, selector: #selector(reloadSelectIdx(_:)), name: .reloadSelectedIdx, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc private func reloadSelectIdx(_ noti: Notification) {
        guard let userinfo = noti.userInfo as? [String: [String]] else { return }
        guard let model = self.model else { return }
        guard let selectedIdxs = userinfo["selectedIdxs"] else { return }
        if let idx = selectedIdxs.firstIndex(of: model.localId) {
            self.selectedIdx = idx + 1
        }
        else {
            self.selectedIdx = 0
        }
    }
    
    func setupContent(_ model: AssetModel) {
        self.model = model
        model.asset.image(self.bounds.width) { (image, info) in
            self.contenImgV.image = image
        }
    }

}
