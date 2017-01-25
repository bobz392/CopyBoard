//
//  EditorViewController.swift
//  CopyBoard
//
//  Created by zhoubo on 2017/1/20.
//  Copyright © 2017年 zhoubo. All rights reserved.
//

import UIKit

class EditorViewController: UIViewController {

    let editorView = EditorView()
    let note: Note
    
    init(note: Note) {
        self.note = note
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.editorView.config(withView: self.view, note: self.note)
//        self.editorView.configNote(content: self.note.content)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.dis))
        self.view.addGestureRecognizer(tap)
        
        
//        let loadingView = DGElasticPullToRefreshLoadingView()
//
//        loadingView.tintColor = UIColor(red: 78/255.0, green: 221/255.0, blue: 200/255.0, alpha: 1.0)
//        self.editorView.editorTextView.dg_addPullToRefreshWithActionHandler({ [weak self] () -> Void in
//            self?.editorView.editorTextView.dg_stopLoading()
//            
////            loadingView.observing = false
//            self?.editorView.editorTextView.dg_removePullToRefresh()
//            self?.dis()
//            }, loadingView: loadingView)
//        
//        if let pairColor = AppPairColors(rawValue: note.color)?.pairColor() {
//            self.editorView.editorTextView.dg_setPullToRefreshFillColor(pairColor.dark)
//            self.editorView.editorTextView.dg_setPullToRefreshBackgroundColor(pairColor.light)
//        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.editorView.configNote(content: self.note.content)
    }
    
    func dis() {
        UIView.animate(withDuration: kNoteViewAlphaAnimation, animations: { 
            self.editorView.editorTextView.alpha = 0
        }) { (finish) in
            self.dismiss(animated: true, completion: nil)
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
