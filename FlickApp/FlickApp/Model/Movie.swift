//
//  Movie.swift
//  FlickApp
//
//  Created by CongTruong on 10/11/16.
//  Copyright © 2016 congtruong. All rights reserved.
//

import Foundation

class Movie {
    var posterPath: String?
    var adult: Bool?
    var overview: String?
    var releaseDate: String?
    var genreIds: [Int]?
    var id: Int?
    var originalTitle: String?
    var originalLanguage: String?
    var title: String?
    var backdropPath: String?
    var popularity: Float?
    var voteCount: Int?
    var video: Bool?
    var voteAverage: Float?
    
    init(posterUrlPath: String?, originalTitle: String?, overview: String?, releaseDate: String?) {
        self.posterPath = posterUrlPath
        self.originalTitle = originalTitle
        self.overview = overview
        self.releaseDate = releaseDate
    }
}
