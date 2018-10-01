//
//  ViewController.swift
//  VisionTest
//
//  Created by jackyshan on 2018/9/30.
//  Copyright © 2018年 GCI. All rights reserved.
//

import UIKit
import Vision

class ViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let handler = VNImageRequestHandler.init(cgImage: (imageView.image?.cgImage!)!, orientation: CGImagePropertyOrientation.up)
        let request = reqReq()
        
        DispatchQueue.global(qos: .userInteractive).async {
            do {
                try handler.perform([request])
            }
            catch {
                print("e")
            }
        }
        
    }

    
    func reqReq() -> VNDetectFaceRectanglesRequest {
        let request = VNDetectFaceRectanglesRequest(completionHandler: { (request, error) in
            
            DispatchQueue.main.async {
                
                if let result = request.results {
                    
                    let transform = CGAffineTransform(scaleX: 1, y: -1).translatedBy(x: 0, y: -self.imageView!.frame.size.height)
                    let translate = CGAffineTransform.identity.scaledBy(x: self.imageView!.frame.size.width, y: self.imageView!.frame.size.height)
                    
                    //遍历所有识别结果
                    for item in result {
                        
                        //标注框
                        let faceRect = UIView(frame: CGRect.zero)
                        faceRect.layer.borderWidth = 3
                        faceRect.layer.borderColor = UIColor.red.cgColor
                        faceRect.backgroundColor = UIColor.clear
                        
                        self.imageView!.addSubview(faceRect)
                        
                        if let faceObservation = item as? VNFaceObservation {
                            
                            let finalRect = faceObservation.boundingBox.applying(translate).applying(transform)
                            faceRect.frame = finalRect
                            
                        }
                        
                    }
                    
                }
            }
            
            
        })
        
        return request
    }

}

