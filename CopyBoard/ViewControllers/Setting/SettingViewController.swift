//
//  SettingViewController.swift
//  CopyBoard
//
//  Created by zhoubo on 2017/2/9.
//  Copyright © 2017年 zhoubo. All rights reserved.
//

import UIKit
import WhatsNewKit

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
        
        if #available(iOS 11.0, *) {
            self.settingView.settingsTableView.contentInsetAdjustmentBehavior = .never;
        } else {
           self.automaticallyAdjustsScrollViewInsets = false
        }
        
        settingView
            .catGuideButton
            .addTarget(self,
                       action: #selector(guildAction), for: .touchUpInside)
    }
    
    @objc private func guildAction() {
        let arrayOfImage = ["step1", "step2", "step3"]
        let local = Localized("step")
        let arrayOfTitle = ["\(local) 1", "\(local) 2", "\(local) 3"]
        let arrayOfDescription = [Localized("description1"), Localized("description2"), Localized("description3")]
        let buttonsTitles = [Localized("doGuild1"), Localized("doGuild2"), Localized("doGuild3")]
        
        let alertView = AlertOnboarding(arrayOfImage: arrayOfImage,
                                        arrayOfTitle: arrayOfTitle,
                                        arrayOfDescription: arrayOfDescription,
                                        arrayOfBottomTitles: buttonsTitles)
        { (index) in
            if #available(iOS 11.0, *) {
                if index == 0 || index == 1 {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    }
                    return false
                } else {
                    return true
                }
            } else {
                if index == 0 {
                    if #available(iOSApplicationExtension 10.0, *) {
                        if let url = URL(string: "App-Prefs:root=General&path=Keyboard/KEYBOARDS") {
                            UIApplication.shared.open(url, options: [:], completionHandler: nil)
                        }
                    } else {
                        if let url = URL(string: "prefs:root=General&path=Keyboard/KEYBOARDS") {
                            UIApplication.shared.openURL(url)
                        }
                    }
                    return false
                } else if index == 1 {
                    if #available(iOSApplicationExtension 10.0, *) {
                        if let url = URL(string: "App-Prefs:root=General&path=Keyboard/KEYBOARDS/com.zhoubo.CopyBoard.Keyboard") {
                            UIApplication.shared.open(url, options: [:], completionHandler: nil)
                        }
                    } else {
                        if let url = URL(string: "prefs:root=General&path=Keyboard/KEYBOARDS/com.zhoubo.CopyBoard.Keyboard") {
                            UIApplication.shared.openURL(url)
                        }
                    }
                    return false
                } else {
                    return true
                }
            }
        }
        
        alertView.show()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.settingView.settingsTableView
            .scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        guard let index = self.selectedIndex else { return }
        self.settingView.settingsTableView.deselectRow(at: index, animated: true)
    }

    @objc func quit() {
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
        let item = self.settingItems[indexPath.section][indexPath.row]
        cell.settingLabel.text = item.settingName()
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return kSettingItemHeight
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = self.settingItems[indexPath.section][indexPath.row]
        
        if item == .rate {
             let url = "https://itunes.apple.com/us/app/sticker-your-note-keyboard/id1212066610?mt=8"
            guard let u = URL(string: url) else { return }
            UIApplication.shared.open(u, options: [:], completionHandler: nil)
        } else if item == .contact {
            guard let url = URL(string: "mailto:zhoubo392@gmail.com")
                else { return }
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            self.selectedIndex = indexPath
            let vc = DetailViewController(rootSettingType: item)
            self.navigationController?.pushViewController(vc, animated: true)
            return
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if (section == self.settingItems.count - 1) {
            return kVersionFooterViewHeight
        } else if (section == 1) {
            return kFooterViewHeight
        } else {
            return CGFloat.leastNormalMagnitude
        }
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if section == self.settingItems.count - 1 {
            return self.settingView.versionFooterView()
        } else if (section == 1) {
            return self.settingView.sectionFooterView(title: Localized("filterHelper"))
        } else {
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            return self.settingView.catHeaderView()
        } else {
            return self.settingView.sectionHeaderView(title: self.settingHeader[section])
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? kCatHeaderViewHeight : kNormalHeaderViewHeight
    }
    
}
