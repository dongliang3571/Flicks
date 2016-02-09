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

class MoviesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var errorMessage: UILabel!

    var movies: [NSDictionary]?
    var myrequest: NSURLRequest?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "refreshControlAction:", forControlEvents: UIControlEvents.ValueChanged)
        tableView.insertSubview(refreshControl, atIndex: 0)
        loadDataFromNetwork()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let movies = movies {
            return movies.count
        } else {
            return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MovieCell", forIndexPath: indexPath) as! MovieCell
        let movie = movies![indexPath.row]
        let title = movie["title"] as? String
        let overview = movie["overview"] as? String
        let baseUrl = "http://image.tmdb.org/t/p/w500"
        let postpath = movie["poster_path"] as? String
        let imageUrl2 : String
        if let mypostpath = postpath {
            imageUrl2 = baseUrl + mypostpath
        }else {
            imageUrl2 = baseUrl
        }
        let imageUrl = NSURL(string: imageUrl2)
        cell.title.text = title
        cell.overview.text = overview
        cell.postview.setImageWithURL(imageUrl!)
        
        print("row \(indexPath.row)")
        return cell
    }
    
    func loadDataFromNetwork() {
        
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
        
        // Display HUD right before the request is made
        MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        
        let task: NSURLSessionDataTask = session.dataTaskWithRequest(myrequest!,
            completionHandler: { (dataOrNil, response, error) in
                if let data = dataOrNil {
                    if let responseDictionary = try! NSJSONSerialization.JSONObjectWithData(
                        data, options:[]) as? NSDictionary {
                            print("response: \(responseDictionary)")
                            
                            self.movies = responseDictionary["results"] as? [NSDictionary]
                            self.tableView.reloadData()
                    }
                }
        })
        task.resume()
        // Hide HUD once the network request comes back (must be done on main UI thread)
        MBProgressHUD.hideHUDForView(self.view, animated: true)
        // ... Remainder of response handling code ...
    }
        
    
    
    
    func refreshControlAction(refreshControl: UIRefreshControl) {
        
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
                            print("response: \(responseDictionary)")
                            
                            self.movies = responseDictionary["results"] as? [NSDictionary]
                            
                            // Reload the tableView now that there is new data
                            self.tableView.reloadData()
                            
                            // Tell the refreshControl to stop spinning
                            refreshControl.endRefreshing()
                    }
                }
        })

        task.resume()
    }
        
    

    

   
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
