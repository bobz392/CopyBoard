//
//  DetailViewController.swift
//  CopyBoard
//
//  Created by zhoubo on 2017/2/13.
//  Copyright © 2017年 zhoubo. All rights reserved.
//

import UIKit

class DetailViewController: BaseViewController, UIGestureRecognizerDelegate {

    let settingView = SettingView()
    fileprivate let settingType: SettingType
    
    init(type: SettingType) {
        self.settingType = type
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.settingView.config(view: self.view)
        self.settingView.configSettingDetail(title: self.settingType.settingName())
        self.settingView.configTableView(delegate: self, dataSource: self)
        
        self.settingView.closeButton.addTarget(self, action: #selector(self.close), for: .touchUpInside)
        self.settingView.backButton.addTarget(self, action: #selector(self.back), for: .touchUpInside)
        
        self.automaticallyAdjustsScrollViewInsets = false
    }
    
    func close() {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    func back() {
        let _ = self.navigationController?.popViewController(animated: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.settingView.settingsTableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.navigationController?.interactivePopGestureRecognizer?.delegate = nil
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func deviceOrientationChanged() {
        self.settingView.invalidateLayout()
    }
    
}

extension DetailViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 6
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNonzeroMagnitude
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return CGFloat.leastNonzeroMagnitude
        } else {
            return 40
        }
    }
    
}
