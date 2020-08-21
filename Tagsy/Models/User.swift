//
//  User.swift
//  Tagsy
//
//  Created by Trevor Pennington on 8/3/20.
//  Copyright © 2020 Trevor Pennington. All rights reserved.
//

import Foundation

struct User {
    let uid: String
    let email: String
    
    init(authData: User) {
        uid = authData.uid
        email = authData.email
    }
    
    init(uid: String, email: String) {
        self.uid = uid
        self.email = email
    }
}
