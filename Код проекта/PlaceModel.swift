//
//  PlaceModel.swift
//  ScrolView
//
//  Created by Игорь Островский on 04.05.2022.
//

import Foundation
import RealmSwift
import UIKit

class Place:Object {
    
    @objc dynamic var name:String = ""
    @objc dynamic var location:String?
    @objc dynamic var type:String?
    @objc dynamic var imageData:Data?
    @objc dynamic var date = Date()

    convenience init(name:String,location:String?,type:String?,imageData:Data?){
        self.init()
        self.name = name
        self.location = location
        self.type = type
        self.imageData = imageData
    }
}
