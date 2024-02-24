import Foundation
import UIKit
protocol DashboardViewModelDelegate: AnyObject {
    func didReceiveEnhancedImage(_ image: UIImage)
}

class DashboardViewModel {
    
    weak var delegate: DashboardViewModelDelegate?
    
    func processEnhancedImage(_ image: UIImage) {
        
        // Notify the delegate with the enhanced image
        delegate?.didReceiveEnhancedImage(image)
    }
}

