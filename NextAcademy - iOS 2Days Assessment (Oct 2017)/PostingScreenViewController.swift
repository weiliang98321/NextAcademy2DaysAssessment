//
//  PostingScreenViewController.swift
//  NextAcademy - iOS 2Days Assessment (Oct 2017)
//
//  Created by Tan Wei Liang on 23/12/2017.
//  Copyright © 2017 Tan Wei Liang. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import FirebaseStorage
import FirebaseDatabase
import FirebaseAuth

class PostingScreenViewController: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var eventImage: UIImageView!
    @IBOutlet weak var eventNameTextField: UITextField!
    @IBOutlet weak var venueTextField: UITextField!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var mapView: MKMapView!
    var ref : DatabaseReference!
    static var uniqueID : [String] = []
    @IBOutlet weak var createEventBtn: UIButton!
    
    @IBAction func createEventBtnTapped(_ sender: Any) {
        
        ref = Database.database().reference()
        guard let name = eventNameTextField.text,
            let venue = venueTextField.text
            
            else { return }
        
        let date = datePicker.date.timeIntervalSince1970
        
        let timestmp = ServerValue.timestamp()
        
        let post : [String:Any] = ["name": name,"venue": venue,"eventImageURL": self.eventPicURL,"latitude" : venueLatitude,"longtitude": venueLongtitude,"eventDate" : date,"DateRecCreated": timestmp]
        var post1Ref = ref.child("Events").childByAutoId()
        post1Ref.setValue(post)
        var postID = post1Ref.key
        
        
        
        ref.child("Events").childByAutoId().updateChildValues(post)
        
        
        self.navigationController?.popViewController(animated: true)
        
        
    }
    
    let manager = CLLocationManager()
    
    var locationAnnotations: String = ""
    
    var eventPicURL : String = ""
    
    var currFilename : String = ""
    
    var venueLatitude : Double = 3.133845
    var venueLongtitude : Double = 101.62998
    
    @objc func enableLoginBtn() {
        
        if eventNameTextField.text == "" || venueTextField.text == "" {
            createEventBtn.isEnabled = false
        } else {
            createEventBtn.isEnabled = true
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[0]
        let span:MKCoordinateSpan = MKCoordinateSpanMake(0.01, 0.01)
        let mylocation:CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        let region:MKCoordinateRegion = MKCoordinateRegionMake(mylocation, span)
        mapView.setRegion(region, animated: true)
        
        self.mapView.showsUserLocation = true
    }
    
    @objc func handleTap(gestureReconizer: UILongPressGestureRecognizer) {
        
        let location = gestureReconizer.location(in: mapView)
        var coordinate = mapView.convert(location,toCoordinateFrom: mapView)
        
        // Add annotation:
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        mapView.addAnnotation(annotation)
        venueLatitude = coordinate.latitude
        venueLongtitude = coordinate.longitude
        //coordinate.longitude = venueLongtitude
        print(venueLatitude)
        print(venueLongtitude)
        
        //locationAnnotations.append(coordinate)
    }
    //open Apple map
    func openMapForPlace() {
        
        let latitude: CLLocationDegrees = 37.2
        let longitude: CLLocationDegrees = 22.9
        
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        mapView.delegate = self as! MKMapViewDelegate
        mapView.mapType = .satellite
        mapView.showsCompass = true
        
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
        
        let gestureRecognizer = UILongPressGestureRecognizer(target: self, action:#selector (handleTap))
        gestureRecognizer.delegate = self as? UIGestureRecognizerDelegate
        gestureRecognizer.minimumPressDuration = 1.0
        mapView.addGestureRecognizer(gestureRecognizer)
        
        //openMapForPlace()
        
        self.hideKeyboardWhenTappedAround()
        NotificationCenter.default.addObserver(self, selector: #selector(enableLoginBtn), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(enableLoginBtn), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    
}

extension PostingScreenViewController : MKMapViewDelegate,UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        guard let title = annotation.title
            else { return nil }
        
        
        let redPinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "pin")
        redPinView.pinTintColor = UIColor.purple
        
        redPinView.canShowCallout = true
        return redPinView
        
        
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        print("Btn tapped")
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        //print(view.annotation?.title)
        
        //Click on the annotation(point), zoom in the map
        guard let center = view.annotation?.coordinate
            else{ return }
        
        let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        let region = MKCoordinateRegion(center: center, span: span)
        mapView.setRegion(region, animated: true)
        
        
    }
    
    func uploadImageToStorage(_ image: UIImage) {
        let ref = Storage.storage().reference()
        
        let timeStamp = Date().timeIntervalSince1970
        
        //compress image so that the image isn't too big
        guard let imageData = UIImageJPEGRepresentation(image, 0.2) else {return}
        
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpeg"
        
        //metadata gives us the url to retrieve the data on the cloud
        
        ref.child("\(timeStamp).jpeg").putData(imageData, metadata: metaData) { (meta, error) in
            if let validError = error {
                print(validError.localizedDescription)
            }
            
            if let downloadPath = meta?.downloadURL()?.absoluteString {
                self.eventPicURL = downloadPath
                self.eventImage.image = image
            }
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        defer {
            dismiss(animated: true, completion: nil)
        }
        
        guard let image = info[UIImagePickerControllerOriginalImage] as? UIImage else {
            return
        }
        
        uploadImageToStorage(image)
        
    }
    
    func createErrorAlert(_ title: String, _ message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "Error", style: .default, handler: nil)
        alert.addAction(action)
        
        present(alert, animated: true, completion:  nil)
        
    }
    
}
