//
//  GraphView.swift
//  graph_test
//
//  Created by Uros Katic on 22/03/16.
//  Copyright © 2016 Uros Katic. All rights reserved.
//

import UIKit

protocol GraphViewDataSource {
    func getGraphForMonth(month: Int, completion:(graph: Graph)->())
    var barWidth : CGFloat { get }
    var scale : CGFloat { get } // max number on graph
    var barColor : UIColor { get }
}

class Bar : UIView {


    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    convenience init(width: CGFloat) {
        self.init(frame: CGRectZero)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.widthAnchor.constraintEqualToConstant(width).active = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("Bars can only be made programatically")
    }
}

class GraphView: UIView {

    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var stackView: UIStackView!

    var dataSource : GraphViewDataSource?
    private let activityIndicator = UIActivityIndicatorView()
    private var monthNumber = 0

    // MARK: Life cycle

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func didMoveToSuperview() {
        self.addSubview(activityIndicator)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.stackView.alignment = UIStackViewAlignment.Bottom
        activityIndicator.hidesWhenStopped = true
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
        activityIndicator.rightAnchor.constraintEqualToAnchor(self.rightAnchor, constant: -15).active = true
        activityIndicator.bottomAnchor.constraintEqualToAnchor(self.bottomAnchor, constant: -15).active = true
    }

    deinit {
        print("Deinitializing", self) // to demonstrate that I'm not messing up.
    }

    // MARK: Drawing

    func showGraph(graph: Graph) {
        fatalError("Use showMonth instead")
        
        // Discussion:
        // If we moved fetching the model to the ViewController, we'd implement this function.
        // However by keeping fetching here, we get the benefit of "free" loading aborts, when
        // user quickly pushes bar arrows. We simply dealloc the graph and interrupt the data source
        // calls (thanks to weak references).
    }

    // This triggers the drawing of the graph.
    // If we use this again on an existing graph, it changes behavior, and redraws with an animation (isRefresh).

    func showMonth(number: Int, completion: (()->())? = nil) {

        self.monthLabel.text = "\(number)"
        guard let source = dataSource else {
            fatalError("Set graphView data source before setting month number")
        }

        activityIndicator.startAnimating()

        // if the graph goes off screen (which means we're 2 months ahead already) faster than 0.5 seconds, then it gets deallocated and the data source is not called.

        after(0.5, { [weak self] in

            guard self != nil else {
                print("Clicking too fast.")
                return
            }

            source.getGraphForMonth((self?.monthNumber)!) { graph -> () in

                // if we get to this point, where our data source returns data, we prevent dealloc till stuff is done.

                guard let strongSelf = self else {
                    return
                }

                let isRefresh = strongSelf.stackView.arrangedSubviews.count > 0 ? true : false

                strongSelf.activityIndicator.stopAnimating()

                if isRefresh {

                    // in case we're refreshing, we keep existing bars, but remove any surplus.

                    while strongSelf.stackView.arrangedSubviews.count > graph.values.count {
                        strongSelf.stackView.arrangedSubviews.last!.hidden = true // this prevents visible bar removal animation at the end of this method.
                        strongSelf.stackView.removeArrangedSubview(strongSelf.stackView.arrangedSubviews.last!)
                    }

                    // clean up  existing height constraints. We animate the change to new height in the end.

                    print("Removing constraints from container:", terminator: " ")

                    strongSelf.constraints.forEach {
                        if $0.firstAttribute == .Height {
                            print(unsafeAddressOf($0), terminator: " ")
                            strongSelf.removeConstraint($0)
                        }
                    }
                    print("")

                    print("Removing constraints from bars:", terminator: " ")

                    for bar in strongSelf.stackView.arrangedSubviews {
                        bar.constraints.forEach {
                            if $0.firstAttribute == .Height {
                                print(unsafeAddressOf($0), terminator: " ")
                                bar.removeConstraint($0)
                            }
                        }
                    }
                    print("")
                }


                var i = 0
                graph.values.forEach {

                    var bar : Bar
                    let multiplier = $0/source.scale

                    // if we have existing bars, we use them

                    if strongSelf.stackView.arrangedSubviews.count > i {
                        bar = strongSelf.stackView.arrangedSubviews[i] as! Bar

                    } else {

                        // otherwise we create new ones

                        bar = Bar(width: source.barWidth)
                        bar.backgroundColor = source.barColor
                        strongSelf.stackView.addArrangedSubview(bar)
                        bar.setNeedsLayout()
                        bar.layoutIfNeeded()
                    }

                    bar.heightAnchor.constraintEqualToAnchor(strongSelf.heightAnchor, multiplier: multiplier).active = true
                    i += 1
                }
                
                // if refreshing we animate the change
                
                if isRefresh {
                    strongSelf.setNeedsLayout()
                    UIView.animateWithDuration(0.3, delay: 0, options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
                        strongSelf.layoutIfNeeded()
                        }, completion: nil)
                }

                if completion != nil {
                    completion!()
                }
            }
        })
    }
}
