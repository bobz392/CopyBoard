
//
//  HelperViewController.swift
//  CopyBoard
//
//  Created by zhoubo on 2017/10/8.
//  Copyright © 2017年 zhoubo. All rights reserved.
//

import UIKit
import WebKit

class HelperViewController: UIViewController {

    let settingType: SettingType
    let webView: WKWebView
    
    init(settingType: SettingType) {
        self.settingType = settingType
        webView = WKWebView()
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.view.addSubview(self.webView)
        self.title = Localized("help")
        webView.snp.makeConstraints { (maker) in
            maker.top.left.right.bottom.equalToSuperview()
        }
        webView.scrollView.bounces = true
        
        let button = UIButton(type: .system)
        button.tintColor = UIColor.black
        button.setImage(UIImage(named: "big_clear"), for: .normal)
        button.frame = CGRect(origin: .zero, size: CGSize(width: 32, height: 32))
        button.addTarget(self, action: #selector(self.quit), for: .touchUpInside)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: button)
        
        let helpName: String
        switch (self.settingType) {
        case .helpCreate:
            helpName = "helpCreate"
        case .helpDelete:
            helpName = "helpDelete"
        case .helpCatagory:
            helpName = "helpCatagory"
        case .helpShare:
            helpName = "helpShare"
        case .helpCheck:
            helpName = "helpCheck"
        case .helpLineCount:
            helpName = "helpLineCount"
        case .helpColor:
            helpName = "helpColor"
        case .helpCopy:
            helpName = "helpCopy"
        default:
            helpName = ""
        }
        if let url = Bundle.main.url(forResource: helpName, withExtension: "mov") {
            let folderUrl = URL(fileURLWithPath: Bundle.main.bundlePath, isDirectory: true)
            webView.loadFileURL(url, allowingReadAccessTo: folderUrl)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
//        UIApplication.shared.setStatusBarHidden(true, with: .none)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
//        UIApplication.shared.setStatusBarHidden(false, with: .none)
    }
    
    @objc func quit() {
        self.dismiss(animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
