//
//  CCPPhoto.swift
//  CCPPhoto
//
//  Created by 储诚鹏 on 2018/12/12.
//  Copyright © 2018 储诚鹏. All rights reserved.
//

import UIKit
import Photos

class CCPPhoto {
    private let handleQueue = DispatchQueue(label: "CCPPhotoHandleQueue")
    private var rqType: AssetMediaType = .image
    private var minWidth = CCPPhotoConfig.mainWidth / 6.0
    private var minHeight = CCPPhotoConfig.mainHeight / 6.0
    
    static let shared = CCPPhoto()
    private init() {}
    
    func imgAlbumDataLength(_ album: AlbumModel, _ completion: @escaping (_ length: String) -> ()) {
        var dataLength = 0
        //由于字节长度的获取是异步的，用count确保所有model的长度都添加上
        var count = 0
        for model in album.models {
            let isImg = model.mediaType == .image || model.mediaType == .gif
            if !isImg { continue }
            model.imgDataLength { (length) in
                dataLength += length
                count += 1
                if count >= album.models.count {
                    completion(self.albumLengthString(Float(dataLength)))
                }
            }
        }
    }
    
    func save(_ image: UIImage, _ loc: CLLocation? = nil, _ completion:((_ asset: PHAsset?)->())? = nil) {
        let request = PHAssetChangeRequest.creationRequestForAsset(from: image)
        save(request, loc, completion)
    }
    
    func save(_ url: URL, _ loc: CLLocation? = nil, _ completion:((_ asset: PHAsset?)->())? = nil) {
        if let request = PHAssetChangeRequest.creationRequestForAssetFromImage(atFileURL: url) {
            save(request, loc, completion)
        }
        else {
            completion?(nil)
        }
    }
    
