//
//  MoviesViewController.swift
//  FlickApp
//
//  Created by CongTruong on 10/11/16.
//  Copyright © 2016 congtruong. All rights reserved.
//

import UIKit
import AFNetworking

class MoviesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var movieTableView: UITableView!
    
    var moviesArray = [Movie]()
    let lowPosterUrlString = "https://image.tmdb.org/t/p/w342"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.movieTableView.delegate = self
        self.movieTableView.dataSource = self
        
        let moviesApiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
        let url = URL(string: "https://api.themoviedb.org/3/movie/now_playing?api_key=\(moviesApiKey)")
        
        loadDataFrom(url: url!)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return moviesArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = movieTableView.dequeueReusableCell(withIdentifier: "movieCell", for: indexPath) as! MovieTableViewCell
        
        // fill data for view
        if let originalTitle = moviesArray[indexPath.row].originalTitle {
            cell.titleLabel.text = originalTitle
        }
        if let overview = moviesArray[indexPath.row].overview {
            cell.overviewLabel.text = overview
        }
        if let posterPath = moviesArray[indexPath.row].posterPath {
            let posterUrl = lowPosterUrlString + posterPath
            cell.posterImageView.setImageWith(URL(string: posterUrl)!)
        }
        
        return cell
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let movieDetailViewController = segue.destination as! MovieDetailViewController
        
        let indexMovie = movieTableView.indexPathForSelectedRow
        movieDetailViewController.movie = moviesArray[(indexMovie?.row)!]
    }

    // MARK: - private method
    
    func loadDataFrom(url: URL) {
        // load data from server
        let request = URLRequest(
            url: url,
            cachePolicy: NSURLRequest.CachePolicy.reloadIgnoringLocalCacheData,
            timeoutInterval: 10)
        let session = URLSession(
            configuration: URLSessionConfiguration.default,
            delegate: nil,
            delegateQueue: OperationQueue.main
        )
        let task: URLSessionDataTask =
            session.dataTask(with: request,
                             completionHandler: { (dataOrNil, response, error) in
                                if let data = dataOrNil {
                                    if let responseDictionary = try! JSONSerialization.jsonObject(
                                        with: data, options:[]) as? NSDictionary {
                                        let moviesDictionary = responseDictionary["results"] as! [NSDictionary]
                                        //print("response: \(self.moviesDictionary)")
                                        self.parseDataFrom(moviesDictionary: moviesDictionary)
                                        self.movieTableView.reloadData()
                                    }
                                }
            })
        task.resume()
    }
    
    func parseDataFrom(moviesDictionary: [NSDictionary]) {
        for movieItem in moviesDictionary {
            let posterPath = movieItem["poster_path"] as? String
            let originalTitle = movieItem["original_title"] as? String
            let overview = movieItem["overview"] as? String
            let releaseDate = movieItem["release_date"] as? String
            
            let movie = Movie(posterUrlPath: posterPath, originalTitle: originalTitle, overview: overview, releaseDate: releaseDate)
            self.moviesArray.append(movie)
        }
        
    }
}













