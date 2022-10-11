//
//  NoteViewController.swift
//  CopyBoard
//
//  Created by zhoubo on 2022/1/1.
//  Copyright © 2022 zhoubo. All rights reserved.
//

import UIKit
import RxSwift
import ContextMenu
import UILibrary

// MARK: - Note View Controller
class NoteViewController: UIViewController {
    
    // MARK: Props
    let viewProps = NoteViewProps()
    let viewModel: NotesViewModel!
    let disposeBag = DisposeBag()
    
    // MARK: Life Circle
    init() {
        let searchDriver = viewProps.searchController.searchBar.rx.text.orEmpty.asDriver()
        self.viewModel =
            NotesViewModel(searchDriver: searchDriver,
                           searchBlock:
                { (query) in
//                    guard let ws = weakSelf else { return }
//                    ws.noteView.searchViewStateChange(query: query.count > 0, notesCount: ws.viewModel.notesCount())
            })
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configNavigationBar()
        viewProps.buildUI(rootView: self.view)
        
        bindLogic()
    }
    
    // MARK: UI
    private func configNavigationBar() {
        uilib_largeTitleSupport(searchController: nil)
        self.title = Localized("sticker")
//        navigationItem.searchController = viewProps.searchController
        
//        let barItem = UIBarButtonItem(customView: viewProps.arrangeButton)
//        navigationItem.rightBarButtonItem = barItem
        
//        viewProps.arrangeButton
//            .rx.tap
//            .subscribe { [unowned self] _ in
//                ContextMenu.shared.show(
//                    sourceViewController: self,
//                    viewController: MenuController(style: .plain),
//                    options: ContextMenu.Options(
//                        containerStyle: ContextMenu.ContainerStyle(
//                            cornerRadius: 12,
//                            xPadding: -20,
//                            backgroundColor: .dms_white
//                        ),
//                        menuStyle: .minimal,
//                        hapticsStyle: .light
//                    ),
//                    sourceView: self.viewProps.arrangeButton,
//                    delegate: nil
//                )
//        }.disposed(by: disposeBag)
        
    }
    
    // MARK: Logic Bind
    func bindLogic() {
        becomeSettingObsever()
        viewProps.collectionView.delegate = self
        viewProps.collectionView.dataSource = self
    }
    
    @objc func action(sender: UIButton) {
//        let tag = sender.tag
//        let note = viewModel.notes[tag]
//        DBManager.shared.deleteNote(note: note)
        let alert = UIAlertController(title: "", message: "",
                                      preferredStyle: .actionSheet)
        let deleteAction = UIAlertAction(title: Localized("delete"),
                                         style: .destructive) { _ in
            
        }
        alert.addAction(deleteAction)
        
        let cancelAction = UIAlertAction(title: Localized("cancel"),
                                         style: .cancel) { _ in
            alert.dismiss(animated: true)
        }
        alert.addAction(cancelAction)
        
        let shareAction = UIAlertAction(title: Localized("share"), style: .default) { _ in
            
        }
        alert.addAction(shareAction)
        
        present(alert, animated: true)
    }
}

extension NoteViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.notesCount()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NotePreviewCell.uilib_reuseIdentifier, for: indexPath) as? NotePreviewCell {
//            let row = indexPath.row
//            cell.updateCellBy(viewModel.noteIn(row: row), row)
//            cell.actionsButton.removeTarget(self, action: nil, for: .touchUpInside)
//            cell.actionsButton.addTarget(self, action: #selector(action(sender:)), for: .touchUpInside)
            let note = self.viewModel.noteIn(row: indexPath.row)
            cell.lastEditLabel.text = "Last edit 1 day ago"
            cell.previewLabel.text = note.content
            cell.starButton.isSelected = note.favourite
            cell.tagLabel.text = note.category
            
            if let pairColor =
                AppPairColors(rawValue: note.color)?.pairColor() {
                cell.tagLabel.backgroundColor = pairColor.light
            }
            
            return cell
        } else {
            return UICollectionViewCell()
        }
    }
}

// MARK: - Note View Props Container
/// 属性存放的列表， Controller 里面尽量简单点
struct NoteViewProps {
    
    let searchButton = UIButton(type: .custom)
    let settingButton = UIButton(type: .custom)
    let arrangeButton: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setImage(Icons.group.iconImage(), for: .normal)
        btn.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        return btn
    }()
    
    let searchController = UISearchController(searchResultsController: nil)
    
    let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets.zero
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        let width = UIScreen.main.bounds.width
        layout.itemSize = CGSize(width: width, height: 115)
        let cv = UICollectionView(frame: .zero,
                                  collectionViewLayout: layout)
//        NoteCell.uilib_registeTo(cv)
        NotePreviewCell.uilib_registeTo(cv)
        return cv
    }()
    
    init() { }
    
    func buildUI(rootView: UIView) {
        rootView.backgroundColor = .dms_white
        rootView.addSubview(collectionView)
        collectionView.backgroundColor = .dms_white
        collectionView.snp.makeConstraints { make in
            make.left.right.top.bottom.equalToSuperview()
        }
    }
    
    func safeareaDidChanged(rootView: UIView) {
        collectionView.snp.updateConstraints { make in
            make.top.equalTo(rootView.safeAreaInsets.top)
            make.bottom.equalTo(rootView.safeAreaInsets.bottom)
        }
        rootView.layoutIfNeeded()
    }
}

extension NoteViewController: GlobalSettingObservable {
    
    func valueChanged(forKey key: GlobalSettings.Key, oldValue: Any?, newValue: Any?) {
//        switch key {
//        case .noteGroupKey:
//            if let grouped = newValue as? Bool {
//                let layout = UICollectionViewFlowLayout()
//                layout.sectionInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
//                layout.minimumLineSpacing = 20
//                layout.minimumInteritemSpacing = 15
//                let width: CGFloat
//                if grouped {
//                    width = (UIScreen.main.bounds.width - 55) * 0.5
//                } else {
//                    width = UIScreen.main.bounds.width - 40
//                }
//                layout.itemSize = CGSize(width: width, height: 86.0 + 20 * 3.0)
//                viewProps.collectionView.setCollectionViewLayout(layout, animated: true)
//            }
//        default:
//            return
//        }
    }
}
