//
//  HomeViewController.swift
//  MediumMenu
//
//  Created by pixyzehn on 2/4/15.
//  Copyright (c) 2015 pixyzehn. All rights reserved.
//

import UIKit
import CoreData

extension NSDate {
    func dateFromString(date: String, format: String) -> NSDate {
        let formatter = NSDateFormatter()
        let locale = NSLocale(localeIdentifier: "en_US_POSIX")
        
        formatter.locale = locale
        formatter.dateFormat = format
        
        return formatter.dateFromString(date)!
    }
}

class HomeViewController: BaseViewController {
    
    
    
    func delay(seconds seconds: Double, completion:()->()) {
        let popTime = dispatch_time(DISPATCH_TIME_NOW, Int64( Double(NSEC_PER_SEC) * seconds ))
        
        dispatch_after(popTime, dispatch_get_main_queue()) {
            completion()
        }
    }
    
    
    
    
     let l2 = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
    
    let l3 = ["2010","2011","2012","2013","2014","2015","2016"]
    
    @IBAction func grabTotals(sender: AnyObject) {
        
        labelText.text = ""
        distanceText.text = ""
        noteText.text = ""
    
        noteText.font = noteText.font?.fontWithSize(22)
        
        
        for x in l2 {
            for y in l3 {
            
        if monthLabel.description.containsString(x) {
            
            if monthLabel.description.containsString(y) {
                
            labelText.text = x
            distanceText.text = "totals"
            
            let month = (l2.indexOf(x))!+1
                
            let year = y
            
            let username = grabUser()
            
            let urlString = "http://www.logarun.com/calendars/"
                
            let date = "\(year)/\(month)"
                
            NSURLSession.sharedSession().dataTaskWithURL(NSURL(string: urlString + username + "/" + date )!) { data, response, error in
                
                let html2 = NSString(data: data!, encoding: NSUTF8StringEncoding)
                let parser2 = NDHpple(HTMLData: html2! as String)
                
                
                let week1 = "//*[@id='ctl00_Content_c_calendar_ctl31_c_panel']/div/div/p"
                
                let week2 = "//*[@id='ctl00_Content_c_calendar_ctl48_c_panel']/div/div/p"
                let week3 = "//*[@id='ctl00_Content_c_calendar_ctl65_c_panel']/div/div/p"
                let week4 = "//*[@id='ctl00_Content_c_calendar_ctl82_c_panel']/div/div/p"
                guard let w1 = parser2.searchWithXPathQuery(week1) else {return}
                guard let w2 = parser2.searchWithXPathQuery(week2) else {return}
                guard let w3 = parser2.searchWithXPathQuery(week3) else {return}
                guard let w4 = parser2.searchWithXPathQuery(week4) else {return}
                
                for a in w1 {
                    print(a.firstChild?.content)
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        if a.firstChild?.content == nil {
                            self.noteText.text = "Run: 00.00 mile"
                        }else{
                            self.noteText.text = ("1) " + (a.firstChild?.content)!).stringByReplacingOccurrencesOfString("Run: ", withString: "")
                        }
                    })
                }
                for b in w2{
                    
                    print(b.firstChild?.content)
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        
                        if b.firstChild!.content == nil {
                            
                            self.noteText.text = self.noteText.text + "\n" + "Run: 00.00 mile"
                            
                        }else{
                        
                        self.noteText.text = self.noteText.text + "\n" + ("2) " + (b.firstChild?.content)!).stringByReplacingOccurrencesOfString("Run: ", withString: "")
                        }
                    })
                }
                for c in w3{
                    
                    print(c.firstChild?.content)
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        
                        if c.firstChild?.content == nil {
                            
                            self.noteText.text = self.noteText.text + "\n" + "Run: 00.00 mile"
                            
                        }else{
                        
                            self.noteText.text = self.noteText.text + "\n" + ("3) " + (c.firstChild?.content)!).stringByReplacingOccurrencesOfString("Run: ", withString: "")
                        }
                    })
                }
                
