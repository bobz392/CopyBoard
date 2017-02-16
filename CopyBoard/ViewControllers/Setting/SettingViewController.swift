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
    fileprivate var settingItems: [[SettingType]]
    fileprivate let settingHeader: [String]
    fileprivate var selectedIndex: IndexPath? = nil

    init() {
        let settingsCreator = SettingItemCreator()
        self.settingItems = settingsCreator.settingsCreator()
        self.settingHeader = settingsCreator.settingsHeader()
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
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

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        guard let index = self.selectedIndex else { return }
        self.settingView.settingsTableView.deselectRow(at: index, animated: true)
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
        return kSettingItemHeight
    }
 
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            return self.settingView.catHeaderView()
        } else {
            return self.settingView.sectionHeaderView(title: self.settingHeader[section])
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedIndex = indexPath
        let item = self.settingItems[indexPath.section][indexPath.row]
        let vc = DetailViewController(rootSettingType: item)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return kCatHeaderViewHeight
        } else {
            return kNormalHeaderViewHeight
        }
    }
    
}
