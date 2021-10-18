//
//  ContentFetcher.swift
//  CBC_News
//
//  Created by Valya Derksen on 2021-10-14.
//

import Foundation
class ContentFetcher : ObservableObject{
    var apiURL = "https://www.cbc.ca/aggregate_api/v1/items?lineupSlug=news&categorySet=cbc-news-apps&typeSet=cbc-news-apps-feed-v2&excludedCategorySet=cbc-news-apps-exclude&page=1&pageSize=20"
    
    @Published var contentList = [Content]()
    
    //singleton instance
    private static var shared : ContentFetcher?
    
    static func getInstance() -> ContentFetcher{
        if shared != nil{
            //instance already exists
            return shared!
        }else{
            // create a new singlton instance
            return ContentFetcher()
        }
    }
    
    func fetchDataFromAPI(){
        guard let api = URL(string: apiURL) else {
            return
        }
        URLSession.shared.dataTask(with: api){ (data: Data?, response: URLResponse?, error: Error?) in
            if let err = error {
                print(#function, "Could not fetch data", err)
            }else {
                // receive data or response
                
                DispatchQueue.global().async {
                    do {
                        if let jsonData = data {
                            let decoder = JSONDecoder()
                            // use this responce if array of JSON objects
                            let decodedList = try decoder.decode([Content].self, from: jsonData)
                            // use this responce if JSON object
                            
                            DispatchQueue.main.async {
                                self.contentList = decodedList
                            }
                            
                        } else {
                            print(#function, "No JSON data received")
                        }
                        
                    } catch  let error {
                        print(#function, error)
                    }
                }
            }
        }.resume()
    }
}
