//
//  CCPPhotoAuthorization.swift
//  CCPPhoto
//
//  Created by 储诚鹏 on 2018/12/18.
//  Copyright © 2018 储诚鹏. All rights reserved.
//

import UIKit

class CCPPhotoAuthorization {
    var needFixImageOrientation = true
    var needFixVideoOrientation = true
    static func toSetting() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }
    
    @discardableResult
    static func authorize() -> Bool {
        let videoStatus = AVCaptureDevice.authorizationStatus(for: .video)
        let photoStatus = PHPhotoLibrary.authorizationStatus()
        let access = videoStatus == .authorized && photoStatus == .authorized
        if access {
            return true
        }
        else if videoStatus == .notDetermined {
            requestVideoAuthorization()
        }
        else if photoStatus == .notDetermined {
            requestPhotoAuthorization()
        }
        return false
    }
    
    private static func requestPhotoAuthorization() {
        PHPhotoLibrary.requestAuthorization({ (status) in
            if status == .authorized {
                authorize()
            }
        })
    }
    
    private static func requestVideoAuthorization() {
        AVCaptureDevice.requestAccess(for: .video) { (access) in
            if access { authorize() }
        }
    }
}
