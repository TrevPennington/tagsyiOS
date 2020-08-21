//
//  TagList.swift
//  Tagsy
//
//  Created by Trevor Pennington on 8/1/20.
//  Copyright © 2020 Trevor Pennington. All rights reserved.
//

import Foundation

struct TagList {
    var key: String
    var title: String
    var hashtags: [String]
    var mentions: [String]
    
    init(key: String, title: String, hashtags: [String], mentions: [String]) {
        self.key = key
        self.title = title
        self.hashtags = hashtags
        self.mentions = mentions
    }
    
    //init snapshot
    
    //func for converting to JSON
}
