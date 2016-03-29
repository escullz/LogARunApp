//
//  BookmarksViewController.swift
//  MediumMenu
//
//  Created by pixyzehn on 2/4/15.
//  Copyright (c) 2015 pixyzehn. All rights reserved.
//

import UIKit

class Leaders: BaseViewController {
    @IBOutlet var leader: UILabel!
    @IBOutlet var trophyPic: UIImageView!
   /* override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }*/

   /* required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }*/
    @IBOutlet var menButt: UIButton!
    @IBOutlet var womenButt: UIButton!
    
    var sectionTitleArrayMen : NSMutableArray = NSMutableArray()
    var sectionTitleArrayWomen : NSMutableArray = NSMutableArray()
    var sectionContentDict : NSMutableDictionary = NSMutableDictionary()
    var arrayForBool : NSMutableArray = NSMutableArray()
    
    let gray = UIColor.colorFromCode(0x656565)
    let green = UIColor.colorFromCode(0x7AA16B)
    let yellow = UIColor.colorFromCode(0xFAFFCD)
    
    var menIsSeleted: Bool = true


    @IBAction func loadMen(sender: AnyObject) {
        
     //   sectionTitleArray = getLeaders()
        
        menIsSeleted = true
    
        tableView.reloadData()
        
        womenButt.titleLabel?.textColor = green
        womenButt.backgroundColor = gray
        
        menButt.backgroundColor = green
        menButt.titleLabel?.textColor = yellow

        view.bringSubviewToFront(menButt)
        view.bringSubviewToFront(womenButt)
        view.bringSubviewToFront(leader)
        
        
    }
    
    @IBAction func loadWomen(sender: AnyObject) {
        
        menIsSeleted = false
       
        tableView.reloadData()
        
        womenButt.titleLabel?.textColor = yellow
        womenButt.backgroundColor = green
        
        menButt.backgroundColor = gray
        menButt.titleLabel?.textColor = green
        
    }
    
    @IBOutlet var tableView: UITableView!
    
    func getLeaders() -> NSMutableArray {
        
        let array1: NSMutableArray = []
        
        let urlString = "https://www.kimonolabs.com/api/5667eba6?&apikey=9xR1gP9goXnNImPQCGAwO9LKCNf8kDDP&kimmodify=1"
        
        if let url = NSURL(string: urlString) {
            
            if let data = try? NSData(contentsOfURL: url, options: []) {
                
                let json: NSDictionary
                
                do {
                    
                    json = try NSJSONSerialization.JSONObjectWithData(data, options: []) as! [String:AnyObject]
                    
                    let large = (json["results"]!["collection1"]!)!
                    
                    for i in Range(start: 0, end: large.count){
                        
                        let Div = large[i]["Divisions"]
                        
                        array1.insertObject(Div!!.description, atIndex: array1.count)
                    
                    }} catch _ {
                    
                    print("error")
                    
                }}}

        return array1
        
    }
    
    func getPeople(int: Int) -> NSMutableArray {
        
        let array1: NSMutableArray = []
        
        let urlString = "https://www.kimonolabs.com/api/5667eba6?&apikey=9xR1gP9goXnNImPQCGAwO9LKCNf8kDDP&kimmodify=1"
        
        if let url = NSURL(string: urlString) {
            
            if let data = try? NSData(contentsOfURL: url, options: []) {
                
                let json: NSDictionary
                
                do {
                    
                    json = try NSJSONSerialization.JSONObjectWithData(data, options: []) as! [String:AnyObject]
                    
                    let large = (json["results"]!["collection1"]!)!
                    
                    let Div = large[int]["People"]
                    
                    for i in Range(start: 0, end: Div!!.count){
                        
                        let peepz = Div!![i]["text"]
                        
                        array1.insertObject(peepz!!.description, atIndex: array1.count)
                        
                    }} catch _ {
                    
                    print("error") }}}
        
        return array1
    
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        menIsSeleted = true
        
        womenButt.titleLabel!.textColor = green
        womenButt.backgroundColor = gray
        
        arrayForBool = ["0","0","0","0","0","0"]
        
        let sectionTitleArray = getLeaders()
        
        for x in sectionTitleArray {
            
            print("sectionTitleArray contents", x, x.description)
            
            if x.description.containsString("Female") {
                
                sectionTitleArrayWomen.addObject(x)
                
                
            }else{
                
                sectionTitleArrayMen.addObject(x)
                
            }
            
        }
        
        sectionTitleArrayMen.reverse()
        
        womenButt.layer.cornerRadius = 16
        menButt.layer.cornerRadius = 16
        
        for i in Range(start: 0, end: 6){
            let tmp1 : NSArray = getPeople(i)
            let string1 = sectionTitleArray.objectAtIndex(i) as? String
            [sectionContentDict .setValue(tmp1, forKey:string1!)]
        }
        
        tableView.reloadData()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        
        if(arrayForBool .objectAtIndex(section).boolValue == true)
        {
            return 10
        }
        
        return 0;
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "ABC"
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return 50
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        
        return 13
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        if(arrayForBool .objectAtIndex(indexPath.section).boolValue == true){
            return 55
        }
        
        return 2;
    }
    
    
    func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        let footerView = UIView(frame: CGRectMake(0, 0, tableView.frame.size.width, 20))
        footerView.backgroundColor = UIColor(
            red: 0xFC/255,
            green: 0xFF/255,
            blue: 0xD7/255,
            alpha: 0.0)
        footerView.tag = section
        
