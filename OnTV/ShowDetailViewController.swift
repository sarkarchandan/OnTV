//
//  ShowDetailViewController.swift
//  OnTV
//
//  Created by Chandan Sarkar on 14.07.17.
//  Copyright © 2017 Chandan. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage

class ShowDetailViewController: UIViewController {
    
    var _series: Series!
    
    var series: Series {
        get {
            return _series
        }
        set {
            _series = newValue
        }
    }
    
    @IBOutlet weak var backdropImageOutlet: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        configureBackdDrop()
    }
    
    func configureBackdDrop() {
        Alamofire.request(series.series_backdrop_path!).responseImage { response in
            if let image = response.result.value {
                self.backdropImageOutlet.image = image
            }
        }
    }
}
