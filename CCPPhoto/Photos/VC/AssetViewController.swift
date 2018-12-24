//
//  AssetViewController.swift
//  CCPPhoto
//
//  Created by 储诚鹏 on 2018/12/21.
//  Copyright © 2018 储诚鹏. All rights reserved.
//

import UIKit

final class AssetViewController: UIViewController {

    @IBOutlet weak var listCollection: UICollectionView!
    private var imgModels = [AssetModel]()
    private var selectedImgIds = [String]()
    private var type: AlbumType = .imageVideo
    
    static var imageVC: AssetViewController {
        get {
            return assetVC()
        }
    }
    
    static var videoVC: AssetViewController {
        get {
            return assetVC(.video)
        }
    }
    
    static var imageVideoVC: AssetViewController {
        get {
            return assetVC(.imageVideo)
        }
    }
    
    private static func assetVC(_ type: AlbumType = .image) -> AssetViewController{
        let assetVC = AssetViewController()
        assetVC.type = type
        return assetVC
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "照片"
        setNav()
        setAutoAdjustScrollViewInsets()
        listCollection.register(UINib(nibName: "AssetCell", bundle: nil), forCellWithReuseIdentifier: "AssetCell")
        setupCollectionLayout()
        fetchData()
    }
    
    private func itemSize() -> CGSize {
        let numOfColumn = CCPPhotoConfig.numOfColumn
        if numOfColumn > 0 {
            let itemWidth = (Int(self.view.bounds.width) - (numOfColumn + 1) * CCPPhotoConfig.itemSpace) / numOfColumn
            return CGSize(width: itemWidth, height: itemWidth)
        }
        return .zero
    }
    
    private func edgeInsets() -> UIEdgeInsets {
        let space = CGFloat(CCPPhotoConfig.itemSpace)
        return  UIEdgeInsets(top: space, left: space, bottom: space, right: space)
    }
    
    private func setupCollectionLayout() {
        let layout = UICollectionViewFlowLayout()
        listCollection.contentInset = edgeInsets()
        layout.itemSize = itemSize()
        layout.minimumInteritemSpacing = CGFloat(CCPPhotoConfig.itemSpace)
        layout.minimumLineSpacing = CGFloat(CCPPhotoConfig.itemSpace)
        listCollection.collectionViewLayout = layout
    }
    
    private func setAutoAdjustScrollViewInsets() {
        if #available(iOS 11.0, *)  {
            listCollection.contentInsetAdjustmentBehavior = .never
        }
        else {
            self.automaticallyAdjustsScrollViewInsets = true
        }
    }
    
    private func setNav() {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "取消", style: .plain, target: self, action: #selector(cancel))
        self.navigationController?.navigationBar.barStyle = .blackTranslucent
    }
    
    @objc private func cancel() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func previewImgs(_ sender: Any) {
    }
    
    @IBAction func originImg(_ sender: Any) {
    }
    
    @IBAction func commit(_ sender: Any) {
    }
    
    private func fetchData() {
        CCPPhoto.fetchCameraRollAlbum(type) { (albumModel) in
            if let album = albumModel {
                self.imgModels = album.models
                self.listCollection.reloadData()
            }
        }
    }
}

extension AssetViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imgModels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AssetCell", for: indexPath) as! AssetCell
        let model = imgModels[indexPath.item]
        cell.setupContent(model)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: false)
        handleSelectedIdxs(indexPath)
        NotificationCenter.default.post(name: .reloadSelectedIdx, object: nil, userInfo: ["selectedIdxs" : selectedImgIds])
    }
    
    private func handleSelectedIdxs(_ indexPath: IndexPath) {
        let model = imgModels[indexPath.item]
        let id = model.asset.localIdentifier
        if let idx = selectedImgIds.firstIndex(of: id) {
            selectedImgIds.remove(at: idx)
        }
        else {
            selectedImgIds.append(id)
        }
    }
}
