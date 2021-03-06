//
//  TagCell.swift
//  Tagsy
//
//  Created by Trevor Pennington on 8/2/20.
//  Copyright © 2020 Trevor Pennington. All rights reserved.
//

import UIKit

class TagCell: UICollectionViewCell {

    @IBOutlet var tagName: UILabel!
    var width: CGFloat!
    // Note: must be strong
    @IBOutlet private var maxWidthConstraint: NSLayoutConstraint! {
        didSet {
            maxWidthConstraint.isActive = false
        }
    }
    
    var maxWidth: CGFloat? = nil {
        didSet {
            guard let maxWidth = maxWidth else {
                return
            }
            maxWidthConstraint.isActive = true
            maxWidthConstraint.constant = maxWidth
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = background //make dark mode compatable
        tagName.font = UIFont(name: sansFont, size: 14)
        
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            contentView.leftAnchor.constraint(equalTo: leftAnchor),
            contentView.rightAnchor.constraint(equalTo: rightAnchor),
            contentView.topAnchor.constraint(equalTo: topAnchor),
            contentView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

}
