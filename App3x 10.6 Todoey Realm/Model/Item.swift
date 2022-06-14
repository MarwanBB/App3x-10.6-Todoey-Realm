//
//  Item.swift
//  App3x 10.6 Todoey Realm
//
//  Created by Marwan Elbahnasawy on 04/06/2022.
//

import Foundation
import RealmSwift

class Item: Object {
    @objc dynamic var titleItem: String!
    @objc dynamic var dateItem: Date!
    @objc dynamic var doneItem: Bool = false
    @objc dynamic var colorItem: String!
    
    
    var parentCategory = LinkingObjects(fromType: Category.self, property: "items")
}
