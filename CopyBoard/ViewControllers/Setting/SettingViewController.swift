//
//  SettingViewController.swift
//  CopyBoard
//
//  Created by zhoubo on 2017/2/9.
//  Copyright © 2017年 zhoubo. All rights reserved.
//

import UIKit

class SettingViewController: BaseViewController {

    let settingView = SettingView()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let bar = self.navigationController?.navigationBar {
            self.settingView.configBarView(bar: bar)
        }
        self.settingView.config(view: self.view)
        
        self.settingView.closeButton
            .addTarget(self, action: #selector(self.quit), for: .touchUpInside)
        
        self.settingView.settingsTableView.delegate = self
        self.settingView.settingsTableView.dataSource = self
    }
    
    func quit() {
        self.dismiss(animated: true) {}
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}

extension SettingViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
    
}