    func saveVideo(_ url: URL, _ loc: CLLocation? = nil, _ completion:((_ asset: PHAsset?)->())? = nil) {
        if let request = PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: url) {
            save(request, loc, completion)
        }
        else {
            completion?(nil)
        }
    }
    
    func fetchCameraRollAlbum(_ type: AlbumType = .image, _ completion:((AlbumModel?)->())?) {
        let mainCompletion: (AlbumModel?)->() = { model in
            DispatchQueue.main.async {
                completion?(model)
            }
        }
        handleQueue.async {
            let fetchOptions = type.fetchOptions()
            let smartAlbums = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .albumRegular, options: nil)
            let model = self.albumModel(smartAlbums, fetchOptions, .smartAlbumUserLibrary)
            mainCompletion(model)
        }
    }
    
    func fetchAllAlums(_ type: AlbumType = .image, _ completion:(([AlbumModel])->())?) {
        let mainCompletion: ([AlbumModel])->() = { model in
            DispatchQueue.main.async {
                completion?(model)
            }
        }
        handleQueue.async {
            var albumModels = [AlbumModel]()
            let fetchOptions = type.fetchOptions()
            let albumTypes: [PHAssetCollectionType] = [.smartAlbum, .album, .album, .album]
            let albumSubTypes: [PHAssetCollectionSubtype] = [.albumRegular, .albumMyPhotoStream, .albumSyncedAlbum, .albumCloudShared]
            var results = [PHFetchResult<PHAssetCollection>]()
            for (idx, albumType) in albumTypes.enumerated() {
                let subType = albumSubTypes[idx]
                let result = PHAssetCollection.fetchAssetCollections(with: albumType, subtype: subType, options: fetchOptions)
                results.append(result)
            }
            if let top = PHCollectionList.fetchTopLevelUserCollections(with: nil) as? PHFetchResult<PHAssetCollection> {
                results.append(top)
            }
            for result in results {
                if let model = self.albumModel(result, fetchOptions) {
                    albumModels.append(model)
                }
            }
            mainCompletion(albumModels)
        }
    }
    
    private func albumLengthString(_ length: Float) -> String{
        var string: NSString = "0B"
        if length >= 0.1 * 1024 * 1024 {
            string = NSString(format: "%0.1fM", length / 1024 / 1024)
        }
        else if length >= 1024 {
            string = NSString(format: "%0.0fK", length / 1024)
        }
        else {
            string = NSString(format: "%0.0fB", length)
        }
        return String(string)
    }
    
    private func albumModel(_ result: PHFetchResult<PHAssetCollection>, _ options: PHFetchOptions?, _ filteSubType: PHAssetCollectionSubtype? = nil) -> AlbumModel? {
        var model: AlbumModel?
        func toModel(_ collection: PHAssetCollection) {
            if collection.estimatedAssetCount > 0 {
                let asset = PHAsset.fetchAssets(in: collection, options: options)
                let assetModels = self.assetModels(asset)
                model = AlbumModel.init(name: collection.localizedTitle ?? "", count: asset.count, result: asset, models: assetModels)
            }
        }
        result.enumerateObjects { (collection, idx, _) in
            if collection.isKind(of: PHAssetCollection.self) {
                if let subtype = filteSubType {
                    if collection.assetCollectionSubtype == subtype {
                        toModel(collection)
                    }
                }
                else {
                    toModel(collection)
                }
             
            }
        }
        return model
    }
    
    private func assetModels(_ result: PHFetchResult<PHAsset>) -> [AssetModel] {
        var models = [AssetModel]()
        result.enumerateObjects { (asset, idx, _) in
            if let model = self.assetModel(asset) {
                 models.append(model)
            }
        }
        return models
    }
    
    private func assetModel(_ result: PHFetchResult<PHAsset>, _ idx: Int) -> AssetModel? {
        let asset = result[idx]
        return self.assetModel(asset)
    }
    
    private func assetModel(_ asset: PHAsset) -> AssetModel? {
        let type = AssetMediaType.from(asset)
        if type != rqType { return nil }
        if !isConformingSize(asset) { return nil }
        let time = type == .video ? videoDurationString(asset.duration) : ""
        return AssetModel(asset, type, time)
    }
    
    private func isConformingSize(_ asset: PHAsset) -> Bool {
        let conformingWidth = minWidth < CGFloat(asset.pixelWidth)
        let conformingHeight = minHeight < CGFloat(asset.pixelHeight)
        return conformingWidth && conformingHeight
    }
    
    private func videoDurationString(_ duration: TimeInterval) -> String {
        var durationX = Int(duration)
        let h = durationX / 3600
        durationX = (h > 0) ? (durationX - 3600 * h) : durationX
        let min = durationX / 60
        durationX = (min > 0) ? (durationX - 60 * min) : durationX
        let sec = durationX
        return formatTime(h) + formatTime(min) + formatTime(sec)
    }
    
    private func formatTime(_ duration: Int) -> String {
        if duration > 0 {
            if duration > 10 {
                return "\(duration):"
            }
            return "0\(duration):"
        }
        return ""
    }
    
    private func save(_ request: PHAssetChangeRequest, _ loc: CLLocation? = nil, _ completion: ((_ asset: PHAsset?)->())?) {
        var identifier: String?
        var asset: PHAsset?
        let mainCompletion: (_ asset: PHAsset?)->() = { (asset) in
            completion?(asset)
        }
        PHPhotoLibrary.shared().performChanges({
            request.location = loc
            request.creationDate = Date()
            identifier = request.placeholderForCreatedAsset?.localIdentifier
        }) { (success, error) in
            if let errorString = error?.localizedDescription {
                print("[CCPPhoto]🌹🌹🌹: save photo error: \(errorString)")
            }
            else if let id = identifier {
                asset = PHAsset.fetchAssets(withLocalIdentifiers: [id], options: nil).firstObject
            }
            mainCompletion(asset)
        }
    }
}

extension CCPPhoto {
    static func fetchCameraRollAlbum(_ type: AlbumType = .image, _ completion:((AlbumModel?)->())?) {
        CCPPhoto.shared.fetchCameraRollAlbum(type, completion)
    }
}









