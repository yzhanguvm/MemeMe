//
//  MemeCollectionViewController.swift
//  MemeMe
//
//  Created by Zhang, Angie on 7/8/16.
//  Copyright © 2016 Zhang, Angie. All rights reserved.
//

import UIKit

class MemeCollectionViewController: UICollectionViewController {
    
    
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    
    var memes: [Meme]!
    let space: CGFloat = 3.0
    var portaitDimension: CGFloat = 150.0
    var landscapeDimension: CGFloat = 150.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Sent Memes"
        
        let applicationDelegate = (UIApplication.sharedApplication().delegate as! AppDelegate)
        memes = applicationDelegate.memes
        
        portaitDimension = (view.frame.size.width - (2 * space)) / 3.0
        landscapeDimension = (view.frame.size.height - (4 * space)) / 5.0
        
        flowLayout.minimumInteritemSpacing = space
        flowLayout.minimumLineSpacing = space
        if (UIDeviceOrientationIsLandscape(UIDevice.currentDevice().orientation)) {
            flowLayout.itemSize = CGSizeMake(landscapeDimension, landscapeDimension)
        }
        if (UIDeviceOrientationIsPortrait(UIDevice.currentDevice().orientation)) {
            flowLayout.itemSize = CGSizeMake(portaitDimension, portaitDimension)
        }
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        if flowLayout == nil {
            return
        }
        if UIDevice.currentDevice().orientation.isLandscape.boolValue {
            flowLayout.minimumInteritemSpacing = space
            flowLayout.minimumLineSpacing = space
            flowLayout.itemSize = CGSizeMake(landscapeDimension, landscapeDimension)
        } else {
            flowLayout.itemSize = CGSizeMake(portaitDimension, portaitDimension)
        }
    }
    
    
    // MARK: Collection View Data Source
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return memes.count
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("MemeCollectionViewCell", forIndexPath: indexPath) as! MemeCollectionViewCell
        let meme = memes[indexPath.item]
        
        cell.imageView.image = meme.memedImage
        cell.imageView.contentMode = UIViewContentMode.ScaleAspectFit
        return cell
    }
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        let detailController = storyboard!.instantiateViewControllerWithIdentifier("MemeDetailViewController") as! MemeDetailViewController
        detailController.meme = memes[indexPath.row]
        navigationController!.pushViewController(detailController, animated: true)
    }

}