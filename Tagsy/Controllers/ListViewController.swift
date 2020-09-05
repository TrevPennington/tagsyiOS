//
//  ViewController.swift
//  Tagsy
//
//  Created by Trevor Pennington on 8/1/20.
//  Copyright © 2020 Trevor Pennington. All rights reserved.
//

import UIKit
import Firebase


class ListViewController: UITableViewController {
    
    @IBOutlet var tableViewOutlet: UITableView!
    var db: Firestore!
    var provider: String?
    var user: User!
    var items: [TagList] = []
    
    var itemsRef: CollectionReference!
    let accountButton = UIImage(systemName: "person")
    
    @IBOutlet var addList: UIBarButtonItem!
    
    var instructions = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //navigationController?.setNavigationBarHidden(false, animated: true)
        navigationItem.hidesBackButton = true
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: accountButton, style: .plain, target: self, action: #selector(goToAccount))
        tableView.tableFooterView = UIView()
         
        tableView.allowsMultipleSelectionDuringEditing = false
        
        
        db = Firestore.firestore()
        Auth.auth().addStateDidChangeListener { (auth, user) in //make in to a const and remove when done. possibly a didset when user is nil that triggers the removal.
          if let user = user {
            self.user = User(uid: user.uid, email: user.email!)
            print("USER SET TO \(user.uid) and \(user.email ?? "")")
            let userRef = Firestore.firestore().collection("users").document(user.uid)
            userRef.setData([
                "email" : user.email ?? "",
                "id" : user.uid
            ])
            //set userRef here
            //TODO: once Apple sign in works
            //let userRef = self.db.collection("users").document("\(user?.uid)")
            self.itemsRef = Firestore.firestore().collection("users").document(user.uid).collection("lists")
            self.title = user.displayName ?? "my lists"
            self.loadFbData()
            //send UserId to TagMapVC
            let tagMapVC = self.tabBarController?.viewControllers?[1] as! TagMapViewController
            tagMapVC.userId = user.uid
          }
        }

    }
    
    override func viewWillAppear(_ animated: Bool) {
        tableViewOutlet.isUserInteractionEnabled = false
        loadFbData()
        renderInstructions()
        hideInstructions()
    }
    
    func renderInstructions() {
        view.addSubview(instructions)
        instructions.translatesAutoresizingMaskIntoConstraints = false
        instructions.layer.zPosition = 1

        
        instructions.text = "tap the '+' to add a new list!"
        instructions.textAlignment = .center
        instructions.font = sansTitleStyle
        instructions.textColor = textHex
        
        //set constraints
        NSLayoutConstraint.activate([
            //instructions.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30.0),
            
            instructions.topAnchor.constraint(equalTo: view.topAnchor, constant: 20.0),
            instructions.heightAnchor.constraint(equalToConstant: 50.0),
            instructions.widthAnchor.constraint(equalToConstant: view.frame.size.width),
        ])
        
    }
    
    func showInstructions() {
        instructions.isHidden = false
    }
    
    func hideInstructions() {
        instructions.isHidden = true
    }
    
    func loadFbData() {
        itemsRef?.getDocuments { (snapshot, error) in //snapshot is a 'snapshot' of data at this point of fetch.
            if let err = error {
                debugPrint("Error fetching docs: \(err)")
            } else {
                guard let snap = snapshot else { return }
                for document in snap.documents {
                    
                    //PARSE - put Dict into TagList class instances
                    let data = document.data()
                    let title = data["title"] as? String ?? "none" //the data comes in as type ANY, so we cast it to whatever we want.
                    let tags = data["tags"] as? [String] ?? []
                    let mentions = data["mentions"] as? [String] ?? []
                    let key = document.documentID
                    
                    //now make a new TagList instance out of the formatted data.
                    let newTagList = TagList(key: key, title: title, hashtags: tags, mentions: mentions)
                    self.items.append(newTagList)
                }
                if self.items.count == 0 {
                    self.showInstructions()
                } else {
                    self.hideInstructions()
                }
                self.tableView.reloadData()
                print("Table view reloaded")
                self.tableViewOutlet.isUserInteractionEnabled = true
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        items = []
    }
    

    
    //MARK: UITableView Delegate methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        if items.count == 0 {
//            showInstructions()
//        } else {
//            hideInstructions()
//        }
        return items.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ItemCell", for: indexPath) as! ListViewCell
        let listItem = items[indexPath.row]
        
        cell.cellTitle?.text = listItem.title

        var tagsToCopy = [String]()
        
      
            for hashtag in listItem.hashtags {
                let hashtagToAdd = "#" + hashtag
                tagsToCopy.append(hashtagToAdd)
            }
            for mention in listItem.mentions {
                let mentionToAdd = "@" + mention
                tagsToCopy.append(mentionToAdd)
            }
        
        
        cell.allTags = tagsToCopy
        cell.sender = self
        cell.listCopied = listItem.title
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            //remove from Fb
            //if public, remove from public list as well.
            
            itemsRef.document("\(items[indexPath.row].key)").delete() { err in
                if let err = err {
                    print("error removing doc \(err)")
                } else {
                    print("removed doc")
                    self.items.remove(at: indexPath.row)
                    tableView.reloadData()
                }
            }
            
            
            
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //segue to detail screen w/ data of list item
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: "ItemViewController") as! ItemViewController

        vc.listItem = items[indexPath.row]
        vc.userId = user.uid
        navigationController?.pushViewController(vc, animated: true)
    }
    
    //MARK: Add Item
    @IBAction func addButtonTouched(_ sender: AnyObject) {
        //segue to detail screen w/ no data
//        let vc = ItemViewController()
//        navigationController?.pushViewController(vc, animated: true)
        
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "ItemViewController") as! ItemViewController
        
        //vc.userId = user.uid
        vc.addingNewList = true
        vc.userId = user.uid
        print("NEW LIST")
        self.show(vc, sender: self)
        items = []
    }
    
    @objc func goToAccount() {
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "AccountVC") as! AccountViewController
        vc.accountName = user.email
        self.show(vc, sender: self)
        items = []
    }

}


