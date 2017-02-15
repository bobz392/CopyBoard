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
    var settingItems = SettingItemCreator().creator()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.settingView.config(view: self.view)
        self.settingView.configTableView(delegate: self, dataSource: self)
        
        self.settingView.closeButton
            .addTarget(self, action: #selector(self.quit), for: .touchUpInside)
        self.automaticallyAdjustsScrollViewInsets = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.settingView.settingsTableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
    }
    
    func quit() {
        self.dismiss(animated: true) {}
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func deviceOrientationChanged() {
        self.settingView.invalidateLayout()
    }

}

extension SettingViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.settingItems.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.settingItems[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SettingsTableViewCell.reuseId, for: indexPath) as! SettingsTableViewCell
        cell.settingLabel.text = self.settingItems[indexPath.section][indexPath.row].settingName()
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
 
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            return self.settingView.catHeaderView()
        } else {
            return self.settingView.sectionHeaderView(title: "KEYBOARD")
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = self.settingItems[indexPath.section][indexPath.row]
        let vc = DetailViewController(type: item)
        self.navigationController?.pushViewController(vc, animated: true)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 190
        } else {
            return 45
        }
    }
    
}