                for d in w4{
                    
                    print(d.firstChild?.content)
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        
                        if d.firstChild?.content == nil {
                            
                            self.noteText.text = self.noteText.text + "\n" + "Run: 00.00 mile"
                            
                        }else{
                        
                            self.noteText.text = self.noteText.text + "\n" + ("4) " + (d.firstChild?.content)!).stringByReplacingOccurrencesOfString("Run: ", withString: "")
                        
                        }
                    })
                }
        
                }
                .resume()
            }}}
        }}
    
    
    //// today icon should be a present... present !!
    func grabUser() -> String {
        
        var name = ""
        
        var newcount = 0
        
        let appDelegate =
        UIApplication.sharedApplication().delegate as! AppDelegate
        let fetchRequest = NSFetchRequest(entityName: "User")
        
        
        do {
            
            let result = try appDelegate.managedObjectContext!.executeFetchRequest(fetchRequest)
            
            for managedObject in result {
                
                newcount += 1
                
                if newcount == (result.count){
                    if let first = managedObject.valueForKey("username") {
                        print("\(first)")
                        
                        name = first as! String
                        return name
                    }
                }
            }
            
        } catch {
            let fetchError = error as NSError
            print(fetchError)
        }
        
        return name
    }
    
  /*  func actionShowLoader() {
        
        var config : SwiftLoader.Config = SwiftLoader.Config()
        config.size = 170
        config.backgroundColor = UIColor(
            red: 0xFE/255,
            green: 0xFE/255,
            blue: 0xD8/255,
            alpha: 0.67)
    
        config.spinnerColor = UIColor(
            red: 0x39/255,
            green: 0x72/255,
            blue: 0x2F/255,
            alpha: 1.0)
        
        config.titleTextColor = UIColor(red:0.88, green:0.26, blue:0.18, alpha:1)
        config.spinnerLineWidth = 3.5
        config.foregroundColor = UIColor.blackColor()
        config.foregroundAlpha = 0.5
        
        let swag = (entryText.text?.startIndex.advancedBy(entryText.text!.characters.count-8))
        
        let stringX = entryText.text?.substringFromIndex(swag!)
        
        SwiftLoader.setConfig(config)
        
        SwiftLoader.show(true)
        
        let name = grabUser()
        
        dayNote(name, date: stringX!)
        
        if entryText.text?.isEmpty == false {

  
            self.toggleButt.hidden = false
            
            self.labelText.hidden = false
            self.distanceStatic.hidden = false
            self.distanceText.hidden = false
            self.loadInfo.hidden = true
            self.paceText.hidden = false
            
            self.noteText.hidden = false
            
            self.entryText.hidden = true
            
            
            var darkBlur = UIBlurEffect(style: UIBlurEffectStyle.Light)
            // 2
            var blurView = UIVisualEffectView(effect: darkBlur)
            
            blurView.alpha = 0.85
            blurView.frame = self.calendarView.bounds
            // 3
            self.calendarView .addSubview(blurView)
            
            delay(seconds: 1.0) { () -> () in
                SwiftLoader.hide()            }

        }
        
    }*/
    // MARK: - Properties
    
    @IBOutlet var distanceStatic: UILabel!
   
    @IBOutlet var bottomConstraint: NSLayoutConstraint!
    
        @IBOutlet var noteText: UITextView!
        @IBOutlet var distanceText: UILabel!
      @IBOutlet var paceText: UILabel!
        @IBOutlet var labelText: UILabel!
        
    @IBOutlet var loadInfo: UITextView!
        
        @IBOutlet var userName: UITextField!
    
        @IBOutlet var loadEntry: UIButton!
    
        func dayNote(username: String, date: String) {
            
            
            let urlString = "http://www.logarun.com/calendars/"
            
        //    let swag = (entryText.text?.startIndex.advancedBy(entryText.text!.characters.count-8))
            
          //  let stringX = entryText.text?.substringFromIndex(swag!)
    
            
            let todaysDate = NSDate().dateFromString(date, format:  "MM/dd/yyyy")
            
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "20"+"yy/MM/dd"
            let DateInFormat = dateFormatter.stringFromDate(todaysDate)
            
            print(urlString + username + "/" + DateInFormat)
            
            NSURLSession.sharedSession().dataTaskWithURL(NSURL(string: urlString + username + "/" + DateInFormat )!) { data, response, error in
                
                let html2 = NSString(data: data!, encoding: NSUTF8StringEncoding)
                let parser2 = NDHpple(HTMLData: html2! as String)
                
                
                let DayTitle = "//*[@id='ctl00_Content_c_dayTitle_c_title']"
                let DayDist = "//*[@id='ctl00_Content_c_applications_act0_ctl00_c_value']"
                let DayNote = "//*[@id='ctl00_Content_c_note_c_note']"
                let paceVal = "//*[@id='ctl00_Content_c_applications_act0_ctl03_c_value']"
                guard let note = parser2.searchWithXPathQuery(DayNote) else {return}
                guard let dist = parser2.searchWithXPathQuery(DayDist) else {return}
                guard let title = parser2.searchWithXPathQuery(DayTitle) else {return}
                guard let pace = parser2.searchWithXPathQuery(paceVal) else {return}
                
                for node in note {
                    print(node.firstChild?.content)
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        
                        if node.firstChild!.content != nil {
                        self.noteText.text = (node.firstChild?.content)!
                        }else{
                            
                            self.noteText.text = "NO NOTE"
                        }
                        
                    })
                }
                for x in dist{
                    
                    print(x.firstChild?.content)
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.distanceText.text = x.firstChild?.content
                    })
                }
                for y in title{
                    
                    print(y.firstChild?.content)
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.labelText.text = y.firstChild?.content
                    })
                }
                
              /*  for swag in pace{
                    
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        
                        print(swag.firstChild?.content)
                        if swag.firstChild?.content != nil{
                            
                        self.entryText.text = (swag.firstChild?.content?.stringByReplacingOccurrencesOfString(" /mile", withString: ""))! + self.entryText.text!
                            
                        }
                    })
                
                    }*/
                }
                .resume()
            
    }
    
    @IBOutlet weak var calendarView: CVCalendarView!
    @IBOutlet weak var menuView: CVCalendarMenuView!
    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var daysOutSwitch: UISwitch!
    
    @IBOutlet var monthButt: UIButton!
    @IBOutlet var weekButt: UIButton!
    var shouldShowDaysOut = true
    var animationFinished = true
    
    var selectedDay:DayView!
    
    @IBOutlet var toggleButt: UIButton!
    
    
    @IBAction func toggleB(sender: AnyObject) {
        
        
        let subViews = self.calendarView.subviews
        for subview in subViews{
            print(subview.description,"NEXT")
            if subview.description.containsString("UIVisualEffectView"){
                subview.removeFromSuperview()
            }
        }
        
        labelText.hidden = true
        distanceStatic.hidden = true
        distanceText.hidden = true
        loadInfo.hidden = false
        noteText.hidden = true
        noteText.text = ""
        distanceText.text = ""
        labelText.text = ""
        toggleButt.hidden = true
        entryText.hidden = false
        paceText.hidden = true
        paceText.text = ""
        
        
        
        
    }
    
    @IBOutlet var entryText: UILabel!
    
    @IBAction func loadEntryButt(sender: AnyObject) {
        

    }
    
    
    @IBOutlet var loadEntryButt: UIButton!
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let date: NSDate = NSDate()
     //   let cal: NSCalendar = NSCalendar(calendarIdentifier: NSGregorianCalendar)!
        
     //   let newDate: NSDate = cal.dateBySettingHour(0, minute: 0, second: 0, ofDate: date, options: NSCalendarOptions())!
    
        let demo: NSDate = date.dateFromString("18:03", format: "HH:mm")
        print(demo)
        
        let todoItem = TodoItem(deadline: demo, title: "Log your shit", UUID: NSUUID().UUIDString)
        TodoList.sharedInstance.addItem(todoItem) // schedule a local notification to persist this item
        
        monthLabel.text = CVDate(date: NSDate()).globalDescription
        
    }
    
    @IBAction func removeCircleAndDot(sender: AnyObject) {
        if let dayView = selectedDay {
            calendarView.contentController.removeCircleLabel(dayView)
            calendarView.contentController.removeDotViews(dayView)
        }
    }
    
    @IBAction func refreshMonth(sender: AnyObject) {
        calendarView.contentController.refreshPresentedMonth()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        calendarView.layer.cornerRadius = 13
        
        calendarView.commitCalendarViewUpdate()
        menuView.commitMenuViewUpdate()
    }
}

