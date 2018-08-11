//
//  ViewController.swift
//  VirtualTourist
//
//  Created by Andrew Llewellyn on 6/26/18.
//  Copyright © 2018 Andrew Llewellyn. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import MapKit
import CoreLocation


class MapViewController: UIViewController, MKMapViewDelegate, NSFetchedResultsControllerDelegate
{

    var pins: [Pin]?
    
    var seguePin: Pin!
    
    var fetchedResultsController: NSFetchedResultsController<Pin>!
    
    var editMode: Bool = false
    
    @IBOutlet weak var mapView: MKMapView!
    
  
    var dataController: DataController!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        //fetchedResultsController.delegate = self
        
        fetchPins()
        
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(self.mapLongPress(_:))) // colon needs to pass through info
        longPress.minimumPressDuration = 1.5
        mapView.addGestureRecognizer(longPress)
        mapView.delegate = self
        
        loadPins(mapView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super .viewWillAppear(true)
        loadPins(mapView)
    }

    
    //MARK: pin style
    func mapView(_ mapView: MKMapView, viewFor view: MKAnnotation) -> MKAnnotationView?
    {
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil
        {
            pinView = MKPinAnnotationView(annotation: view, reuseIdentifier: reuseId)
            pinView!.canShowCallout = false
            pinView!.pinTintColor = .red
        }
        else
        {
            pinView!.annotation = view
        }
        
        return pinView
    }
    
    //MARK: Trying new tap event method
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView)
    {
        //MARK: fetch to make sure all latest pins are available
        fetchPins()
        
        //segue to photo album view
       var tappedPoint = view.annotation?.coordinate as! CLLocationCoordinate2D
        
        if editMode == false
        {
            //TODO: set segue Pin to be a pin
            for pin in pins!
            {
                if (pin.latitude == tappedPoint.latitude) && (pin.longitude == tappedPoint.longitude)
                {
                    self.seguePin = pin
                    
                }
                else
            
                {
                    continue
                }
            }
            performSegue(withIdentifier: "viewAlbum", sender: self)
        }
        else
        {
            for pin in pins!
            {
                if (pin.latitude == tappedPoint.latitude) && (pin.longitude == tappedPoint.longitude)
                {
                    let removalIndex = pins?.index(of: pin)
                    pins?.remove(at: removalIndex!)
                    deletePin(pin)
                    do {
                   try dataController.viewContext.save()
                    }
                    catch
                    {
                        print("error saving delete")
                    }
                }
                else
                {
                    continue
                }
            }
        }
    }
    
    
    //MARK: Set the long press to drop pin
    @objc func mapLongPress(_ recognizer: UIGestureRecognizer)
    {
        let tappedAt = recognizer.location(in: self.mapView)
        
        let tappedCoordinate : CLLocationCoordinate2D = mapView.convert(tappedAt, toCoordinateFrom: self.mapView) // will get coordinates
        
        addPin(tappedCoordinate)
    }
    
    
    //MARK: ADD A PIN TO MAP AND CONTEXT
    func addPin(_ coordinate: CLLocationCoordinate2D)
    {
       // var newPin = MKPointAnnotation()
        
        let newPin = Pin(context: dataController.viewContext)
       // newPin.coordinate = coordinate
        newPin.latitude = coordinate.latitude
        newPin.longitude = coordinate.longitude
        GetPhotos.sharedInstance().searchByLatLon(newPin.latitude, newPin.longitude, dataController: dataController, pin: newPin){
            print("Photos have loaded for the new pin.")
        }
        
        let mapPin = MKPointAnnotation()
        
        let mapPinCoordinate = CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude)
        
        // TODO: Start downloading photos here
        
        mapPin.coordinate = mapPinCoordinate
        
        mapView.addAnnotation(mapPin)
      
        do
        {
           try  dataController.viewContext.save()
        }
        catch
        {
            print("saving didn't work")
        }
    }
    
    @IBAction func edit(_ sender: Any) {
        
        if editMode == false{
            editMode = true
        }
        else
        {
            editMode = false
        }
        
    }
    
    
    func loadPins(_ mapView: MKMapView)
    {
        
        if (pins?.count)! > 0
        {
            mapView.removeAnnotations(mapView.annotations)
            for pin in pins!
            {
              // let  mapPin = MKAnnotation(coordinate: CLLocationCoordinate2D(latitude: pin.latitude, longitude: pin.longitude)
                
                let mapPin = MKPointAnnotation()
                
                mapPin.coordinate = CLLocationCoordinate2D(latitude: pin.latitude, longitude: pin.longitude)
                
                mapView.addAnnotation(mapPin)
                    
               // performUIUpdatesOnMain {
                  //  mapView.reloadInputViews()
               // }
            }
        }
        else if (pins?.count)! == 0
        {
            if (mapView.annotations.count) != 0
            {
                    mapView.removeAnnotations(mapView.annotations)
            }
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        
        if let vc = segue.destination as? PhotoAlbumViewController
        {
            //vc.location = pinPoint
            vc.dataController = dataController
            vc.pin = seguePin
            vc.lat = seguePin.latitude
            vc.lon = seguePin.longitude
            
        }
    }

    func fetchPins()
    {
        
        print("fetchPins function has been called")
        
        pins = []
        
        let fetchRequest: NSFetchRequest<Pin> = Pin.fetchRequest()
       
        // MARK: sort by location? we'll see how this works
        let sortDescriptor = NSSortDescriptor(key: "latitude", ascending: true)
        
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        if let result = try? dataController.viewContext.fetch(fetchRequest)
        {
            print("*********************************************************")
            print(result.count)
            print("*********************************************************")
            pins = result
        }
    }
    
    func deletePin(_ pin: Pin)
    {
        let mapPin = MKPointAnnotation()
        mapPin.coordinate = CLLocationCoordinate2D(latitude: pin.latitude, longitude: pin.longitude)
        self.mapView.removeAnnotation(mapPin)
        dataController.viewContext.delete(pin)
        fetchPins()
        self.loadPins(self.mapView)
    }

 
    
    /*fileprivate func setFetchedResultsController()
     {
        
        let fetchRequest: NSFetchRequest<Pin> = Pin.fetchRequest()
        
        // MARK: sort by location? we'll see how this works
        let sortDescriptor = NSSortDescriptor(key: "latitude", ascending: true)
        
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        do
        {
            try fetchedResultsController.performFetch()
        }
        catch
        {
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
    }
*/
}

