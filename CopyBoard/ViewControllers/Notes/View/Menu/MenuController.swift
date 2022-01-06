//
//  MenuController.swift
//  CopyBoard
//
//  Created by zhoubo on 2022/1/3.
//  Copyright © 2022 zhoubo. All rights reserved.
//

import UIKit
import SnapKit
import RxCocoa
import UILibrary
import ContextMenu

struct MenuAction {
    var title: String
    var selected: Bool = true
    var icon: Icons? = nil
    var handler: () -> Void
}

class MenuController: UITableViewController {
    
    var menuContents: [[MenuAction]] = {
       
        let groupItem = MenuAction(title: Localized("card"),
                                   selected: MemoSettings.shared.useGroup,
                                   icon: Icons.group) {
            GlobalSettings.default.set(forKey: .noteGroupKey,
                                       value: true)
        }

        let listItem = MenuAction(title: Localized("list"),
                                  selected: !MemoSettings.shared.useGroup,
                                  icon: Icons.list) {
            GlobalSettings.default.set(forKey: .noteGroupKey,
                                       value: false)
        }
        return [
            [
                groupItem,
                listItem,
            ]
        ]
    }()
    
    static let rowHeight: CGFloat = 44
    
    override init(style: UITableView.Style) {
        super.init(style: style)

    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        MenuCell.uilib_registeTo(tableView)
        tableView.reloadData()
        tableView.layoutIfNeeded()
        preferredContentSize = CGSize(width: 250, height: tableView.contentSize.height)
        tableView.backgroundColor = .clear
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuContents[section].count
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return menuContents.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: MenuCell.uilib_reuseIdentifier, for: indexPath) as? MenuCell {
            let menu = menuContents[indexPath.section][indexPath.row]
            cell.updateCellBy(menu)
            return cell
        } else {
            return UITableViewCell()
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let action = menuContents[indexPath.section][indexPath.row]
        action.handler()
        
        dismiss(animated: true, completion: nil)
    }
    
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return MenuController.rowHeight
    }

}

private class MenuCell: UITableViewCell {
   
    private let selectImageView = UIImageView()
    private var nameLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.systemFont(ofSize: 14)
        lbl.textColor = .dms_black
        return lbl
    }()
    
    private let iconImageView = UIImageView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        buildUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func buildUI() {
        contentView.addSubview(selectImageView)
        selectImageView.image = Icons.selected.iconImage()
        selectImageView.tintColor = .dms_black
        contentView.addSubview(nameLabel)
        contentView.addSubview(iconImageView)
        
        selectImageView.snp.makeConstraints { make in
            make.width.height.equalTo(14)
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(10)
        }
        
        nameLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(31)
            make.centerY.equalToSuperview()
        }
        
        iconImageView.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(15)
            make.width.height.equalTo(20)
            make.centerY.equalToSuperview()
        }
    }
    
    func updateCellBy(_ action: MenuAction) {
        nameLabel.text = action.title
        iconImageView.image = action.icon?.iconImage()
        selectImageView.isHidden = !action.selected
    }
}
