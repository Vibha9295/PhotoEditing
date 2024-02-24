//
//  Constants.swift
//  DemoRoomvu
//
//  Created by Sparrow on 2024-02-23.
//

import Foundation

// MARK: - Constants Class
class Constants {
    static let enhancedImageNotification = Notification.Name("EnhancedImageNotification")
    
    static let selectSourceTitle = "Select Source"
    static let photoLibraryTitle = "Photo Library"
    static let cameraTitle = "Camera"
    static let cancelTitle = "Cancel"
    
    static let cameraAccessDeniedTitle = "Camera Access Denied"
    static let cameraAccessDeniedMessage = "Please enable camera access in your device settings to use this feature."
    
    static let okTitle = "OK"
    static let cellIdentifier = "cell"
    static let cameraButtonImageName = "ic_camera"
    static let editPhotoVCIdentifier = "EditPhotoVC"
}
// MARK: - API Errors

enum APIClientError: Error {
    case invalidImageData
    case invalidURL
    case invalidResponse
    case decodingError(Error)
    case networkError(Error)
    
    init(error: Error) {
        self = .networkError(error)
    }
}
