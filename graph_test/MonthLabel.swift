//
//  MonthLabel.swift
//  graph_test
//
//  Created by Uros Katic on 22/03/16.
//  Copyright © 2016 Uros Katic. All rights reserved.
//

import UIKit

enum TextAnimationDirection {
    case left
    case right
    case none
}

class MonthLabel: UIView {

    @IBOutlet weak var label: UILabel!

    func setText(text: String, animationDirection: TextAnimationDirection) {
        
        let animation = CATransition()
        animation.type = kCATransitionPush
        animation.duration = 0.5
        switch animationDirection {
        case .left:
            animation.subtype = kCATransitionFromLeft
        case .right:
            animation.subtype = kCATransitionFromRight
        case .none:
            animation.type = kCATransitionFade
        }

        label.layer.addAnimation(animation, forKey: nil)
        label.text = text

        UIView.animateWithDuration(0.4, animations: {
            self.setNeedsLayout()
            self.layoutIfNeeded()
        })


    }

        required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
