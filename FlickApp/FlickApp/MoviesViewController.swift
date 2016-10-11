//
//  MoviesViewController.swift
//  FlickApp
//
//  Created by CongTruong on 10/11/16.
//  Copyright © 2016 congtruong. All rights reserved.
//

import UIKit
import AFNetworking
import MBProgressHUD
import SystemConfiguration

public class Reachability {
    
    class func isConnectedToNetwork() -> Bool {
        
        var zeroAddress = sockaddr_in(sin_len: 0, sin_family: 0, sin_port: 0, sin_addr: in_addr(s_addr: 0), sin_zero: (0, 0, 0, 0, 0, 0, 0, 0))
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        guard let defaultRouteReachability = withUnsafePointer(to: &zeroAddress, {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                SCNetworkReachabilityCreateWithAddress(nil, $0)
            }
        }) else {
            return false
        }
//        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
//            SCNetworkReachabilityCreateWithAddress(kCFAllocatorDefault, UnsafePointer($0))
//        }
        
        var flags: SCNetworkReachabilityFlags = SCNetworkReachabilityFlags(rawValue: 0)
        if SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) == false {
            return false
        }
        
        let isReachable = flags == .reachable
        let needsConnection = flags == .connectionRequired
        
        return isReachable && !needsConnection
        
    }
}

class MoviesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var networkErrorView: UIView!
    @IBOutlet weak var movieTableView: UITableView!
    
    var moviesArray = [Movie]()
    let lowPosterUrlString = "https://image.tmdb.org/t/p/w342"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Initialize a UIRefreshControl
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshControlAction(refreshControl:)), for: UIControlEvents.valueChanged)
        // add refresh control to table view
        movieTableView.insertSubview(refreshControl, at: 0)
        
        // if device cannot connect network
        if Reachability.isConnectedToNetwork() == false {
            networkErrorView.isHidden = false;
            return
        }
        
        // show progress hub
        MBProgressHUD.showAdded(to: self.view, animated: true)

        self.movieTableView.delegate = self
        self.movieTableView.dataSource = self
        
        loadDataFrom(handleStopProcess: nil)
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
    
    // MARK - refreshControl
    
    // Makes a network request to get updated data
    // Updates the tableView with the new data
    // Hides the RefreshControl
    func refreshControlAction(refreshControl: UIRefreshControl) {
        // if device cannot connect network
        if Reachability.isConnectedToNetwork() == false {
            networkErrorView.isHidden = false;
            refreshControl.endRefreshing()
            return
        }
        else {
            networkErrorView.isHidden = true;
        }
        
        let handleProcessControl = { () -> () in
            // Tell the refreshControl to stop spinning
            refreshControl.endRefreshing()
        }
        
        loadDataFrom(handleStopProcess: handleProcessControl)
    }


    // MARK: - private method
    
    func loadDataFrom(handleStopProcess: (() -> ())?) {
        // create url for load data
        let moviesApiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
        let url = URL(string: "https://api.themoviedb.org/3/movie/now_playing?api_key=\(moviesApiKey)")
        
        // load data from server
        let request = URLRequest(
            url: url!,
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
                                        
                                        // reload table view
                                        self.movieTableView.reloadData()
                                        
                                        // hide progress hub
                                        MBProgressHUD.hide(for: self.view, animated: true)
                                        
                                        // Tell the refreshControl to stop spinning if have
                                        if handleStopProcess != nil {
                                            handleStopProcess!()
                                        }
                                    }
                                }
            })
        task.resume()
    }
    
    func parseDataFrom(moviesDictionary: [NSDictionary]) {
        for movieItem in moviesDictionary {
            // get data from dictionary
            let posterPath = movieItem["poster_path"] as? String
            let originalTitle = movieItem["original_title"] as? String
            let overview = movieItem["overview"] as? String
            let releaseDate = movieItem["release_date"] as? String
            
            // create object and add to array movies
            let movie = Movie(posterUrlPath: posterPath, originalTitle: originalTitle, overview: overview, releaseDate: releaseDate)
            self.moviesArray.append(movie)
        }
        
    }
    
}













