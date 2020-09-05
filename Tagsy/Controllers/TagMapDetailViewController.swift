//
//  TagMapDetailViewController.swift
//  Tagsy
//
//  Created by Trevor Pennington on 8/10/20.
//  Copyright © 2020 Trevor Pennington. All rights reserved.
//

import UIKit
import MapKit
import Firebase

class TagMapDetailViewController: UIViewController {
    
    private let reuseIdentifier = "TagCell"
    
    @IBOutlet var listTitle: UILabel!
    @IBOutlet var listAuthor: UIButton!
    @IBOutlet weak var tagsLayout: TagsLayout!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var tagMapItem: ListLocation?
    var userId: String = ""
    
    var allTags = [String]()
    
    var saveCount = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //MARK: Styling
        listTitle.font = titleStyle

        listAuthor.titleLabel?.font = tagStyle
        
        collectionView.collectionViewLayout = tagsLayout
        collectionView.delegate = self

        // Do any additional setup after loading the view.
        listTitle?.text = tagMapItem?.title
        listAuthor?.setTitle("by @\(tagMapItem?.author ?? "nil")", for: .normal)
                
        print(userId)
        displayTags()
        
    }
    
    func displayTags() {
        allTags = []
        
        if let tagMapItem = tagMapItem {
            for hashtag in tagMapItem.hashtags {
                let hashtagToAdd = "#" + hashtag
                allTags.append(hashtagToAdd)
            }
            for mention in tagMapItem.mentions {
                let mentionToAdd = "@" + mention
                allTags.append(mentionToAdd)
            }
        }

    }
    
    //MARK: Save to user's lists
    @IBAction func saveList(_ sender: Any) {
        //save to user's Fb
        
        if saveCount > 0 {
            let titleAttrString = NSMutableAttributedString(string: "You just saved \(tagMapItem?.title ?? "this list"). Are you sure you want to save it again?", attributes: [NSAttributedString.Key.font: sansTitleStyle as Any])
            
            let alert = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: saveListFinal(_:)))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
            alert.setValue(titleAttrString, forKey: "attributedTitle")
            
        } else {
            saveListFinal(self)
          
        }
    }
    
    func saveListFinal(_ sender: Any) {
        let ref = Firestore.firestore().collection("users").document(userId).collection("lists")
        
        if let tagMapItem = tagMapItem {
        ref.addDocument(data: [
            "title" : tagMapItem.title!,
            "tags" : tagMapItem.hashtags,
            "mentions" : tagMapItem.mentions
        ])
        saveCount += 1
        alertUser(title: "saved to your lists 👍", sender: self)
        } else {
            print("error")
        }
    }
    
    //MARK: Copy all tags to clipboard
    @IBAction func copyAll(_ sender: Any) {
        print("copy all pressed")
        
        var stringToPaste = "•\n•\n•\n•\n•\n•\n•\n•\n"
        for tag in allTags {
            stringToPaste += "\(tag) "
        }
        //for mention in mentions..
        
        let pasteboard = UIPasteboard.general
        pasteboard.string = stringToPaste //put all tags and mentions here, together
        alertUser(title: "copied to clipboard 👌", sender: self)
        print(type(of: self))
    }
    
    @IBAction func goToInsta() {

        let username = tagMapItem?.author ?? "" // Your Instagram Username here
        print("https://www.instagram.com/\(username)")
        
        let appURL = URL(string: "instagram://user?username=\(username)")!
        let application = UIApplication.shared
        
        //alert for opening Insta
        let instaModal = UIAlertController(title: nil, message: "open Instagram?", preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "yes", style: .default, handler: { alert -> Void in
            if application.canOpenURL(appURL)
            {
                application.open(appURL)
            }
            else
            {
                let webURL = URL(string: "https://instagram.com/\(username)")!
                application.open(webURL)
            }
        })
        let cancelAction = UIAlertAction(title: "cancel", style: .cancel)
        instaModal.addAction(confirmAction)
        instaModal.addAction(cancelAction)
        
        self.present(instaModal, animated: true, completion: nil)
        


    }
    
    
}

//MARK: Collection View
extension TagMapDetailViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return allTags.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! TagCell
        cell.tagName?.text = "\(allTags[indexPath.item])"
        cell.layer.cornerRadius = 12.0
        cell.backgroundColor = .systemGray5
        
        return cell
    }
}

extension TagMapDetailViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        //print("PHAIL THIS WON'T SHOW")
        let text = allTags[indexPath.row]
        let font: UIFont = UIFont(name: sansFont, size: 14) ??  UIFont.systemFont(ofSize: 14.0) // set here font name and font size
        let width = text.SizeOf(font).width
        return CGSize(width: width + 17.0, height: 22.0) // ADD width + space between text (for ex : 20.0)
        }
}
