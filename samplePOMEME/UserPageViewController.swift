//
//  UserPageViewController.swift
//  samplePOMEME
//
//  Created by 藤澤洋佑 on 2018/12/14.
//  Copyright © 2018年 NEKOKICHI. All rights reserved.
//

import UIKit
import NCMB

class UserPageViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        return cell
    }
    
    //メニューボタン
    @IBAction func menu(_ sender: Any) {
        let alert = UIAlertController(title: "メニュー", message:  nil, preferredStyle: .alert)
        let logoutAction = UIAlertAction(title: "ログアウト", style: .default) { (action) in
            NCMBUser.logOutInBackground({ (error) in
                if error != nil {
                    print("logout error")
                } else {
                    self.syncronize()
                }
            })
        }
        let deleteAction = UIAlertAction(title: "退会", style: .destructive) { (action) in
            let user = NCMBUser.current()
            user?.deleteInBackground({ (error) in
                if error != nil {
                    print("delete error")
                } else {
                    self.syncronize()
                }
            })
        }
        let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel) { (action) in
            alert.dismiss(animated: true, completion: nil)
        }
        alert.addAction(logoutAction)
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    //同期する際の処理
    func syncronize() {
        //storyboardを宣言
        let storyboard = UIStoryboard(name: "SignIN", bundle: Bundle.main)
        let next = storyboard.instantiateViewController(withIdentifier: "signin")
        next.modalTransitionStyle = .crossDissolve
        self.present(next, animated: true, completion: nil)
        //ログイン状態を解除
        let ud = UserDefaults.standard
        ud.set(false, forKey: "isLogin")
        ud.synchronize()
    }
    
}
