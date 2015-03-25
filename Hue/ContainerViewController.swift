//
//  ContainerViewController.swift
//  Hue
//
//  Created by James Taylor on 2015-03-18.
//  Copyright (c) 2015 James Lin Taylor. All rights reserved.
//

import UIKit

class ContainerViewController: UIViewController, CameraViewControllerDelegate, MenuViewControllerDelegate {
    
    var cameraViewController: CameraViewController
    var samplesViewController: SamplesViewController
    var menuViewController: MenuViewController
    
    var containerView: UIView!
    var menuContainerView: UIView!
    
    var menuContainerBottomConstraint: NSLayoutConstraint!
    var menuContainerTopConstraint: NSLayoutConstraint!
    
    var selectedViewController: UIViewController? {
        didSet {
            self.transitionFromViewController(oldValue, toViewController: self.selectedViewController)
        }
    }
    
    override init () {
        self.cameraViewController = CameraViewController()
        self.samplesViewController = SamplesViewController()
        self.menuViewController = MenuViewController()
        super.init(nibName: nil, bundle: nil)
        self.cameraViewController.delegate = self
        self.menuViewController.delegate = self
    }
   
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
 
    
    override func loadView() {
        
        let rootView = UIView()
        
        self.containerView = UIView()
        self.containerView.setTranslatesAutoresizingMaskIntoConstraints(false)

        self.menuContainerView = UIView()
        self.menuContainerView.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        rootView.addSubview(self.containerView)
        rootView.addSubview(self.menuContainerView)
        
        // container view constraints
        rootView.addConstraint(NSLayoutConstraint(item: self.containerView, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: rootView, attribute: NSLayoutAttribute.Width, multiplier: 1, constant: 0))
        rootView.addConstraint(NSLayoutConstraint(item: self.containerView, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: rootView, attribute: NSLayoutAttribute.Height, multiplier: 1, constant: 0))
        rootView.addConstraint(NSLayoutConstraint(item: self.containerView, attribute: NSLayoutAttribute.Left, relatedBy: NSLayoutRelation.Equal, toItem: rootView, attribute: NSLayoutAttribute.Left, multiplier: 1, constant: 0))
        rootView.addConstraint(NSLayoutConstraint(item: self.containerView, attribute: NSLayoutAttribute.Right, relatedBy: NSLayoutRelation.Equal, toItem: rootView, attribute: NSLayoutAttribute.Right, multiplier: 1, constant: 0))
        
        // color menu container constraints
        rootView.addConstraint(NSLayoutConstraint(item: self.menuContainerView, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: rootView, attribute: NSLayoutAttribute.Width, multiplier: 1.0, constant: 0))
        rootView.addConstraint(NSLayoutConstraint(item: self.menuContainerView, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1.0, constant: SAMPLE_HEIGHT))
        rootView.addConstraint(NSLayoutConstraint(item: self.menuContainerView, attribute: NSLayoutAttribute.Left, relatedBy: NSLayoutRelation.Equal, toItem: rootView, attribute: NSLayoutAttribute.Left, multiplier: 1.0, constant: 0))
        
        self.menuContainerBottomConstraint = NSLayoutConstraint(item: self.menuContainerView, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: rootView, attribute: NSLayoutAttribute.Bottom, multiplier: 1.0, constant: 0)
        self.menuContainerTopConstraint = NSLayoutConstraint(item: self.menuContainerView, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: rootView, attribute: NSLayoutAttribute.Top, multiplier: 1.0, constant: 0)
        
        self.view = rootView
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.selectedViewController = self.cameraViewController
        
        // menu view controller
        self.menuViewController.view.setTranslatesAutoresizingMaskIntoConstraints(true)
        self.menuViewController.view.autoresizingMask = UIViewAutoresizing.FlexibleWidth | UIViewAutoresizing.FlexibleHeight
        self.menuViewController.view.frame = self.menuContainerView.bounds
        self.menuContainerView.addSubview(self.menuViewController.view)
        self.addChildViewController(self.menuViewController)
        self.menuViewController.didMoveToParentViewController(self)
    }
    
    // MARK: - Private Methods
    
