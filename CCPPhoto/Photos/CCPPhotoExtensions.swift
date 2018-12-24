//
//  CCPPhotoExtensions.swift
//  CCPPhoto
//
//  Created by 储诚鹏 on 2018/12/18.
//  Copyright © 2018 储诚鹏. All rights reserved.
//

import UIKit
import Photos

extension AVMutableVideoComposition {
    static func fixVideoComposition(_ asset: AVAsset) -> AVMutableVideoComposition {
        let composition = AVMutableVideoComposition()
        let degree = composition.videoDegree(asset)
        if degree > 0 {
            if let track = composition.track(asset) {
                var translateToCenter = CGAffineTransform.identity
                var mixedTransform = CGAffineTransform.identity
                composition.frameDuration = CMTime(value: 1, timescale: 30)
                let instruction = AVMutableVideoCompositionInstruction()
                instruction.timeRange = CMTimeRange(start: .zero, end: asset.duration)
                let layerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: track)
                let size = track.naturalSize
                if degree == 90 {
                    translateToCenter = CGAffineTransform(translationX: size.height, y: 0)
                    mixedTransform = translateToCenter.rotated(by: CGFloat.pi / 2)
                    composition.renderSize = CGSize(width: size.height, height: size.width)
                }
                else if degree == 180 {
                    translateToCenter = CGAffineTransform(translationX: size.width, y: size.height)
                    mixedTransform = translateToCenter.rotated(by: CGFloat.pi)
                    composition.renderSize = CGSize(width: size.width, height: size.height)
                }
                else if degree == 270 {
                    translateToCenter = CGAffineTransform(translationX: 0, y: size.width)
                    mixedTransform = translateToCenter.rotated(by: CGFloat.pi*1.5)
                    composition.renderSize = CGSize(width: size.height, height: size.width)
                }
                layerInstruction.setTransform(mixedTransform, at: .zero)
                instruction.layerInstructions = [layerInstruction]
                composition.instructions = [instruction]
            }
        }
        return composition
    }
    
    private func track(_ asset: AVAsset) -> AVAssetTrack? {
        let tracks = asset.tracks(withMediaType: .video)
        return tracks.first
    }
    
    /*
     | 1 0 0 |
     identity = | 0 1 0 |
     | 0 0 1 |
     | a  b  0 |
     transform = | c  d  0 |
     | tx ty 1 |
     x1 = ax0 + cy0 + tx
     y1 = bx0 + dy0 + ty
     */
    private func videoDegree(_ asset: AVAsset) -> Int {
        var degree = 0
        if let track = track(asset) {
            let t = track.preferredTransform
            //portrait
            if t.a == 0 && t.b == 1 && t.c == -1 && t.d == 0 {
                degree = 90
            }
                //protraitUpsideDown
            else if t.a == 0 && t.b == -1 && t.c == 1 && t.d == 0 {
                degree = 270
            }
                //landscapeRight
            else if t.a == 1 && t.b == 0 && t.c == 0 && t.d == 1 {
                degree = 0
            }
                //landscapeLeft
            else if t.a == -1 && t.b == 0 && t.c == 0 && t.d == -1 {
                degree = 180
            }
        }
        return degree
    }
}

    extension UIImage {
        func scale(to size: CGSize) -> UIImage {
            let width = self.size.width > size.width ? size.width : self.size.width
            let height = self.size.height > size.height ? size.height : self.size.height
            UIGraphicsBeginImageContext(CGSize(width: width, height: height))
            self.draw(in: CGRect(x: 0, y: 0, width: width, height: height))
            defer { UIGraphicsEndImageContext() }
            return UIGraphicsGetImageFromCurrentImageContext() ?? self
        }
        
        private func tranformRotate(_ transform: inout CGAffineTransform, _ width: CGFloat, _ height: CGFloat, _ angle: CGFloat) {
            transform = transform.translatedBy(x: width, y: height)
            transform = transform.rotated(by: angle)
        }
        
        private func tranformScale(_ transform: inout CGAffineTransform, _ width: CGFloat) {
            transform = transform.translatedBy(x: width, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
        }
        
        private func rotate(_ transform: inout CGAffineTransform) {
            switch self.imageOrientation {
            case .down, .downMirrored:
                tranformRotate(&transform, self.size.width, self.size.height, CGFloat.pi)
            case .left, .leftMirrored:
                tranformRotate(&transform, self.size.width, 0, CGFloat.pi / 2)
            case .right, .rightMirrored:
                tranformRotate(&transform, 0, self.size.height, -CGFloat.pi / 2)
            default:()
            }
        }
        
        private func scale(_ transform: inout CGAffineTransform) {
            switch self.imageOrientation {
            case .upMirrored, .downMirrored:
                tranformScale(&transform, self.size.width)
            case .leftMirrored, .rightMirrored:
                tranformScale(&transform, self.size.height)
            default:()
            }
        }
        
        func fixOrientationUp() -> UIImage {
            if self.imageOrientation == .up { return self }
            var transform = CGAffineTransform.identity
            var newImg = self
            rotate(&transform)
            scale(&transform)
            if let cgImg = self.cgImage {
                let ctx = CGContext(data: nil, width: Int(self.size.width), height: Int(self.size.height), bitsPerComponent: cgImg.bitsPerComponent, bytesPerRow: 0, space: cgImg.colorSpace!, bitmapInfo: cgImg.bitmapInfo.rawValue)
                ctx?.concatenate(transform)
                let rect = CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height)
                let rect1 = CGRect(x: 0, y: 0, width: self.size.height, height: self.size.width)
                switch self.imageOrientation {
                case .left, .leftMirrored, .right, .rightMirrored:
                    ctx?.draw(cgImg, in: rect1)
                default:
                    ctx?.draw(cgImg, in: rect)
                }
                if let newCgimg = ctx?.makeImage() {
                    newImg = UIImage(cgImage: newCgimg)
                }
            }
            return newImg
        }
}

