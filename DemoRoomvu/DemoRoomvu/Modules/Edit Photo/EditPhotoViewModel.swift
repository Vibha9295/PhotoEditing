import UIKit

protocol EditPhotoViewModelDelegate: AnyObject {
    func imageUploadSuccess()
    func imageUploadFailure(error: Error)
}

class EditPhotoViewModel {
    weak var delegate: EditPhotoViewModelDelegate?
    func uploadImage(image: UIImage, authToken: String, progressHandler: @escaping (Float) -> Void) {
        APIClient.uploadImage(image: image, token: authToken, progressHandler: { progress in
            DispatchQueue.main.async {
                progressHandler(progress)
            }
        }) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let apiResponse):
                print("Image uploaded successfully. Status: \(apiResponse.status)")
                self.delegate?.imageUploadSuccess()
            case .failure(let error):
                print("Error uploading image. Error: \(error)")
                self.delegate?.imageUploadFailure(error: error)
            }
        }
    }
    
    func applyCircularMask(imageView: UIImageView, scrlView: UIScrollView) {
        let circularMaskLayer = CAShapeLayer()
        
        // Calculate the center and radius for a circular path
        let visibleRect = scrlView.convert(scrlView.bounds, to: imageView)
        let centerX = visibleRect.origin.x + visibleRect.size.width / 2.0
        let centerY = visibleRect.origin.y + visibleRect.size.height / 2.0
        let radius = min(visibleRect.size.width, visibleRect.size.height) / 2.0
        
        let circularPath = UIBezierPath(arcCenter: CGPoint(x: centerX, y: centerY), radius: radius, startAngle: 0, endAngle: CGFloat(2 * Double.pi), clockwise: true)
        
        circularMaskLayer.path = circularPath.cgPath
        circularMaskLayer.fillRule = .evenOdd
        
        let maskLayer = CALayer()
        maskLayer.backgroundColor = UIColor.black.cgColor
        maskLayer.addSublayer(circularMaskLayer)
        
        imageView.layer.mask = maskLayer
    }
    
    func removeCircularMask(imageView: UIImageView) {
        imageView.layer.mask = nil
    }
    
    func saveImageToLocal(image: UIImage) {
        if let data = image.jpegData(compressionQuality: 0.8) {
            let filename = getDocumentsDirectory().appendingPathComponent("uploadedImage.jpg")
            try? data.write(to: filename)
        }
    }
    
    private func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    deinit {
        print("EditPhotoViewModel deinitialized")
    }
}
