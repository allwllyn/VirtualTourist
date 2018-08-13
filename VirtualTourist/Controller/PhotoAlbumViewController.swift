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
    
    //var fetchedResultsController: NSFetchedResultsController<Photo>!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        setupFetchedResultsController()
        
       // lat = pin?.coordinate.latitude
        //lon = pin?.coordinate.longitude
        
        let space: CGFloat = 3.0
        let widthDimension = (view.frame.size.width - (2*space)) / 3.0
        let heightDimension = (view.frame.size.height - (2*space)) / 5.0
        
        collectionFlow.minimumInteritemSpacing = space
        collectionFlow.minimumLineSpacing = space
        collectionFlow.itemSize = CGSize(width: widthDimension, height: heightDimension)
        
        reloadAfterTime()
        
        //fetchPhotos()
        
      // loadPhotos()
    
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        photoCollection.reloadData()
        
    }
    
    func reloadAfterTime(delayTime: TimeInterval = 0.2){
        photoCollection.reloadData()
    }
    
  /*  fileprivate func setFetchedResultsController() {
        let fetchRequest: NSFetchRequest<Photo> = Photo.fetchRequest()
        
       // let sortDescriptor = NSSortDescriptor( key: "creationDate", ascending: false)
        //fetchRequest.sortDescriptors = [sortDescriptor]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        do
        {
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
    
   /* override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoCell", for: indexPath) as! PhotoCell
        
        //let photo = photoAlbum[(indexPath as NSIndexPath).row]
        
        if photoAlbum.count == 9
        {
            let photo = photoAlbum[(indexPath as NSIndexPath).row]
            cell.imageView.image = UIImage(data: photo)
            cell.activityIndicator.isHidden = true
        }
        else
        {
            cell.backgroundColor = UIColor.lightGray
            cell.imageView.image = nil
            cell.activityIndicator.isHidden = false
            cell.activityIndicator.startAnimating()
        }
        
        //cell.image = photo
        
        return cell
    }*/
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
    
       let cell = photoCollection.dequeueReusableCell(withReuseIdentifier: "photoCell", for: indexPath) as! PhotoCell
        
        if (fetchedResultsController.fetchedObjects?.count)! == 9
        {
        let aPhoto = fetchedResultsController.object(at: indexPath).binary!
            cell.activityIndicator.isHidden = true
            cell.imageView.image = UIImage(data: aPhoto)
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
    
    
    /*func fetchPhotos()
    {
        
        print("fetchPhotos function has been called")
        
        let fetchRequest: NSFetchRequest<Photo> = Photo.fetchRequest()
        
        // MARK: sort by creationDate?
        let predicate = NSPredicate(format: "pin == %@", pin)
        fetchRequest.predicate = predicate
        let sortDescriptor = NSSortDescriptor(key: "binary", ascending: true)
        
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        if let result = try? dataController.viewContext.fetch(fetchRequest)
        {
            print("*********************************************************")
            print(result.count)
            print("*********************************************************")
            print(result[0].binary)
            for i in result
            {
                if photoAlbum.count < 9
                {
                photoAlbum.append(i.binary!)
                }
            }
        }
    }*/
    
    
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
