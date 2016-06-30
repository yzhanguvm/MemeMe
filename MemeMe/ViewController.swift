//
//  ViewController.swift
//  MemeMe
//
//  Created by Zhang, Angie on 6/27/16.
//  Copyright © 2016 Zhang, Angie. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var albumButton: UIBarButtonItem!
    
    @IBOutlet weak var topText: UITextField!
    @IBOutlet weak var bottomText: UITextField!
        
    @IBOutlet weak var topToolBar: UIToolbar!
    @IBOutlet weak var bottomToolBar: UIToolbar!
    
    let memeTextAttributes = [
        NSStrokeColorAttributeName : UIColor.blackColor(),
        NSForegroundColorAttributeName : UIColor.blackColor(),
        
        NSFontAttributeName : UIFont(name: "HelveticaNeue-CondensedBlack", size: 36)!,
        NSStrokeWidthAttributeName : -3    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        topText.delegate = self
        bottomText.delegate = self
        
        view.bringSubviewToFront(topText);
        view.bringSubviewToFront(bottomText);
    }
    
    override func viewWillAppear(animated: Bool) {
        cameraButton.enabled = UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)
        
        setTextField(topText, text: "TOP")
        setTextField(bottomText, text: "BOTTOM")
        
        subscribeToKeyboardNotifications(#selector(ViewController.keyboardWillShow(_:)), notification: UIKeyboardWillShowNotification)
        subscribeToKeyboardNotifications(#selector(ViewController.keyboardWillHide(_:)), notification: UIKeyboardWillHideNotification)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }
    
    // MARK: pick images
    
    @IBAction func pickAnImageFromCamera(sender: UIBarButtonItem) {
        pickAnImage(UIImagePickerControllerSourceType.Camera)
    }
    
    @IBAction func pickAnImageFromAlbum(sender: UIBarButtonItem) {
        pickAnImage(UIImagePickerControllerSourceType.PhotoLibrary)
    }

    func pickAnImage(sourceType: UIImagePickerControllerSourceType) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = sourceType
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imageView.contentMode = .ScaleAspectFit
            imageView.image = pickedImage
        }
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    // MARK: textFields
    
    func setTextField(textField: UITextField, text: String) {
        textField.text = text
        textField.defaultTextAttributes = memeTextAttributes
        textField.textAlignment = .Center
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        
        // Figure out what the new text will be, if we return true
        var newText: NSString = textField.text!
        newText = newText.stringByReplacingCharactersInRange(range, withString: string)
        
        textField.textAlignment = .Center
        
        // returning true gives the text field permission to change its text
        return true
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // MARK: show and hide keyboard
    
    func keyboardWillShow(notification: NSNotification) {
        if bottomText.isFirstResponder() && view.frame.origin.y == 0 {
            view.frame.origin.y -= getKeyboardHeight(notification)
        }
    }
    
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.CGRectValue().height
    }
    
    func subscribeToKeyboardNotifications(selector: Selector, notification name: String) {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: selector, name: name, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardFrameEndUserInfoKey, object: nil)
    }
    
    func keyboardWillHide(notification: NSNotification) {
        view.frame.origin.y = 0
    }
    
    // MARK: memed image
    
    func generateMemedImage() -> UIImage
    {
        topToolBar.hidden = true
        bottomToolBar.hidden = true
        
        // Render view to an image
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawViewHierarchyInRect(self.view.frame, afterScreenUpdates: true)
        let memedImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        topToolBar.hidden = false
        bottomToolBar.hidden = false
        
        return memedImage
    }
    
    // MARK: share image
    
    struct Meme {
        let topString: String
        let bottomString: String
        let originalImage: UIImage?
        let memedImage: UIImage
        
    }
    
    func save() -> Meme {
        //Create the meme object
        return Meme( topString: topText.text!, bottomString: bottomText.text!, originalImage:
            imageView.image, memedImage: generateMemedImage())
    }
    
    @IBAction func shareImage(sender: UIBarButtonItem) {
        
        let meme: Meme = save()
        let shareItems: Array = [meme.memedImage]
        let activityViewController: UIActivityViewController = UIActivityViewController(activityItems: shareItems, applicationActivities: nil)
        activityViewController.excludedActivityTypes = [UIActivityTypePrint, UIActivityTypePostToWeibo, UIActivityTypeCopyToPasteboard, UIActivityTypeAddToReadingList, UIActivityTypePostToVimeo]
        presentViewController(activityViewController, animated: true, completion: nil)
    }
    
    // MARK: cancel
    
    @IBAction func cancelEditting(sender: UIBarButtonItem) {
        topText.text = "TOP"
        bottomText.text = "BOTTOM"
        imageView.image = nil
    }
    
}