// MARK: - CVCalendarViewDelegate & CVCalendarMenuViewDelegate

extension HomeViewController: CVCalendarViewDelegate, CVCalendarMenuViewDelegate {
    
    /// Required method to implement!
    func presentationMode() -> CalendarMode {
        return .MonthView
    }
    
    /// Required method to implement!
    func firstWeekday() -> Weekday {
        return .Sunday
    }
    
    // MARK: Optional methods
    
    func shouldShowWeekdaysOut() -> Bool {
        return shouldShowDaysOut
    }
    
    func shouldAnimateResizing() -> Bool {
        return true // Default value is true
    }
    
    func didSelectDayView(dayView: CVCalendarDayView, animationDidFinish: Bool) {
        print("\(dayView.date.commonDescription) is selected!")
        
        distanceText.text = ""
        labelText.text = ""
        noteText.text = ""
        
        noteText.font = noteText.font?.fontWithSize(18)

        
        selectedDay = dayView
        
        let user = grabUser()
        
        dayNote(user, date: dayView.date.commonDescription)
        
    }
    
    
    
    func presentedDateUpdated(date: CVDate) {
        if monthLabel.text != date.globalDescription && self.animationFinished {
            let updatedMonthLabel = UILabel()
            updatedMonthLabel.textColor = monthLabel.textColor
            updatedMonthLabel.font = monthLabel.font
            updatedMonthLabel.textAlignment = .Right
            updatedMonthLabel.text = date.globalDescription
            updatedMonthLabel.sizeToFit()
            updatedMonthLabel.alpha = 0
            updatedMonthLabel.center = self.monthLabel.center
            
            let offset = CGFloat(48)
            updatedMonthLabel.transform = CGAffineTransformMakeTranslation(0, offset)
            updatedMonthLabel.transform = CGAffineTransformMakeScale(1, 0.1)
            
            UIView.animateWithDuration(0.35, delay: 0, options: UIViewAnimationOptions.TransitionFlipFromTop, animations: {
                self.animationFinished = false
                self.monthLabel.transform = CGAffineTransformMakeTranslation(0, -offset)
                self.monthLabel.transform = CGAffineTransformMakeScale(1, 0.1)
                self.monthLabel.alpha = 0
                
                updatedMonthLabel.alpha = 1
                updatedMonthLabel.transform = CGAffineTransformIdentity
                
                }) { _ in
                    
                    self.animationFinished = true
                    self.monthLabel.frame = updatedMonthLabel.frame
                    self.monthLabel.text = updatedMonthLabel.text
                    self.monthLabel.transform = CGAffineTransformIdentity
                    self.monthLabel.alpha = 1
                    updatedMonthLabel.removeFromSuperview()
            }
            
            self.view.insertSubview(updatedMonthLabel, aboveSubview: self.monthLabel)
        }
    }
    
