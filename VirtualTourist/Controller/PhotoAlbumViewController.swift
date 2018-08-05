//
//  PhotoAlbumViewController.swift
//  VirtualTourist
//
//  Created by Andrew Llewellyn on 7/16/18.
//  Copyright © 2018 Andrew Llewellyn. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import MapKit
import CoreLocation


class PhotoAlbumViewController: UICollectionViewController, NSFetchedResultsControllerDelegate
{
    @IBOutlet weak var photoCollection: UICollectionView!
    
    
    @IBOutlet weak var collectionFlow: UICollectionViewFlowLayout!
    
    var dataController: DataController!
    
    var pin: Pin?
    
     var fetchedResultsController: NSFetchedResultsController<Photo>!
    
    var lat: Double?
    
    var lon: Double?
    
    var location: CLLocation!
    
    var photoAlbum = [Data]()
    
    //var fetchedResultsController: NSFetchedResultsController<Photo>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //setFetchedResultsController()
        
       // lat = pin?.coordinate.latitude
        //lon = pin?.coordinate.longitude
        
        
        
        let space: CGFloat = 3.0
        let widthDimension = (view.frame.size.width - (2*space)) / 3.0
        let heightDimension = (view.frame.size.height - (2*space)) / 5.0
        
        collectionFlow.minimumInteritemSpacing = space
        collectionFlow.minimumLineSpacing = space
        collectionFlow.itemSize = CGSize(width: widthDimension, height: heightDimension)
        
       loadPhotos()
    
    }
    
  /*  fileprivate func setFetchedResultsController() {
        let fetchRequest: NSFetchRequest<Photo> = Photo.fetchRequest()
        
       // let sortDescriptor = NSSortDescriptor( key: "creationDate", ascending: false)
        //fetchRequest.sortDescriptors = [sortDescriptor]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        do{
            try fetchedResultsController.performFetch()
        }
        catch {
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
    }*/
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return 9
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoCell", for: indexPath) as! PhotoCell
        
        //let photo = photoAlbum[(indexPath as NSIndexPath).row]
        
        if photoAlbum.count == 9
        {
            let photo = photoAlbum[(indexPath as NSIndexPath).row]
            cell.imageView.image = UIImage(data: photo)
            cell.activityIndicator.isHidden = true
        }
        else{
            cell.backgroundColor = UIColor.lightGray
            cell.imageView.image = nil
            cell.activityIndicator.isHidden = false
            cell.activityIndicator.startAnimating()
        }
        
        //cell.image = photo
        
        return cell
    }
    
    
    
    func loadPhotos()
    {
        GetPhotos.sharedInstance().searchByLatLon(lat!, lon!, dataController: dataController, pin: pin!)
        {
            
        
            self.photoAlbum = GetPhotos.sharedInstance().photoAlbum
            
            performUIUpdatesOnMain
            {
                self.photoCollection.reloadData()
            }
        }
    }
    
}
