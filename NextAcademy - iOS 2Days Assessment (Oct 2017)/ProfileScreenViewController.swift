//
//  ProfileScreenViewController.swift
//  NextAcademy - iOS 2Days Assessment (Oct 2017)
//
//  Created by Tan Wei Liang on 23/12/2017.
//  Copyright © 2017 Tan Wei Liang. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseStorage
import FirebaseDatabase

class ProfileScreenViewController: UIViewController {
    
    var events : [Event] = []
    var ref : DatabaseReference!
    var userId : String = ""
    var selectedEvents : Event?
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var firstNameLabel: UILabel!
    @IBOutlet weak var lastNameLabel: UILabel!
    @IBAction func signOutBtnTapped(_ sender: Any) {
        signOutUser()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        fetchUser()
        fetchEvents()
        // Do any additional setup after loading the view.
    }
    
    func fetchUser() {
        ref = Database.database().reference()
        guard let uid = Auth.auth().currentUser?.uid else {return}
        userId = uid
        
        ref.child("Users").child(userId).observe(.value, with: { (snapshot) in
            
            guard let info = snapshot.value as? [String: Any] else {return}
            
            //cast snapshot.value to correct Datatype
            if let email = info["email"] as? String,
                let firstName = info["firstName"] as? String,
                let lastName = info["lastName"] as? String{
                self.emailLabel.text = email
                self.firstNameLabel.text = firstName
                self.lastNameLabel.text = lastName
            }
            
            
            
        })
    }
    
    func fetchEvents() {
        
        ref = Database.database().reference()
        guard let uid = Auth.auth().currentUser?.uid else {return}
        userId = uid
        
        ref.child("Users").child(userId).child("events").observe(.childAdded, with: { (snapshot) in
            
            guard let info = snapshot.value as? [String : Any] else {return}
            
            if  let eventName = info["name"] as? String,
                let venue = info["venue"] as? String,
                let eventImageURL = info["eventImageURL"] as? String,
                let eventDate = info["eventDate"] as? String,
                let eventTime = info["eventTime"] as? String,
                let latitude = info["latitude"] as? Double,
                let longtitude = info["longtitude"] as? Double
                
            {
                
                self.ref.queryOrdered(byChild: "eventDate")
                
                
                // self.contacts.removeAll()
                DispatchQueue.main.async {
                    let newEvents = Event(aName: eventName,aDate: eventDate, aTime: eventTime, aVenue: venue, aLatitude: latitude, aLongtitude: longtitude, anImageURL: eventImageURL)
                    self.selectedEvents = newEvents
                    self.events.append(newEvents)
                    
                    
                    print(newEvents)
                    
                    let index = self.events.count - 1
                    let indexPath = IndexPath(row: index, section: 0)
                    self.tableView.insertRows(at: [indexPath], with: .right)
                }
                
                
                return
            }
        })
        
        
    }
    
    func signOutUser() {
        do {
            try Auth.auth().signOut()
            dismiss(animated: true, completion: nil)
            
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
    
    func createDateString(_ timeStamp: Double) -> String {
        let date = Date(timeIntervalSince1970: timeStamp)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat  = "dd/MM/yyyy"
        
        return dateFormatter.string(from: date)
    }
    
    func createTimeString(_ timeStamp: Double) -> String {
        let date = Date(timeIntervalSince1970: timeStamp)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat  = "hh:mm a"
        
        return dateFormatter.string(from: date)
    }
}

extension ProfileScreenViewController : UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return events.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //1.get the cell
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "eventCell", for: indexPath) as? ProfileScreenTableViewCell else { return UITableViewCell() }
        
        
        var aEvent = events[indexPath.row]
        
        cell.eventNameLabel.text = aEvent.name
        cell.dateLabel.text = aEvent.date
        cell.venueLabel.text = aEvent.venue
        
        //
        
        return cell
    }
    
}

extension ProfileScreenViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        guard let destination = storyboard?.instantiateViewController(withIdentifier: "DetailScreenViewController") as? DetailScreenViewController else {return}
        
        let selectedEvents = events[indexPath.row]
        
        destination.selectedEvents = selectedEvents
        
        navigationController?.pushViewController(destination, animated: true)
        
    }
    
    
}
