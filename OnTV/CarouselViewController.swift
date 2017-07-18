//
//  CarouselViewController.swift
//  OnTV
//
//  Created by Chandan Sarkar on 14.07.17.
//  Copyright © 2017 Chandan. All rights reserved.
//

import UIKit
import CoreData
import Alamofire

// MARK: - ViewController Main Components
class CarouselViewController: UIViewController,
UINavigationControllerDelegate,
UISearchBarDelegate{
    
    // Getting reference of the PersistentContainer
    var container: NSPersistentContainer? = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer
    // Getting reference of the NSFetchedResultController
    var seriesBasicFetchedResultController: NSFetchedResultsController<Series>!
    // Outlet for the UiCollectionView
    @IBOutlet weak var seriesCollectionViewOutlet: UICollectionView!
    // Computed property for the UIStatusBarStyle
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return UIStatusBarStyle.lightContent
    }
    
    //UISearchController reference as Optional
    private var searchController: UISearchController?
    // IBAction function for the Search Functionality
    @IBAction func searchBarButtonClicked(_ sender: UIBarButtonItem) {
        searchController = UISearchController(searchResultsController: nil)
        searchController?.hidesNavigationBarDuringPresentation = true
        searchController?.searchBar.keyboardType = UIKeyboardType.default
        searchController?.searchBar.placeholder = "Looking for a series !!!"
        searchController?.searchBar.searchBarStyle = UISearchBarStyle.minimal
        (searchController?.searchBar.value(forKey: "searchField") as? UITextField)?.textColor = UIColor.black
        searchController?.searchBar.tintColor = UIColor.black
        self.searchController?.searchBar.delegate = self
        present(searchController!, animated: true, completion: nil)
    }
    
    // IBAction function for refreshing the view
    @IBAction func refreshBarButtonClicked(_ sender: Any) {
        self.fetchSeriesDataFromDatastore()
        self.seriesCollectionViewOutlet.reloadData()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setTranslucentNavigationBar()
        downloadSeriesData {
            self.seriesCollectionViewOutlet.reloadData()
        }
        self.seriesCollectionViewOutlet.dataSource = self
        self.seriesCollectionViewOutlet.delegate = self
        self.fetchSeriesDataFromDatastore()
        self.seriesCollectionViewOutlet.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.fetchSeriesDataFromDatastore()
        self.seriesCollectionViewOutlet.reloadData()
    }
    
    
    // Configures the Translucent Navigation Bar
    func setTranslucentNavigationBar() {
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.view.backgroundColor = .clear
        self.navigationController?.navigationBar.barStyle = .blackOpaque
    }
    
    // Downloads the series data with Api call
    func downloadSeriesData(downloadComplete: @escaping DownloadComplete){
        Alamofire.request(BASIC_TV_DATA_URL).responseJSON { response in
            if let data = response.result.value as? [String:Any] {
                if let series_array = data["results"] as? [[String:Any]] {
                    self.persistBasicSeriesData(series_array)
                }
            }
            downloadComplete()
        }
    }
}


// MARK: - Persistence and UICollectionView Components
extension CarouselViewController: UICollectionViewDataSource,
UICollectionViewDelegate,
NSFetchedResultsControllerDelegate{
    
    // Persists the series data into datastore
    func persistBasicSeriesData(_ seriesData: [[String:Any]]) {
        self.container?.performBackgroundTask { context in
            try? Series.persistSeriesDataWithCheck(data: seriesData, in: context)
            try? context.save()
        }
        //printDatabaseStatistic()
    }
    
    // Checks whether the persistence is successful
    func printDatabaseStatistic(){
        container?.viewContext.perform {
            if Thread.isMainThread {
                print("Main Thread")
            }else{
                print("Background Thread")
            }
            if (self.container?.viewContext) != nil {
                let seriesFethcRequest: NSFetchRequest<Series> = Series.fetchRequest()
                if let seriesCount = (try? self.container?.viewContext.fetch(seriesFethcRequest))??.count {
                    print("Series Count: \(seriesCount)")
                }
            }
        }
    }
    
    // Fetches the Series data from Datastore
    func fetchSeriesDataFromDatastore() {
        let seriesBasicFetchRequest: NSFetchRequest<Series> = Series.fetchRequest()
        let seriesBasicSortDescriptor = NSSortDescriptor(key: "series_rating", ascending: false)
        seriesBasicFetchRequest.sortDescriptors = [seriesBasicSortDescriptor]
        self.seriesBasicFetchedResultController = NSFetchedResultsController(fetchRequest: seriesBasicFetchRequest, managedObjectContext: (self.container?.viewContext)!, sectionNameKeyPath: nil, cacheName: nil)
        self.seriesBasicFetchedResultController.delegate = self
        do{
            try self.seriesBasicFetchedResultController.performFetch()
        }catch{
            let error = error as NSError
            print("Error while feteching data: \(error)")
        }
    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.seriesCollectionViewOutlet.refreshControl?.beginRefreshing()
        self.seriesCollectionViewOutlet.reloadData()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.seriesCollectionViewOutlet.refreshControl?.endRefreshing()
        self.seriesCollectionViewOutlet.reloadData()
    }
    
    // Returns the number of sections that should be in our collection
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if let sections = self.seriesBasicFetchedResultController.sections {
            return sections.count
        }
        return 0
    }
    
    // Returns the number of items that should be per section in our collection
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let sections = self.seriesBasicFetchedResultController.sections {
            let sectionInfo = sections[section]
            return sectionInfo.numberOfObjects
        }
        return 0
    }
    
    // Cofigures and returns a collection vew cell as they should look like in UICollectionView
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "seriesCell", for: indexPath) as? CarouselCell {
            let series = self.seriesBasicFetchedResultController.object(at: indexPath)
            cell.configureSeriesPosterCell(series)
            return cell
        }else{
            return CarouselCell(coder: NSCoder())!
        }
    }
    
    // Defines what happens when use clicks on a collection item
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let seriesObjects = seriesBasicFetchedResultController.fetchedObjects , seriesObjects.count > 0 {
            let series = seriesObjects[indexPath.row]
            performSegue(withIdentifier: "showSeriesDetail", sender: series)
        }
    }
    
    // Prepares to perform the Segue transition
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showSeriesDetail" {
            if let destination = segue.destination as? ShowDetailViewController {
                if let series = sender as? Series {
                    destination.series = series
                }
            }
        }
    }
}

//MARK: - Scrolling customisation component
extension CarouselViewController: UIScrollViewDelegate {
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let layout = self.seriesCollectionViewOutlet?.collectionViewLayout as! UICollectionViewFlowLayout
        let cellWidthIncludingSpacing = layout.itemSize.width + layout.minimumLineSpacing
        var offset = targetContentOffset.pointee
        let index = (offset.x + scrollView.contentInset.left) / cellWidthIncludingSpacing
        let roundedIndex = index.rounded()
        offset = CGPoint(x: roundedIndex * cellWidthIncludingSpacing - scrollView.contentInset.left, y: -scrollView.contentInset.top)
        targetContentOffset.pointee = offset
    }
}

