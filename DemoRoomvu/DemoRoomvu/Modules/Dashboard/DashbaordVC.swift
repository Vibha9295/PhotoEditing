//
//  DashbaordVC.swift
//  DemoRoomvu
//
//  Created by Sparrow on 2024-02-23.
//

import UIKit
import AVFoundation
class DashbaordVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // MARK: - IBOutlets
    @IBOutlet weak var btnProfileOut: UIButton!
    
    // MARK: - Properties
    private var viewModel = DashboardViewModel()
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupViewModel()
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleEnhancedImageNotification(_:)), name: Notification.Name("EnhancedImageNotification"), object: nil)
        
        // Do any additional setup after loading the view.
    }
    private func setupViewModel() {
        viewModel.delegate = self
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        btnProfileOut.cornerRadius = btnProfileOut.frame.height / 2
    }
    
    // MARK: - Notification Handler
    @objc func handleEnhancedImageNotification(_ notification: Notification) {
        guard let enhancedImage = notification.object as? UIImage else {
            return
        }
        viewModel.processEnhancedImage(enhancedImage)
    }
    // MARK: - Actions
    @IBAction func btnEditPhotoAct(_ sender: Any) {
        navigateToPhotoLibrary()
        
    }
    
    // MARK: - Photo Library
    private func navigateToPhotoLibrary() {
        guard let photoLibraryVC = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "PhotoLibraryVC") as? PhotoLibraryVC else {
            return
        }
        navigationController?.pushViewController(photoLibraryVC, animated: true)
    }
    
    @objc private func openPhotoLibraryOrCamera() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        
        let alertController = UIAlertController(title: Constants.selectSourceTitle, message: nil, preferredStyle: .actionSheet)
        
        let photoLibraryAction = UIAlertAction(title: Constants.photoLibraryTitle, style: .default) { _ in
            imagePicker.sourceType = .photoLibrary
            self.present(imagePicker, animated: true, completion: nil)
        }
        
        let cameraAction = UIAlertAction(title: Constants.cameraTitle, style: .default) { _ in
            self.handleCameraAction(with: imagePicker)
        }
        
        let cancelAction = UIAlertAction(title: Constants.cancelTitle, style: .cancel, handler: nil)
        
        alertController.addAction(photoLibraryAction)
        alertController.addAction(cameraAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    private func handleCameraAction(with imagePicker: UIImagePickerController) {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let status = AVCaptureDevice.authorizationStatus(for: .video)
            if status == .authorized {
                imagePicker.sourceType = .camera
                present(imagePicker, animated: true, completion: nil)
            } else if status == .denied {
                // Handle denied access with an alert
                showCameraAccessDeniedAlert()
            } else if status == .notDetermined {
                requestCameraPermission(for: imagePicker)
            }
        }
    }
    
    private func showCameraAccessDeniedAlert() {
        let alert = UIAlertController(
            title: Constants.cameraAccessDeniedTitle,
            message: Constants.cameraAccessDeniedMessage,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: Constants.okTitle, style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    private func requestCameraPermission(for imagePicker: UIImagePickerController) {
        AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
            guard let self = self else { return }
            
            if granted {
                DispatchQueue.main.async {
                    imagePicker.sourceType = .camera
                    self.present(imagePicker, animated: true, completion: nil)
                }
            } else {
                showCameraAccessDeniedAlert()
            }
        }
    }
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}


// MARK: - DashboardViewModelDelegate
extension DashbaordVC: DashboardViewModelDelegate {
    func didReceiveEnhancedImage(_ image: UIImage) {
        btnProfileOut.setImage(image, for: .normal)
    }
}
