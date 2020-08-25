//
//  ItemViewController.swift
//  Tagsy
//
//  Created by Trevor Pennington on 8/2/20.
//  Copyright © 2020 Trevor Pennington. All rights reserved.
//

import UIKit
import Firebase

class ItemViewController: UIViewController, UIGestureRecognizerDelegate, UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate {

    private let reuseIdentifier = "Tag"
    
    @IBOutlet var listTitle: UITextField!
    @IBOutlet var addTag: UITextField!
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet var collectionView: UICollectionView!

    @IBOutlet weak var tagsLayout: TagsLayout!
    

    var copyAllButton = UIBarButtonItem()
    var infoButton = UIBarButtonItem()
    
    var listItem = TagList(key: "", title: "", hashtags: [], mentions: []) {
        didSet {
            if listItem.hashtags.count != 0 || listItem.mentions.count != 0 {
                self.copyAllButton.isEnabled = true
            } else {
                self.copyAllButton.isEnabled = false
            }
        }
    }
    var addingNewList = false
    var userId: String? = ""
    var ref: CollectionReference!
    
    var allTags = [String]()
    let pickerItems = ["#", "@"]
    var hashtagSelected = true
    
    var baseTagPrompt = "add a"
    var tagPrompt = "tag"
    var mentionPrompt = "mention"
    var tagCount = 0
    var mentionCount = 0
    
    let infoImage = UIImage(systemName: "ellipsis.circle")
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //MARK: Styling
        listTitle.font = titleStyle
        addTag.font = tagStyle
       
        
        collectionView.collectionViewLayout = tagsLayout
        collectionView.delegate = self


