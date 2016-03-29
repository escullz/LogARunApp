//
//  TeamVC.swift
//  LogARun
//
//  Created by Emmett Scully on 2/21/16.
//  Copyright © 2016 pixyzehn. All rights reserved.
//

import UIKit

extension NSDate {
    func dateFromString2(date: String, format: String) -> NSDate {
        let formatter = NSDateFormatter()
        let locale = NSLocale(localeIdentifier: "en_US_POSIX")
        
        formatter.locale = locale
        formatter.dateFormat = format
        
        return formatter.dateFromString(date)!
    }
}


class TeamVC: BaseViewController {
    
    @IBOutlet var teamText: UILabel!
    @IBOutlet var idText: UILabel!
    
  
    
    func getTeam () {
       
        let urlString = "http://www.logarun.com/"
        NSURLSession.sharedSession().dataTaskWithURL(NSURL(string: urlString)!) { data, response, error in
            
            let html2 = NSString(data: data!, encoding: NSUTF8StringEncoding)
            let parser2 = NDHpple(HTMLData: html2! as String)
            let team = "//*[@id='header_secondLevel']/ul/li[2]/ul/li[2]/a"
            let id = "//*[@id='header_secondLevel']/ul/li[2]/ul/li[2]/a/@href"
            guard let team1 = parser2.searchWithXPathQuery(team) else {
                
              
                
                return}
            guard let id1 = parser2.searchWithXPathQuery(id) else {
                
                
                return}
            for a in team1 {
                print(a.firstChild?.content)
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                
                    self.teamText.text = (a.firstChild?.content)
            })
            }
            for x in id1 {
                print(x.firstChild?.content)
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    
                    self.idText.text = (x.firstChild?.content)?.stringByReplacingOccurrencesOfString("TeamCalendar.aspx?teamid=", withString: "")
                })
            }
            }
            .resume()
    }
    
    func getNotesPerPerson() -> NSMutableDictionary {
        
        var swag = TeamVC()
        let array = self.getLeaders()
        let dict = self.makeDict(self.getLeaders())
        var bigDict: NSMutableDictionary = NSMutableDictionary()
        
        for i in Range(start: 0, end: array.count) {
            
         //   dayNote(dict.allKeys[i] as! String, date: "1/26/2016")
            
        /*    swag.dayNote(dict.allKeys[i] as! String, date: "1/26/2016") { //, completionHandler: { (entryText, error) -> NSMutableDictionary in
                
                let swag = entryText
                bigDict.setValue(swag, forKey: dict.allValues[i] as! String)
                return bigDict
            }*/
            
        }
        print(bigDict)
        return bigDict
    }
    
