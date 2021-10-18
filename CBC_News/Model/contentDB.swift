//
//  contentDB.swift
//  CBC_News
//
//  Created by Valya Derksen on 2021-10-17.
//

import Foundation

class ContentDB : Codable {
    var id : Int
    var title: String
    var date : String
    var image : String
    var type : [String]
    
    init(id: Int, title: String, date: String, image: String, type : [String]) {
        self.id = id
        self.title = title
        self.date = date
        self.image = image
        self.type = type
    }
}
