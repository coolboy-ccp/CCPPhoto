//
//  ViewController.swift
//  CCPPhoto
//
//  Created by 储诚鹏 on 2018/12/12.
//  Copyright © 2018 储诚鹏. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    @IBAction func image(_ sender: Any) {
        self.navigationController?.pushViewController(ImagePicker(), animated: true)
    }
    
    @IBAction func video(_ sender: Any) {
    }
    
    @IBAction func imageVideo(_ sender: Any) {
    }
}

