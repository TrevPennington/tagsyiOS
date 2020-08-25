//
//  ListViewCell.swift
//  
//
//  Created by Trevor Pennington on 8/22/20.
// 

import UIKit

class ListViewCell: UITableViewCell {

    @IBOutlet weak var cellTitle: UILabel!
    @IBOutlet weak var copyButton: UIButton!
    var allTags = [String]()
    var sender: UIViewController!
    var listCopied: String?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        copyButton.translatesAutoresizingMaskIntoConstraints = false
        
        let constraints = [
            copyButton.centerYAnchor.constraint(equalTo: cellTitle.centerYAnchor),
            copyButton.rightAnchor.constraint(equalTo: cellTitle.rightAnchor, constant: -20)
        ]
        NSLayoutConstraint.activate(constraints)
        
    }
    @IBAction func copyAll(_ sender: Any) {
        print("copy all pressed")
        
        var stringToPaste = "•\n•\n•\n•\n•\n•\n•\n•\n"
        for tag in allTags {
            stringToPaste += "\(tag) "
        }
        //for mention in mentions..
        
        let pasteboard = UIPasteboard.general
        pasteboard.string = stringToPaste //put all tags and mentions here, together
        alertUser(title: "copied \(listCopied ?? "") to clipboard 👌", sender: self.sender)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
