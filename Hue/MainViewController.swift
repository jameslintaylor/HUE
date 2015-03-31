//
//  MainViewController
//  Hue
//
//  Created by James Taylor on 2015-03-18.
//  Copyright (c) 2015 James Lin Taylor. All rights reserved.
//

import UIKit

let TAB_HEIGHT: CGFloat = 100

class MainViewController: UIViewController, DraggableViewDelegate, CameraViewControllerDelegate, SamplesViewControllerDelegate {
    
    var cameraViewController: CameraViewController
    
    var samplesViewController: SamplesViewController
    var samplesViewControllerBackground: UIView!

    var animator: UIDynamicAnimator!
    var samplesViewBehaviour: SamplesViewBehaviour!
    
    override init () {
        
        self.cameraViewController = CameraViewController()
        self.samplesViewController = SamplesViewController()
        
        super.init(nibName: nil, bundle: nil)
        
        self.cameraViewController.delegate = self
        self.samplesViewController.delegate = self
        
    }
   
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.cameraViewController.view.frame = self.view.bounds
        self.addChildViewController(self.cameraViewController)
        self.view.addSubview(self.cameraViewController.view)
        self.cameraViewController.didMoveToParentViewController(self)
        
        self.samplesViewController.view.frame = CGRect(x: 0, y: self.view.bounds.height - TAB_HEIGHT, width: self.view.bounds.width, height: self.view.bounds.height + 100)
        self.addChildViewController(self.samplesViewController)
        self.view.addSubview(self.samplesViewController.view)
        self.samplesViewController.didMoveToParentViewController(self)
        
        self.samplesViewControllerBackground = UIView(frame: CGRect(x: 0, y: self.view.bounds.height - TAB_HEIGHT, width: self.view.bounds.width, height: TAB_HEIGHT))
        self.samplesViewControllerBackground.backgroundColor = UIColor.blackColor()
        self.view.insertSubview(self.samplesViewControllerBackground, belowSubview: self.samplesViewController.view)
        
        //dynamics
        self.animator = UIDynamicAnimator(referenceView: self.view)
        self.samplesViewBehaviour = SamplesViewBehaviour(view: self.samplesViewController.view, openTo: 0, closeTo: self.view.bounds.height - TAB_HEIGHT)
        self.animator.addBehavior(self.samplesViewBehaviour)
        
        self.samplesViewController.appearance = .HidingSamples
        self.samplesViewController.tab.animator = self.animator
        self.samplesViewController.tab.delegate = self
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    // MARK: - DraggableViewDelegate
    
    func draggableViewBeganDragging(view: DraggableView) {
        self.samplesViewController.appearance = self.samplesViewBehaviour.open ? .HidingSamples : .ShowingSamples
        self.cameraViewController.paused = !self.samplesViewBehaviour.open
    }
    
    func draggableView(view: DraggableView, draggingEndedWithVelocity velocity: CGPoint) {
        
        if velocity.y < 0 {
          
            if (self.samplesViewController.view.center.y < SCR_HEIGHT) | (velocity.y < -SCR_HEIGHT) {
                self.samplesViewBehaviour.open = true
            }
            
        } else {
            
            if (self.samplesViewController.view.center.y > SCR_HEIGHT) | (velocity.y > SCR_HEIGHT) {
                self.samplesViewBehaviour.open = false
            }
            
        }

        self.samplesViewController.appearance = self.samplesViewBehaviour.open ? .ShowingSamples : .HidingSamples
        self.cameraViewController.paused = self.samplesViewBehaviour.open
        self.samplesViewBehaviour.setInitialVelocity(velocity.y)
        
    }
    
    // MARK: - CameraViewControllerDelegate
    
    func cameraViewController(viewController: CameraViewController, targetUpdatedWithColor color: UIColor?) {
        self.samplesViewController.setSampleColor(color)
    }
    
    func cameraViewController(viewController: CameraViewController, capturedSampleWithColor color: UIColor?, thumbnail: UIImage?) {
        
        let imageData = UIImagePNGRepresentation(thumbnail)
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
        let uuid = NSUUID().UUIDString
        let fileName = "thumbnail-\(uuid).png"
        let imagePath = paths.stringByAppendingPathComponent(fileName)
        
        if !imageData.writeToFile(imagePath, atomically: false) {
            println("couldn't saved")
        } else {
         
            Sample.insertSampleWithColor(color, thumbnailFileName: fileName, inManagedObjectContext: self.samplesViewController.tableViewManager.managedObjectContext)
            self.samplesViewController.animateSampleSaved()
            
        }
        
    }
    
    // MARK: - SamplesViewControllerDelegate
 
    func samplesViewControllerShouldShowSamples(viewController: SamplesViewController) {
        self.samplesViewBehaviour.open = true
        self.samplesViewController.appearance = .ShowingSamples
        self.cameraViewController.paused = self.samplesViewBehaviour.open
    }
    
    func samplesViewControllerShouldHideSamples(viewController: SamplesViewController) {
        self.samplesViewBehaviour.open = false
        self.samplesViewController.appearance = .HidingSamples
        self.cameraViewController.paused = self.samplesViewBehaviour.open
    }
    
    func samplesViewControllerShouldSwitchModes(viewController: SamplesViewController) {
        
        if self.samplesViewBehaviour.open {
            
            self.samplesViewBehaviour.open = false
            self.samplesViewBehaviour.setInitialVelocity(1000)
            
        } else {
            
            self.samplesViewBehaviour.open = true
            self.samplesViewBehaviour.setInitialVelocity(0)
            
        }
        
        self.samplesViewController.appearance = self.samplesViewBehaviour.open ? .ShowingSamples : .HidingSamples
        self.cameraViewController.paused = self.samplesViewBehaviour.open
        
    }
    
    func samplesViewControllerConfusedUser(viewController: SamplesViewController) {
        let yVelocity: CGFloat = self.samplesViewBehaviour.open ? 2000 : -800
        self.samplesViewBehaviour.setInitialVelocity(yVelocity)
    }
    
}
