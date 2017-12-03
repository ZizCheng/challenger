//
//  ChallengeResponseCamera.swift
//  Challenger MessagesExtension
//
//  Created by Zizheng Cheng on 11/1/17.
//  Copyright © 2017 Lifely. All rights reserved.
//

import UIKit
import Messages
import AVFoundation
import Photos

class ResponseCameraVC : MSMessagesAppViewController, AVCapturePhotoCaptureDelegate {
    
    @IBOutlet weak var previewView: UIView!
    @IBOutlet weak var capturedImage: UIImageView!
    @IBOutlet weak var goodButton: UIButton!
    @IBOutlet weak var retakeButton: UIButton!
    
    var captureSession: AVCaptureSession!
    var cameraOutput : AVCapturePhotoOutput!
    var previewLayer: AVCaptureVideoPreviewLayer!
    
    var captureDevice : AVCaptureDevice?
    var conversation : MSConversation!
    var tap : UIGestureRecognizer!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        captureSession = AVCaptureSession()
        captureSession.sessionPreset = AVCaptureSession.Preset.high
        cameraOutput = AVCapturePhotoOutput()
        
        let captureDevice = AVCaptureDevice.default(for: AVMediaType.video)
        
        if let input = try? AVCaptureDeviceInput(device: captureDevice!) {
            if (captureSession.canAddInput(input)) {
                captureSession.addInput(input)
                if (captureSession.canAddOutput(cameraOutput)) {
                    captureSession.addOutput(cameraOutput)
                    previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
                    previewLayer.frame = previewView.frame
                    previewLayer.bounds = previewView.bounds
                    previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
                    previewView.layer.addSublayer(previewLayer)
                    captureSession.startRunning()
                }
            } else {
                print("issue here : captureSesssion.canAddInput")
            }
        } else {
            print("some problem here")
        }
        previewView.frame = view.bounds
        previewView.translatesAutoresizingMaskIntoConstraints = true
        
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
        rightSwipe.direction = UISwipeGestureRecognizerDirection.right
        tap = UITapGestureRecognizer(target: self, action: #selector(self.respondToTapGesture))
        self.view.addGestureRecognizer(rightSwipe)
        self.view.addGestureRecognizer(tap)
        
        self.view.sendSubview(toBack: goodButton)
        self.view.sendSubview(toBack: retakeButton)
    }
    
    @objc func respondToTapGesture(gesture: UIGestureRecognizer)
    {
        let settings = AVCapturePhotoSettings()
        let previewPixelType = settings.availablePreviewPhotoPixelFormatTypes.first!
        let previewFormat = [
            kCVPixelBufferPixelFormatTypeKey as String: previewPixelType,
            kCVPixelBufferWidthKey as String: self.previewView.frame.width,
            kCVPixelBufferHeightKey as String: self.previewView.frame.height
        ] as [String : Any]
        settings.previewPhotoFormat = previewFormat
        
        cameraOutput.capturePhoto(with: settings, delegate: self)
    }
    func photoOutput(_ captureOutput: AVCapturePhotoOutput, didFinishProcessingPhoto photoSampleBuffer: CMSampleBuffer?, previewPhoto previewPhotoSampleBuffer: CMSampleBuffer?, resolvedSettings: AVCaptureResolvedPhotoSettings, bracketSettings: AVCaptureBracketedStillImageSettings?, error: Error?)
    {
        
        if let error = error
        {
            print("error occured : \(error.localizedDescription)")
        }
        
        if  let sampleBuffer = photoSampleBuffer,
            let previewBuffer = previewPhotoSampleBuffer,
            let dataImage =  AVCapturePhotoOutput.jpegPhotoDataRepresentation(forJPEGSampleBuffer:  sampleBuffer, previewPhotoSampleBuffer: previewBuffer)
        {
            
            let dataProvider = CGDataProvider(data: dataImage as CFData)
            let cgImageRef: CGImage! = CGImage(jpegDataProviderSource: dataProvider!, decode: nil, shouldInterpolate: true, intent: .defaultIntent)
            let image = UIImage(cgImage: cgImageRef, scale: 1.0, orientation: UIImageOrientation.right)
            
            self.capturedImage.image = image
            gotImage()
            
        }
        else
        {
            print("error")
        }
    }
    
    func gotImage()
    {
        self.view.removeGestureRecognizer(tap)
        self.view.sendSubview(toBack: previewView)
        self.view.bringSubview(toFront: goodButton)
        self.view.bringSubview(toFront: retakeButton)
        captureSession.stopRunning()
    }
    func createResponseImage(image: UIImage, challenge: String) -> UIImage
    {
        return image
    }
    override func didBecomeActive(with conversation: MSConversation)
    {
        self.conversation = conversation
    }
    @objc func respondToSwipeGesture(gesture: UIGestureRecognizer)
    {
        self.requestPresentationStyle(MSMessagesAppPresentationStyle.compact)
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "CDVC") as! ChallengeDecisionVC
        self.present(vc, animated: false, completion: nil)
    }
    @IBAction func goodButtonClick(_ sender: UIButton)
    {
        /*let conversation = activeConversation
        let session = conversation?.selectedMessage?.session ?? MSSession()
        let price = prizeBox.text
        let challenge = challengeBox.text
        
        let layout = MSMessageTemplateLayout()
        layout.image = createImageForMessage(text: challenge!)
        layout.subcaption = price
        
        var components = URLComponents()
        let id = URLQueryItem(name: "Type", value: "Issued")
        let cid = URLQueryItem(name: "Challenge", value: challenge)
        components.queryItems = [id, cid]
        
        let message = MSMessage(session: session)
        message.layout = layout
        message.url = components.url
        message.summaryText = "You have been challenged..."
        
        conversation?.insert(message)*/
        
        conversation = activeConversation
        if(conversation == nil)
        {
            conversation = MSConversation()
        }
        let session = conversation?.selectedMessage?.session ?? MSSession()
        
        let layout = MSMessageTemplateLayout()
        layout.image = self.capturedImage.image
        layout.subcaption = "Completed!"
        
        var components = URLComponents()
        let id = URLQueryItem(name: "Type", value: "completed")
        let cid = URLQueryItem(name: "Challenge", value: "challenge")
        components.queryItems = [id, cid]
        
        let message = MSMessage(session: session)
        message.layout = layout
        message.url = components.url
        message.summaryText = "Done"
        
        conversation?.insert(message, completionHandler: nil)
        
        self.requestPresentationStyle(.compact)
    }
    @IBAction func retakeButtonClick(_ sender: UIButton)
    {
        self.view.addGestureRecognizer(tap)
        self.view.bringSubview(toFront: previewView)
        self.view.sendSubview(toBack: goodButton)
        self.view.sendSubview(toBack: retakeButton)
        captureSession.startRunning()
    }
    
}
