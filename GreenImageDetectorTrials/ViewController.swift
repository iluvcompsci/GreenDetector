//
//  ViewController.swift
//  GreenImageDetectorTrials
//
//  Created by Bliss Chapman on 3/29/15.
//  Copyright (c) 2015 Bliss Chapman. All rights reserved.
//

import UIKit
import AVFoundation
import CoreGraphics

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var resultsLabel: UILabel!
    
    var ratioOfGreenRequiredToBeSpring: CGFloat = 0.075
    private lazy var imageAnalysisHelper = Helper()
    
    private var imageToAnalyze: UIImage? {
        didSet{
            if imageView != nil { imageView.image = imageToAnalyze }
            if let image = imageToAnalyze { analyzeImage(image) }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        determinePermissionStatus()
    }
    
    private func analyzeImage(image: UIImage) {
        resultsLabel.text = "Thinking..."
        let qos = Int(QOS_CLASS_USER_INITIATED.value)
        dispatch_async(dispatch_get_global_queue(qos, 0), { () -> Void in
            let greenness: CGFloat = self.imageAnalysisHelper.analyzeImageForGreenness(image)
            dispatch_async(dispatch_get_main_queue()) {
                var ratioOfGreen = greenness/(image.size.width * image.size.height)
                if ratioOfGreen > self.ratioOfGreenRequiredToBeSpring {
                    self.resultsLabel.text = "Spring is here!"
                } else {
                    self.resultsLabel.text = "3 more months of winter 😢"
                }
            }
        })
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        imageToAnalyze = info[UIImagePickerControllerEditedImage] as? UIImage
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    private func determinePermissionStatus() -> Bool {
        var authorized = false
        let status = AVCaptureDevice.authorizationStatusForMediaType(AVMediaTypeVideo)
        switch status {
        case .Authorized: return true
        case .Denied: return false
        case .Restricted: return false
        case .NotDetermined:
            AVCaptureDevice.requestAccessForMediaType(AVMediaTypeVideo, completionHandler: { (granted: Bool) in
                authorized = granted
            })
            return authorized
        }
    }
    
    private func showNotAvailableAlert(title: String, message: String) {
        var noCameraAlert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        noCameraAlert.addAction(UIAlertAction(title: "Dismiss", style: .Default, handler: { action in self.dismissViewControllerAnimated(true, completion: nil) }))
        presentViewController(noCameraAlert, animated: true, completion: nil)
    }
    
    @IBAction private func takeNewPhoto(sender: UIButton) {
        if !UIImagePickerController.isSourceTypeAvailable(.Camera) { showNotAvailableAlert("Error", message: "Device has no camera") }
        
        var picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        picker.sourceType = .Camera
        presentViewController(picker, animated: true, completion: nil)
    }
    
    @IBAction private func selectPhotoFromLibrary(sender: UIButton) {
        if !UIImagePickerController.isSourceTypeAvailable(.PhotoLibrary) { showNotAvailableAlert("Error", message: "Device has no photo library") }
        var picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        picker.sourceType = .PhotoLibrary
        
        presentViewController(picker, animated: true, completion: nil)
    }
}

