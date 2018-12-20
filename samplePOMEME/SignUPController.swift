//
//  SignUPController.swift
//  samplePOMEME
//
//  Created by 藤澤洋佑 on 2018/12/14.
//  Copyright © 2018年 NEKOKICHI. All rights reserved.
//

import UIKit
import NCMB
import SVProgressHUD

class SignUPController: UIViewController,UITextFieldDelegate {
    
    @IBOutlet weak var userName: UITextField!
    @IBOutlet weak var passWord: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func createNewAccount(_ sender: Any) {
        //ユーザー情報を保存
        //NCMBUserのインスタンス
        let user = NCMBUser()
        //ユーザー名を登録
        user.userName = userName.text
        //パスワードを登録
        user.password = passWord.text
        
        //既に新規登録したか確認
        //既に登録した
        if let _ = NCMBUser.current() {
            //"既にログインしてます"と通知
            return
        //まだ登録してないor未ログイン中
        } else {
            //ユーザー情報を登録
            if userName.text != nil && passWord.text != nil {
                user.signUpInBackground { (error) in
                    if error != nil {
                        //データ保存のエラー
                        SVProgressHUD.showError(withStatus: error!.localizedDescription)
                        //ポップアップを削除
                        SVProgressHUD.dismiss(withDelay: 1.0)
                        return
                    } else {
                        //ログイン状態をログイン中にする
                        let ud = UserDefaults.standard
                        ud.set(true, forKey: "LoginStatus")
                        ud.synchronize()
                        //Main.StoryBoardに遷移
                        self.transitionView("Main", "tabbar", .crossDissolve)
                    }
                }
            } else {
                //入力されてない箇所があることを通知
                self.alert()
            }
        }
    }
    
    @IBAction func login(_ sender: Any) {
        transitionView("SignIN", "signin", .flipHorizontal)
    }
    
    //Storyboardに遷移する関数
    func transitionView(_ name:String, _ storyboardID:String, _ style:UIModalTransitionStyle) {
        //storyboardを宣言
        let storyboard = UIStoryboard(name: name, bundle: Bundle.main)
        let next = storyboard.instantiateViewController(withIdentifier: storyboardID)
        next.modalTransitionStyle = style
        self.present(next, animated: true, completion: nil)
    }
    
    //アラート
    func alert() {
        let alert = UIAlertController(title: "入力されてない箇所があります。", message:  nil, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .cancel) { (action) in
            alert.dismiss(animated: true, completion: nil)
        }
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        userName.resignFirstResponder()
        passWord.resignFirstResponder()
    }
    
}
