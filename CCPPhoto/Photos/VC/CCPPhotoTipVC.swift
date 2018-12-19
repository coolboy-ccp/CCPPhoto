//
//  CCPPhotoTipVC.swift
//  CCPPhoto
//
//  Created by 储诚鹏 on 2018/12/12.
//  Copyright © 2018 储诚鹏. All rights reserved.
//

import UIKit

class CCPPhotoTipVC: UIViewController {
    @IBOutlet weak var tipLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tipLabel.text = "允许\(appName())访问您的手机相册"
    }

    @IBAction func setting(_ sender: Any) {
        CCPPhotoAuthorization.toSetting()
    }
    
    private func appName() -> String {
        if let dic = Bundle.main.localizedInfoDictionary {
            let name = dic["CFBundleDisplayName"] ?? dic["CFBundleName"]
            return name as! String
        }
        return ""
    }
    

}
