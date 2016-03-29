//
//  ViewController.swift
//  graph_test
//
//  Created by Uros Katic on 22/03/16.
//  Copyright © 2016 Uros Katic. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var refreshButton: UIButton!
    @IBOutlet weak var leftButton: UIButton!
    @IBOutlet weak var rightButton: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var container: UIView!
    @IBOutlet weak var monthLabel: MonthLabel!
    
    private var currentMonthNumber = NSDate.monthsSinceReferenceDate
    private let dataSource = DataSource()
    private var graphViews = [GraphView]()

    override func viewDidLoad() {

        // Strategy: We use a scrollview, which has a content container that is always 3 screens wide. And we're always on the middle one.
        // When the user scrolls/uses arrows we drop 1 old graph, add 1 new graph, and offset the other two. To make this invisible to the user
        // we manipulate the scrollview offset.

        super.viewDidLoad()

        NSNotificationCenter.defaultCenter().addObserver(self, selector: "rotated", name: UIDeviceOrientationDidChangeNotification, object: nil)
        monthLabel.setText(NSDate().monthName, animationDirection: TextAnimationDirection.none)
        
        leftButton.addTarget(self, action: Selector("previousMonthButton"), forControlEvents: UIControlEvents.TouchUpInside)
        rightButton.addTarget(self, action: Selector("nextMonthButton"), forControlEvents: UIControlEvents.TouchUpInside)
        refreshButton.addTarget(self, action: Selector("refreshCurrentMonth"), forControlEvents: UIControlEvents.TouchUpInside)
        scrollView.pagingEnabled = true
        scrollView.scrollEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.delegate = self
        container.widthAnchor.constraintEqualToAnchor(scrollView.widthAnchor, multiplier:  3.0).active = true
        container.heightAnchor.constraintEqualToAnchor(scrollView.heightAnchor).active = true

        // we create 3 graphViews which only differ in the monthNumber. Which dictates what the data source will return to them.

        for i in 0...2 {
            graphViews.append(NSBundle.mainBundle().loadNibNamed("GraphView", owner: nil, options: nil)[0] as! GraphView)
            container.addSubview(graphViews[i])
            graphViews[i].dataSource = dataSource
            graphViews[i].showMonth(currentMonthNumber+i-1)
        }

        graphViews.forEach {
            $0.bottomAnchor.constraintEqualToAnchor(container.bottomAnchor).active = true
            $0.widthAnchor.constraintEqualToAnchor(scrollView.widthAnchor).active = true
            $0.heightAnchor.constraintEqualToAnchor(container.heightAnchor).active = true
        }

        self.regenerateHorizontalConstraints()
    }

    override func viewDidAppear(animated: Bool) {

        // initially put us on the middle portion of the scrollview. Doesn't work before didAppear.

        scrollView.setContentOffset(CGPointMake(scrollView.contentOffset.x + scrollView.frame.size.width, 0), animated:  false)
    }

    func regenerateHorizontalConstraints() {

        // As we're adding and removing GraphViews, horizontal constraints between them become obsolete and need to be fixed. We do this here.
        // Vertical constraints don't need updating.

        // Note: Removing a view removes all constraints which involve it, even if they are in other views' constraints array. So we're basically manually removing 1 constraint each time, while 2 drop off due to view removal.

        container.removeConstraints(container.constraints.filter {$0.identifier == "temporary"})

        var constraint : NSLayoutConstraint

        constraint = graphViews[0].leftAnchor.constraintEqualToAnchor(container.leftAnchor)
        constraint.identifier = "temporary"
        constraint.active = true

        constraint = graphViews[1].leftAnchor.constraintEqualToAnchor(graphViews[0].rightAnchor)
        constraint.identifier = "temporary"
        constraint.active = true

        constraint = graphViews[2].leftAnchor.constraintEqualToAnchor(graphViews[1].rightAnchor)
        constraint.identifier = "temporary"
        constraint.active = true

    }

    // the following two functions create and insert new graphViews into the scrollView, fix constraints, and then offset the scrollView


    func previousMonth(animated animated: Bool) {

        currentMonthNumber -= 1

        monthLabel.setText(dataSource.monthLabel(currentMonthNumber), animationDirection:TextAnimationDirection.right)

        graphViews[2].removeFromSuperview()
        graphViews.removeLast()
        graphViews.insert((NSBundle.mainBundle().loadNibNamed("GraphView", owner: nil, options: nil)[0] as! GraphView), atIndex: 0)
        container.addSubview(graphViews[0])
        graphViews[0].dataSource = dataSource
        graphViews[0].showMonth(currentMonthNumber-1)
        graphViews[0].bottomAnchor.constraintEqualToAnchor(container.bottomAnchor).active = true
        graphViews[0].widthAnchor.constraintEqualToAnchor(scrollView.widthAnchor).active = true
        graphViews[0].heightAnchor.constraintEqualToAnchor(container.heightAnchor).active = true

        regenerateHorizontalConstraints()

        scrollView.setContentOffset(CGPointMake(2*scrollView.frame.size.width, 0), animated:  false)
        scrollView.setContentOffset(CGPointMake(scrollView.frame.size.width, 0), animated:  animated)
    }

    func nextMonth(animated animated: Bool) {

        currentMonthNumber += 1

        monthLabel.setText(dataSource.monthLabel(currentMonthNumber), animationDirection:TextAnimationDirection.right)

        graphViews[0].removeFromSuperview()
        graphViews.removeFirst()
        graphViews.append(NSBundle.mainBundle().loadNibNamed("GraphView", owner: nil, options: nil)[0] as! GraphView)
        container.addSubview(graphViews[2])
        graphViews[2].dataSource = dataSource
        graphViews[2].showMonth(currentMonthNumber+1)
        graphViews[2].bottomAnchor.constraintEqualToAnchor(container.bottomAnchor).active = true
        graphViews[2].widthAnchor.constraintEqualToAnchor(scrollView.widthAnchor).active = true
        graphViews[2].heightAnchor.constraintEqualToAnchor(container.heightAnchor).active = true

        self.regenerateHorizontalConstraints()

        scrollView.setContentOffset(CGPointMake(0, 0), animated:  false)
        scrollView.setContentOffset(CGPointMake(scrollView.frame.size.width, 0), animated:  animated)
    }

    func previousMonthButton() {
        previousMonth(animated: true)
    }

    func nextMonthButton() {
        nextMonth(animated: true)
    }

    func refreshCurrentMonth() {
        refreshButton.enabled = false
        graphViews[1].showMonth(currentMonthNumber, completion: {
            self.refreshButton.enabled = true
        })
    }

    func rotated() {
        scrollView.setContentOffset(CGPointMake(scrollView.frame.size.width, 0), animated:  false)
    }

}

extension ViewController : UIScrollViewDelegate {

    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {

        switch scrollView.contentOffset.x {
        case 2*scrollView.frame.size.width:
            nextMonth(animated: false)
        case 0:
            previousMonth(animated: false)
        default:
            break
        }
    }
}

