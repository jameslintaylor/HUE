//
//  ContainerViewController.swift
//  Hue
//
//  Created by James Taylor on 2015-03-18.
//  Copyright (c) 2015 James Lin Taylor. All rights reserved.
//

import UIKit

@objc protocol ContainerViewControllerDelegate: class {
    
    optional
    
    func containerViewController(containerViewController: ContainerViewController, didSelectViewController viewController: UIViewController)

    func containerViewController(containerViewController: ContainerViewController, animationControllerForTransitioningFromViewController fromViewController: UIViewController, toViewController: UIViewController) -> UIViewControllerAnimatedTransitioning
    
}

class ContainerViewController: UIViewController {

    weak var delegate: ContainerViewControllerDelegate?
    
    var cameraViewController: CameraViewController
    var samplesViewController: SamplesViewController
    
    var containerView: UIView!
    var switchButton: UIButton!
    
    var selectedViewController: UIViewController? {
        didSet {
            self.transitionFromViewController(oldValue, toViewController: self.selectedViewController)
        }
    }
    
    override init () {
     
        self.cameraViewController = CameraViewController()
        self.samplesViewController = SamplesViewController()
        
        super.init(nibName: nil, bundle: nil)
        
    }
   
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
 
    
    override func loadView() {
        
        let rootView = UIView()
        
        self.containerView = UIView()
        self.containerView.backgroundColor = UIColor.redColor()
        self.containerView.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        self.switchButton = UIButton()
        self.switchButton.backgroundColor = UIColor.blackColor()
        self.switchButton.addTarget(self, action: Selector("buttonTapped:"), forControlEvents: UIControlEvents.TouchUpInside)
        self.switchButton.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        rootView.addSubview(self.containerView)
        rootView.addSubview(self.switchButton)
        
        // container view constraints
        let widthConstraint = NSLayoutConstraint(item: self.containerView, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: rootView, attribute: NSLayoutAttribute.Width, multiplier: 1, constant: 0)
        let heightConstraint = NSLayoutConstraint(item: self.containerView, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: rootView, attribute: NSLayoutAttribute.Height, multiplier: 1, constant: 0)
        let leftConstraint = NSLayoutConstraint(item: self.containerView, attribute: NSLayoutAttribute.Left, relatedBy: NSLayoutRelation.Equal, toItem: rootView, attribute: NSLayoutAttribute.Left, multiplier: 1, constant: 0)
        let rightConstraint = NSLayoutConstraint(item: self.containerView, attribute: NSLayoutAttribute.Right, relatedBy: NSLayoutRelation.Equal, toItem: rootView, attribute: NSLayoutAttribute.Right, multiplier: 1, constant: 0)
        rootView.addConstraints([widthConstraint, heightConstraint, leftConstraint, rightConstraint])
        
        // button constraints
        switchButton.frame.size = CGSize(width: 40, height: 40)
        let verticalConstraint = NSLayoutConstraint(item: self.switchButton, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: rootView, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0)
        let horizontalConstraint = NSLayoutConstraint(item: self.switchButton, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: rootView, attribute: NSLayoutAttribute.CenterY, multiplier: 1, constant: 0)
        rootView.addConstraints([verticalConstraint, horizontalConstraint])
        
        self.view = rootView
        
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.selectedViewController = self.cameraViewController
        
    }
    
    // MARK: - Private Methods
    
    func transitionFromViewController(fromViewController: UIViewController?, toViewController: UIViewController!) {
        
        if (fromViewController == toViewController) | !self.isViewLoaded() {
            return
        }
        
        let toView = toViewController.view
        toView.frame = self.containerView.bounds
        
        fromViewController?.willMoveToParentViewController(nil)
        self.addChildViewController(toViewController)
        
        // if this is the initial presentation, add the new child view controller with no animation
        if (fromViewController == nil) {
            self.containerView.addSubview(toView)
            toViewController.didMoveToParentViewController(self)
            return
        }
        
        var animator: UIViewControllerAnimatedTransitioning = AnimatedTransition()
        //let animator = self.delegate?.containerViewController(self, animationControllerForTransitioningFromViewController: fromViewController!, toViewController: toViewController)
        
        let context = TransitioningContext(fromViewController: fromViewController!, toViewController: toViewController)
        context.completionBlock = { (didComplete: Bool) -> Void in
            
            fromViewController!.view.removeFromSuperview()
            fromViewController!.removeFromParentViewController()
            toViewController.didMoveToParentViewController(self)
            
            animator.animationEnded?(didComplete)
            self.switchButton.userInteractionEnabled = true
        
        }
        
        self.switchButton.userInteractionEnabled = false
        animator.animateTransition(context)
        
    }
    
