//
//  AlbumsCell.swift
//  CCPPhoto
//
//  Created by 储诚鹏 on 2018/12/24.
//  Copyright © 2018 储诚鹏. All rights reserved.
//

import UIKit

class AlbumsCell: UITableViewCell {
    @IBOutlet weak var albumNameLabel: UILabel!
    @IBOutlet weak var headerImgV: UIImageView!
    @IBOutlet weak var numberLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func setContents(_ album: AlbumModel) {
        albumNameLabel.text = album.name
        numberLabel.text = "(\(album.count))"
        if let asset = album.result.lastObject {
            asset.image(60) { (image, _) in
                self.headerImgV.image = image
            }
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
