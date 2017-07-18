//
//  Genre.swift
//  OnTV
//
//  Created by Chandan Sarkar on 14.07.17.
//  Copyright © 2017 Chandan. All rights reserved.
//

import UIKit
import CoreData
import Alamofire

class Genre: NSManagedObject {
    
//    class func persistGenresWithCheck(data series: [String:Any], in context: NSManagedObjectContext) throws {
//        if let seriesName = series["name"] as? String {
//            let seriesFetchRequest: NSFetchRequest<Series> = Series.fetchRequest()
//            let seriesPredicate = NSPredicate(format: "series_name == %@", seriesName)
//            seriesFetchRequest.predicate = seriesPredicate
//            
//            do {
//                let matchingSeries = try context.fetch(seriesFetchRequest)
//                assert(matchingSeries.count <= 1, "Datastore inconsistency detected")
//                if matchingSeries.count == 1 {
//                    let fetchedSeries = matchingSeries[0]
//                    
//                    if fetchedSeries.toGenre?.count == 0 {
//                        
//                        if let genres = series["genres"] as? [[String:Any]] {
//                            for genreDictionary in genres {
//                                
//                                let genre = Genre(context: context)
//                                
//                                if let genreId = genreDictionary["id"] as? Int16 {
//                                    genre.genre_id = genreId
//                                }
//                                if let genreName = genreDictionary["name"] as? String {
//                                    genre.genre_name = genreName
//                                }
//                                fetchedSeries.addToToGenre(genre)
//                            }
//                        }
//                    }
//                }
//            }
//            catch {
//                throw error
//            }
//        }
//    }
    
    class func persistGenereForSeries(entity series: Series, in context: NSManagedObjectContext) {
        if series.toGenre?.count == 0 {
            let DETAIL_TV_DATA_URL = "\(BASE_URL_TV)\(series.series_id)\(AUTH_PARAM)\(API_KEY)"
            
            Alamofire.request(DETAIL_TV_DATA_URL).responseJSON { response in
                if let seriesDetails = response.result.value as? [String:Any] {
                    if let genreDetails = seriesDetails["genres"] as? [[String:Any]] {
                        
                        for genreDictionary in genreDetails {
                            
                            let genre = Genre(context: context)
                            
                            if let genreId = genreDictionary["id"] as? Int16 {
                                genre.genre_id = genreId
                            }
                            if let genreName = genreDictionary["name"] as? String {
                                genre.genre_name = genreName
                            }
                            series.addToToGenre(genre)
                            try? context.save()
                        }
                    }
                }
            }
        }
    }
}

