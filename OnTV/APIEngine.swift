//
//  APIEngine.swift
//  OnTV
//
//  Created by Chandan Sarkar on 14.07.17.
//  Copyright © 2017 Chandan. All rights reserved.
//

import Foundation

let BASE_URL_TV = "http://api.themoviedb.org/3/tv/"
let AUTH_PARAM = "?api_key="
let TV_TYPE_POPULAR = "popular"
let PAGE_PARAM = "&page=1"

let BASIC_TV_DATA_URL = "\(BASE_URL_TV)\(TV_TYPE_POPULAR)\(AUTH_PARAM)\(API_KEY)\(PAGE_PARAM)"

let BASE_URL_POSTER = "http://image.tmdb.org/t/p/w780"
let BASE_URL_BACKDROP = "http://image.tmdb.org/t/p/w1280"


//Your API Key goes here//
let API_KEY = "Your Api key goes here..."

//Custom closure that will denote the completion of the download
typealias DownloadComplete = () -> ()
