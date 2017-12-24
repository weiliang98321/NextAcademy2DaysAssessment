//
//  DetailScreenViewController.swift
//  NextAcademy - iOS 2Days Assessment (Oct 2017)
//
//  Created by Tan Wei Liang on 23/12/2017.
//  Copyright © 2017 Tan Wei Liang. All rights reserved.
//

import UIKit
import MapKit
import FirebaseStorage
import FirebaseDatabase
import FirebaseAuth

class DetailScreenViewController: UIViewController , CLLocationManagerDelegate {
    
    var selectedEvents : Event?
    
    @IBOutlet weak var eventImage: UIImageView!
    @IBOutlet weak var eventNameLabel: UILabel!
    @IBOutlet weak var eventDateLabel: UILabel!
    @IBOutlet weak var eventTimeLabel: UILabel!
    
    @IBOutlet weak var mapView: MKMapView!
    
   
    
    @IBOutlet weak var joinBtnTapped: UIButton!
    
    @IBOutlet weak var cancelBtnTapped: UIButton!
    @IBAction func joinBtnTapped(_ sender: Any) {
        joinEvent()
        cancelBtnTapped.isHidden = false
        joinBtnTapped.isHidden = true
    }
    @IBAction func cancelBtnTapped(_ sender: Any) {
        cancelEvent()
        joinBtnTapped.isHidden = false
        cancelBtnTapped.isHidden = true
    }
    
    
    let manager = CLLocationManager()
    var ref : DatabaseReference!
    static var userId : String = ""
    var autoId : String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Details"
        // Do any additional setup after loading the view.
        eventImage.loadImage(from: (selectedEvents?.imageURL)!)
        eventNameLabel.text = selectedEvents?.name
        eventDateLabel.text = selectedEvents?.date
        eventTimeLabel.text = selectedEvents?.time
        
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
        
        mapView.delegate = self
        mapView.mapType = .satellite
        mapView.showsCompass = true
        
        let eventAnnotation = MKPointAnnotation()
        eventAnnotation.coordinate = CLLocationCoordinate2DMake((selectedEvents?.latitude)!, (selectedEvents?.longtitude)!)
        eventAnnotation.title = "Event Location"
        eventAnnotation.subtitle = "We are here"
        
        
        
        mapView.addAnnotation(eventAnnotation)
        
    }
    
    func cancelEvent () {
        
        DetailScreenViewController.remove(parentA: autoId)
    }
    
    
    func joinEvent () {
        guard let name = selectedEvents?.name,
            let venue = selectedEvents?.venue,
            let date = selectedEvents?.date,
            let time = selectedEvents?.time,
            let image = selectedEvents?.imageURL,
            let latitude = selectedEvents?.latitude,
            let longtitude = selectedEvents?.longtitude
            
            else { return }
        
        ref = Database.database().reference()
        guard let uid = Auth.auth().currentUser?.uid else {return}
        DetailScreenViewController.userId = uid
        
        //let event = selectedEvents.
        
        let post : [String:Any] = ["name": name,"venue": venue,"eventImageURL": image,"latitude" : latitude,"longtitude": longtitude,"eventDate" : date,"eventTime": time]
        var post1Ref = ref.child("Users").child(DetailScreenViewController.userId).child("events").childByAutoId()
        post1Ref.updateChildValues(post)
        autoId = post1Ref.key
        
        }
    

    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[0]
        let span:MKCoordinateSpan = MKCoordinateSpanMake(0.001, 0.001)
        let mylocation:CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: (selectedEvents?.latitude)!, longitude: (selectedEvents?.longtitude)!)
        let region:MKCoordinateRegion = MKCoordinateRegionMake(mylocation, span)
        mapView.setRegion(region, animated: true)
        
        self.mapView.showsUserLocation = true
    }
    
    func openMapForPlace() {
        
        let latitude: CLLocationDegrees = (selectedEvents?.latitude)!
        let longitude: CLLocationDegrees = (selectedEvents?.longtitude)!
        
        let regionDistance:CLLocationDistance = 10000
        let coordinates = CLLocationCoordinate2DMake(latitude, longitude)
        let regionSpan = MKCoordinateRegionMakeWithDistance(coordinates, regionDistance, regionDistance)
        let options = [
            MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center),
            MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span)
        ]
        let placemark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = "Place Name"
        mapItem.openInMaps(launchOptions: options)
    }
    
    @IBAction func buttonUploadTapped(_ sender: Any) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self as? UIImagePickerControllerDelegate & UINavigationControllerDelegate
        
        present(imagePicker, animated: true, completion: nil)
    }
    
    
}
extension DetailScreenViewController : MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        guard let title = annotation.title
            else { return nil }
        
        if title == "Kuala Lumpur" {
            let annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "MeePinPoint")
            
            //change the image from pin to mee
            annotationView.image = UIImage(named: "mee")
            
            //show the window ( title and the subtitle ) on top of the pinpoint
            annotationView.canShowCallout = true
            
            //add a button to the callOut
            annotationView.rightCalloutAccessoryView = UIButton(type: .infoLight)
            return annotationView
            
            
        }
        else {
            let redPinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "pin")
            redPinView.pinTintColor = UIColor.purple
            
            redPinView.canShowCallout = true
            let btn = UIButton(type:.infoDark) as UIButton
            redPinView.rightCalloutAccessoryView = btn
            return redPinView
            
        }
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        let ac = UIAlertController(title: "Want to know more  about the place?", message: "Let us lead you to the place", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default){ (action1) in
            self.openMapForPlace()
        })
        present(ac, animated: true)
    }
    
    //Do something when tap on the annotation view
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        //print(view.annotation?.title)
        
        //Click on the annotation(point), zoom in the map
        guard let center = view.annotation?.coordinate
            else{ return }
        
        let span = MKCoordinateSpan(latitudeDelta: 0.001, longitudeDelta: 0.001)
        let region = MKCoordinateRegion(center: center, span: span)
        mapView.setRegion(region, animated: true)
        
        
        
    }
    
    static let ref = Database.database().reference()

    
    static func remove(parentA: String) {
        
        let ref = self.ref.child("Users").child(userId).child("events").child(parentA)
        
        ref.removeValue { error, _ in
            
            print(error)
        }
    }
    
}

