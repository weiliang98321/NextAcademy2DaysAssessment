//
//  SortScreenViewController.swift
//  NextAcademy - iOS 2Days Assessment (Oct 2017)
//
//  Created by Tan Wei Liang on 24/12/2017.
//  Copyright © 2017 Tan Wei Liang. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

class SortScreenViewController: UIViewController {

    var events : [Event] = []
    var ref : DatabaseReference!
    var userId : String = ""
    var selectedEvents : Event?
    
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Sort"
        tableView.dataSource = self
        tableView.delegate = self
        
        fetchEvents()
        // Do any additional setup after loading the view.
    }

    func fetchEvents () {
        
        ref = Database.database().reference()
        guard let uid = Auth.auth().currentUser?.uid else {return}
        userId = uid
        
        ref.child("Events").observe(.childAdded, with: { (snapshot) in
            
            guard let info = snapshot.value as? [String : Any] else {return}
            
            if  let eventName = info["name"] as? String,
                let venue = info["venue"] as? String,
                let eventImageURL = info["eventImageURL"] as? String,
                let eventTime = info["eventDate"] as? Double,
                let latitude = info["latitude"] as? Double,
                let longtitude = info["longtitude"] as? Double
                
            {
                
                self.ref.queryOrdered(byChild: "eventDate")

                
                // self.contacts.removeAll()
                DispatchQueue.main.async {
                    let newEvents = Event(aName: eventName,aDate: self.createDateString(eventTime), aTime: self.createTimeString(eventTime), aVenue: venue, aLatitude: latitude, aLongtitude: longtitude, anImageURL: eventImageURL)
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

extension SortScreenViewController : UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return events.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //1.get the cell
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "eventCell", for: indexPath) as? SortScreenTableViewCell else { return UITableViewCell() }
        
        
        var aEvent = events[indexPath.row]
        
        cell.nameLabel.text = aEvent.name
        cell.dateLabel.text = String(aEvent.date)
        cell.venueLabel.text = aEvent.venue
        cell.eventImageView.loadImage(from: aEvent.imageURL ?? "")
        
        //
        
        return cell
    }
    
}

extension SortScreenViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        guard let destination = storyboard?.instantiateViewController(withIdentifier: "DetailScreenViewController") as? DetailScreenViewController else {return}
        
        let selectedEvents = events[indexPath.row]
        
        destination.selectedEvents = selectedEvents
        
        navigationController?.pushViewController(destination, animated: true)
        
    }
    
    
}
