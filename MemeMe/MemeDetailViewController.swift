//
//  MemeDetailViewController.swift
//  MemeMe
//
//  Created by Zhang, Angie on 7/8/16.
//  Copyright © 2016 Zhang, Angie. All rights reserved.
//

import UIKit

class MemeDetailViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    
    var meme: Meme!
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        tabBarController?.tabBar.hidden = true
        
        imageView!.image = meme.memedImage
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.hidden = false
    }
    
    @IBAction func editMemedImage(sender: UIBarButtonItem) {
        performSegueWithIdentifier("editMeme", sender: sender)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "editMeme") {
            let editorViewController = segue.destinationViewController as! MemeEditorViewController
            editorViewController.meme = meme
        }
    }
    
}

