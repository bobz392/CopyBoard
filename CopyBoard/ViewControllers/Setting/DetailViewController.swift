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
    fileprivate let rootSettingType: SettingType
    fileprivate var detailTypes: [[SettingType]]
    fileprivate let detailHeaders: [String]
    fileprivate var selectedIndex: IndexPath? = nil

    init(rootSettingType: SettingType) {
        self.rootSettingType = rootSettingType
        let types = rootSettingType.detailTypes()
        self.detailTypes = types.0
        self.detailHeaders = types.1
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.settingView.config(view: self.view)
        self.settingView.configSettingDetail(title: self.rootSettingType.settingName())
        self.settingView.configTableView(delegate: self, dataSource: self)
        
        self.settingView.closeButton.addTarget(self, action: #selector(self.close), for: .touchUpInside)
        self.settingView.backButton.addTarget(self, action: #selector(self.back), for: .touchUpInside)
        
        if #available(iOS 11.0, *) {
            self.settingView.settingsTableView.contentInsetAdjustmentBehavior = .never;
        } else {
            self.automaticallyAdjustsScrollViewInsets = false
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self

        guard let index = self.selectedIndex else { return }
        self.settingView.settingsTableView.deselectRow(at: index, animated: true)
        self.selectedIndex = nil
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.settingView.settingsTableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
        
        guard let index = self.selectedIndex else { return }
        self.settingView.settingsTableView.reloadRows(at: [index], with: .none)
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

    func close() {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }

    func back() {
        let _ = self.navigationController?.popViewController(animated: true)
    }

}

extension DetailViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.detailTypes[section].count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.detailTypes.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return kSettingItemHeight
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SettingsTableViewCell.reuseId, for: indexPath) as! SettingsTableViewCell
        self.detailTypes[indexPath.section][indexPath.row]
            .detailSettingConfig(cell: cell, rootSettingType: self.rootSettingType, row: indexPath.row, section: indexPath.section)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if let footer = self.rootSettingType.detailFooter(),
            footer.count > 0 {
            return 40
        } else {
            return CGFloat.leastNonzeroMagnitude
        }
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if let footer = self.rootSettingType.detailFooter(),
            footer.count > section {
            return self.settingView.sectionFooterView(title: footer[section])
        } else {
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let title = self.detailHeaders[section]
        return title.characters.count > 0 ? kNormalHeaderViewHeight : CGFloat.leastNonzeroMagnitude
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let title = self.detailHeaders[section].uppercased()
        return title.characters.count > 0 ? self.settingView.sectionHeaderView(title: title) : nil
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        let item = self.detailTypes[indexPath.section][indexPath.row]
        return item.selectedType() == .value ? nil : indexPath
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = self.detailTypes[indexPath.section][indexPath.row]
        switch item.selectedType() {
        case .push:
            self.selectedIndex = indexPath
            let detailVC = DetailViewController(rootSettingType: item)
            self.navigationController?.pushViewController(detailVC, animated: true)
        
        case .select:
            tableView.deselectRow(at: indexPath, animated: true)
            item.selectedType().selectAction(rootSettingType: self.rootSettingType, selectedType: item, row: indexPath.row, section: indexPath.section)
            tableView.reloadData()
            
        case .value:
            tableView.deselectRow(at: indexPath, animated: true)
        
        case .pushHelp:
            print(item)
            
        }
    }
    
}
