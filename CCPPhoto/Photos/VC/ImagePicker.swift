//
//  ImagePicker.swift
//  CCPPhoto
//
//  Created by 储诚鹏 on 2018/12/18.
//  Copyright © 2018 储诚鹏. All rights reserved.
//

import UIKit

class ImagePicker: UIViewController {
    @IBOutlet weak var listCollection: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "照片"
        setNav()

        self.automaticallyAdjustsScrollViewInsets = true
        listCollection.register(UINib(nibName: "AssetCell", bundle: nil), forCellWithReuseIdentifier: "AssetCell")
    }
    
    private func setNav() {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "取消", style: .plain, target: self, action: #selector(cancel))
    }
    
    @objc private func cancel() {
        self.navigationController?.popViewController(animated: true)
        self.navigationController?.navigationBar.barStyle = .blackTranslucent
    }

    @IBAction func previewImgs(_ sender: Any) {
    }
    
    @IBAction func originImg(_ sender: Any) {
    }
    
    @IBAction func commit(_ sender: Any) {
    }
}

extension ImagePicker: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AssetCell", for: indexPath) as! AssetCell
        return cell
    }
    
    
}
