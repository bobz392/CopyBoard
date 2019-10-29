//
//  BaseViewController.swift
//  CopyBoard
//
//  Created by zhoubo on 2017/1/12.
//  Copyright © 2017年 zhoubo. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController {
    
    fileprivate var sourceViewBlock: SourceViewBlock? = nil
    fileprivate var previewViewControllerBlock: PreviewViewControllerBlock? = nil
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        self.modalPresentationStyle = .overFullScreen
        if #available(iOS 13.0, *) {
            self.isModalInPresentation = true
            UIApplication.shared.statusBarStyle = .darkContent
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default
            .addObserver(self, selector: #selector(self.deviceOrientationChanged),
                         name: UIApplication.didChangeStatusBarOrientationNotification, object: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func deviceOrientationChanged() {
        
    }
    
//    open func scrollViewShouldScrollToTop(_ scrollView: UIScrollView) -> Bool {
//        if let navigationController = self.navigationController as? ScrollingNavigationController {
//            navigationController.showNavbar(animated: true)
//        }
//        return true
//    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
}

// Mark: - 3d touch
extension BaseViewController: UIViewControllerPreviewingDelegate {
    typealias SourceViewBlock = () -> UIView
    typealias PreviewViewControllerBlock = (UIViewControllerPreviewing, CGPoint) -> UIViewController?
    
    @available(iOS 9.0, *)
    func registerPerview(sourceViewBlock: @escaping SourceViewBlock,
                         previewViewControllerBlock: @escaping PreviewViewControllerBlock) {
        self.previewViewControllerBlock = previewViewControllerBlock
        self.sourceViewBlock = sourceViewBlock
        
        if self.traitCollection.forceTouchCapability == .available {
            self.registerForPreviewing(with: self, sourceView: sourceViewBlock())
        }
    }
    
    @available(iOS 9.0, *)
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        self.present(viewControllerToCommit, animated: false, completion: nil)
    }
    
    @available(iOS 9.0, *)
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        return self.previewViewControllerBlock?(previewingContext, location)
    }
    
    @available(iOS 8.0, *)
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        switch traitCollection.forceTouchCapability {
        case .available:
            guard let block = self.sourceViewBlock else { return }
            self.registerForPreviewing(with: self, sourceView: block())
        default:
            return
        }
    }
    
}
