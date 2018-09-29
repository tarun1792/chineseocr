//
//  ViewController.swift
//  chineseOCR2.0
//
//  Created by Tarun Kaushik on 21/06/18.
//  Copyright © 2018 Tarun Kaushik. All rights reserved.
//

import UIKit
import TesseractOCR

class ViewController: UIViewController,G8TesseractDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var progressLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        progressLabel.text = ""
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.selectPic))
        tap.numberOfTapsRequired = 1
        imageView.addGestureRecognizer(tap)
        imageView.isUserInteractionEnabled = true
        activityIndicator.startAnimating()
        activityIndicator.isHidden = true
        
    }
    
    func progressImageRecognition(for tesseract: G8Tesseract!) {
        print("recognition progress \(tesseract.progress)%")
        
        if tesseract.progress < 10 && tesseract.progress > 0 {
            progressLabel.text = "recognition progress 5% completed"
        }else if tesseract.progress >= 10 && tesseract.progress < 15{
             progressLabel.text = "recognition progress 10% completed"
        }else if tesseract.progress >= 15 && tesseract.progress < 25{
             progressLabel.text = "recognition progress 15% completed"
        }else if tesseract.progress >= 25 && tesseract.progress < 40{
             progressLabel.text = "recognition progress 25% completed"
        }else if tesseract.progress >= 40 && tesseract.progress < 60{
             progressLabel.text = "recognition progress 50% completed"
        }else if tesseract.progress >= 60 && tesseract.progress < 80{
             progressLabel.text = "recognition progress 70% completed"
        }else{
             progressLabel.text = "recognition progress \(tesseract.progress) completed"
        }
        
    }
    
    fileprivate func performExtraction() {
        if let tesseract = G8Tesseract(language: "chi_tra"){
            tesseract.delegate = self
            // tesseract.charWhitelist = "01234567890"
            if let image = imageView.image{
                if image == #imageLiteral(resourceName: "placeHolderImage"){
                    imageView.image = UIImage(named: "chineseText")
                    tesseract.image = UIImage(named: "chineseText")?.g8_grayScale()
                }else{
                    tesseract.image = image.g8_blackAndWhite()
                }
            }
            
            tesseract.recognize()
            
            textView.text = tesseract.recognizedText
        }
        
        activityIndicator.stopAnimating()
        activityIndicator.isHidden = true
    }
    
    @IBAction func extractButtonAction(_ sender: Any) {

        
        self.activityIndicator.startAnimating()
        self.activityIndicator.isHidden = false

        UIView.animate(withDuration: 0.25, delay: 0.25, options: .curveEaseInOut, animations: {
            
        }) { (aucess) in
            self.performExtraction()
        }

    }
    
    @objc func selectPic(){
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
            let picker = UIImagePickerController()
            picker.sourceType = .photoLibrary
            picker.delegate = self
            picker.allowsEditing = true
            self.present(picker, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage,let scaledImage = image.scaleImage(640){
            imageView.image = scaledImage
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveButtonAction(_ sender: Any) {
        // 1
        if textView.text.isEmpty {
            return
        }
        // 2
        let activityViewController = UIActivityViewController(activityItems:
            [textView.text], applicationActivities: nil)
        // 3
        let excludeActivities:[UIActivityType] = [
            .assignToContact,
            .saveToCameraRoll,
            .addToReadingList,
            .postToFlickr,
            .postToVimeo]
        activityViewController.excludedActivityTypes = excludeActivities
        // 4
        present(activityViewController, animated: true)
    }
    

}

extension UIImage {
    func scaleImage(_ maxDimension: CGFloat) -> UIImage? {
        
        var scaledSize = CGSize(width: maxDimension, height: maxDimension)
        
        if size.width > size.height {
            let scaleFactor = size.height / size.width
            scaledSize.height = scaledSize.width * scaleFactor
        } else {
            let scaleFactor = size.width / size.height
            scaledSize.width = scaledSize.height * scaleFactor
        }
        
        UIGraphicsBeginImageContext(scaledSize)
        draw(in: CGRect(origin: .zero, size: scaledSize))
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return scaledImage
    }
}

