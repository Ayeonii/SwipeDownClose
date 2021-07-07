//
//  UIViewControllerExtension.swift
//  SwipeDownClose
//
//  Created by 이아연 on 2021/07/07.
//

import UIKit

extension UIViewController : UIViewControllerTransitioningDelegate {
    
    func dismissDetail(direction : CATransitionSubtype, type : CATransitionType, completion : (()->Void)? = nil) {
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = .push
        transition.subtype = direction
        transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        
        view.window?.layer.add(transition, forKey: kCATransition)
        dismiss(animated: false, completion : completion)
    }
    
    public func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return CustomSizePresentationController(presentedViewController: presented, presenting: presenting)
    }
}

class CustomSizePresentationController : UIPresentationController {
    
    override var frameOfPresentedViewInContainerView: CGRect {
        get {
            guard let theView = containerView else {
                return CGRect.zero
            }
            return CGRect(x: 0, y: 0, width: theView.bounds.width, height: (theView.bounds.height))
        }
    }
    
    let dimmingView: UIView = {
        let dimmingView = UIView()
        dimmingView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        dimmingView.translatesAutoresizingMaskIntoConstraints = false
        return dimmingView
    }()

    override func presentationTransitionWillBegin() {
        super.presentationTransitionWillBegin()

        let superview = presentingViewController.view!
        superview.addSubview(dimmingView)
        NSLayoutConstraint.activate([
            dimmingView.leadingAnchor.constraint(equalTo: superview.leadingAnchor),
            dimmingView.trailingAnchor.constraint(equalTo: superview.trailingAnchor),
            dimmingView.bottomAnchor.constraint(equalTo: superview.bottomAnchor),
            dimmingView.topAnchor.constraint(equalTo: superview.topAnchor)
        ])

        dimmingView.alpha = 0
        presentingViewController.transitionCoordinator?.animate(alongsideTransition: { _ in
            self.dimmingView.alpha = 1
        }, completion: nil)
    }
    
    
    override func dismissalTransitionWillBegin() {
        super.dismissalTransitionWillBegin()

        presentingViewController.transitionCoordinator?.animate(alongsideTransition: { _ in
            self.dimmingView.alpha = 0
        }, completion: { _ in
            self.dimmingView.removeFromSuperview()
        })
    }
}