    func topMarker(shouldDisplayOnDayView dayView: CVCalendarDayView) -> Bool {
        return true
    }
    
    func dotMarker(shouldShowOnDayView dayView: CVCalendarDayView) -> Bool {
        let day = dayView.date.day
        let randomDay = Int(arc4random_uniform(31))
        if day == randomDay {
            return true
        }
        
        return false
    }
    
    func dotMarker(colorOnDayView dayView: CVCalendarDayView) -> [UIColor] {
        
        let red = CGFloat(arc4random_uniform(600) / 255)
        let green = CGFloat(arc4random_uniform(600) / 255)
        let blue = CGFloat(arc4random_uniform(600) / 255)
        
        let color = UIColor(red: red, green: green, blue: blue, alpha: 0.0)
        
        let numberOfDots = Int(arc4random_uniform(3) + 1)
        switch(numberOfDots) {
        case 2:
            return [color, color]
        case 3:
            return [color, color, color]
        default:
            return [color] // return 1 dot
        }
    }
    
    func dotMarker(shouldMoveOnHighlightingOnDayView dayView: CVCalendarDayView) -> Bool {
        return true
    }
    
    func dotMarker(sizeOnDayView dayView: DayView) -> CGFloat {
        return 13
    }
    
    
    func weekdaySymbolType() -> WeekdaySymbolType {
        return .Short
    }
    
    func selectionViewPath() -> ((CGRect) -> (UIBezierPath)) {
        return { UIBezierPath(rect: CGRectMake(0, 0, $0.width, $0.height)) }
    }
    
    func shouldShowCustomSingleSelection() -> Bool {
        return false
    }
    
    func preliminaryView(viewOnDayView dayView: DayView) -> UIView {
        let circleView = CVAuxiliaryView(dayView: dayView, rect: dayView.bounds, shape: CVShape.Circle)
        circleView.fillColor = .colorFromCode(0x3A7330)
        return circleView
    }
    
