import UIKit
import Photos

protocol PhotoLibraryViewModelDelegate: AnyObject {
    func didFetchPhotos(_ photos: [UIImage])
    func didEncounterError(_ error: PhotoLibraryError)
}

enum PhotoLibraryError {
    case accessDenied
    case limitedAccess
}

class PhotoLibraryViewModel {
    
    weak var delegate: PhotoLibraryViewModelDelegate?
    private var imageRequestIds: [PHImageRequestID] = []
    
    func fetchPhotos() {
        let status = PHPhotoLibrary.authorizationStatus()
        switch status {
        case .authorized:
            fetchPhotosFromLibrary()
        case .notDetermined:
            requestAuthorizationAndFetchPhotos()
        case .denied, .restricted:
            delegate?.didEncounterError(.accessDenied)
        case .limited:
            delegate?.didEncounterError(.limitedAccess)
        @unknown default:
            delegate?.didEncounterError(.accessDenied)
        }
    }
    // MARK: - Photo Fetching
    private func fetchPhotosFromLibrary() {
        var photos: [UIImage] = []
        
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        
        let fetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions)
        
        for index in 0..<fetchResult.count {
            let asset = fetchResult.object(at: index)
            let requestOptions = PHImageRequestOptions()
            requestOptions.deliveryMode = .highQualityFormat
            
            let imageRequestId = PHImageManager.default().requestImage(
                for: asset,
                targetSize: CGSize(width: 200, height: 200),
                contentMode: .aspectFill,
                options: requestOptions
            ) { (image, _) in
                if let image = image {
                    photos.append(image)
                }
                
                self.delegate?.didFetchPhotos(photos)
            }
            
            imageRequestIds.append(imageRequestId)
        }
    }
    
    deinit {
        // Cancel all pending image requests when the view controller is deallocated
        for imageRequestId in imageRequestIds {
            PHImageManager.default().cancelImageRequest(imageRequestId)
        }
    }
    private func fetchPhotosFromLibrary1() {
        var photos: [UIImage] = []
        
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        
        let fetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions)
        
        for index in 0..<fetchResult.count {
            let asset = fetchResult.object(at: index)
            let requestOptions = PHImageRequestOptions()
            requestOptions.deliveryMode = .highQualityFormat
            
            PHImageManager.default().requestImage(for: asset, targetSize: CGSize(width: 200, height: 200), contentMode: .aspectFill, options: requestOptions) { (image, _) in
                if let image = image {
                    photos.append(image)
                }
                
                self.delegate?.didFetchPhotos(photos)
            }
        }
    }
    
    private func requestAuthorizationAndFetchPhotos() {
        PHPhotoLibrary.requestAuthorization { [weak self] (newStatus) in
            guard let self = self, newStatus == .authorized else {
                self?.delegate?.didEncounterError(.accessDenied)
                return
            }
            
            self.fetchPhotosFromLibrary()
        }
    }
    
    
}

