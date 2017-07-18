//
//  CarouselCell.swift
//  OnTV
//
//  Created by Chandan Sarkar on 15.07.17.
//  Copyright © 2017 Chandan. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage
import CoreData

class CarouselCell: UICollectionViewCell {
    
    // Getting reference for the NSPersistentContainer
    var container: NSPersistentContainer? = ((UIApplication.shared.delegate as? AppDelegate)?.persistentContainer)
    
    @IBOutlet weak var seriesPosterOutlet: UIImageView!
//    @IBOutlet weak var seriesNameOutlet: UILabel!
//    @IBOutlet weak var seriesRatingOutlet: UILabel!
//    @IBOutlet weak var seriesGenreOutlet: UILabel!
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.layer.cornerRadius = 5.0
        self.clipsToBounds = true
    }
    
    // Configures each cell to show the Series Posters
    func configureSeriesPosterCell(_ series: Series) {
        print("configurePosterCell is called")
        Alamofire.request(series.series_poster_path!).responseImage { response in
            if let posterImage = response.result.value {
                self.seriesPosterOutlet.image = posterImage
            }
        }
//        self.seriesNameOutlet.text = series.series_name
//        self.seriesRatingOutlet.text = "\(series.series_rating)/10"
        
//        var genreString: String = ""
//        printDatabaseStatistic()
//        if series.toGenre?.count == 0 {
//            genreString = "Will be updated..."
//        }else{
//            let array = series.toGenre?.allObjects as! [Genre]
//            var counter = 0
//            for genre in array {
//                if counter < 2 {
//                    if let eachGenre = genre.genre_name {
//                        genreString = "\(genreString) \(eachGenre)"
//                    }
//                }
//                counter += 1
//            }
//        }
//        seriesGenreOutlet.text = genreString
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
                let genereFethcRequest: NSFetchRequest<Genre> = Genre.fetchRequest()
                if let genreCount = (try? self.container?.viewContext.fetch(genereFethcRequest))??.count {
                    print("Genre Count: \(genreCount)")
                }
            }
        }
    }
}
