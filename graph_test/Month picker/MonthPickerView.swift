//
//  MonthPickerView.swift
//  graph_test
//
//  Created by Matic Oblak on 3/29/16.
//  Copyright © 2016 Uros Katic. All rights reserved.
//

import UIKit

public protocol MonthPickerViewDelegate: class {
    func monthPickerViewChangedDate(sender: MonthPickerView, newDate: NSDate)
}

public class MonthPickerView: UIView {
    
    // MARK: - Interface
    
    public var date = NSDate() {
        didSet {
            let previousDate = _date
            _date = currentMonthFrom(date)
            if(date.compare(previousDate) == .OrderedAscending) {
                refresh(.FromLeft)
            } else if(date.compare(previousDate) == .OrderedDescending) {
                refresh(.FromRight)
            } else {
                refresh(.None)
            }
        }
    }
    
    public var delegate: MonthPickerViewDelegate?
    
    public var calendar = NSCalendar.currentCalendar()
    
    // MARK: - Private
    
    @IBOutlet private weak var labelContainer: UIView!
    @IBOutlet private weak var monthLabel: UILabel!
    
    private enum AnimationType {
        case None
        case Fade
        case FromLeft
        case FromRight
    }
    
    private var _date:NSDate
    
    override public init(frame: CGRect) {
        _date = MonthPickerView.thisMonth(NSCalendar.currentCalendar())
        super.init(frame: frame)
        
    }
    public required init?(coder aDecoder: NSCoder) {
        _date = MonthPickerView.thisMonth(NSCalendar.currentCalendar())
        super.init(coder: aDecoder)
    }
    
    private func refresh(animation: AnimationType) {
        let transition = CATransition()
        transition.type = kCATransitionPush
        transition.duration = 0.3
        
        switch animation {
        case .None:
            labelContainer.layer.addAnimation(transition, forKey: nil)
            monthLabel.text = currentMonthText()
        case .Fade:
            transition.subtype = kCATransitionFade
            labelContainer.layer.addAnimation(transition, forKey: nil)
            monthLabel.text = currentMonthText()
        case .FromLeft:
            transition.subtype = kCATransitionFromLeft
            labelContainer.layer.addAnimation(transition, forKey: nil)
            monthLabel.text = currentMonthText()
        case .FromRight:
            transition.subtype = kCATransitionFromRight
            labelContainer.layer.addAnimation(transition, forKey: nil)
            monthLabel.text = currentMonthText()
        }
        
        UIView.animateWithDuration(transition.duration, animations: {
            self.setNeedsLayout()
            self.layoutIfNeeded()
        })
    }

    private func currentMonthText() -> String {
        return _date.year == NSDate().year ? _date.monthName : "\(_date.monthName) \(_date.year) "
    }
    
    @IBAction private func previousPressed(sender: AnyObject) {
        date = previousMonthFrom(_date)
        delegate?.monthPickerViewChangedDate(self, newDate: _date)
    }
    
    @IBAction private func nextPressed(sender: AnyObject) {
        date = nextMonthFrom(_date)
        delegate?.monthPickerViewChangedDate(self, newDate: _date)
    }
    
    private static func thisMonth(calendar: NSCalendar) -> NSDate {
        let date:NSDate = NSDate()
        
        let components:NSDateComponents = calendar.components([.Year, .Month, .Day], fromDate: date)
        components.setValue(1, forComponent: .Day)
        
        if let toReturn = calendar.dateFromComponents(components) {
            return toReturn
        } else {
            return date
        }
    }
    
    public func currentMonthFrom(date: NSDate) -> NSDate {
        let date:NSDate = date
        
        let components:NSDateComponents = calendar.components([.Year, .Month, .Day], fromDate: date)
        components.setValue(1, forComponent: .Day)
        
        if let toReturn = calendar.dateFromComponents(components) {
            return toReturn
        } else {
            return date
        }
    }
    public func nextMonthFrom(date: NSDate) -> NSDate {
        if let date = calendar.dateByAddingUnit(.Month, value: 1, toDate: date, options: []) {
            return date
        } else {
            return date
        }
    }
    public func previousMonthFrom(date: NSDate) -> NSDate {
        if let date = calendar.dateByAddingUnit(.Month, value: -1, toDate: date, options: []) {
            return date
        } else {
            return date
        }
    }

}
