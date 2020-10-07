//
//  PlaceModel.swift
//  TableView
//
//  Created by Саша Гужавин on 01.10.2020.
//

import RealmSwift

class Place: Object {
    
    @objc dynamic var name = ""
    @objc dynamic var location: String?
    @objc  dynamic var type: String?
    @objc dynamic var imageData: Data?
    @objc dynamic var restoranImage: String?

    
    convenience init (name: String, location: String?, type: String?, imageData: Data?) {
        self.init()
        self.name = name
        self.location = location
        self.type = type
        self.imageData = imageData
        
        
        
    }
}

