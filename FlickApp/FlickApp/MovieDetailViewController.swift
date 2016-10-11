//
//  MovieDetailViewController.swift
//  FlickApp
//
//  Created by CongTruong on 10/11/16.
//  Copyright © 2016 congtruong. All rights reserved.
//

import UIKit
import AFNetworking

class MovieDetailViewController: UIViewController {

    @IBOutlet weak var posterImageView: UIImageView!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var percentageLabel: UILabel!
    @IBOutlet weak var hourLabel: UILabel!
    @IBOutlet weak var overviewLabel: UILabel!
    
    var movie: Movie!
    let highPosterUrlString = "https://image.tmdb.org/t/p/original"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        if let originalTitle = movie.originalTitle {
            self.titleLabel.text = originalTitle
        }
        if let overview = movie.overview {
            self.overviewLabel.text = overview
        }
        if let posterPath = movie.posterPath {
            self.posterImageView.setImageWith(URL(string: highPosterUrlString + posterPath)!)
        }
        if let dateRelease = movie.releaseDate {
            self.dateLabel.text = dateRelease
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
