//
//  LocationSearchViewController.swift
//  Tagsy
//
//  Created by Trevor Pennington on 8/12/20.
//  Copyright © 2020 Trevor Pennington. All rights reserved.
//

import UIKit
import MapKit

protocol LocationSearchViewControllerDelegate : NSObjectProtocol {
    func doSomethingWith(data: MKPlacemark)
}

class LocationSearchViewController: UIViewController, UISearchBarDelegate {

    @IBOutlet var searchBar: UISearchBar!
    var searchResults: [MKPlacemark] = []
    @IBOutlet var tableView: UITableView!
    
    weak var delegate: LocationSearchViewControllerDelegate?
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        searchBar.delegate = self
        tableView.allowsSelection = true

        
        
    }
    @IBAction func dismissButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.searchResults = []
        print("searchText \(searchText)")
        let searchRequest = MKLocalSearch.Request()
        searchRequest.naturalLanguageQuery = searchText
        
        let search = MKLocalSearch(request: searchRequest)
        search.start { response, error in
            guard let response = response else {
                print("Error: \(error?.localizedDescription ?? "Unknown error").")
                return
            }

//            for item in response.mapItems {
//                print(item.placemark)
//                //if item is in USA
//                if item.placemark.countryCode == "US" && item.placemark.locality != nil && item.placemark.administrativeArea != nil {
//                    //also if locality + admin isn't already in the results
//                    self.searchResults.append(item.placemark)
//
//                }
            for item in response.mapItems {
            self.searchResults.append(item.placemark)
            }
                
//            self.searchResults = self.searchResults.filter { result in
//                    if result.title?.contains(",") ?? false {
//                        return false
//                    }
//
//                    if result.title?.rangeOfCharacter(from: CharacterSet.decimalDigits) != nil {
//                        return false
//                    }
//
//                    if result.subtitle?.rangeOfCharacter(from: CharacterSet.decimalDigits) != nil {
//                        return false
//                    }
//
//                    return true
//                }

//                self.searchResultsCollectionView.reloadData()
//            }
            
            self.tableView.reloadData()
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

//MARK: TableView
extension LocationSearchViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ResultCell", for: indexPath)
        let listItem = searchResults[indexPath.row]
        //let stringedItem = listItem.title
        cell.textLabel?.text = listItem.name
        cell.detailTextLabel?.text = listItem.administrativeArea ?? ""

        return cell
    }
    

}

extension LocationSearchViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("selected a row")
        let local = searchResults[indexPath.row]
        //print(local.name)
        self.searchResults = []
        self.tableView.reloadData()

        //set location of SendPublic VC here. not working. USE DELEGATE PATTERN
        // Whenever you want to pass a data back
        if let delegate = delegate{
            delegate.doSomethingWith(data: local)
        }
        
        
        dismiss(animated: true, completion: nil)
    }
}
