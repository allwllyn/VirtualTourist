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
    
    var pin: Pin!
    
    var fetchedResultsController: NSFetchedResultsController<Photo>!
    
    var lat: Double?
    
    var lon: Double?
    
    var location: CLLocation!
    
    var photoAlbum = [Data]()
    
    let dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateStyle = .medium
        return df
    }()
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        setupFetchedResultsController()
        
        let space: CGFloat = 3.0
        let widthDimension = (view.frame.size.width - (2*space)) / 3.0
        let heightDimension = (view.frame.size.height - (2*space)) / 5.0
        
        collectionFlow.minimumInteritemSpacing = space
        collectionFlow.minimumLineSpacing = space
        collectionFlow.itemSize = CGSize(width: widthDimension, height: heightDimension)
        
        reloadAfterTime()
    
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        photoCollection.reloadData()
        
    }
    
    func reloadAfterTime(delayTime: TimeInterval = 0.2){
        photoCollection.reloadData()
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return fetchedResultsController.fetchedObjects?.count ?? 9
    }
    
 
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
    
       let cell = photoCollection.dequeueReusableCell(withReuseIdentifier: "photoCell", for: indexPath) as! PhotoCell
        
        if (fetchedResultsController.fetchedObjects?.count)! != 0
        {
            if let aPhoto = fetchedResultsController.object(at: indexPath).binary
            {
            cell.activityIndicator.isHidden = true
            cell.imageView.image = UIImage(data: aPhoto)
            }
        }
        else
        {
            cell.backgroundColor = UIColor.lightGray
            cell.imageView.image = nil
            cell.activityIndicator.isHidden = false
            cell.activityIndicator.startAnimating()
        }
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        deletePhoto(at: indexPath)
        photoCollection.reloadData()
        self.loadView()
    }
    
    
    
    func loadPhotos()
    {
        GetPhotos.sharedInstance().photoAlbum = []
        
        GetPhotos.sharedInstance().searchByLatLon(lat!, lon!, dataController: dataController, pin: pin!)
        {
            self.photoAlbum = GetPhotos.sharedInstance().photoAlbum
            
            performUIUpdatesOnMain
            {
                self.photoCollection.reloadData()
            }
        }
    }
    
    func deletePhoto(at indexPath: IndexPath) {
        let photoToDelete = fetchedResultsController.object(at: indexPath)
        dataController.viewContext.delete(photoToDelete)
        try? dataController.viewContext.save()
    }
    
  @IBAction func newSet()
    {
        let photosToDelete = fetchedResultsController.fetchedObjects as! [Photo]
        
        for photo in photosToDelete
        {
            dataController.viewContext.delete(photo)
            do
            {try dataController.viewContext.save()
            }
            catch{
                print("Could not delete")
            }
        }
        GetPhotos.sharedInstance().photoAlbum = []
        
        GetPhotos.sharedInstance().searchByLatLon(lat!, lon!, dataController: dataController, pin: pin!)
        {
            self.photoAlbum = GetPhotos.sharedInstance().photoAlbum
            
            performUIUpdatesOnMain
            {
                self.setupFetchedResultsController()
                self.photoCollection.reloadData()
            }
        }
    }
    
    fileprivate func setupFetchedResultsController() {
        let fetchRequest:NSFetchRequest<Photo> = Photo.fetchRequest()
        let predicate = NSPredicate(format: "pin == %@", pin)
        fetchRequest.predicate = predicate
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: "\(pin)-photos")
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
    }
}
