//
//  DetailViewController.swift
//  Flicks
//
//  Created by dong liang on 2/15/16.
//  Copyright © 2016 dong. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    
    @IBOutlet weak var detailImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var overview: UILabel!
    
    @IBOutlet weak var infoView: UIView!
    @IBOutlet weak var myScrollView: UIScrollView!
    
    
    var movie: NSDictionary?

    override func viewDidLoad() {
        super.viewDidLoad()
//        
        let contentWidth = myScrollView.frame.size.width
        let contentHeight = infoView.frame.origin.y + infoView.frame.size.height
        
        myScrollView.contentSize = CGSize(width: contentWidth, height: contentHeight)
        setupDetail()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupDetail() {
        if let localmovie = movie {
            
            titleLabel.text = localmovie["title"] as? String
            overview.text = localmovie["overview"] as? String
            overview.sizeToFit()
            
            let baseUrl = "http://image.tmdb.org/t/p/w500"
            if let poster_path = localmovie["poster_path"] as? String {
                let poster_url = NSURL(string: baseUrl+poster_path)
                detailImage.setImageWithURL(poster_url!)
            }
            
        }
        else {
            print("error occured")
        }
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
