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

class MoviesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UISearchBarDelegate {

    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var movieCollectionView: UICollectionView!
    @IBOutlet weak var networkErrorView: UIView!
    @IBOutlet weak var movieTableView: UITableView!
    let searchBar = UISearchBar()
    
    var moviesArray = [Movie]()
    var moviesSearchArray = [Movie]()
    var currentPage = 1
    var isLoading: Bool!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.currentPage = 1
        self.isLoading = false
        
        // set page control (page 1 is init page)
        self.pageControl.currentPage = 1
        
        // Initialize a UIRefreshControl
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshControlAction(refreshControl:)), for: UIControlEvents.valueChanged)
        // add refresh control to table view
        movieTableView.insertSubview(refreshControl, at: 0)
        // add refresh control to collection view
        movieCollectionView.insertSubview(refreshControl, at: 0)
        
        // if device cannot connect network
        if Reachability.isConnectedToNetwork() == false {
            networkErrorView.isHidden = false;
            return
        }
        
        // show progress hub
        MBProgressHUD.showAdded(to: self.view, animated: true)

        // set datasource, delegate for tableview
        self.movieTableView.delegate = self
        self.movieTableView.dataSource = self
        // set datasource, delegate for collectionview
        self.movieCollectionView.delegate = self
        self.movieCollectionView.dataSource = self
        
        loadDataFrom(handleStopProcess: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        addSearchBar()
    }
    
    func addSearchBar() {
        searchBar.showsCancelButton = false
        searchBar.placeholder = "Search"
        searchBar.delegate = self
        
        self.navigationItem.titleView = searchBar
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func showTableView(_ sender: AnyObject) {
        self.movieCollectionView.isHidden = true
        self.movieTableView.isHidden = false
        
        // set page control
        self.pageControl.currentPage = 1
    }
    
    @IBAction func showCollectionView(_ sender: AnyObject) {
        self.movieCollectionView.isHidden = false
        self.movieTableView.isHidden = true
        
        // set page control
        self.pageControl.currentPage = 0
    }
    
    // MARK: - implement search bar delegate
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
    }
    
    // called when text changes (including clear)
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String){
        self.moviesSearchArray = moviesArray.filter({
            ($0.originalTitle?.contains(searchText))!
        })
        
        if searchText == "" {
            self.moviesSearchArray = self.moviesArray
        }
        
        self.movieTableView.reloadData()
        self.movieCollectionView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
        searchBar.resignFirstResponder()
    }
    
    // MARK: - implement collection delegate function
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return moviesSearchArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = movieCollectionView.dequeueReusableCell(withReuseIdentifier: "movieCollectionViewCell", for: indexPath) as! MovieCollectionViewCell
        
        // fill data for view
        if let originalTitle = moviesSearchArray[indexPath.row].originalTitle {
            cell.titleLabel.text = originalTitle
        }
        if let overview = moviesSearchArray[indexPath.row].overview {
            cell.overviewLabel.text = overview
        }
        if let posterPath = moviesSearchArray[indexPath.row].posterPath {
            let posterUrl = Global.mediumPosterUrlString + posterPath
            //            cell.posterImageView.setImageWith(URL(string: posterUrl)!)
            let imageRequest = URLRequest(
                url: URL(string: posterUrl)!,
                cachePolicy: NSURLRequest.CachePolicy.reloadIgnoringLocalCacheData,
                timeoutInterval: 10)
            cell.posterImageView.setImageWith(
                imageRequest,
                placeholderImage: nil,
                success: { (imageRequest, imageResponse, image) -> Void in
                    
                    // imageResponse will be nil if the image is cached
                    if imageResponse != nil {
                        //print("Image was NOT cached, fade in image")
                        cell.posterImageView.alpha = 0.0
                        cell.posterImageView.image = image
                        UIView.animate(withDuration: 0.3, animations: { () -> Void in
                            cell.posterImageView.alpha = 1.0
                        })
                    } else {
                        //print("Image was cached so just update the image")
                        cell.posterImageView.image = image
                    }
                },
                failure: { (imageRequest, imageResponse, error) -> Void in
                    // do something for the failure condition
            })
        }
        
        return cell
    }
    
    // MARK: - implement method UICollectionViewDelegateFlowLayout
    
    // change size of cell
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (self.view.bounds.width - 5) / 2
        let height = width * 1.5
        return CGSize(width: width, height: height)
    }
    
    
    // MARK: - implement table delegate function
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return moviesSearchArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = movieTableView.dequeueReusableCell(withIdentifier: "movieCell", for: indexPath) as! MovieTableViewCell
        
        // fill data for view
        if let originalTitle = moviesSearchArray[indexPath.row].originalTitle {
            cell.titleLabel.text = originalTitle
        }
        if let overview = moviesSearchArray[indexPath.row].overview {
            cell.overviewLabel.text = overview
        }
        if let posterPath = moviesSearchArray[indexPath.row].posterPath {
            let posterUrl = Global.mediumPosterUrlString + posterPath
            let imageRequest = URLRequest(
                url: URL(string: posterUrl)!,
                cachePolicy: NSURLRequest.CachePolicy.reloadIgnoringLocalCacheData,
                timeoutInterval: 10)
            cell.posterImageView.setImageWith(
                imageRequest,
                placeholderImage: nil,
                success: { (imageRequest, imageResponse, image) -> Void in
                    
                    // imageResponse will be nil if the image is cached
                    if imageResponse != nil {
                        //print("Image was NOT cached, fade in image")
                        cell.posterImageView.alpha = 0.0
                        cell.posterImageView.image = image
                        UIView.animate(withDuration: 0.3, animations: { () -> Void in
                            cell.posterImageView.alpha = 1.0
                        })
                    } else {
                        //print("Image was cached so just update the image")
                        cell.posterImageView.image = image
                    }
                },
                failure: { (imageRequest, imageResponse, error) -> Void in
                    // do something for the failure condition
            })
        }
        
        cell.selectionStyle = UITableViewCellSelectionStyle.none;
        
        return cell
    }
    
    // load next page
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row > (moviesArray.count - 5) && isLoading == false {
            self.currentPage += 1
            self.loadDataFrom(handleStopProcess: nil)
        }
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let movieDetailViewController = segue.destination as! MovieDetailViewController
        
        var indexMovie: IndexPath!
        if segue.identifier == "showDetailMovieFromCollectionView" {
            indexMovie = movieCollectionView.indexPathsForSelectedItems?[0]
        }
        if segue.identifier == "showDetailMovieFromTableView" {
            indexMovie = movieTableView.indexPathForSelectedRow
        }
        movieDetailViewController.movie = moviesSearchArray[(indexMovie?.row)!]
        
        // hide keyboard of search bar
        searchBar.resignFirstResponder()
    }
    
    // MARK: - refreshControl
    
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
        
        // reset current page
        self.currentPage = 1
        
        let handleProcessControl = { () -> () in
            // Tell the refreshControl to stop spinning
            refreshControl.endRefreshing()
        }
        
        loadDataFrom(handleStopProcess: handleProcessControl)
    }


    // MARK: - private method
    
    func loadDataFrom(handleStopProcess: (() -> ())?) {
        self.isLoading = true
        
        // create url for load data
        let url = URL(string: "\(Global.prefixUrlStringRequest + Global.moviesApiKey)&page=\(self.currentPage)")
        
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
                                        self.parseDataFrom(moviesDictionary: moviesDictionary)
                                        
                                        // reload table view
                                        self.movieTableView.reloadData()
                                        self.movieCollectionView.reloadData()
                                        
                                        // hide progress hub
                                        MBProgressHUD.hide(for: self.view, animated: true)
                                        
                                        // Tell the refreshControl to stop spinning if have
                                        if handleStopProcess != nil {
                                            handleStopProcess!()
                                        }
                                        
                                        self.isLoading = false
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
        
        self.moviesSearchArray = self.moviesArray
    }
    
}













