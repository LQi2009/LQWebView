//
//  ViewController.swift
//  LQWebViewSwift
//
//  Created by LiuQiqiang on 2018/9/17.
//  Copyright © 2018年 LiuQiqiang. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let start = UIButton(type: .custom)
        
        start.frame = CGRect(x: 40, y: 40, width: 100, height: 40)
        start.backgroundColor = UIColor.red
        start.addTarget(self, action: #selector(startAction), for: .touchUpInside)
        
        self.view.addSubview(start)
    }
    
    @objc func startAction() {
        let test = TestViewController()
        self.present(test, animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

