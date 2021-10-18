//
//  DatabaseHelper.swift
//  CBC_News
//
//  Created by Valya Derksen on 2021-10-17.
//

import Foundation

import Foundation
import CoreData
import UIKit

class DatabaseHelper {
    // singleton instance
    private static var shared : DatabaseHelper?
    
    static func getInstance()-> DatabaseHelper {
        if shared != nil {
            // instance already exist
            return shared!
        } else {
            // create a new instance
            return DatabaseHelper(contex : (UIApplication.shared.delegate as! AppDelegate).persistentConteiner.viewContext)
        }
    }
    
    private let moc : NSManagedObjectContext
    private let ENTITY_NAME = "ContentDB"
    
    private init (contex : NSManagedObjectContext){
        self.moc = contex
    }
    
    // insert new order into CoreData
    func insertContent(content : SavedContent){
        do {
            // try insert new record
            let newContent = NSEntityDescription.insertNewObject(forEntityName: ENTITY_NAME, into: self.moc) as! ContentDB
            
            newContent.id = Int32(content.id)
            newContent.title = content.title
            newContent.date = content.date
            newContent.image = content.image
            newContent.type = content.type as NSObject
            
            if self.moc.hasChanges{
                try self.moc.save()
                print(#function, "Data inserted successfully")
            }
            
        }catch let error as NSError {
            print(#function, "Could not save data \(error)")
        }
    }
    
    // retrieve all Saved Content
    func getAllContent() -> [ContentDB]?{
        let fetchRequest = NSFetchRequest<ContentDB>(entityName: ENTITY_NAME)
        
        do{
            // execute request
            let result = try self.moc.fetch(fetchRequest)
            print(#function, "Fetched data: \(result as [ContentDB])")
            // return fetched object
            return result as [ContentDB]
        } catch let error as NSError{
            print("Could not fetch data \(error) \(error.code)")
        }
        return nil
    }
    
}
