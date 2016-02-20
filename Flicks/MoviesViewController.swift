//
//  MoviesViewController.swift
//  Flicks
//
//  Created by dong liang on 2/3/16.
//  Copyright © 2016 dong. All rights reserved.
//

import UIKit
import AFNetworking
import MBProgressHUD
import SystemConfiguration

class MoviesViewController: UIViewController {

    @IBOutlet weak var tableView: UICollectionView!
    @IBOutlet weak var errorMessage: UIButton!
    @IBOutlet weak var searchBar: UISearchBar!

    @IBOutlet weak var voteSegment: UISegmentedControl!
    
    var movies: [NSDictionary]?
    var myrequest: NSURLRequest?
    var filteredData: [NSDictionary]?
    var endpoint: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        searchBar.delegate = self
        
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "refreshControlAction:", forControlEvents: UIControlEvents.ValueChanged)
        tableView.insertSubview(refreshControl, atIndex: 0)
        
        if Reachability.isConnectedToNetwork() {
            errorMessage.hidden = true
            MBProgressHUD.showHUDAddedTo(self.view, animated: true)
            loadDataFromNetwork()
            MBProgressHUD.hideHUDForView(self.view, animated: true)
        } else {
            errorMessage.hidden = false
        }
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    func loadDataFromNetwork() {
        
        // ... Create the NSURLRequest (myRequest) ...
        let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
        let url = NSURL(string: "https://api.themoviedb.org/3/movie/\(endpoint)?api_key=\(apiKey)")
        myrequest = NSURLRequest(
            URL: url!,
            cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData,
            timeoutInterval: 10)
        
        // Configure session so that completion handler is executed on main UI thread
        let session = NSURLSession(
            configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
            delegate:nil,
            delegateQueue:NSOperationQueue.mainQueue()
        )
        
        // Display HUD right before the request is made
        
        
        let task: NSURLSessionDataTask = session.dataTaskWithRequest(myrequest!,
            completionHandler: { (dataOrNil, response, error) in
                if let data = dataOrNil {
                    if let responseDictionary = try! NSJSONSerialization.JSONObjectWithData(
                        data, options:[]) as? NSDictionary {
//                            print("response: \(responseDictionary)")
                            
                            self.movies = responseDictionary["results"] as? [NSDictionary]
                            
                            let sortedarray = self.filterbyvote(self.movies!)
                            self.filteredData = sortedarray
                            self.tableView.reloadData()
                    }
                }
        })
        task.resume()
        // Hide HUD once the network request comes back (must be done on main UI thread)
        
        // ... Remainder of response handling code ...
    }
        
    
    
    
    func refreshControlAction(refreshControl: UIRefreshControl) {
        if Reachability.isConnectedToNetwork() {
            errorMessage.hidden = true
            errorMessage.setTitle("Network error!(Click to refresh)", forState: UIControlState.Normal)
        } else {
            errorMessage.hidden = false
            errorMessage.setTitle("Network is still down, try again", forState: UIControlState.Normal)
            refreshControl.endRefreshing()
        }
        // ... Create the NSURLRequest (myRequest) ...
        let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
        let url = NSURL(string: "https://api.themoviedb.org/3/movie/now_playing?api_key=\(apiKey)")
        myrequest = NSURLRequest(
            URL: url!,
            cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData,
            timeoutInterval: 10)
        // Configure session so that completion handler is executed on main UI thread
        let session = NSURLSession(
            configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
            delegate:nil,
            delegateQueue:NSOperationQueue.mainQueue()
        )
        
        let task : NSURLSessionDataTask = session.dataTaskWithRequest(myrequest!,
            completionHandler: { (data, response, error) in
                // ... Use the new data to update the data source ...
                if let mydata = data {
                    if let responseDictionary = try! NSJSONSerialization.JSONObjectWithData(
                        mydata, options:[]) as? NSDictionary {
//                            print("response: \(responseDictionary)")
                            
                            self.movies = responseDictionary["results"] as? [NSDictionary]
                            self.filteredData = self.movies
                            // Reload the tableView now that there is new data
                            self.tableView.reloadData()
                            
                            // Tell the refreshControl to stop spinning
                            refreshControl.endRefreshing()
                    }
                }
        })

        task.resume()
    }
        
    

    
    internal class Reachability {
        class func isConnectedToNetwork() -> Bool {
            var zeroAddress = sockaddr_in()
            zeroAddress.sin_len = UInt8(sizeofValue(zeroAddress))
            zeroAddress.sin_family = sa_family_t(AF_INET)
            let defaultRouteReachability = withUnsafePointer(&zeroAddress) {
                SCNetworkReachabilityCreateWithAddress(nil, UnsafePointer($0))
            }
            var flags = SCNetworkReachabilityFlags()
            if !SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) {
                return false
            }
            let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
            let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
            return (isReachable && !needsConnection)
        }
    }
   
    
    @IBAction func buttonPressed(sender: UIButton) {
        if Reachability.isConnectedToNetwork() {
            errorMessage.hidden = true
            errorMessage.setTitle("Network error!(Click to refresh)", forState: UIControlState.Normal)
            loadDataFromNetwork()
        } else {
            errorMessage.hidden = false
            errorMessage.setTitle("Network is still down, try again", forState: UIControlState.Normal)
        }
    }


}



