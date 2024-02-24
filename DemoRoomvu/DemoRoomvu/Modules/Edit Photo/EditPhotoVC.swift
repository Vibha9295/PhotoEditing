import UIKit

class EditPhotoVC: UIViewController, UIScrollViewDelegate, UIGestureRecognizerDelegate, EditPhotoViewModelDelegate {
    
    // MARK: - Outlets
    @IBOutlet weak var scrlView: UIScrollView!
    @IBOutlet weak var sliderZoomIN_OUT: UISlider!
    @IBOutlet weak var vwImage: UIView!
    @IBOutlet weak var switchRemoveBG: UISwitch!
    @IBOutlet weak var imageView: UIImageView!
    
    // MARK: - Properties
    var imageToCrop: UIImage?
    var circularOverlay = UIView()
    var loaderView: LoadGIFView?
    var viewModel: EditPhotoViewModel!
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = EditPhotoViewModel()
        viewModel.delegate = self
        imageView.image = imageToCrop
        setupSlider()
        setupScrollView()
        setupCircularOverlay()
    }
    
    // MARK: - Setup Methods
    func setupSlider() {
        sliderZoomIN_OUT.minimumValue = 1.0
        sliderZoomIN_OUT.maximumValue = 3.0
        sliderZoomIN_OUT.value = 1.0
    }
    
    func setupScrollView() {
        scrlView.delegate = self
        scrlView.minimumZoomScale = 1.0
        scrlView.maximumZoomScale = 3.0
        scrlView.zoomScale = 1.0
        scrlView.contentSize = imageView.frame.size
    }
    
    func setupCircularOverlay() {
        let circularOverlaySize: CGFloat = min(imageView.frame.width, imageView.frame.height)
        circularOverlay = UIView(frame: CGRect(x: 0, y: 0, width: circularOverlaySize, height: circularOverlaySize))
        circularOverlay.center = imageView.center
        circularOverlay.layer.cornerRadius = circularOverlaySize / 2
        circularOverlay.layer.borderWidth = 2.0
        circularOverlay.layer.borderColor = UIColor.white.cgColor
        circularOverlay.isUserInteractionEnabled = true
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        panGesture.delegate = self
        circularOverlay.addGestureRecognizer(panGesture)
        circularOverlay.isUserInteractionEnabled = true
        vwImage.addSubview(circularOverlay)
    }
    // MARK: - Gesture Recognizer
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    @objc func handlePan(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: vwImage)
        scrlView.contentOffset.x -= translation.x
        scrlView.contentOffset.y -= translation.y
        gesture.setTranslation(CGPoint.zero, in: vwImage)
    }
    
    // MARK: - UIScrollViewDelegate
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        if switchRemoveBG.isOn {
            viewModel.applyCircularMask(imageView: imageView, scrlView: scrlView)
        } else {
            viewModel.removeCircularMask(imageView: imageView)
        }
        let offsetX = max((scrollView.bounds.size.width - scrollView.contentSize.width) * 0.5, 0)
        let offsetY = max((scrollView.bounds.size.height - scrollView.contentSize.height) * 0.5, 0)
        scrollView.contentInset = UIEdgeInsets(top: offsetY, left: offsetX, bottom: 0, right: 0)
    }
    // MARK: - EditPhotoViewModelDelegate
    
    func saveImageToLocal(image: UIImage) {
        viewModel.saveImageToLocal(image: image)
    }
    
    func imageUploadSuccess() {
        DispatchQueue.main.async {
            self.loaderView?.isHidden = true
            NotificationCenter.default.post(name: Notification.Name("EnhancedImageNotification"), object: self.imageView.image)
            self.navigationController?.popToRootViewController(animated: true)
        }
    }
    
    func imageUploadFailure(error: Error) {
        DispatchQueue.main.async {
            self.loaderView?.isHidden = true
            print("Error uploading image. Error: \(error)")
            // Handle failure, update UI, or perform other error handling
        }
    }
    // MARK: - IBActions
    @IBAction func sliderZoomIN_OutAct(_ sender: UISlider) {
        let scale = CGFloat(sliderZoomIN_OUT.value)
        scrlView.setZoomScale(scale, animated: true)
    }
    
    @IBAction func btnRotateAct(_ sender: Any) {
        imageView.transform = imageView.transform.rotated(by: CGFloat(Double.pi / 2))
    }
    
    @IBAction func switchRemoveBGAct(_ sender: UISwitch) {
        if sender.isOn {
            viewModel.applyCircularMask(imageView: imageView, scrlView: scrlView)
        } else {
            viewModel.removeCircularMask(imageView: imageView)
        }
    }
    
    @IBAction func btnUploadHeadshot(_ sender: Any) {
        guard let croppedImage = imageView.image else {
            return
        }
        
        saveImageToLocal(image: croppedImage)
        let authToken = "AHpzZnQjHfPaRd9NMCq8"
        
        let loaderView = LoadGIFView.show(in: self.view)
        viewModel.uploadImage(image: croppedImage, authToken: authToken) { progress in
            loaderView.updateProgress(progress)
        }
    }
    
    @IBAction func btnCancelAct(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnClose(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    deinit {
        print("EditPhotoVC deinitialized")
    }
}
