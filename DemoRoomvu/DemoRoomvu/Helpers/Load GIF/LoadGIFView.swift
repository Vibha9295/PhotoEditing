//
//  LoadGIFView.swift
//  DemoRoomvu
//
//  Created by Sparrow on 2024-02-23.
//

import Foundation
import UIKit
class LoadGIFView: UIView {
    
    @IBOutlet weak var progressView: UIProgressView!
    static func show(in view: UIView) -> LoadGIFView {
        let loaderView = LoadGIFView.fromNib()
        loaderView.frame = view.bounds
        
        view.addSubview(loaderView)
        return loaderView
    }
    
    func hide() {
        removeFromSuperview()
    }
    
    // Customize this method to update the progress of your UIProgressView
    func updateProgress(_ progress: Float) {
        progressView.progress = progress
        print("progress: \(progress)")
    }
    class func fromNib() -> LoadGIFView {
        return Bundle.main.loadNibNamed("LoadGIFView", owner: nil, options: nil)?.first as! LoadGIFView
    }
}
