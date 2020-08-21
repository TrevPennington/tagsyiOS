//
//  ListLocation.swift
//  Tagsy
//
//  Created by Trevor Pennington on 8/11/20.
//  Copyright © 2020 Trevor Pennington. All rights reserved.
//

import UIKit
import MapKit

class ListLocation: NSObject, MKAnnotation {
    var title: String? //list title, probs not necessary bc TagList
    var coordinate: CLLocationCoordinate2D
    var author: String? //@trevorandshelby
    var hashtags: [String]
    var mentions: [String]
    var key: String? //written from Fb
    
    init(title: String, coordinate: CLLocationCoordinate2D, author: String, hashtags: [String], mentions: [String], key: String) {
        self.title = title
        self.coordinate = coordinate
        self.author = author
        self.hashtags = hashtags
        self.mentions = mentions
        self.key = key
    }
}
