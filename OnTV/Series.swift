//
//  Series.swift
//  OnTV
//
//  Created by Chandan Sarkar on 14.07.17.
//  Copyright © 2017 Chandan. All rights reserved.
//

import UIKit
import CoreData

class Series: NSManagedObject {
    
    //Persists the basic series data with checking prior existence
    class func persistSeriesDataWithCheck(data serieses: [[String:Any]] , in context: NSManagedObjectContext) throws {
        for series in serieses {
            if let seriesName = series["name"] as? String {
                let seriesFetchRequest: NSFetchRequest<Series> = Series.fetchRequest()
                let seriesPredicate = NSPredicate(format: "series_name == %@", seriesName)
                seriesFetchRequest.predicate = seriesPredicate
                
                do{
                    let matchingSerieses = try context.fetch(seriesFetchRequest)
                    assert(matchingSerieses.count <= 1, "Datastore inconsistency detected")
                    
                    if matchingSerieses.count == 0 {
                        let seriesEntity = Series(context: context)
                        if let seriesId = series["id"] as? Int32 {
                            seriesEntity.series_id = seriesId
                        }
                        seriesEntity.series_name = seriesName
                        seriesEntity.series_is_favorite = false
                        if let seriesSynopsis = series["overview"] as? String {
                            seriesEntity.series_synopsis = seriesSynopsis
                        }
                        if let seriesRating = series["vote_average"] as? Double {
                            seriesEntity.series_rating = seriesRating
                        }
                        if let seriesPosterUri = series["poster_path"] as? String {
                            seriesEntity.series_poster_path = "\(BASE_URL_POSTER)\(seriesPosterUri)"
                        }
                        if let seriesBackdropUri = series["backdrop_path"] as? String {
                            seriesEntity.series_backdrop_path = "\(BASE_URL_BACKDROP)\(seriesBackdropUri)"
                        }
                        if let seriesFirstAirDate = series["first_air_date"] as? NSDate {
                            seriesEntity.series_first_air_date = seriesFirstAirDate
                        }
                        Genre.persistGenereForSeries(entity: seriesEntity, in: context)
                    }
                }catch{
                    throw error
                }
            }
        }
    }
}
