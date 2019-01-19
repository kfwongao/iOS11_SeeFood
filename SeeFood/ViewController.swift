//
//  ViewController.swift
//  SeeFood
//
//  Created by Huanqiang Kin Fat WONG on 19/1/2019.
//  Copyright © 2019 Huanqiang Kin Fat WONG. All rights reserved.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var results: UITextView!
    
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
//        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = false
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        guard let image = info[.originalImage] as? UIImage else {
            return
        }
        imageView.image = image
        
        guard let ciimage = CIImage(image: image) else {
            fatalError("Could not convert UIImage to CIImage")
        }
        
        detect(image: ciimage)
        
        imagePicker.dismiss(animated: true, completion: nil)
    }

    func detect(image : CIImage) {
        guard let model = try? VNCoreMLModel(for: Inceptionv3().model) else {
            fatalError("Loading CoreML Model Failed.")
        }
        
        let request = VNCoreMLRequest(model: model) { (request, error) in
            guard let results = request.results as? [VNClassificationObservation] else {
                fatalError("Model failed to process image.")
            }
            
            var text = "Image recognised as follows: \n"
            for (index, elements) in results.enumerated() {
                if index < 3 {
                    let identifier = elements.identifier
                    let percentage = elements.confidence * 100
                    
                    text = text + "\(identifier) \(percentage)% \n"
                } else {
                    break
                }
            }
            
            self.results.text = text
            
        }
        
        let handler = VNImageRequestHandler(ciImage: image)
        do {
            try handler.perform([request])
        } catch {
            print(error)
        }
    }

    @IBAction func cameraTapped(_ sender: UIBarButtonItem) {
        
        present(imagePicker, animated: true, completion: nil)
    }
    
}

