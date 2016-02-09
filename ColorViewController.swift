//
//  ColorViewController.swift
//  Flicks
//
//  Created by dong liang on 2/9/16.
//  Copyright © 2016 dong. All rights reserved.
//

import UIKit

class ColorViewController: UIViewController {
    
    
    @IBOutlet weak var mycollectionview: UICollectionView!
    
    
    @IBOutlet weak var myflow: UICollectionViewFlowLayout!
    let totalColors: Int = 100
    func colorForIndexPath(indexPath: NSIndexPath) -> UIColor {
        if indexPath.row >= totalColors {
            return UIColor.blackColor()	// return black if we get an unexpected row index
        }
        
        var hueValue: CGFloat = CGFloat(indexPath.row) / CGFloat(totalColors)
        return UIColor(hue: hueValue, saturation: 1.0, brightness: 1.0, alpha: 1.0)
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        mycollectionview.dataSource = self
        
        
        myflow.minimumLineSpacing = 0
        myflow.minimumInteritemSpacing = 0
        myflow.sectionInset = UIEdgeInsetsMake(0, 0, 0, 10)

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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

extension ColorViewController: UICollectionViewDataSource {
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return totalColors
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("mycolorcell", forIndexPath: indexPath) as! MyCollectionViewCell
        let cellColor = colorForIndexPath(indexPath)
        cell.backgroundColor = cellColor
        
        if CGColorGetNumberOfComponents(cellColor.CGColor) == 4 {
            let redComponent = CGColorGetComponents(cellColor.CGColor)[0] * 255
            let greenComponent = CGColorGetComponents(cellColor.CGColor)[1] * 255
            let blueComponent = CGColorGetComponents(cellColor.CGColor)[2] * 255
            cell.colorlabel.text = String(format: "%.0f, %.0f, %.0f", redComponent, greenComponent, blueComponent)
        }
        
        return cell
    }
}


