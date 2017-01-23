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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        } else {
//            Def.log("该设备不支持3D-Touch")
        }
    }
    
    @available(iOS 9.0, *)
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        self.navigationController?.pushViewController(viewControllerToCommit, animated: false)
    }
    
    @available(iOS 9.0, *)
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        return self.previewViewControllerBlock?(previewingContext, location)
    }
    
    @available(iOS 8.0, *)
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        if #available(iOS 9.0, *) {
            switch traitCollection.forceTouchCapability {
            case .available:
                guard let block = self.sourceViewBlock else { return }
                self.registerForPreviewing(with: self, sourceView: block())
            default:
                return
            }
        }
    }
    
}
