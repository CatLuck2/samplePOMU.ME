//
//  UserPageViewController.swift
//  samplePOMEME
//
//  Created by 藤澤洋佑 on 2018/12/14.
//  Copyright © 2018年 NEKOKICHI. All rights reserved.
//

import UIKit
import NCMB

class UserPageViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIGestureRecognizerDelegate  {
    
    //imagePickerControllerのタップイベント
    
    //alertのタップイベント
    
    //imagePickerControllerの起動元を判別
    var identification_imagePicker = ""
    
    //セルの内容を格納する配列
    let cellArray = ["1","2","3","4","5","1","2","3","4","5","1","2"]
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var themeImage: UIImageView!
    
    @IBOutlet weak var iconImage: UIImageView!
    
    @IBOutlet weak var userID: UILabel!
    
    @IBOutlet weak var linkcolorButton: UIButton!
    
    @IBOutlet weak var profileLabel: UITextView!
    
    @IBOutlet weak var twitterIcon: UIImageView!
    
    @IBOutlet weak var instagramIcon: UIImageView!
    
    @IBOutlet weak var facebookIcon: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //リンクカラーボタンを非表示に
        linkcolorButton.isHidden = true

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
        
        //UserPageViewCellを登録
        tableView.register(UINib(nibName: "UserPageViewCell", bundle: Bundle.main), forCellReuseIdentifier: "userpagecell")
        //tableViewのセルの高さを設定
        tableView.estimatedRowHeight = 72
        tableView.rowHeight = 72
        //tableViewの不要なセルを削除
        tableView.tableFooterView = UIView()
        
        //GestureRecognizerのDelegate
        themeImage.isUserInteractionEnabled = false
        iconImage.isUserInteractionEnabled = false
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cellArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "userpagecell", for: indexPath)
        cell.textLabel?.text = cellArray[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    //マイページを編集
    @IBAction func editUserPage(_ sender: Any) {
        
        //リンクカラーボタンを表示
        linkcolorButton.isHidden = false
        //２つのImageViewにタップジェスチャーを追加
        themeImage.isUserInteractionEnabled = true
        iconImage.isUserInteractionEnabled = true
        self.themeImage.addGestureRecognizer(UIGestureRecognizer(target: self, action: #selector(UserPageViewController.album(_:))))
        self.iconImage.addGestureRecognizer(UIGestureRecognizer(target: self, action: #selector(UserPageViewController.album(_:))))
        //３つのSNSリンクボタンにタップジェスチャーを追加
        
        //profileを編集可能に
        profileLabel.isEditable = true
        //tableView
    }
    
    //リンクカラーを設定
    @IBAction func linkcolorButton(_ sender: Any) {
    }
    
    //どのimageをタップしたかを検出
//    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
//        print("1")
//        //Viewタップしたか
//        guard touch.view != nil else {
//            print("tap error")
//            return false
//        }
//        print("2")
//        if touch.view!.viewWithTag(1) != nil {
//            identification_imagePicker = "theme"
//            return true
//        } else if touch.view!.viewWithTag(2) != nil {
//            identification_imagePicker = "icon"
//            return true
//        }
//
//        //themeImage,iconImageのどっちをタップした?
////        switch touch.view?.viewWithTag() {
////        case themeImage:
////            identification_imagePicker = "theme"
////            return true
////        case iconImage:
////            identification_imagePicker = "icon"
////            return true
////        default:
////            break
////        }
//
//        return false
//    }
    
    
    
    //アルバムを起動
    @objc func album(_ sender: UITapGestureRecognizer) {
        print(1)
        //SourceType.camera：カメラを指定
        let sourceType:UIImagePickerController.SourceType
            = UIImagePickerController.SourceType.photoLibrary
        //アルバムを立ち上げる
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.photoLibrary){
            // インスタンスの作成
            let cameraPicker = UIImagePickerController()
            cameraPicker.sourceType = sourceType
            cameraPicker.delegate = self
            //アルバム画面を開く
            self.present(cameraPicker, animated: true, completion: nil)
        }
    }
    
    //アルバムで画像を選択したら
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        //選択した画像を取得
        let image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        
        //identification_imagePickerの値で分岐
        switch identification_imagePicker {
        case "theme":
            themeImage.image = image
        case "icon":
            iconImage.image = image
        default:
            break
        }
        
        //アルバム画面を閉じる
        picker.dismiss(animated: true, completion: nil)
        
    }
    
    
    //メニューボタン
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
    
    //同期する際の処理
    func syncronize() {
        //storyboardを宣言
        let storyboard = UIStoryboard(name: "SignIN", bundle: Bundle.main)
        let next = storyboard.instantiateViewController(withIdentifier: "signin")
        next.modalTransitionStyle = .crossDissolve
        self.present(next, animated: true, completion: nil)
        //ログイン状態を解除
        let ud = UserDefaults.standard
        ud.set(false, forKey: "LoginStatus")
        ud.synchronize()
    }
    
}
