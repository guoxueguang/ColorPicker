//
//  PickColorViewController.swift
//  ColorPicker
//
//  Created by Linsw on 16/12/3.
//  Copyright © 2016年 Linsw. All rights reserved.
//

import UIKit

class PickColorViewController: UIViewController {

    @IBOutlet weak var imageContainerScrollView: UIScrollView!
    @IBOutlet weak var sourceImageView: UIImageView!
    
    @IBOutlet weak var colorInformationView: ColorInformationView!
    
    
    @IBOutlet weak var imageViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageViewTrailingConstraint: NSLayoutConstraint!

    private var colorAnchorView : ColorAnchorView!
    private let colorCollectionSourceManager = ColorCollectionSourceManager.shared
//MARK: Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        sourceImageView.image = UIImage(named: "PickColorImage")
        colorAnchorView = ColorAnchorView(center: CGPoint(x: windowBounds.width/2, y: windowBounds.height/2), size: SizeAdaptation.shared.colorAnchorViewSize, targetView: view)
       
        self.view.addSubview(colorAnchorView)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        updateMinZoomScaleForSize(size: imageContainerScrollView.bounds.size)
    }
//MARK: help func
    fileprivate func updateMinZoomScaleForSize(size: CGSize) {
        
        let widthScale = size.width / sourceImageView.bounds.width
        let heightScale = size.height / sourceImageView.bounds.height
        let minScale = min(widthScale, heightScale)
        if (abs(minScale - imageContainerScrollView.minimumZoomScale) < 0.01) {
            return
        }else{
            imageContainerScrollView.minimumZoomScale = minScale
            imageContainerScrollView.zoomScale = minScale
        }
    }
    
    //图片居中
    fileprivate func updateConstraintsForSize(size: CGSize) {
        let yOffset = max(0, (size.height - sourceImageView.frame.height) / 2)
        imageViewTopConstraint.constant = yOffset
        imageViewBottomConstraint.constant = yOffset
        let xOffset = max(0, (size.width - sourceImageView.frame.width) / 2)
        imageViewLeadingConstraint.constant = xOffset
        imageViewTrailingConstraint.constant = xOffset
        view.layoutIfNeeded()
    }
    
    fileprivate func updateAnchorAndIndicationColor(){
        let pointInImage = colorAnchorView.superview!.convert(colorAnchorView.center, to: sourceImageView)
        colorAnchorView.refreshImage()
        colorInformationView.currentColor = sourceImageView.image!.getPixelColor(pos: pointInImage)
    }
//MARK: IBAction
    @IBAction func longPressToActiveAnchor(_ sender: UILongPressGestureRecognizer) {
        let posInImageView = sender.location(in: imageContainerScrollView)
        if posInImageView.x<0 || posInImageView.y<0 || posInImageView.x>imageContainerScrollView.contentSize.width || posInImageView.y>imageContainerScrollView.contentSize.height {
            return
        }else{
            colorAnchorView.center = sender.location(in: view)
            colorAnchorView.refreshImage()
            colorInformationView.currentColor = sourceImageView.image!.getPixelColor(pos: sender.location(in: sourceImageView))
            switch colorAnchorView.magnifyStyle {
            case .above:
                if sender.location(in: nil).y <= colorAnchorView.halfHeight + 64 {
                    colorAnchorView.magnifyStyle = .below
                }
                break
            case .below:
                if sender.location(in: nil).y > colorAnchorView.halfHeight + 64 {
                    colorAnchorView.magnifyStyle = .above
                }
                break
            }
            
        }
    }
    
    @IBAction func saveCurrentColor(_ sender: UIBarButtonItem) {
        colorCollectionSourceManager.saveOneCollectedColor(color: CollectedColor(date: Date(), color: colorInformationView.currentColor)){success in
            if !success {
                print("fail to save color")
            }else{
                
                self.present(sharedAlertVC,animated: true,completion: nil)
            }
        }
    }
    @IBAction func selectImageFromPhotoLibrary(_ sender: UIBarButtonItem) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.delegate = self
        
        present(imagePickerController, animated: true, completion: nil)
    }
}

extension PickColorViewController : UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return sourceImageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        updateConstraintsForSize(size: imageContainerScrollView.bounds.size)
        updateAnchorAndIndicationColor()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updateAnchorAndIndicationColor()    
    }
}

extension PickColorViewController : UIImagePickerControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        guard let selectedImage = info[UIImagePickerControllerOriginalImage] as? UIImage else{
            print("fail to get image from library")
            dismiss(animated: true, completion: nil)
            return
        }
        sourceImageView.image = selectedImage
        updateConstraintsForSize(size: imageContainerScrollView.bounds.size)
        updateMinZoomScaleForSize(size: imageContainerScrollView.bounds.size)
        dismiss(animated: true, completion: nil)
    }

}

extension PickColorViewController : UINavigationControllerDelegate {
    
}

