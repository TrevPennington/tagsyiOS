//
//  TagMapViewController.swift
//  Tagsy
//
//  Created by Trevor Pennington on 8/6/20.
//  Copyright © 2020 Trevor Pennington. All rights reserved.
//

import UIKit
import MapKit
import Firebase

class TagMapAnnotation: MKPointAnnotation {
    var locationIndex: Int = 0
    
}

class TagMapViewController: UIViewController, MKMapViewDelegate, UISearchBarDelegate {

    @IBOutlet var mapView: MKMapView!
    @IBOutlet var searchBar: UISearchBar!
    
    fileprivate let locationManager:CLLocationManager = CLLocationManager()
    
    var tagsArray: [TagMapAnnotation] = []
    var index = 0
    
    var listLocations: [ListLocation] = []
    var locationsRef: CollectionReference!
    
    let annotationButton = UIImage(systemName: "eye")
    
    var userId: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        


        searchBar?.delegate = self
        self.locationsRef = //Firestore.firestore().collection("public").document("forReview").collection("lists")
            Firestore.firestore().collection("featured")

        
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.startUpdatingLocation()
        
        mapView.showsUserLocation = true
        mapViewDidFinishLoadingMap(mapView)
        
        if let userId = userId {
            print(userId)
        }
        print("LOADED MAP AND ANNOTATIONS")
        
        
        locationsRef.getDocuments { (snapshot, error) in //snapshot is a 'snapshot' of data at this point of fetch.
            if let err = error {
                debugPrint("Error fetching docs: \(err)")
            } else {
                guard let snap = snapshot else { return }
                for document in snap.documents {
                    
                    //PARSE - put Dict into TagList class instances
                    let data = document.data()
                    let locationName = data["title"] as? String ?? "none" //the data comes in as type ANY, so we cast it to whatever we want.
                    
                    let latitude = data["latitude"] as? String ?? ""
                    let longitude = data["longitude"] as? String ?? ""
                    let author = data["author"] as? String ?? "n/a"
                    let hashtags = data["hashtags"] as? [String] ?? [""]
                    let mentions = data["mentions"] as? [String] ?? [""]
                    let key = document.documentID
                    //convert lat/long to double
                    let coordinateLat = Double(latitude)!
                    let coordinateLong = Double(longitude)!
                    
                    //now make a new TagList instance out of the formatted data.
                    //let newTagLocation = TagLocation(locationName: locationName, author: author, list: tagList, key: key)
                    let newListLocation = ListLocation(title: locationName, coordinate: CLLocationCoordinate2D(latitude: coordinateLat, longitude: coordinateLong), author: author, hashtags: hashtags, mentions: mentions, key: key)
                    self.listLocations.append(newListLocation)
          
                    
                }
                
                print("DOCUMENT IS \(self.listLocations)")
                
                for item in self.listLocations {
                    let point = TagMapAnnotation()
                    point.title = item.title
                    point.subtitle = "@\(item.author ?? "n/a")"
                    point.coordinate = item.coordinate
                    point.locationIndex = self.index
                    self.index += 1
                    self.mapView.addAnnotation(point)
                    print(item.coordinate)
                }
                self.index = 0
            }
        }

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        //CLEAN UP
       
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        print("searchText \(searchText)")
        let searchRequest = MKLocalSearch.Request()
        searchRequest.naturalLanguageQuery = searchText
        
        let search = MKLocalSearch(request: searchRequest)
        search.start { response, error in
            guard let response = response else {
                print("Error: \(error?.localizedDescription ?? "Unknown error").")
                return
            }

            for item in response.mapItems {
                //print(item.placemark ?? "No phone number.")
            }
        }
    }
    
    
    func mapViewDidFinishLoadingMap(_ mapView: MKMapView) {
        /* MARK: For limiting map
        let center = CLLocationCoordinate2D(latitude: 38.573936, longitude: -92.603760) //center of USA, roughly. for example
        let latMeters = CLLocationDistance(10_000_000.00) //left and right pan
        let longMeters = CLLocationDistance(5_000_000.00) //up and down pan
        
        let coordinateRegion = MKCoordinateRegion(
            center: center,
            latitudinalMeters: latMeters,
            longitudinalMeters: longMeters)
        
        let cameraBoundary = MKMapView.CameraBoundary(coordinateRegion: coordinateRegion)
        mapView.setCameraBoundary(cameraBoundary, animated: true)
 */
    }

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard annotation is MKPointAnnotation else { return nil }

        let identifier = "Annotation"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)

        if annotationView == nil {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView!.canShowCallout = true
            //add button and action
            let viewBtn = UIButton(type: .detailDisclosure)
            //viewBtn.setImage(annotationButton, for: .normal)
            annotationView?.rightCalloutAccessoryView = viewBtn

            
        } else {
            annotationView!.annotation = annotation
        }

        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {

            print("view tapped")
            let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "TagMapDetailViewController") as! TagMapDetailViewController
            //pass the whole thing.
            if let pin = view.annotation as? TagMapAnnotation {
                print(pin.locationIndex)
                vc.tagMapItem = listLocations[pin.locationIndex]
                vc.userId = userId ?? ""
            }
            self.present(vc, animated: true) //present is modally, show is non-modally
        }
    
    
    @IBAction func onSearch() {
        //perform search. goes to a location + zoom level.
    }

}

//
//private extension MKMapView {
//    func centerToLocation(_ location: CLLocation, regionRadius: CLLocationDistance = 1000) { //sets the region of the initial location
//        let coordinateRegion = MKCoordinateRegion(
//            center: location.coordinate,
//            latitudinalMeters: regionRadius,
//            longitudinalMeters: regionRadius)
//        setRegion(coordinateRegion, animated: true)
//    }
//}
