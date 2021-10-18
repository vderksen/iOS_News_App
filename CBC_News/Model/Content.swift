//
//  Content.swift
//  CBC_News
//
//  Created by Valya Derksen on 2021-10-14.
//


import Foundation

// Model Content used to fethced data from API

struct Content : Codable {
    var id : Int
    var title: String
    var date : String // publish date
    var image : String // typeAttributes {} -> imageLarge
    var type : [String] // typeAttributes {} -> sectionLabels []
    
    init(){
        self.id = 0
        self.title = ""
        self.date = ""
        self.image = ""
        self.type = []
    }
    
    enum CodingKeys : String, CodingKey {
        case id = "id"
        case title = "title"
        case date = "readablePublishedAt"
        case image = "imageLarge"
        case type = "sectionLabels"
        case typeAttributes = "typeAttributes"
    }
    
    func encode(to encoder: Encoder) throws {
        // nothing to encode
    }
    
    init(from decoder: Decoder) throws {
        let response = try decoder.container(keyedBy: CodingKeys.self)
        
        self.id = try response.decodeIfPresent(Int.self, forKey: .id) ?? 0
        self.title = try response.decodeIfPresent(String.self, forKey: .title) ?? "Unavaliable"
        self.date = try response.decodeIfPresent(String.self, forKey: .date) ?? "Unavaliable"
       
        let typeAttributesContainer = try response.decodeIfPresent(TypeAttributes.self, forKey: .typeAttributes)
        self.image = typeAttributesContainer?.image ?? "Unavaliable"
        self.type = typeAttributesContainer?.type ?? ["Unavaliable"]
    }
        
}

// Additional Structure to parse the content from "typeAttributes" object
struct TypeAttributes : Codable {
    var image : String // imageLarge
    var type : [String] // sectionList []
    
    enum CodingKeys : String, CodingKey {
        case image = "imageLarge"
        case type = "sectionLabels"
    }
    
    init(from decoder: Decoder) throws {
        let response = try decoder.container(keyedBy: CodingKeys.self)
        self.image = try response.decodeIfPresent(String.self, forKey: .image) ?? "Unavaliable"
        self.type = try response.decodeIfPresent([String].self, forKey: .type) ?? ["Unavaliable"]
    }
    
    func encode(to encoder: Encoder) throws {
        // nothing to encode
    }
}






