//
//  SignINController.swift
//  samplePOMEME
//
//  Created by 藤澤洋佑 on 2018/12/14.
//  Copyright © 2018年 NEKOKICHI. All rights reserved.
//

import UIKit
import NCMB
import SVProgressHUD

class SignINController: UIViewController {
    
    @IBOutlet weak var userName: UITextField!
    @IBOutlet weak var passWord: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func remenberUserName(_ sender: Any) {
        self.alert("あなたのユーザー名", (NCMBUser.current()?.userName)!)
    }
    
    @IBAction func remenberPassWord(_ sender: Any) {
    }
    
    @IBAction func signUp(_ sender: Any) {
        transitionView("SignUP", "signup", .flipHorizontal)
    }
    
    @IBAction func signIn(_ sender: Any) {
        //２つのtextFieldには値が入力されている？
        if userName.text != nil && passWord.text != nil {
            //データベースと照合
            NCMBUser.logInWithUsername(inBackground: userName.text, password: passWord.text) { (result,error) in
                if error != nil {
                    //データ保存のエラー
                    SVProgressHUD.showError(withStatus: error!.localizedDescription)
                    //ポップアップを削除
                    SVProgressHUD.dismiss(withDelay: 1.0)
                } else {
                    let ud = UserDefaults.standard
                    ud.set(true, forKey: "LoginStatus")
                    ud.synchronize()
                    //Main.StoryBoardに遷移
                    self.transitionView("Main", "tabbar", .crossDissolve)
                }
            }
        } else {
            //一致しないことを通知
            self.alert("入力されてない箇所があります。","OK")
        }
    }
    
    //画面遷移の関数
    func transitionView(_ name:String, _ storyboardID:String, _ style:UIModalTransitionStyle) {
        //storyboardを宣言
        let storyboard = UIStoryboard(name: name, bundle: Bundle.main)
        let next = storyboard.instantiateViewController(withIdentifier: storyboardID)
        next.modalTransitionStyle = style
        self.present(next, animated: true, completion: nil)
    }
    
    //アラート
    func alert(_ title1:String, _ title2:String) {
        let alert = UIAlertController(title: title1, message:  nil, preferredStyle: .alert)
        let okAction = UIAlertAction(title: title2, style: .cancel) { (action) in
            alert.dismiss(animated: true, completion: nil)
        }
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }

}