extension MoviesViewController: UICollectionViewDataSource, UICollectionViewDelegate, UISearchBarDelegate {
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let movies = filteredData {
            return movies.count
        } else {
            return 0
        }
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = tableView.dequeueReusableCellWithReuseIdentifier("MovieCell", forIndexPath: indexPath) as! MovieCell
        let movie = filteredData![indexPath.row]
//        let title = movie["title"] as? String
//        let overview = movie["overview"] as? String
        let baseUrl = "http://image.tmdb.org/t/p/w500"
//        let votes = movie["vote_average"] as? Float
//        print(votes!)
        let postpath = movie["poster_path"] as? String
        let imageUrl2 : String
        if let mypostpath = postpath {
            imageUrl2 = baseUrl + mypostpath
        }else {
            imageUrl2 = baseUrl
        }
        let imageUrl: NSURLRequest = NSURLRequest(URL: NSURL(string: imageUrl2)!)
//        cell.title.text = title
//        cell.overview.text = overview
        cell.postview.setImageWithURLRequest(
            imageUrl,
            placeholderImage: nil,
            success: { (imageRequest, imageResponse, image) -> Void in
                
                // imageResponse will be nil if the image is cached
                if imageResponse != nil {
//                    print("Image was NOT cached, fade in image")
                    cell.postview.alpha = 0.0
                    cell.postview.image = image
                    UIView.animateWithDuration(2, animations: { () -> Void in
                        cell.postview.alpha = 1.0
                    })
                } else {
//                    print("Image was cached so just update the image")
                    cell.postview.image = image
                }
            },
            failure: { (imageRequest, imageResponse, error) -> Void in
                // do something for the failure condition
            }
        )
        
//        print("row \(indexPath.row)")
        return cell
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        filteredData = self.movies
        if searchText.isEmpty {
            tableView.reloadData()
        }
        else {
            var temp_array = [NSDictionary]()
            for each in filteredData! {
                let titleString = each["title"] as? String
                if titleString!.rangeOfString(searchText, options: .CaseInsensitiveSearch) != nil {
                    temp_array.append(each)
                }
                
                filteredData = temp_array
            }
            tableView.reloadData()
        }

    }
    
    
    @IBAction func voteSegmentPressed(sender: UISegmentedControl) {
        if(voteSegment.selectedSegmentIndex == 0) {
            var temp_array = [NSDictionary]()
            var sortedArray = [NSDictionary]()
            temp_array = self.movies!
            sortedArray = temp_array.sort { (element1, element2) -> Bool in
                return (element1["vote_average"] as! Float) > (element2["vote_average"] as! Float)
            }
            
            filteredData = sortedArray
            tableView.reloadData()
        }
        else {
            var temp_array = [NSDictionary]()
            var sortedArray = [NSDictionary]()
            temp_array = self.movies!
            sortedArray = temp_array.sort { (element1, element2) -> Bool in
                return (element1["vote_average"] as! Float) < (element2["vote_average"] as! Float)
            }
            
            filteredData = sortedArray
            tableView.reloadData()
        }
        
        
    }
    
    
    func filterbyvote(dictionary: [NSDictionary]) -> [NSDictionary]{
        
        var temp_array = [NSDictionary]()
        temp_array = dictionary
        let sortedArray = temp_array.sort { (element1, element2) -> Bool in
            return (element1["vote_average"] as! Float) > (element2["vote_average"] as! Float)
        }
        
        return sortedArray
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        let cell = sender as! UICollectionViewCell
        let indexpath = tableView.indexPathForCell(cell)
        let movie = movies![indexpath!.row]
        
        let detailViewController = segue.destinationViewController as! DetailViewController
        detailViewController.movie = movie
    }
    
    
}
