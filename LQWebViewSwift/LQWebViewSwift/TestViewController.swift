//
//  TestViewController.swift
//  LQWebViewSwift
//
//  Created by LiuQiqiang on 2018/9/21.
//  Copyright © 2018年 LiuQiqiang. All rights reserved.
//

import UIKit

class TestViewController: UIViewController, LQWebViewDelegate {

    var webView: LQWebView = LQWebView()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        webView.frame = self.view.bounds
        self.view .addSubview(webView)
//
//        webView.delegate = self
        webView.loadURLString("https://www.baidu.com")
//        webView.loadLocakFile("test.pdf")
        let back = UIButton(type: .custom)
        
        back.frame = CGRect(x: 40, y: 40, width: 100, height: 40)
        back.backgroundColor = UIColor.red
        back.addTarget(self, action: #selector(backAction), for: .touchUpInside)

        self.view.addSubview(back)
        // Do any additional setup after loading the view.
    }
    

    @objc func backAction() {
        self.dismiss(animated: true, completion: nil)
    }
    
    deinit {
        print("deinit")
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