//    func dayNote(username: String, date: String) -> NSMutableDictionary {
//        
//        var finalDict : NSMutableDictionary = NSMutableDictionary()
//        
//        let urlString = "http://www.logarun.com/calendars/"
//        
//        //    let swag = (entryText.text?.startIndex.advancedBy(entryText.text!.characters.count-8))
//        
//        //  let stringX = entryText.text?.substringFromIndex(swag!)
//        
//        
//        let todaysDate = NSDate().dateFromString(date, format:  "MM/dd/yyyy")
//        
//        let dateFormatter = NSDateFormatter()
//        dateFormatter.dateFormat = "20"+"yy/MM/dd"
//        let DateInFormat = dateFormatter.stringFromDate(todaysDate)
//        
//    //    print(urlString + username + "/" + DateInFormat)
//        
//        let url: NSURL = NSURL(string: urlString + username + "/" + DateInFormat)!
//        
//     //   NSURLSession.sharedSession().dataTaskWithURL(url) { data, response, error in
//            
//            
//            let sesh = NSURLSession.sharedSession().dataTaskWithURL(url){
//                (data, response, error) in
//            
//            
//            
//            let html2 = NSString(data: data!, encoding: NSUTF8StringEncoding)
//            let parser2 = NDHpple(HTMLData: html2! as String)
//            
//            
//            let DayTitle = "//*[@id='ctl00_Content_c_dayTitle_c_title']"
//            let DayDist = "//*[@id='ctl00_Content_c_applications_act0_ctl00_c_value']"
//            let DayNote = "//*[@id='ctl00_Content_c_note_c_note']"
//            guard let note = parser2.searchWithXPathQuery(DayNote) else {return}
//            guard let dist = parser2.searchWithXPathQuery(DayDist) else {return}
//            guard let title = parser2.searchWithXPathQuery(DayTitle) else {return}
//            
//            for node in note {
//                
//                finalDict.setValue(username, forKey: (node.firstChild?.content)!)
//
//                // print(node.firstChild?.content)
//             ///   dispatch_async(dispatch_get_main_queue(), { () -> Void in
//                    
//                  
//                    
//             //   })
//            }
//            for x in dist{
//                
//              //  print(x.firstChild?.content)
////                dispatch_async(dispatch_get_main_queue(), { () -> Void in
////                    self.distanceText.text = x.firstChild?.content
////                })
//            }
//            for y in title{
//                
//               // print(y.firstChild?.content)
////                dispatch_async(dispatch_get_main_queue(), { () -> Void in
////                    self.labelText.text = y.firstChild?.content
////                })
//            }
//            
//            }
//            .resume()
//        
//        return finalDict
//        
//    }
    
    func getLeaders() -> NSMutableArray {
        
        let array1: NSMutableArray = []
        
        let urlString = "https://www.kimonolabs.com/api/egdprjwe?apikey=9xR1gP9goXnNImPQCGAwO9LKCNf8kDDP"
        
        if let url = NSURL(string: urlString) {
            if let data = try? NSData(contentsOfURL: url, options: []) {
                let json: NSDictionary
                do {
                    json = try NSJSONSerialization.JSONObjectWithData(data, options: []) as! [String:AnyObject]
                    
                    let large = (json["results"]!["collection2"]!)!
                    
                    for i in Range(start: 0, end: large.count){
                        let Div = large[i]["Team_Member"]
                        let Name = Div!!["text"]
                        array1.insertObject(Name!!.description, atIndex: array1.count)
                    }
                    
                } catch _ {
                    
                    print("error")
                    
                }
            }
        }
        
        return array1
        
    }
    
    func makeDict(array: NSMutableArray) -> NSMutableDictionary {
        
        let finalDict: NSMutableDictionary = NSMutableDictionary()
        
        let urlString = "https://www.kimonolabs.com/api/egdprjwe?apikey=9xR1gP9goXnNImPQCGAwO9LKCNf8kDDP"
        
        if let url = NSURL(string: urlString) {
            if let data = try? NSData(contentsOfURL: url, options: []) {
                let json: NSDictionary
                do {
                    json = try NSJSONSerialization.JSONObjectWithData(data, options: []) as! [String:AnyObject]
                    
                    let large = (json["results"]!["collection2"]!)!
                    
                    for i in Range(start: 0, end: large.count){
                        let swag = large[i]["Team_Member"]
                        let small = swag!!["href"]
                        let small2 = (swag!!["text"])
                        
                        
                        let new: String = small!!.description.stringByReplacingOccurrencesOfString("http://www.logarun.com/calendars/", withString: "")
                        
                        let newB: String = small2!!.description.stringByReplacingOccurrencesOfString("\"", withString: "")
                        
                        let index = new.startIndex.advancedBy(new.characters.count-7)
                        
                        let new2 = new.substringToIndex(index)
                        
                        for x in Range(start: 0, end: array.count){
                            
                            
                            if String(array[x]) == String(newB) {
                                
                                finalDict.setValue(newB, forKey: new2)
                                
                            }}}} catch _ {
                                print("error")
                }}}
        
        return finalDict
        
    }

    
    
    
      override func viewDidLoad() {
        super.viewDidLoad()
        
       // getTeam()
        
        let array = makeDict(getLeaders())
        
       print(array)
        
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
