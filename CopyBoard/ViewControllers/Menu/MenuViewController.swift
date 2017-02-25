//
//  MenuViewController.swift
//  CopyBoard
//
//  Created by zhoubo on 2017/1/30.
//  Copyright © 2017年 zhoubo. All rights reserved.
//

import UIKit

class MenuViewController: BaseViewController {

    let menuView = MenuView()
    weak var note: Note? = nil
    fileprivate var barHeight: CGFloat = DeviceManager.shared.isLandscape ? 0 : 20
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if let bar = self.navigationController?.navigationBar {
            menuView.configBar(bar: bar)
        }
        menuView.configView(view: self.view)
        menuView.menuTableView.delegate = self
        menuView.menuTableView.dataSource = self
        menuView.closeButton.addTarget(self, action: #selector(self.quitMenu), for: .touchUpInside)
        menuView.menuTableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func quitMenu() {
        self.dismiss(animated: true, completion: nil)
    }

}

extension MenuViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard  let note = self.note else {
            fatalError("in ment note must not nil")
        }
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: MenuDateTableCell.reuseId,
                                                     for: indexPath) as! MenuDateTableCell
            cell.configEditDate(date: note.modificationDate ?? Date())
            cell.layoutIfNeeded()
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: MenuDeviceTableCell.reuseId,
                                                     for: indexPath) as! MenuDeviceTableCell
            cell.config(row: indexPath.row, note: note)
            cell.layoutIfNeeded()
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return MenuDateTableCell.rowHeight
        } else {
            return MenuDeviceTableCell.rowHeight
        }
    }
    
}
