//
//  SelectColorViewController.swift
//  samplePOMEME
//
//  Created by 藤澤洋佑 on 2018/12/19.
//  Copyright © 2018年 NEKOKICHI. All rights reserved.
//

import UIKit

class SelectColorViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    //セルの色
    let color:[UIColor] = [UIColor.black,
                           UIColor.darkGray,
                           UIColor.lightGray,
                           UIColor.gray,
                           UIColor.red,
                           UIColor.green,
                           UIColor.blue,
                           UIColor.cyan,
                           UIColor.yellow,
                           UIColor.magenta,
                           UIColor.orange,
                           UIColor.purple,
                           UIColor.brown]
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return color.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "selectcell", for: indexPath)
        cell.textLabel?.backgroundColor = color[indexPath.row]
        cell.backgroundColor = color[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let nav = self.navigationController
        // 一つ前のViewControllerを取得する
        let upvc = nav?.viewControllers[0] as! UserPageViewController
        // 値を渡す
        upvc.recieve(color: color[indexPath.row])
        // popする
        _ = navigationController?.popViewController(animated: true)
    }
    
}
