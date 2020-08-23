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
    @IBOutlet var listAuthor: UILabel!
    @IBOutlet weak var tagsLayout: TagsLayout!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var tagMapItem: ListLocation?
    var userId: String = ""
    
    var allTags = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //MARK: Styling
        listTitle.font = titleStyle
        listAuthor.font = tagStyle
        
        collectionView.collectionViewLayout = tagsLayout
        collectionView.delegate = self

        // Do any additional setup after loading the view.
        listTitle?.text = tagMapItem?.title
        listAuthor?.text = "by @\(tagMapItem?.author ?? "nil")"
                
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
        let ref = Firestore.firestore().collection("users").document(userId).collection("lists")
        
        if let tagMapItem = tagMapItem {
        ref.addDocument(data: [
            "title" : tagMapItem.title!,
            "tags" : tagMapItem.hashtags,
            "mentions" : tagMapItem.mentions
        ])
        alertUser(title: "saved to your lists 👍", sender: self)
        } else {
            print("error")
        }
    }
    
    //MARK: Copy all tags to clipboard
    @IBAction func copyAll(_ sender: Any) {
        print("copy all pressed")
        
        var stringToPaste = "•\n•\n•\n•\n•\n•\n•\n•"
        for tag in allTags {
            stringToPaste += "\(tag) "
        }
        //for mention in mentions..
        
        let pasteboard = UIPasteboard.general
        pasteboard.string = stringToPaste //put all tags and mentions here, together
        alertUser(title: "copied to clipboard 👌", sender: self)
        print(type(of: self))
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
        return cell
    }
}

extension TagMapDetailViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        //print("PHAIL THIS WON'T SHOW")
        let text = allTags[indexPath.row]
        let font: UIFont = UIFont(name: "Baskerville", size: 14) ??  UIFont.systemFont(ofSize: 14.0) // set here font name and font size
        let width = text.SizeOf(font).width
        return CGSize(width: width + 17.0, height: 22.0) // ADD width + space between text (for ex : 20.0)
        }
}
