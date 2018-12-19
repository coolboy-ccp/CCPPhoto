//
//  CCPPhotoModels.swift
//  CCPPhoto
//
//  Created by 储诚鹏 on 2018/12/18.
//  Copyright © 2018 储诚鹏. All rights reserved.
//

import UIKit
import Photos

struct AlbumModel {
    let name: String
    let count: Int
    let result: PHFetchResult<PHAsset>
    let models: [AssetModel]
}

struct AssetModel {
    let asset: PHAsset
    var isSelected: Bool = false
    let mediaType: AssetMediaType
    let timeLength: String
    
    init(_ asset: PHAsset, _ type: AssetMediaType, _ timeLength: String = "") {
        self.asset = asset
        self.mediaType = type
        self.timeLength = timeLength
    }
    
    func imgDataLength(_ completion:@escaping (_ length: Int) -> ()) {
        let options = PHImageRequestOptions()
        options.resizeMode = .fast
        options.isNetworkAccessAllowed = true
        if mediaType == .gif {
            options.version = .original
        }
        PHImageManager.default().requestImageData(for: asset, options: options) { (data, _, _, _) in
            completion(data?.count ?? 0)
        }
    }
}

enum AssetMediaType: Int {
    case unknown, image, video, audio, gif
}

extension AssetMediaType {
    static func from(_ asset: PHAsset) -> AssetMediaType {
        switch asset.mediaType {
        case .image:
            if let filename = asset.value(forKey: "filename") as? String {
                if filename.hasPrefix("GIF") {
                    return gif
                }
            }
            return image
        default:
            if let type = self.init(rawValue: asset.mediaType.rawValue) {
                return type
            }
            return unknown
        }
    }
}

enum AlbumType {
    case video
    case image
    case imageVideo
}

extension AlbumType {
    func fetchOptions(_ sort: SortType = .creationDate(ascending: true)) -> PHFetchOptions {
        let options = PHFetchOptions()
        switch self {
        case .image:
            options.predicate = NSPredicate.init(format: "mediaType == %ld", PHAssetMediaType.image.rawValue)
        case .video:
            options.predicate = NSPredicate.init(format: "mediaType == %ld", PHAssetMediaType.video.rawValue)
        case .imageVideo:()
        }
        optionsSort(options, sort)
        return options
    }
    
    private func optionsSort(_ options: PHFetchOptions, _ sort: SortType) {
        switch sort {
        case .creationDate(ascending: let asc):
            options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: asc)]
        }
    }
}
enum SortType {
    case creationDate(ascending: Bool)
}

