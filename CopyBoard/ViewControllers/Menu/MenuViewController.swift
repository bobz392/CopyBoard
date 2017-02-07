//
//  MenuViewController.swift
//  CopyBoard
//
//  Created by zhoubo on 2017/1/30.
//  Copyright © 2017年 zhoubo. All rights reserved.
//

import UIKit

class MenuViewController: UIViewController {

    fileprivate let menuView = MenuView()
    weak var note: Note? = nil
    var statysBarHidden = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.quitMenu))
        self.view.addGestureRecognizer(tap)
        
        menuView.configView(view: self.view)
        menuView.menuTableView.delegate = self
        menuView.menuTableView.dataSource = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func quitMenu() {
        self.viewDeckController?.closeSide(true)
        DeviceManager.shared.hiddenStatusBar(hidden: false)
    }

}

extension MenuViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard  let note = self.note else {
            fatalError("in ment note must not nil")
        }
        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: MenuDateTableCell.reuseId, for: indexPath) as! MenuDateTableCell
            cell.configEditDate(date: note.modificationDate ?? Date())
            
            return cell
        default:
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = AppColors.cloudHeader
        let label = UILabel()
        label.text = Localized("infomation")
        label.textColor = AppColors.menuText
        label.font = appFont(size: 17)
        view.addSubview(label)
        label.snp.makeConstraints { maker in
            maker.centerY.equalToSuperview().offset(self.statysBarHidden ? 0 : 10)
            maker.left.equalToSuperview().offset(12)
        }
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.row {
        case 0:
            return MenuDateTableCell.rowHeight
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44 + (self.statysBarHidden ? 0 : 20)
    }
    
}
