//
//  PhotoCell.swift
//  VirtualTourist
//
//  Created by Andrew Llewellyn on 7/21/18.
//  Copyright © 2018 Andrew Llewellyn. All rights reserved.
//


import Foundation
import UIKit



class PhotoCell: UICollectionViewCell
{
    
    
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func prepareForReuse()
    {
        
        super.prepareForReuse()
        
        if imageView.image == nil {
            activityIndicator.isHidden = false
            activityIndicator.startAnimating()
        }
    }
        
}

    
