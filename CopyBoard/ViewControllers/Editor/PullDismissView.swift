//
//  PullDismissView.swift
//  CopyBoard
//
//  Created by zhoubo on 2017/1/26.
//  Copyright © 2017年 zhoubo. All rights reserved.
//

import UIKit

final class PullDismissView: DGElasticPullToRefreshLoadingView {
    
    typealias ProgressBlock = (CGFloat) -> Void
    
    private let pb: ProgressBlock
    let imageView = UIImageView()
    
    init(progressBlock: @escaping ProgressBlock) {
        self.pb = progressBlock
        super.init(frame: .zero)
        
        self.addSubview(self.imageView)
        self.imageView.image = Icons.clear.iconImage()
        self.imageView.contentMode = .scaleAspectFit
        self.imageView.tintColor = UIColor.white
        self.imageView.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.width.equalTo(12)
            make.height.equalTo(12)
        }
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func stopLoading() {
        super.stopLoading()
    }
    
    override func startAnimating() {
        super.startAnimating()
    }
    
    
    override func setPullProgress(_ progress: CGFloat) {
        super.setPullProgress(progress)
        self.imageView.alpha = progress
        if progress >= 1, self.imageView.tag == 0 {
            self.imageView.tag = 1
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.3, initialSpringVelocity: 0.1, options: UIViewAnimationOptions.beginFromCurrentState,     animations: {
                let scale: CGFloat = 1 + 0.5 * progress
                self.imageView.transform = CGAffineTransform(scaleX: scale , y: scale)
            }, completion: nil)
        } else if progress < 1, self.imageView.tag == 1 {
            self.imageView.tag = 0
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.3, initialSpringVelocity: 0.1, options: UIViewAnimationOptions.beginFromCurrentState, animations: {
                self.imageView.transform = CGAffineTransform(scaleX: 1, y: 1)
            }, completion: nil)
        }

        self.pb(progress)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
}