    func buttonTapped(button: UIButton) {
        
        self.selectedViewController = self.selectedViewController == self.cameraViewController ? self.samplesViewController : self.cameraViewController
        
    }
    
}

// MARK: - Private Transitioning Context

private class TransitioningContext: NSObject, UIViewControllerContextTransitioning {
    
    var completionBlock: ((Bool) -> Void)?
    
    private var viewControllers: NSDictionary
    private var views: NSDictionary
    
    private var disappearingFromRect: CGRect
    private var appearingFromRect: CGRect
    private var disappearingToRect: CGRect
    private var appearingToRect: CGRect

    init(fromViewController: UIViewController, toViewController: UIViewController) {
        
        self.viewControllers = [UITransitionContextFromViewControllerKey: fromViewController, UITransitionContextToViewControllerKey: toViewController]
        self.views = [UITransitionContextFromViewKey: fromViewController.view, UITransitionContextToViewKey: toViewController.view]
        
        // frame setup
        let containerBounds = fromViewController.view.superview!.bounds
        self.disappearingFromRect = containerBounds
        self.appearingFromRect = CGRectOffset(containerBounds, 0, containerBounds.height)
        self.disappearingToRect = CGRectOffset(containerBounds, 0, -containerBounds.height)
        self.appearingToRect = containerBounds
        
        super.init()
        
    }
    
    private func containerView() -> UIView {
        
        return self.viewForKey(UITransitionContextFromViewKey)!.superview!
    
    }
    
    private func initialFrameForViewController(viewController: UIViewController) -> CGRect {
        
        var frame: CGRect
        if viewController == self.viewControllerForKey(UITransitionContextFromViewControllerKey) {
            frame = self.disappearingFromRect
        } else {
            frame = self.appearingFromRect
        }
        
        return frame
    }
    
    private func finalFrameForViewController(viewController: UIViewController) -> CGRect {
        
        var frame: CGRect
        if viewController == self.viewControllerForKey(UITransitionContextFromViewControllerKey) {
            frame = self.disappearingToRect
        } else {
            frame = self.appearingToRect
        }
        
        return frame
        
    }
    
    private func viewControllerForKey(key: String) -> UIViewController? {
        
        return self.viewControllers[key] as? UIViewController
        
    }
    
    private func viewForKey(key: String) -> UIView? {
        
        return self.views[key] as? UIView
        
    }
    
    private func completeTransition(didComplete: Bool) {
        
        if let completionBlock = self.completionBlock {
            completionBlock(didComplete)
        }
        
    }
    
    private func transitionWasCancelled() -> Bool {
        
        return false // non interactive transition can't be cancelled
        
    }
    
    // trivial implementations
    private func isAnimated() -> Bool { return true }
    private func isInteractive() -> Bool { return false }
    private func targetTransform() -> CGAffineTransform { return CGAffineTransformIdentity }
    private func presentationStyle() -> UIModalPresentationStyle { return UIModalPresentationStyle.Custom }
    
    // empty implementations (interactive transitions)
    private func updateInteractiveTransition(percentComplete: CGFloat) {}
    private func finishInteractiveTransition() {}
    private func cancelInteractiveTransition() {}
    
}

// MARK: - Private Animated Transition

private class AnimatedTransition: NSObject, UIViewControllerAnimatedTransitioning {
    
    private func transitionDuration(transitionContext: UIViewControllerContextTransitioning) -> NSTimeInterval {
        
        return 0.2
        
    }
    
    private func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        
        let fromViewController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)
        let toViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)
        
        transitionContext.containerView().addSubview(toViewController!.view)
        
        toViewController!.view.frame = transitionContext.initialFrameForViewController(toViewController!)
        fromViewController!.view.frame = transitionContext.initialFrameForViewController(fromViewController!)
        
        UIView.animateWithDuration(self.transitionDuration(transitionContext), animations: {
            
            toViewController!.view.frame = transitionContext.finalFrameForViewController(toViewController!)
            fromViewController!.view.frame = transitionContext.finalFrameForViewController(fromViewController!)
            
        }, completion: { (finished) -> Void in
        
            transitionContext.completeTransition(finished)
            
        })
        
    }
    
}
