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
        
        self.editorView.config(withView: self.view)
//        self.editorView.configNote(content: self.note.content)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.dis))
        self.view.addGestureRecognizer(tap)
        
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
