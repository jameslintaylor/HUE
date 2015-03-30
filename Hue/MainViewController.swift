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
    
    var samplesTab: DraggableView!
    
    var animator: UIDynamicAnimator!
    var samplesTabBehaviour: SamplesTabBehaviour!
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
        
        self.samplesViewController.view.frame = self.view.bounds
        self.addChildViewController(self.samplesViewController)
        self.view.addSubview(self.samplesViewController.view)
        self.samplesViewController.didMoveToParentViewController(self)
        
        self.samplesTab = DraggableView(frame: CGRect(x: 0, y: self.view.bounds.height - TAB_HEIGHT, width: self.view.bounds.width, height: TAB_HEIGHT))
        self.samplesTab.delegate = self
        self.view.addSubview(self.samplesTab)

    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.setupDynamics()
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    // MARK: - Private Methods
    
    func setupDynamics() {
        
        self.animator = UIDynamicAnimator(referenceView: self.view)
        
        self.samplesTabBehaviour = SamplesTabBehaviour(tab: self.samplesTab, openToPoint: CGPoint(x: SCR_WIDTH/2, y: TAB_HEIGHT * 3/2))
        self.animator.addBehavior(self.samplesTabBehaviour)
        
        self.samplesViewBehaviour = SamplesViewBehaviour(view: self.samplesViewController.view, tab: self.samplesTab)
        self.animator.addBehavior(self.samplesViewBehaviour)
        
        self.samplesViewBehaviour.startAnchorPointUpdates()
        
    }
    
    // MARK: - DraggableViewDelegate
    
    func draggableViewBeganDragging(view: DraggableView) {
        self.animator.removeBehavior(self.samplesTabBehaviour)
    }
    
    func draggableView(view: DraggableView, draggingEndedWithVelocity velocity: CGPoint) {
        
        self.samplesTabBehaviour.open = velocity.y < 0
        self.samplesTabBehaviour.setInitialVelocity(velocity)
        self.animator.addBehavior(self.samplesTabBehaviour)
        
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
            
            println("not saved")
        
        } else {
         
            println("saved")
            Sample.insertSampleWithColor(color, thumbnailFileName: fileName, inManagedObjectContext: self.samplesViewController.tableViewManager.managedObjectContext)
       
        }
        
    }
    
}
