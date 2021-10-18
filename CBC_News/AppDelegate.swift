//
//  AppDelegate.swift
//  CBC_News
//
//  Created by Valya Derksen on 2021-10-14.
//

import UIKit
import CoreData

@main
class AppDelegate: UIResponder, UIApplicationDelegate {



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    // Core Data
    lazy var persistentConteiner : NSPersistentContainer = {
        let container = NSPersistentContainer(name: "CBC_News")
        container.loadPersistentStores(completionHandler: {(storeDescription, error) in
            if let error = error as NSError? {
               // fatalError("Unresolved error \(error)")
                print("Unresolved error \(error)")
            }
        })
        return container
    }()
    
    // Core Data Saving support
    func saveContex(){
        let contex = persistentConteiner.viewContext
        
        if contex.hasChanges {
            do{
                try contex.save()
            }catch{
                let nserror = error as NSError
                // fatalError("Unresolved error \(nserror)")
                 print("Unresolved error \(nserror)")
            }
        }
    }


}
