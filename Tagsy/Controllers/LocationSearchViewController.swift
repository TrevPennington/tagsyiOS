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
    @IBOutlet var tableView: UITableView!
    
    var searchResults: [MKPlacemark] = []
    
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
        //self.searchResults = [] //this might be causing the crash
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(self.reload(_:)), object: searchBar)
        perform(#selector(self.reload(_:)), with: searchBar, afterDelay: 0.75)
        
    }
    
    @objc func reload(_ searchBar: UISearchBar) {
        print("searchText \(searchBar.text!)")
        let searchRequest = MKLocalSearch.Request()
        searchRequest.naturalLanguageQuery = searchBar.text
        
        let search = MKLocalSearch(request: searchRequest)
        search.start { response, error in
            guard let response = response else {
                print("Error: \(error?.localizedDescription ?? "Unknown error").")
                return
            }
            var newArray: [MKPlacemark] = []
            for item in response.mapItems {
                newArray.append(item.placemark)
                
            }
            self.searchResults = newArray
            self.tableView.reloadData()
        }
    }

}

//MARK: TableView
extension LocationSearchViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ResultCell", for: indexPath)
        let listItem = searchResults[indexPath.row]
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
        //self.searchResults = []
        //self.tableView.reloadData()

        //set location of SendPublic VC here. not working. USE DELEGATE PATTERN
        // Whenever you want to pass a data back
        if let delegate = delegate{
            delegate.doSomethingWith(data: local)
        }
        
        
        dismiss(animated: true, completion: nil)
    }
}