extension AVURLAsset {
    func exportVideoUrl(_ presetName: String = AVAssetExportPreset640x480, _ needFix: Bool = true, _ completion:((_ path: URL?)->())?) {
        let mainCompletion: (_ path: URL?)->() = { path in
            completion?(path)
        }
        if let session = AVAssetExportSession(asset: self, presetName: presetName) {
            if !videoOutType(session) { completion?(nil) }
            let fileUrl = videoOutFilePath()
            session.outputURL = fileUrl
            session.shouldOptimizeForNetworkUse = true
            if needFix {
                let composition = AVMutableVideoComposition.fixVideoComposition(self)
                if composition.renderSize.width > 0 {
                    session.videoComposition = composition
                }
            }
            session.exportAsynchronously {
                switch session.status {
                case .unknown, .exporting, .waiting:()
                case .completed:
                    mainCompletion(fileUrl)
                case .failed:
                    print("导出失败")
                    mainCompletion(nil)
                case .cancelled:
                    print("取消导出")
                    mainCompletion(nil)
                }
            }
        }
        else {
            mainCompletion(nil)
        }
        
    }
    
    private func videoOutType(_ session: AVAssetExportSession) -> Bool {
        let supportTypes = session.supportedFileTypes
        if supportTypes.count > 0 {
            if supportTypes.contains(.mp4) {
                session.outputFileType = .mp4
            }
            else {
                session.outputFileType = supportTypes.first!
            }
            return true
        }
        print("该视频不支持导出")
        return false
    }
    
    private func videoOutFilePath() -> URL? {
        let format = DateFormatter()
        format.dateFormat = "yyyy-MM-dd HH:mm:ss:SSS"
        let time = format.string(from: Date())
        let directory = "vidoes"
        let fileString = NSTemporaryDirectory() + "/\(directory)/video-\(time)" + self.url.lastPathComponent
        if !videoOutDirectory(directory) { return nil }
        return URL(string: fileString)
    }
    
    private func videoOutDirectory(_ name: String) -> Bool{
        let path = NSTemporaryDirectory() + name
        if !FileManager.default.fileExists(atPath: path) {
            if let _ = try? FileManager.default.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil) {
                return true
            }
            return false
        }
        return true
    }
}

extension PHAsset {
    
    typealias CCPPhotoCompletionHandler = (_ image: UIImage, _ info: [AnyHashable: Any]?)->()
    func videoUrl(_ presetName: String = AVAssetExportPreset640x480, _ needFix: Bool, _ completion:((_ path: URL?)->())?) {
        let options = PHVideoRequestOptions()
        options.version = .original
        options.deliveryMode = .automatic
        options.isNetworkAccessAllowed = true
        let mainQueueCompletion: (URL?)->() = {
            (path) in
            DispatchQueue.main.async {
                completion?(path)
            }
        }
        PHImageManager.default().requestAVAsset(forVideo: self, options: options) { (asset, _, _) in
            if let urlAsset = asset as? AVURLAsset {
                urlAsset.exportVideoUrl(presetName, needFix, mainQueueCompletion)
            }
            else {
                mainQueueCompletion(nil)
            }
        }
    }
    
    @discardableResult
    func image(_ width: CGFloat, _ allowCloud: Bool = true, _ progress: PHAssetImageProgressHandler? = nil, _ completion: CCPPhotoCompletionHandler?) -> PHImageRequestID {
        let imgSize = aspectSize(width)
        let options = PHImageRequestOptions()
        options.resizeMode = .fast
        options.progressHandler = progress
        options.isNetworkAccessAllowed = allowCloud
        return PHImageManager.default().requestImage(for: self, targetSize: imgSize, contentMode: .aspectFill, options: options) { (image, info) in
            if let img = image {
                completion?(img, info)
            }
        }
    }
    
    @discardableResult
    func originImage(_ allowCloud: Bool = true, _ progress: PHAssetImageProgressHandler? = nil, _ completion: CCPPhotoCompletionHandler?) -> PHImageRequestID {
        let options = PHImageRequestOptions()
        options.resizeMode = .fast
        options.progressHandler = progress
        options.isNetworkAccessAllowed = allowCloud
        return PHImageManager.default().requestImageData(for: self, options: options, resultHandler: { (imgData, _, _, info) in
            guard let data = imgData else { return }
            if let img = UIImage(data: data) {
                let fixImg = img.fixOrientationUp()
                completion?(fixImg, info)
            }
        })
    }
    
    private func aspectSize(_ width: CGFloat) -> CGSize {
        let rate = CGFloat(self.pixelWidth) / CGFloat(self.pixelHeight)
        let scaleWidth = width * (CCPPhotoConfig.screenScale) * 1.5
        var aspectWidth = scaleWidth
        if rate < 0.2 {
            aspectWidth = scaleWidth * 0.5
        }
        else if rate > 1.8 {
            aspectWidth = scaleWidth * rate
        }
        let aspectHeight = aspectWidth / rate
        return CGSize(width: aspectWidth, height: aspectHeight)
    }
    
}
