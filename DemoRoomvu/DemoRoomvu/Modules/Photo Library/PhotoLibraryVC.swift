//
//  PhotoLibraryVC.swift
//  DemoRoomvu
//
//  Created by Sparrow on 2024-02-23.
//

import UIKit
import Photos

class PhotoLibraryVC: UIViewController, UICollectionViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, PhotoLibraryViewModelDelegate  {
    
    // MARK: - IBOutlets
    @IBOutlet weak var cvPhotos: UICollectionView!
    
    // MARK: - Properties
    
    private var photos: [UIImage] = []
    private var selectedImage: UIImage?
    private var viewModel: PhotoLibraryViewModel!
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        setupViewModel()
    }
    
    // MARK: - CollectionView Setup
    
    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.sectionInset = UIEdgeInsets.zero
        
        let cellWidth = cvPhotos.frame.width / 3
        layout.itemSize = CGSize(width: cellWidth, height: cellWidth)
        
        cvPhotos.collectionViewLayout = layout
        cvPhotos.delegate = self
        cvPhotos.dataSource = self
        
    }
    private func setupViewModel() {
        viewModel = PhotoLibraryViewModel()
        viewModel.delegate = self
        viewModel.fetchPhotos()
    }
    // MARK: - PhotoLibraryViewModelDelegate
    
    func didFetchPhotos(_ photos: [UIImage]) {
        self.photos = photos
        cvPhotos.reloadData()
    }
    
    func didEncounterError(_ error: PhotoLibraryError) {
        showAlert(message: "Error: \(error)")
    }
    // MARK: - Photo Fetching
    
    @objc private func openCamera() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = false
        
        present(imagePicker, animated: true, completion: nil)
    }
    
    // MARK: - Helper Methods
    
    private func handleNextButtonAction() {
        if let selectedImage = selectedImage {
            navigateToEditPhoto(with: selectedImage)
        } else {
            showAlert(message: "Please select a photo to proceed.")
        }
    }
    private func navigateToEditPhoto(with image: UIImage) {
        guard let editPhotoVC = storyboard?.instantiateViewController(withIdentifier: "EditPhotoVC") as? EditPhotoVC else {
            showAlert(message: "Failed to instantiate EditPhotoVC.")
            return
        }
        
        editPhotoVC.imageToCrop = image
        navigationController?.pushViewController(editPhotoVC, animated: true)
    }
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
    // MARK: - Button Actions
    
    @IBAction func btnNextAct(_ sender: Any) {
        handleNextButtonAction()
        
    }
    
    @IBAction func btnBackAct(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}

extension PhotoLibraryVC: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count + 1 // Add 1 for the camera button
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        cell.contentView.subviews.forEach { $0.removeFromSuperview() }
        
        if indexPath.item == 0 {
            addCameraButton(to: cell)
        } else {
            displayPhoto(in: cell, at: indexPath)
        }
        
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.item == 0 {
            openCamera()
        } else {
            handlePhotoSelection(at: indexPath)
        }
    }
    // MARK: - Helper Methods
    
    private func addCameraButton(to cell: UICollectionViewCell) {
        let cameraButton = UIButton(type: .custom)
        cameraButton.setImage(UIImage(named: "ic_camera"), for: .normal)
        cameraButton.addTarget(self, action: #selector(openCamera), for: .touchUpInside)
        cameraButton.translatesAutoresizingMaskIntoConstraints = false
        cell.contentView.addSubview(cameraButton)
        
        NSLayoutConstraint.activate([
            cameraButton.centerXAnchor.constraint(equalTo: cell.contentView.centerXAnchor),
            cameraButton.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor)
        ])
    }
    
    private func displayPhoto(in cell: UICollectionViewCell, at indexPath: IndexPath) {
        let imageView = UIImageView(frame: cell.contentView.bounds)
        imageView.contentMode = .scaleToFill
        imageView.image = photos[indexPath.item - 1]
        cell.contentView.addSubview(imageView)
    }
    
    private func handlePhotoSelection(at indexPath: IndexPath) {
        let selectedCell = cvPhotos.cellForItem(at: indexPath)!
        
        guard let cropperVC = storyboard?.instantiateViewController(withIdentifier: "EditPhotoVC") as? EditPhotoVC,
              let indexPath = cvPhotos.indexPath(for: selectedCell) else {
            return
        }
        
        let selectedPhotoIndex = indexPath.item - 1
        selectedImage = selectedPhotoIndex >= 0 ? photos[selectedPhotoIndex] : nil
        cropperVC.imageToCrop = selectedPhotoIndex >= 0 ? photos[selectedPhotoIndex] : nil
        
        navigationController?.pushViewController(cropperVC, animated: true)
    }
}

