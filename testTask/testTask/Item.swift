//
//  File.swift
//  testTask
//
//  Created by Евгений Клебан on 3/5/19.
//  Copyright © 2019 Евгений Клебан. All rights reserved.
//

import Foundation

struct Item {
    let title: String
    let link: String
    
    init(dictionary: Dictionary<String, Any>) {
        title = dictionary["title"] as? String ?? ""
        link = dictionary["link"] as? String ?? ""
    }
}
