//
//  PopPresentingAnimationController.swift
//  roomy
//
//  Created by Ryan Liszewski on 4/18/17.
//  Copyright © 2017 Poojan Dave. All rights reserved.
//

import Foundation
import UIKit
import pop

class PopPresentingAnimationController: NSObject, UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.5;
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let fromView = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)!.view!
        fromView.alpha = 0.3
        fromView.isUserInteractionEnabled = false
        
        let toView = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)!.view!
        toView.frame = CGRect(x: 0,
                              y: 0,
                              width: transitionContext.containerView.bounds.width * 0.8,
                              height: transitionContext.containerView.bounds.height * 0.3);
        let p = CGPoint(x: transitionContext.containerView.center.x, y: transitionContext.containerView.center.y);
        toView.alpha = 0.92
        toView.center = p;
        
        transitionContext.containerView.addSubview(toView)
        
        let positionAnimation = POPSpringAnimation(propertyNamed: kPOPLayerPositionY)!
        positionAnimation.toValue = transitionContext.containerView.center.y
        positionAnimation.springBounciness = 10
        positionAnimation.completionBlock = { (anim, finished) in
            transitionContext.completeTransition(true)
        }
        
        let scaleAnimation = POPSpringAnimation(propertyNamed: kPOPLayerScaleXY)!
        scaleAnimation.springBounciness = 5
        scaleAnimation.fromValue = NSValue(cgPoint: CGPoint(x: 1.2, y: 1.4))
        
        toView.layer.pop_add(positionAnimation, forKey: "positionAnimation")
        toView.layer.pop_add(scaleAnimation, forKey: "scaleAnimation")
    }
}
