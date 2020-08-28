//
//  SendPublicViewController.swift
//  Tagsy
//
//  Created by Trevor Pennington on 8/12/20.
//  Copyright © 2020 Trevor Pennington. All rights reserved.
//

import UIKit
import MapKit
import Firebase

class SendPublicViewController: UIViewController, LocationSearchViewControllerDelegate, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource {

    
    @IBOutlet weak var tableView: UITableView!
    func doSomethingWith(data: MKPlacemark) {
        //perfom action here. you received it from LocationSearch.
        //setLocation.text = "\(data.locality ?? "n/a"), \(data.administrativeArea ?? "n/a")" //city / state
        submitForm[0].title = "\(data.locality ?? "n/a"), \(data.administrativeArea ?? "n/a")"
        self.tableView.reloadData()
        locationSelected = data
    }

    @IBOutlet weak var listTitle: UITextField!
    @IBOutlet weak var listAuthor: UITextField!
    @IBOutlet weak var handleLabel: UILabel!
    var submitButton: UIBarButtonItem!
    
    @IBOutlet var details: UILabel!

    var locationSelected: MKPlacemark? {
        didSet {
                submitButton.isEnabled = true
        }
    }
    var locationText = ""
    //let pubRef = Firestore.firestore().collection("public").document("forReview").collection("lists")
    let pubRef = Firestore.firestore().collection("featured")

    var listItem = TagList(key: "", title: "", hashtags: [], mentions: [])
    
    let submitForm = [SubmitForItem(title: "set a location", subTitle: "location for use on TagMap")]
    
    @IBAction func titleChanged(_ sender: UITextField) {
        if listTitle.text == "" {
            submitButton.isEnabled = false
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //MARK: Styling
        listTitle.font = titleStyle
        listAuthor.font = tagStyle
        handleLabel.font = tagStyle
        details.font = tagStyle
        tableView.tableFooterView = UIView()
        
        submitButton = UIBarButtonItem(title: "submit", style: .plain, target: self, action: #selector(sendPublic))
        navigationItem.setRightBarButton(submitButton, animated: true)
        submitButton.isEnabled = false

        details.text = "Add a location and your Instagram handle (for credit) to submit. Submitting will send the list to Tagsy for review. If selected, your list will be displayed on TagMap with a link to your Instagram. Lists on TagMap get changed out periodically."
        listTitle.text = listItem.title

    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return submitForm.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SubmitCell", for: indexPath)
        let submitItem = submitForm[indexPath.row]
        
        cell.textLabel?.text = submitItem.title
        cell.textLabel?.font = tagStyle
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        self.performSegue(withIdentifier: "LocationSearchSegue", sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {

        if textField == listAuthor
        {
            textField.text = textField.text?.replacingOccurrences(of: "[\\ @#]", with: "", options: .regularExpression)
        }
        return true
    }

    //MARK: Send Button
    @objc func sendPublic(_ sender: Any) {
        //format the local
        let latitude = locationSelected?.coordinate.latitude ?? 0.0
        let longitude = locationSelected?.coordinate.longitude ?? 0.0
        
        //MARK: send to Fb pubRef
        pubRef.addDocument(data: [
            "title" : listTitle.text!,
            "author" : listAuthor.text!,
            "latitude" : String(latitude),
            "longitude" : String(longitude),
            //LIST (from prev. VC)
            "hashtags" : listItem.hashtags,
            "mentions" : listItem.mentions
        ])  { err in
                       if let err = err {
                           print("Error sending public \(err)")
                       } else {
                            print("success sending public")
                            DispatchQueue.main.async {
                                alertUser(title: "Thank you fou submitting your list! We will review it and let you know if we post it!", sender: self)
                            }
                            self.navigationController?.popViewController(animated: true)

                       }
                   }
    }
    
    //MARK: Receive local back
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "LocationSearchSegue"){
            let vc = segue.destination as! LocationSearchViewController
            vc.delegate = self
        }
    }

}