    func preliminaryView(shouldDisplayOnDayView dayView: DayView) -> Bool {
        if (dayView.isCurrentDay) {
            return true
        }
        return false
    }
    
    func supplementaryView(viewOnDayView dayView: DayView) -> UIView {
        let π = M_PI
        
        let ringSpacing: CGFloat = 3.0
        let ringInsetWidth: CGFloat = 1.0
        let ringVerticalOffset: CGFloat = 1.0
        var ringLayer: CAShapeLayer!
        let ringLineWidth: CGFloat = 1.5
        let ringLineColour: UIColor = .colorFromCode(0x3A7330)
        
        let newView = UIView(frame: dayView.bounds)
        
        let diameter: CGFloat = (newView.bounds.width) - ringSpacing
        let radius: CGFloat = diameter / 2.0
        
        let rect = CGRectMake(newView.frame.midX-radius, newView.frame.midY-radius-ringVerticalOffset, diameter, diameter)
        
        ringLayer = CAShapeLayer()
        newView.layer.addSublayer(ringLayer)
        
        ringLayer.fillColor = nil
        ringLayer.lineWidth = ringLineWidth
        ringLayer.strokeColor = ringLineColour.CGColor
        
        let ringLineWidthInset: CGFloat = CGFloat(ringLineWidth/2.0) + ringInsetWidth
        let ringRect: CGRect = CGRectInset(rect, ringLineWidthInset, ringLineWidthInset)
        let centrePoint: CGPoint = CGPointMake(ringRect.midX, ringRect.midY)
        let startAngle: CGFloat = CGFloat(-π/2.0)
        let endAngle: CGFloat = CGFloat(π * 2.0) + startAngle
        let ringPath: UIBezierPath = UIBezierPath(arcCenter: centrePoint, radius: ringRect.width/2.0, startAngle: startAngle, endAngle: endAngle, clockwise: true)
        
        ringLayer.path = ringPath.CGPath
        ringLayer.frame = newView.layer.bounds
        
        return newView
    }
    
    func supplementaryView(shouldDisplayOnDayView dayView: DayView) -> Bool {
      
        return false
    }
}


// MARK: - CVCalendarViewAppearanceDelegate

extension HomeViewController: CVCalendarViewAppearanceDelegate {
    func dayLabelPresentWeekdayInitallyBold() -> Bool {
        return false
    }
    
    func spaceBetweenDayViews() -> CGFloat {
        return 2
    }
}

// MARK: - IB Actions

extension HomeViewController {
    @IBAction func switchChanged(sender: UISwitch) {
        if sender.on {
            calendarView.changeDaysOutShowingState(false)
            shouldShowDaysOut = true
        } else {
            calendarView.changeDaysOutShowingState(true)
            shouldShowDaysOut = false
        }
    }
    
    @IBAction func todayMonthView() {
        calendarView.toggleCurrentDayView()
       // weekButt.hidden = false
       // monthButt.hidden = true
        

    }
    
    /// Switch to WeekView mode.
    
 
    
    @IBAction func loadPrevious(sender: AnyObject) {
        calendarView.loadPreviousView()
    }
    
    
    @IBAction func loadNext(sender: AnyObject) {
        calendarView.loadNextView()
    }
}

// MARK: - Convenience API Demo

extension HomeViewController {
    func toggleMonthViewWithMonthOffset(offset: Int) {
        let calendar = NSCalendar.currentCalendar()
        //        let calendarManager = calendarView.manager
        let components = Manager.componentsForDate(NSDate()) // from today
        
        components.month += offset
        
        let resultDate = calendar.dateFromComponents(components)!
        
        self.calendarView.toggleViewWithDate(resultDate)
    }
    
    func didShowNextMonthView(date: NSDate)
    {
        //        let calendar = NSCalendar.currentCalendar()
        //        let calendarManager = calendarView.manager
        let components = Manager.componentsForDate(date) // from today
        
        print("Showing Month: \(components.month)")
    }
    
    
    func didShowPreviousMonthView(date: NSDate)
    {
        //        let calendar = NSCalendar.currentCalendar()
        //        let calendarManager = calendarView.manager
        let components = Manager.componentsForDate(date) // from today
        
        print("Showing Month: \(components.month)")
    }
    
}