        return footerView
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerView = UIView(frame: CGRectMake(0, 0, tableView.frame.size.width-20, 40))
        headerView.backgroundColor = green
        headerView.layer.borderColor = UIColor.colorFromCode(0x3A7330).CGColor
        headerView.layer.cornerRadius = 25
        headerView.layer.borderWidth = 3
        headerView.tag = section
        let headerString = UILabel(frame: CGRect(x: (tableView.frame.midX)-((tableView.frame.size.width-10)/2), y: (headerView.frame.midY)-12, width: tableView.frame.size.width-10, height: 36)) as UILabel
        
        if menIsSeleted {
            headerString.text = sectionTitleArrayMen.objectAtIndex(section) as? String
        }else{
            headerString.text = sectionTitleArrayWomen.objectAtIndex(section) as? String
        }
        
        headerString.textAlignment = .Center
        headerString.textColor = UIColor.colorFromCode(0xFCFFD7)
        headerString.font = UIFont(name: "Helvetica-Neue-Bold", size: 35)
       
        if headerString.text == "Runners (Male - Ages 18 and under) who have run the most miles over the last 7 days" {
            headerString.text = "Men 18 & Younger"
            headerString.font = UIFont(name: "Helvetica-Neue", size: 45)
        }
        if headerString.text == "Runners (Female - Ages 18 and under) who have run the most miles over the last 7 days" {
            headerString.text = "Women 18 & Younger"
            headerString.font = UIFont(name: "Helvetica-Neue", size: 45)
            
        }
        if headerString.text == "Runners (Female - Ages 19-22) who have run the most miles over the last 7 days" {
            headerString.text = "Women 19-22"
            headerString.font = UIFont(name: "Helvetica-Neue", size: 45)
            
        }
        if headerString.text == "Runners (Female) who have run the most miles over the last 7 days" {
            headerString.text = "All Women"
            headerString.font = UIFont(name: "Helvetica-Neue", size: 45)
            
        }
        if headerString.text == "Runners (Male - Ages 19-22) who have run the most miles over the last 7 days" {
            headerString.text = "Men 19-22"
            headerString.font = UIFont(name: "Helvetica-Neue", size: 45)
            
        }
        if headerString.text == "Runners (Male) who have run the most miles over the last 7 days" {
            headerString.text = "All Men"
            headerString.font = UIFont(name: "Helvetica-Neue", size: 45)
            
        }
        headerView .addSubview(headerString)
        
        let headerTapped = UITapGestureRecognizer (target: self, action:"sectionHeaderTapped:")
        headerView .addGestureRecognizer(headerTapped)
        
        return headerView
        
    }
    
    func sectionHeaderTapped(recognizer: UITapGestureRecognizer) {
        print("Tapping working")
        print(recognizer.view?.tag)
        
        let indexPath : NSIndexPath = NSIndexPath(forRow: 0, inSection:(recognizer.view?.tag as Int!)!)
        if (indexPath.row == 0) {
            
            var collapsed = arrayForBool .objectAtIndex(indexPath.section).boolValue
            collapsed       = !collapsed;
            
            arrayForBool .replaceObjectAtIndex(indexPath.section, withObject: collapsed)
            //reload specific section animated
            let range = NSMakeRange(indexPath.section, 1)
            let sectionToReload = NSIndexSet(indexesInRange: range)
            self.tableView .reloadSections(sectionToReload, withRowAnimation:UITableViewRowAnimation.Fade)
            
            
        }
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        
        let CellIdentifier = "person"
        var list : NSMutableArray
        var cell :UITableViewCell
        cell = tableView.dequeueReusableCellWithIdentifier(CellIdentifier, forIndexPath: indexPath)
        
        let manyCells : Bool = arrayForBool .objectAtIndex(indexPath.section).boolValue
        
        if (!manyCells) {
            cell.textLabel!.text = "click to enlarge";
        }
        else{
            if menIsSeleted {
                list = sectionTitleArrayMen
            }else{
                list = sectionTitleArrayWomen
            }
            
            let content = sectionContentDict .valueForKey(list.objectAtIndex(indexPath.section) as! String) as! NSArray
            cell.textLabel?.text = String(indexPath.row+1) + ".   " + (content .objectAtIndex(indexPath.row) as! String)
            cell.backgroundColor = UIColor(
                red: 0x34/255,
                green: 0x67/255,
                blue: 0x33/255,
                alpha: 0.0)
            cell.textLabel?.textAlignment = .Center
            cell.textLabel?.textColor = .blackColor()
        

        }
        
        cell.layer.transform = CATransform3DMakeScale(0.1,0.1,0)
        UIView.animateWithDuration(0.3, animations: {
            cell.layer.transform = CATransform3DMakeScale(1,1,1)
            },completion: { finished in
                UIView.animateWithDuration(0.1, animations: {
                    cell.layer.transform = CATransform3DMakeScale(1,1,1)
                })
        })
        
        return cell
    }
    
    
}