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

class SendPublicViewController: UIViewController, LocationSearchViewControllerDelegate, UITextFieldDelegate {
    func doSomethingWith(data: MKPlacemark) {
        //perfom action here. you received it from LocationSearch.
        setLocation.text = "\(data.locality ?? "n/a"), \(data.administrativeArea ?? "n/a")" //city / state
        locationSelected = data
    }

    @IBOutlet weak var listTitle: UITextField!
    @IBOutlet weak var listAuthor: UITextField!
    
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet var details: UILabel!
    @IBOutlet var setLocation: UILabel!
    var locationSelected: MKPlacemark? {
        didSet {
                submitButton.isEnabled = true
        }
    }
    var locationText = ""
    let pubRef = Firestore.firestore().collection("public").document("forReview").collection("lists")
    var listItem = TagList(key: "", title: "", hashtags: [], mentions: [])
    
    @IBAction func titleChanged(_ sender: UITextField) {
        if listTitle.text == "" {
            submitButton.isEnabled = false
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        submitButton.isEnabled = false
        submitButton.layer.cornerRadius = 12.0

        details.text = "submitting will send to Tagsy for review. If selected, your list will be on TagMap with a link to your Instagram for 1 month."
        
        listTitle.text = listItem.title
        print("inside SEND now. listItem = \(listItem)")

    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {

        if textField == listAuthor
        {
            textField.text = textField.text?.replacingOccurrences(of: "[\\ @#]", with: "", options: .regularExpression)
        }
        return true
    }

    //MARK: Send Button
    @IBAction func sendPublic(_ sender: Any) {
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
                                alertUser(title: "Thank you fou submitting your list!", sender: self)
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
