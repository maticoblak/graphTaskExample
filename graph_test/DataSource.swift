//
//  DataSource.swift
//  graph_test
//
//  Created by Uros Katic on 22/03/16.
//  Copyright © 2016 Uros Katic. All rights reserved.
//

import UIKit

struct Graph { // this is basically our model.
    let values : [CGFloat]
}

class DataSource : GraphViewDataSource {


    func monthLabel(monthNumber : Int)-> String {

        let date = NSDate.referenceDate.addMonths(monthNumber)
        return date.year == NSDate().year ? date.monthName : "\(date.monthName) \(date.year) "
    }

    // "fake" backend call to get data

    func getGraphForMonth(month: Int, completion:(graph: Graph)->()) {
        after(1.0, {

            // generating some data

//            let numberOfComponents = (10...15).random
//            let numberOfComponents = 200
            let numberOfComponents = 5
            var values = [CGFloat]()
            for i in 1...numberOfComponents {
//                values.append(CGFloat(100.random))
                values.append(CGFloat(i*5))
            }
            completion(graph: Graph(values: values))
        })
    }

    var barWidth : CGFloat {
        return 30
    }

    var scale : CGFloat {
        return 100
    } // max number on graph. A bar of this size spans the full height of the graph view.

    var barColor : UIColor {
        return UIColor.greenColor()
    }
}