    func transitionFromViewController(fromViewController: UIViewController?, toViewController: UIViewController!) {
        
        if (fromViewController == toViewController) | !self.isViewLoaded() {
            return
        }
        
        let toView = toViewController.view
        toView.setTranslatesAutoresizingMaskIntoConstraints(true)
        toView.autoresizingMask = UIViewAutoresizing.FlexibleWidth | UIViewAutoresizing.FlexibleHeight
        toView.frame = self.containerView.bounds
        
        fromViewController?.willMoveToParentViewController(nil)
        self.addChildViewController(toViewController)
        
        if toViewController == self.cameraViewController {
            self.view.removeConstraint(self.menuContainerTopConstraint)
            self.view.addConstraint(self.menuContainerBottomConstraint)
        } else {
            self.view.removeConstraint(self.menuContainerBottomConstraint)
            self.view.addConstraint(self.menuContainerTopConstraint)
        }
        
        // if this is the initial presentation, add the new child view controller with no animation
        if (fromViewController == nil) {
            self.containerView.addSubview(toView)
            toViewController.didMoveToParentViewController(self)
            return
        }
        
        var animator: UIViewControllerAnimatedTransitioning = AnimatedTransition()
        
        let context = TransitioningContext(fromViewController: fromViewController!, toViewController: toViewController, goingUp: toViewController == self.cameraViewController)
        context.completionBlock = { (didComplete: Bool) -> Void in
            
            fromViewController!.view.removeFromSuperview()
            fromViewController!.removeFromParentViewController()
            toViewController.didMoveToParentViewController(self)
            
            animator.animationEnded?(didComplete)
        }
        
        animator.animateTransition(context)
        
        // animate menu container constraint change
        UIView.animateWithDuration(0.3, delay: 0.0, options: .CurveEaseOut, animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    func buttonTapped(button: UIButton) {
        
        self.selectedViewController = self.selectedViewController == self.cameraViewController ? self.samplesViewController : self.cameraViewController
    }
    
    // MARK: - Camera View Controller Delegate
    
    func cameraViewController(viewController: CameraViewController, didUpdateWithColor color: UIColor?) {
        
        dispatch_async(dispatch_get_main_queue(), {
            self.menuViewController.updateWithColor(color)
        })
        
    }
    
    // MARK: - Menu View Controller Delegate
    
    func menuViewController(viewController: MenuViewController, requestedChangeMenuToState state: MenuState) -> Bool {
        
        if (state == .Camera) & (self.selectedViewController == self.samplesViewController) {
            self.selectedViewController = self.cameraViewController
            return true
        } else if (state == .Samples) & (self.selectedViewController == self.cameraViewController) {
            self.selectedViewController = self.samplesViewController
            return true
        }
        return false
    }
    
    func menuViewControllerStartedSampleCapture(viewController: MenuViewController) {
        self.cameraViewController.captureImage()
    }
    
    func menuViewController(viewController: MenuViewController, didConfirmSampleCaptureWithColor color: UIColor?) {
        Sample.insertSampleWithColor(color, inManagedObjectContext: self.samplesViewController.tableViewManager.managedObjectContext)
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

    init(fromViewController: UIViewController, toViewController: UIViewController, goingUp: Bool) {
        
        self.viewControllers = [UITransitionContextFromViewControllerKey: fromViewController, UITransitionContextToViewControllerKey: toViewController]
        self.views = [UITransitionContextFromViewKey: fromViewController.view, UITransitionContextToViewKey: toViewController.view]
        
        // frame setup
        let containerBounds = fromViewController.view.superview!.bounds
        let offset = goingUp ? containerBounds.height : -containerBounds.height
        
        self.disappearingFromRect = CGRectOffset(containerBounds, 0, 0)
        self.appearingFromRect = CGRectOffset(containerBounds, 0, -offset)
        self.disappearingToRect = CGRectOffset(containerBounds, 0, offset)
        self.appearingToRect = CGRectOffset(containerBounds, 0, 0)
        
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
        return 0.3
    }
    
    private func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        
        let fromViewController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)
        let toViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)
        
        transitionContext.containerView().addSubview(toViewController!.view)
        
        toViewController!.view.frame = transitionContext.initialFrameForViewController(toViewController!)
        fromViewController!.view.frame = transitionContext.initialFrameForViewController(fromViewController!)
        
        UIView.animateWithDuration(self.transitionDuration(transitionContext), delay: 0.0, options: .CurveEaseOut, animations: {
            
            toViewController!.view.frame = transitionContext.finalFrameForViewController(toViewController!)
            fromViewController!.view.frame = transitionContext.finalFrameForViewController(fromViewController!)
            
        }, completion: { (finished) -> Void in
        
            transitionContext.completeTransition(finished)
            
        })
    }
    
}
