//
//  ViewController.swift
//  MemeMe
//
//  Created by Zhang, Angie on 6/27/16.
//  Copyright © 2016 Zhang, Angie. All rights reserved.
//

import UIKit

class MemeEditorViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var albumButton: UIBarButtonItem!
    
    @IBOutlet weak var topText: UITextField!
    @IBOutlet weak var bottomText: UITextField!
        
    @IBOutlet weak var topToolBar: UIToolbar!
    @IBOutlet weak var bottomToolBar: UIToolbar!
    
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    
    var meme: Meme?
    
    let memeTextAttributes = [
        NSStrokeColorAttributeName : UIColor.blackColor(),
        NSForegroundColorAttributeName : UIColor.whiteColor(),
        
        NSFontAttributeName : UIFont(name: "HelveticaNeue-CondensedBlack", size: 36)!,
        NSStrokeWidthAttributeName : -5    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate = (UIApplication.sharedApplication().delegate as! AppDelegate)
        if appDelegate.memes.count == 0 {
            cancelButton.enabled = false
        }
        if meme == nil {
            shareButton.enabled = false
        }
        topText.delegate = self
        bottomText.delegate = self
        
        view.bringSubviewToFront(topToolBar);
        view.bringSubviewToFront(bottomToolBar);
        
        view.bringSubviewToFront(topText);
        view.bringSubviewToFront(bottomText);
    }
    
    override func viewWillAppear(animated: Bool) {
        cameraButton.enabled = UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)
        
        if meme != nil {
            setTextField(topText, text: meme!.topString)
            setTextField(bottomText, text: meme!.bottomString)
            imageView.image = meme!.originalImage
        } else {
            setTextField(topText, text: "TOP")
            setTextField(bottomText, text: "BOTTOM")
        }
        
        subscribeToKeyboardNotifications(#selector(MemeEditorViewController.keyboardWillShow(_:)), notification: UIKeyboardWillShowNotification)
        subscribeToKeyboardNotifications(#selector(MemeEditorViewController.keyboardWillHide(_:)), notification: UIKeyboardWillHideNotification)
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
            shareButton.enabled = true
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
    
    func saveOriginalImage() -> UIImage {
        
        
        topText.hidden = true
        bottomText.hidden = true
        
        let image = generateImage()
        
        topText.hidden = false
        bottomText.hidden = false
        
        return image
    }
    
    func generateImage() -> UIImage {
        
        topToolBar.hidden = true
        bottomToolBar.hidden = true
        
        // Render view to an image
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawViewHierarchyInRect(self.view.frame, afterScreenUpdates: true)
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        topToolBar.hidden = false
        bottomToolBar.hidden = false
        
        return image
    }
    
    // MARK: share image
    
    func save() -> Meme {
        //Create the meme object
        let meme = Meme( topString: topText.text!, bottomString: bottomText.text!, originalImage: saveOriginalImage(), memedImage: generateImage())
        
        //Add it to the memes array on the Application Delegate
        (UIApplication.sharedApplication().delegate as! AppDelegate).memes.append(meme)
        return meme
    }
    
    @IBAction func shareImage(sender: UIBarButtonItem) {
        
        let meme: Meme = save()
        let shareItems: Array = [meme.memedImage]
        let activityViewController: UIActivityViewController = UIActivityViewController(activityItems: shareItems, applicationActivities: nil)
        activityViewController.excludedActivityTypes = [UIActivityTypePrint, UIActivityTypePostToWeibo, UIActivityTypeCopyToPasteboard, UIActivityTypeAddToReadingList, UIActivityTypePostToVimeo]
        activityViewController.completionWithItemsHandler = {activity, success, items, error in
            if (success) {
                self.performSegueWithIdentifier("showSentMemes", sender: nil)
            }
        
        }
        
        presentViewController(activityViewController, animated: true, completion: nil)
    }
    
//    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//        if (segue.identifier == "showSentMemes") {
//            segue.destinationViewController as! UITabBarController
//        }
//    }
//    @IBAction func unwindToCancel(segue: UIStoryboardSegue, sender: AnyObject) {
//        performSegueWithIdentifier("showSentMemes", sender: sender)
//    }
    
    @IBAction func cancelEditting(sender: AnyObject) {
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
}