        // Do any additional setup after loading the view.
        copyAllButton = UIBarButtonItem(title: "copy", style: .plain, target: self, action: #selector(copyAll))
        infoButton = UIBarButtonItem(image: infoImage, style: .plain, target: self, action: #selector(infoModal))
        navigationItem.setRightBarButtonItems([infoButton, copyAllButton], animated: true)

        
        self.addTag.addTarget(self, action: #selector(onReturn), for: UIControl.Event.editingDidEndOnExit)
        //self.addTag.placeholder = ""

        
        //LIST SETUP
        print("PASSED USER ID IS: \(userId!)")
        print("PASSED ITEM KEY IS: \(listItem.key)")
        ref = Firestore.firestore().collection("users").document(userId!).collection("lists")
        checkIfAddingOrEditing()
        
        let lpgr = UILongPressGestureRecognizer(target: self, action: #selector(self.handleLongPress(_:)))
         lpgr.minimumPressDuration = 0.5
         lpgr.delaysTouchesBegan = true
         lpgr.delegate = self
         self.collectionView.addGestureRecognizer(lpgr)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        displayTags()
        addTag.placeholder = tagPrompt
    }
    
    func displayTags() {
        //add mentions and tags into 1 array
        //allTags = listItem.hashtags + listItem.mentions
        allTags = []
        //print(listItem.mentions)
        for hashtag in listItem.hashtags {
            let hashtagToAdd = "#" + hashtag
            allTags.append(hashtagToAdd)
        }
        for mention in listItem.mentions {
            let mentionToAdd = "@" + mention
            allTags.append(mentionToAdd)
        }
        tagCount = listItem.hashtags.count
        mentionCount = listItem.mentions.count
        
        tagPrompt = baseTagPrompt + " hashtag (\(tagCount)/30)"
        mentionPrompt = baseTagPrompt + " mention (\(mentionCount)/5)"
    }
    
    func checkIfAddingOrEditing() {
        if addingNewList {
            copyAllButton.isEnabled = false
        } else { //editting list. List item was set from segue
            listTitle.text = listItem.title
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) { //refactor this. (repeating code).
                
        listItem.title = listTitle.text ?? "no title"
        
        if addingNewList { //NEW LIST

            //MARK: ADD NEW LIST TO FIREBASE
            if listItem.hashtags != [] || listTitle.text != "" {
                if listTitle.text == "" {
                    listItem.title = "no title"
                }
                ref.addDocument(data: [
                    "title" : listItem.title,
                    "tags" : listItem.hashtags,
                    "mentions" : listItem.mentions
                ])
            }
            addingNewList = false
        
        } else { //EDITTING LIST
            
            //MARK: EVERYTHING IS EMPTY, DELETE LIST
            if listTitle.text == "" && listItem.hashtags == [] && listItem.mentions == [] {
                ref.document("\(listItem.key)").delete() { err in
                    if let err = err {
                        print("error removing doc \(err)")
                    } else {
                        print("removed doc")
                        
                    }
                }
            } else {
                //MARK: UPDATE THE LIST IN FB
              ref.document(listItem.key).updateData([
                  "title" : listItem.title,
                  "tags" : listItem.hashtags,
                  "mentions" : listItem.mentions
              ]) { err in
                  if let err = err {
                      print("Error updating doc: \(err)")
                  } else {
                      print("success updating")
                  }
              }
            }
        }
        //Any clean-up, do here.
        allTags = []
        print("TAGS CLEANED")
    }
    
    //MARK: PICKER for #/@
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerItems.count
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let label = (view as? UILabel) ?? UILabel()

        label.textAlignment = .center
        label.font = tagStyle

        label.text = pickerItems[row]

        return label
      }
    
    
    // Capture the picker view selection
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if row == 1 {
            hashtagSelected = false
            //change addTag.placeholder
            addTag.placeholder = mentionPrompt
        } else {
            hashtagSelected = true
            addTag.placeholder = tagPrompt
        }
        print(hashtagSelected)
        
    }
    
    //ADD NEW TAG
    @IBAction func onReturn() {
        self.addTag.resignFirstResponder() //close keyboard
        
        //if hashtag
        if hashtagSelected {
            if tagCount < 30 {
                listItem.hashtags.insert(addTag.text!, at: 0) //append tag to array
                displayTags()
                collectionView.reloadData()
                addTag.text = ""
            } else { //too many
                alertUser(title: "only 30 hashtags are allowed on Instagram", sender: self)
            }
            
        //if mention
        } else {
            if mentionCount < 5 {
                listItem.mentions.insert(addTag.text!, at: 0) //append to mention array
                displayTags()
                collectionView.reloadData()
                addTag.text = ""
            } else { //too many
                alertUser(title: "only 5 mentions are allowed on Instagram", sender: self)
            }
        }

    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {

        if textField == addTag
        {
            textField.text = textField.text?.replacingOccurrences(of: "[\\ @#]", with: "", options: .regularExpression)
        }
        return true
    }
    
    //DELETE TAG
    
    @objc func handleLongPress(_ gestureRecognizer: UILongPressGestureRecognizer) {
        guard gestureRecognizer.state != .ended else { return }

        let point = gestureRecognizer.location(in: collectionView)

        if let indexPath = collectionView.indexPathForItem(at: point),
           let _ = collectionView.cellForItem(at: indexPath) {
            // do stuff with your cell, for example print the indexPath
            print(indexPath.row)
            
            if indexPath.row + 1 > listItem.hashtags.count {
                let mentionRow = indexPath.row - listItem.hashtags.count
                listItem.mentions.remove(at: mentionRow)
            } else {
                listItem.hashtags.remove(at: indexPath.row)
            }
            
            self.displayTags()
            self.collectionView.reloadData()
        } else {
            print("Could not find index path")
        }
    }
    
    //MARK: COPY ALL TAGS
    @objc func copyAll() {
        print("copy all pressed")
        
        var stringToPaste = "•\n•\n•\n•\n•\n•\n•\n•"
        for tag in allTags {
            stringToPaste += "\(tag) "
        }
        //for mention in mentions..
        
        let pasteboard = UIPasteboard.general
        pasteboard.string = stringToPaste //put all tags and mentions here, together
        alertUser(title: "copied to clipboard 👌", sender: self)
    }
    
    
    //MARK: Open Menu Modal
    @objc func infoModal() {
        print("OPEN MODAL ")
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Submit List", style: .default, handler: submitButtonTapped(_:)))
        alert.addAction(UIAlertAction(title: "Delete List", style: .default, handler: deleteButtonTapped(_:)))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    
    //MARK: Go to Send Public VC
    func submitButtonTapped(_ sender: Any) {
        //put title text into list.title
        if allTags.count > 9 { //always be 9
            //let viewController = SendPublicViewController() //make this legit
            
            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let viewController = storyBoard.instantiateViewController(withIdentifier: "SendPublicViewController") as! SendPublicViewController

        //MARK: CHECK FOR ADDING NEW LIST
            if addingNewList {
                //ADD THE NEW LIST TO FIREBASE
                //DispatchQueue.main.async {
                    if self.listItem.hashtags != [] || self.listTitle.text != "" {
                        if self.listTitle.text == "" {
                            self.listItem.title = "no title"
                        }
                        var newRef: DocumentReference? = nil
                        newRef = self.ref.addDocument(data: [
                            "title" : self.listItem.title,
                            "tags" : self.listItem.hashtags,
                            "mentions" : self.listItem.mentions
                        ]) { err in
                        if let err = err {
                            print("Error adding document: \(err)")
                        } else {
                            print("Document added with ID: \(newRef!.documentID)")
                            //add this id to listItem.key
                            self.listItem.key = newRef!.documentID
                            viewController.listItem = self.listItem
                            print("from adding new list")
                            print(self.listItem)
                            self.addingNewList = false
                            //MARK: NOW MOVE TO SENDPUB.
                            //self.performSegue(withIdentifier: "SendPublicSegue", sender: self)
                            //instead of segue, do it programatically
                            self.navigationController?.pushViewController(viewController, animated: true)
                        }
                    }
                  }
            } else {
                viewController.listItem = self.listItem
                print("from editting list")
                print(self.listItem)
                self.navigationController?.pushViewController(viewController, animated: true)
            }
        listItem.title = listTitle.text ?? "no title"
        
        } else {
            alertUser(title: "must have at least 10 tags to submit!", sender: self)
        }
    }
    
    //MARK: Delete List?
    func deleteButtonTapped(_ sender: Any) {
        let titleAttrString = NSMutableAttributedString(string: "Are you sure you want to delete this list?", attributes: [NSAttributedString.Key.font: sansTitleStyle as Any])
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: deleteList(_:)))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
        alert.setValue(titleAttrString, forKey: "attributedTitle")
    }
    //MARK: Delete List Confirmed
    func deleteList(_ sender: Any) {
        if addingNewList {
            //set everything to nil and return home
            listTitle.text = ""
            listItem = TagList(key: "", title: "", hashtags: [], mentions: [])
        } else {
            print("DELETE THE LIST AND SEND HOME")
            ref.document("\(listItem.key)").delete() { err in
                if let err = err {
                    print("error removing doc \(err)")
                } else {
                    print("removed doc")
                    
                }
            }
        
        }
        self.navigationController?.popViewController(animated: true)
    }
    

}
//MARK: CollectionView

extension ItemViewController: UICollectionViewDataSource {
    
     func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return allTags.count
     }

     func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
         let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! TagCell
        cell.tagName?.text = "\(allTags[indexPath.item])"
        cell.layer.cornerRadius = 12.0
        return cell

     }
  
}

extension ItemViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        //print("PHAIL THIS WON'T SHOW")
        let text = allTags[indexPath.row]
        let font: UIFont = UIFont(name: sansFont, size: 14) ??  UIFont.systemFont(ofSize: 14.0) // set here font name and font size
        let width = text.SizeOf(font).width
        return CGSize(width: width + 17.0, height: 22.0) // ADD width + space between text (for ex : 20.0)
        }
}

extension String {
    
    func SizeOf(_ font: UIFont) -> CGSize {
        return self.size(withAttributes: [NSAttributedString.Key.font: font])
    }
}


