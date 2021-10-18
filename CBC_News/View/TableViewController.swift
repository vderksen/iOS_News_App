//
//  TableViewController.swift
//  CBC_News
//
//  Created by Valya Derksen on 2021-10-14.
//

import UIKit
import Combine
import Network

class TableViewController: UITableViewController {
    
    // API Fetcher
    private let contentFetcher = ContentFetcher.getInstance()
    private var contentList : [Content] = [Content]()  // the collection of objects received from API
    private var cancellables: Set<AnyCancellable> = []
    
    // Core Data
    private let dbHelper = DatabaseHelper.getInstance()
    private var cachedList : [ContentDB] = [ContentDB]() // the collection of objects received from Core Data
    
    private var filterrredList : [Content] = [Content]() // the collection of object filltered by type/category
    
    private var typesArray : [String] = [] // the collection of types to filter data
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Check for Network Connection
        monotirNetwork()
        
        // Add Navigation Bar
        configureNavigationBar()
    
        // FETCH data from CBC NEWS API
        self.contentFetcher.fetchDataFromAPI()
        self.receiveChanges()
        
        self.tableView.rowHeight = 250
        self.tableView.reloadData()
        
        // Add Refresh controller
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        self.refreshControl = refreshControl
    }
    
    // reload view again with refresh controller
    @objc func refresh(refreshControl: UIRefreshControl)
    {
        viewDidLoad()
        refreshControl.endRefreshing()
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        
        // if the data being filtered, display filtered list
        if(!self.filterrredList.isEmpty) {
            return self.filterrredList.count
        }
        
        // if no filtered data, check content list. If content list empty due network issue, display cahced list
        else if (self.contentList.isEmpty){
            return self.cachedList.count
        }
        
        // otherwise show full content list (when view did load and when user chose ALL news category)
        else {
            return self.contentList.count
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! TableViewCell

        // Configure the cell...
        // if the data being filtered, use filtered list to Configure the cell
        if(!self.filterrredList.isEmpty){
            cell.lblTitle.text = "\(self.filterrredList[indexPath.row].title)"
            let date = self.filterrredList[indexPath.row].date.components(separatedBy: ",")
            cell.lblPublishDate.text = "\(date[0])"
            let url = URL(string: self.filterrredList[indexPath.row].image)
            cell.coverImg.load(url: url!)
        }
        
        // if filtered and full content lists empty, use cached list to Configure the cell
        else if(self.contentList.isEmpty){
            cell.lblTitle.text = "\(String(describing: self.cachedList[indexPath.row].title))"
            let date = self.cachedList[indexPath.row].date!.components(separatedBy: ",")
            cell.lblPublishDate.text = "\(String(describing: date[0]))"
            let url = URL(string: self.cachedList[indexPath.row].image!)
            cell.coverImg.load(url: url!)
        }
        
        // otherwise, use full content list to Configure the cell
        else {
            cell.lblTitle.text = "\(self.contentList[indexPath.row].title)"
            let date = self.contentList[indexPath.row].date.components(separatedBy: ",")
            cell.lblPublishDate.text = "\(date[0])"
            let url = URL(string: self.contentList[indexPath.row].image)
            cell.coverImg.load(url: url!)
        }
        return cell
    }
    
    private func receiveChanges(){
        self.contentFetcher.$contentList.receive(on: RunLoop.main)
            .sink{ (item) in
                print(#function, "Received item : ", item)
                self.contentList.removeAll()
                self.contentList.append(contentsOf: item)
                self.tableView.reloadData()
                
                for item in self.contentList {
                    self.saveContent(content : item)
                    self.createTypeList(content : item)
                  }
            }
            .store(in : &cancellables)
    }
    
    func createTypeList(content : Content){
        self.typesArray.append(contentsOf: content.type) // append types arrays from each content object to types array
        self.typesArray.append("All")
        self.typesArray = Array(Set(self.typesArray)) // keep only unique values of types
        self.typesArray.sort()
        print("Array of types: \(self.typesArray) contains \(self.typesArray.count) elements")
        configureNavigationBar() // configure Navigation Bar again to create Meny items based on types array
    }
    
    // Save content object received form API to Core Data
    func saveContent(content : Content) {
        let newContent = SavedContent(id: content.id, title: content.title, date: content.date, image: content.image, type : content.type)
        self.dbHelper.insertContent(content: newContent)
    }
    
    // MARK: - NETWORK CONNECTION
    
    // check connection
    func monotirNetwork(){
        let monitor = NWPathMonitor()
        monitor.pathUpdateHandler = { path in
            // if not connection, show error notification
            if path.status == .unsatisfied {
                DispatchQueue.main.async {
                    self.showNetworkError()
                    
                    self.fetchAllSavedContent()
                }
            }
        }
        let queue = DispatchQueue(label: "Network")
        monitor.start(queue: queue)
    }
    
    // Display "No Interne Connection" alert message
    private func showNetworkError() {
        let alert = UIAlertController(title: nil, message: "No Internet connection.", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    // Fetch data from Core Data if no connection
    private func fetchAllSavedContent(){
        if(self.dbHelper.getAllContent() != nil){
            self.cachedList = self.dbHelper.getAllContent()!
            self.tableView.reloadData()
        }else {
            print(#function, "No data received from dbHelper")
        }
    }
    
    
    // MARK: - NAVIGATION BAR
    
    // Configure navigation bar
    private func configureNavigationBar(){
        let navBar = UINavigationBar(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 44))
        view.addSubview(navBar)
        
        // Add title to Navigation Bar
        let navItem = UINavigationItem(title: "")
        
        // Add Filter button to Navigation Bar on the right
        navItem.leftBarButtonItem = UIBarButtonItem(title: "CBC NEWS Filter", primaryAction: nil, menu: filterTapped())
        
        // change colors of bar
        navBar.barTintColor = UIColor.red
        
        // change color and style of left button title
        navItem.leftBarButtonItem?.tintColor = UIColor.white
        let attributes: [NSAttributedString.Key : Any] = [ .font: UIFont.boldSystemFont(ofSize: 20) ]
        navItem.leftBarButtonItem?.setTitleTextAttributes(attributes, for: .normal)
        
        navBar.setItems([navItem], animated: false)
    }

    // Display UIMenu when Filter button is pressed
    @objc private func filterTapped() -> UIMenu {
        var categoryMenu: UIMenu {
            let menuAction = self.typesArray.map { [weak self] item -> UIAction in
                let name = item
                return UIAction(title: name) { [weak self] _ in
                    self?.filterAPIData(category: item)
                }
            }
            print(menuAction)
            return UIMenu(title: "Choose Category", children: menuAction)
        }
        
        return categoryMenu
        
    }
    
    // Filter Data when Type/Category is chosen
    private func filterAPIData(category: String) {
        let type = category
        
        // if user chose to see All News, display full content list
        if(type == "All"){
            filterrredList = contentList
        }
        
        // if user chose to see any other type/category, filter content list by type
        else {

            filterrredList = contentList.filter { $0.type.contains(type)  }
            }
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
}

// MARK: - EXTENTION to get image from url

extension UIImageView {
    func load(url: URL) {
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: url) {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self?.image = image
                    }
                }
            }
        }
    }
}
