//
//  PhotoTakingHelper.swift
//  Makestagram
//
//  Created by sakura davis on 7/1/16.
//  Copyright © 2016 Make School. All rights reserved.
//

import UIKit

//a function of type PhotoTakingHelperCallback has one parameter (a UIImage?) and returns Void.
typealias PhotoTakingHelperCallback = UIImage? -> Void

class PhotoTakingHelper : NSObject {
    
    //viewController stores a weak reference to a UIViewController.
    //View controller on which AlertViewController and UIImagePickerController are presented
    weak var viewController: UIViewController!
    var callback: PhotoTakingHelperCallback
    var imagePickerController: UIImagePickerController?
    
     //The initializer of this class receives the view controller on which we will present other view controllers and the callback that we will call as soon as a user has picked an image.
    init(viewController: UIViewController, callback: PhotoTakingHelperCallback) {
        self.viewController = viewController
        self.callback = callback
        
        super.init()
      
        //present the dialog that allows users to choose between their camera and their photo library.
        showPhotoSourceSelection()
    }
    
    func showPhotoSourceSelection() {
        // Allow user to choose between photo library and camera
       
        //By choosing the .ActionSheet option we create a popup that gets displayed from the bottom edge of the screen.
        let alertController = UIAlertController(title: nil, message: "Where do you want to get your picture from?", preferredStyle: .ActionSheet)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        alertController.addAction(cancelAction)
        
    
        
        // Only show camera option if rear camera is available
        //check if the current device has a rear camera by using the isCameraDeviceAvailable(_:) method
        if (UIImagePickerController.isCameraDeviceAvailable(.Rear)) {
            let cameraAction = UIAlertAction(title: "Photo from Camera", style: .Default) { (action) in
                //we add an action to the alert controller that allows the user to take a new photo
                self.showImagePickerController(.Camera)
            }
            
            alertController.addAction(cameraAction)
        }
        
        let photoLibraryAction = UIAlertAction(title: "Photo from Library", style: .Default) { (action) in
            self.showImagePickerController(.PhotoLibrary)
            //We call showImagePickerController and pass either .PhotoLibrary or .Camera as argument - based on the user's choice.
        }
        
        alertController.addAction(photoLibraryAction)

        
        viewController.presentViewController(alertController, animated: true, completion: nil)
    }
    
    func showImagePickerController(sourceType: UIImagePickerControllerSourceType) {
        //creates a UIImagePickerController.
        imagePickerController = UIImagePickerController()
      //  Depending on the sourceType the UIImagePickerController will activate the camera and display a photo taking overlay - or will show the user's photo library
        imagePickerController!.sourceType = sourceType
        //Sign up to become the delegate of the UIImagePickerController
        imagePickerController!.delegate = self
        //Once the imagePickerController is initialized and configured, we present it.
        self.viewController.presentViewController(imagePickerController!, animated: true, completion: nil)
    }
    
}

extension PhotoTakingHelper: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    //We implement two different delegate methods: One is called when an image is selected, the other is called when the cancel button is tapped.
    
    //First we hide the image picker controller, then we call the callback and hand it the image that has been selected as an argument. After this line runs the TimelineViewController will have received the image through its callback closure.
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
        viewController.dismissViewControllerAnimated(false, completion: nil)
        callback(image)
    }
    
    //Hide the image picker controller by calling dismissViewControllerAnimated on viewController.
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        viewController.dismissViewControllerAnimated(true, completion: nil)
    }
    
}