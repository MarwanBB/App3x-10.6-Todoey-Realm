//
//  Category.swift
//  App3x 10.6 Todoey Realm
//
//  Created by Marwan Elbahnasawy on 04/06/2022.
//

import Foundation
import RealmSwift

class Category: Object {
    @objc dynamic var titleCategory : String!
    @objc dynamic var dateCategory: Date!
    @objc dynamic var colorCategory: String!
    
    let items = List<Item>()
}
