import UIKit

extension UIView {
    @IBInspectable var borderColor: UIColor {
        get {
            return UIColor(CGColor: self.layer.borderColor!)
        }
        set {
            self.layer.borderColor = newValue.CGColor
            self.layer.borderWidth = 2
        }
    }
}

extension NSDate {

    static var referenceDate : NSDate {
        return NSDate(timeIntervalSinceReferenceDate: 0)
    }

    static var monthsSinceReferenceDate : Int {
        print("Months since reference date", NSCalendar.currentCalendar().components(NSCalendarUnit.Month, fromDate: NSDate.referenceDate, toDate: NSDate(), options: NSCalendarOptions(rawValue: 0)).month)
        return NSCalendar.currentCalendar().components(NSCalendarUnit.Month, fromDate: NSDate.referenceDate, toDate: NSDate(), options: NSCalendarOptions(rawValue: 0)).month
    }

    var year : Int {
        return NSCalendar.currentCalendar().component(NSCalendarUnit.Year, fromDate: self)
    }

    func addMonths(months : Int)->(NSDate) {
        let components = NSDateComponents()
        components.month = months
        return NSCalendar.currentCalendar().dateByAddingComponents(components, toDate: self, options: NSCalendarOptions(rawValue: 0))!
    }

    var monthName : String {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "MMMM"
        return formatter.stringFromDate(self)
    }






}

extension Int {
    var random : Int {
        return Int(arc4random_uniform(UInt32(self)))
    }
}
extension Range {
    var random : Int {
        var offset = 0
        if (startIndex as! Int) < 0 {
            offset = abs(startIndex as! Int)
        }
        let mini = UInt32(startIndex as! Int + offset)
        let maxi = UInt32(endIndex as! Int + offset)
        return Int(mini + arc4random_uniform(maxi - mini)) - offset
    }

}

