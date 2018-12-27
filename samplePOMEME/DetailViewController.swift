//
//  DetailViewController.swift
//  samplePOMEME
//
//  Created by 藤澤洋佑 on 2018/12/17.
//  Copyright © 2018年 NEKOKICHI. All rights reserved.
//

import UIKit
import NCMB

class DetailViewController: UIViewController,UITableViewDataSource,UITableViewDelegate {
    
    //セルの内容を格納
    let cellArray = ["1"]
    
    //ObjectIDを取得
    var objectID = ""
    
    //ページ用のSNSURL
    var twitterURL = ""
    var instagramURL = ""
    var facebookURL = ""
    
    //NCMBUser用の配列
    var user = NCMBUser()
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var themeImage: UIImageView!
    @IBOutlet weak var iconImage: UIImageView!
    @IBOutlet weak var userID: UILabel!
    @IBOutlet weak var profileText: UITextView!
    @IBOutlet weak var twitterIcon: UIImageView!
    @IBOutlet weak var instagramIcon: UIImageView!
    @IBOutlet weak var facebookIcon: UIImageView!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(user)
        
        //角丸
        iconImage.layer.cornerRadius = 50
        //枠線
        iconImage.layer.borderWidth = 0.5
        //調整
        iconImage.layer.masksToBounds = true
        twitterIcon.layer.cornerRadius = 40
        twitterIcon.layer.borderWidth = 0.5
        twitterIcon.layer.masksToBounds = true
        instagramIcon.layer.cornerRadius = 40
        instagramIcon.layer.borderWidth = 0.5
        instagramIcon.layer.masksToBounds = true
        facebookIcon.layer.cornerRadius = 40
        facebookIcon.layer.borderWidth = 0.5
        facebookIcon.layer.masksToBounds = true

        //DetailViewCellを設定
        tableView.register(UINib(nibName: "DetailViewCell", bundle: Bundle.main), forCellReuseIdentifier: "detailcell")
        //tableViewのセルの高さを設定
        tableView.estimatedRowHeight = 72
        tableView.rowHeight = 72
        //tableViewの不要なセルを削除
        tableView.tableFooterView = UIView()
        
        //SNS用のタップジェスチャー
//        let twitterGesture = UIGestureRecognizer(target: self, action: #selector(DetailViewController.openSNSLink(_:)))
//        twitterGesture.delegate = self
//        let instagramGesture = UIGestureRecognizer(target: self, action: #selector(UserPageViewController.themeImageAction(_:)))
//        instagramGesture.delegate = self
//        let facebookGesture = UIGestureRecognizer(target: self, action: #selector(UserPageViewController.themeImageAction(_:)))
//        facebookGesture.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //取得したユーザーからデータを取得
        profileText.text = (user.object(forKey: "Profile") as! String)
        
        userID.text = "@" + (user.userName)!
        
        //SNSのURLを取得
        twitterURL = user.object(forKey: "TwitterURL") as! String
        if twitterURL != "" {
            twitterIcon.alpha = 1.0
        } else {
            twitterIcon.alpha = 0.5
        }
        instagramURL = user.object(forKey: "InstagramURL") as! String
        if instagramURL != "" {
            instagramIcon.alpha = 1.0
        } else {
            instagramIcon.alpha = 0.5
        }
        facebookURL = user.object(forKey: "FacebookURL") as! String
        if facebookURL != "" {
            facebookIcon.alpha = 1.0
        } else {
            facebookIcon.alpha = 0.5
        }
        
        //NCMBから画像を取得
        if let readData_theme = NCMBFile.file(withName: "theme " + user.objectId, data: nil) as? NCMBFile {
            //テーマ画像を取得
            readData_theme.getDataInBackground { (data, error) in
                if error != nil {
                    print(error)
                } else {
                    self.themeImage.image = UIImage(data: data!)
                }
            }
        } else {
            //代わりの画像を用意
            self.themeImage.image = UIImage(named: "icons8-コンタクト-45.png")
        }
        
        if let readData_icon = NCMBFile.file(withName: "icon " + user.objectId, data: nil) as? NCMBFile {
            //アイコン画像を取得
            readData_icon.getDataInBackground { (data, error) in
                if error != nil {
                    print(error)
                } else {
                    self.iconImage.image = UIImage(data: data!)
                }
            }
        } else {
            //代わりの画像を用意
            self.iconImage.image = UIImage(named: "icons8-コンタクト-45.png")
        }
        //更新
        tableView.reloadData()
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cellArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "detailcell", for: indexPath)
        cell.textLabel?.text = cellArray[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    @IBAction func menu(_ sender: Any) {
        let alert = UIAlertController(title: "メニュー", message:  nil, preferredStyle: .alert)
        let logoutAction = UIAlertAction(title: "ログアウト", style: .default) { (action) in
            NCMBUser.logOutInBackground({ (error) in
                if error != nil {
                    print("logout error")
                } else {
                    //ログアウト
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
                    //ログアウト
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
    
    //各SNSのジェスチャー
    //Twitter
    @IBAction func tapGesture_twitter(_ sender: UITapGestureRecognizer) {
        openSNSLink(url: user.object(forKey: "TwitterURL") as! String)
    }
    //Instagram
    @IBAction func tapGesture_instagram(_ sender: UITapGestureRecognizer) {
        openSNSLink(url: user.object(forKey: "InstagramURL") as! String)
    }
    //Facebook
    @IBAction func tapGesture_facebook(_ sender: UITapGestureRecognizer) {
        openSNSLink(url: user.object(forKey: "FacebookURL") as! String)
    }
    
    //SNSのリンクをsafari経由で開く
    @objc func openSNSLink(url:String) {
        //http,httpsかを確認
        if url.prefix(7) == "http://" || url.prefix(8) == "https://" {
            //文字列をURLに変換
            let url = URL(string: url)!
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
            }
        } else {}
    }
    
    //同期する際の処理
    func syncronize() {
        //storyboardを宣言
        let storyboard = UIStoryboard(name: "SignIN", bundle: Bundle.main)
        let next = storyboard.instantiateViewController(withIdentifier: "signin") as! SignINController
        next.modalTransitionStyle = .crossDissolve
        self.present(next, animated: true, completion: nil)
        //ログイン状態を解除
        let ud = UserDefaults.standard
        ud.set(false, forKey: "LoginStatus")
        ud.synchronize()
    }
    
}
