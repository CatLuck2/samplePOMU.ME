//
//  UserPageViewController.swift
//  samplePOMEME
//
//  Created by 藤澤洋佑 on 2018/12/14.
//  Copyright © 2018年 NEKOKICHI. All rights reserved.
//

import UIKit
import NCMB

class UserPageViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,UITextViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIGestureRecognizerDelegate  {
    
    //imagePickerControllerの起動元を判別
    var identification_imagePicker = ""
    
    //データベース保存用のSNSURL
    var twitterURL = ""
    var instagramURL = ""
    var facebookURL = ""
    
    //編集画面かを識別する
    //true:編集画面,false:マイページ
    var isEditMode = false
    
    //タップしたSNSを識別する
    var name_sns = ""
    
    //URLとコメントを持つItemクラス
    var object = Item()
    //Itemクラスを格納する配列
    var objects = [Item]()
    
    //セルの色を格納
    var cell_color:UIColor = UIColor.white
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var themeImage: UIImageView!
    @IBOutlet weak var iconImage: UIImageView!
    @IBOutlet weak var userID: UILabel!
    @IBOutlet weak var linkcolorButton: UIButton!
    @IBOutlet weak var profileLabel: UITextView!
    @IBOutlet weak var twitterIcon: UIImageView!
    @IBOutlet weak var instagramIcon: UIImageView!
    @IBOutlet weak var facebookIcon: UIImageView!
    @IBOutlet weak var editUserPage: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //objectsを初期化
        object.link = ""
        object.title = "追加する"
        objects.append(object)
        
        //リンクカラーボタンを非表示に
        linkcolorButton.isHidden = true
        
        //プロフィール文のデリゲート
        profileLabel.delegate = self

        //アイコン
        iconImage.layer.cornerRadius = 50
        iconImage.layer.borderWidth = 0.5
        iconImage.layer.masksToBounds = true
        //Twitterアイコン
        twitterIcon.layer.cornerRadius = 40
        twitterIcon.layer.borderWidth = 0.5
        twitterIcon.layer.masksToBounds = true
        //instagramアイコン
        instagramIcon.layer.cornerRadius = 40
        instagramIcon.layer.borderWidth = 0.5
        instagramIcon.layer.masksToBounds = true
        //facebookアイコン
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
        
        //imagePicker用のタップジェスチャー
        let imageGesture = UIGestureRecognizer(target: self, action: #selector(UserPageViewController.themeImageAction(_:)))
        imageGesture.delegate = self
        //Alert用のタップジェスチャー
        let alertGesture = UIGestureRecognizer(target: self, action: #selector(UserPageViewController.themeImageAction(_:)))
        alertGesture.delegate = self
        //２つのimageViewにタップジェスチャーを追加
        self.themeImage.addGestureRecognizer(imageGesture)
        self.iconImage.addGestureRecognizer(imageGesture)
        //３つのSNSボタンにタップジェスチャーを追加
        self.twitterIcon.addGestureRecognizer(alertGesture)
        self.instagramIcon.addGestureRecognizer(alertGesture)
        self.facebookIcon.addGestureRecognizer(alertGesture)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //更新
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return objects.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "userpagecell", for: indexPath)
        //マイページの時は非常時、編集モードなら表示する
        if isEditMode == false && objects.count - 1 == indexPath.row {
            return cell
        } else {
            if objects[indexPath.row].title == "追加する" {
                cell.contentView.backgroundColor = UIColor.blue
            } else {
                //URLの場合
                if objects[indexPath.row].link != "" {
                    cell.contentView.backgroundColor = cell_color
                    cell.backgroundColor = cell_color
                    //コメントの場合
                } else {
                    cell.contentView.backgroundColor = UIColor.white
                }
            }
            cell.textLabel?.text = objects[indexPath.row].title
            cell.textLabel?.textAlignment = .center
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //編集画面なら
        if isEditMode == true {
            //"追加する"をタップしたら
            if indexPath.row == objects.count - 1 {
                let alert = UIAlertController(title: "アイテムを追加", message: "どちらを追加しますか?", preferredStyle: .alert)
                let commentAction = UIAlertAction(title: "コメント", style: .default) { (action) in
                    alert.dismiss(animated: true, completion: nil)
                    let commentAlert = UIAlertController(title: "コメントを追加", message: "コメントを入力してください", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: .default, handler: { (action) in
                        //textFieldを配列に格納
                        guard let textfield:[UITextField] = commentAlert.textFields else {return}
                        //配列からテキストを取り出す
                        for textField in textfield {
                            switch textField.tag {
                            case 1:
                                //Itemクラスを宣言
                                let objectItem = Item()
                                //textFieldに入力した内容をobjectのcommentプロパティに追加
                                objectItem.title = textField.text!
                                //objectsにobjectを追加
                                self.objects.insert(objectItem, at: 0)
                            default: break
                            }
                        }
                        commentAlert.dismiss(animated: true, completion: nil)
                        //更新
                        tableView.reloadData()
                    })
                    let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel, handler: { (action) in
                        commentAlert.dismiss(animated: true, completion: nil)
                        tableView.deselectRow(at: indexPath, animated: true)
                    })
                    //アラートにtextFieldを追加
                    commentAlert.addTextField { (text:UITextField!) in
                        text.placeholder = "コメント"
                        text.tag = 1
                    }
                    commentAlert.addAction(okAction)
                    commentAlert.addAction(cancelAction)
                    self.present(commentAlert, animated: true, completion: nil)
                }
                let linkAction = UIAlertAction(title: "リンク", style: .default) { (action) in
                    alert.dismiss(animated: true, completion: nil)
                    let linkAlert = UIAlertController(title: "リンクを追加", message: "タイトルとURLを入力してください", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: .default, handler: { (action) in
                        //Itemクラスを宣言
                        let objectItem = Item()
                        //textFieldを配列に格納
                        guard let textfield:[UITextField] = linkAlert.textFields else {return}
                        //配列からテキストを取り出す
                        for textField in textfield {
                            switch textField.tag {
                            case 1:
                                //textFieldに入力した内容をobjectのtitleプロパティに追加
                                objectItem.link = textField.text!
                            case 2:
                                //textFieldに入力した内容をobjectのプロパティに追加
                                objectItem.title = textField.text!
                            default: break
                            }
                        }
                        //objectsにobjectを追加
                        self.objects.insert(objectItem, at: 0)
                        linkAlert.dismiss(animated: true, completion: nil)
                        //更新
                        tableView.reloadData()
                    })
                    let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel, handler: { (action) in
                        linkAlert.dismiss(animated: true, completion: nil)
                        tableView.deselectRow(at: indexPath, animated: true)
                    })
                    //アラートにtextFieldを追加
                    linkAlert.addTextField { (text:UITextField!) in
                        text.placeholder = "URLリンク"
                        text.tag = 1
                    }
                    linkAlert.addTextField { (text:UITextField!) in
                        text.placeholder = "URLタイトル"
                        text.tag = 2
                    }
                    linkAlert.addAction(okAction)
                    linkAlert.addAction(cancelAction)
                    self.present(linkAlert, animated: true, completion: nil)
                }
                alert.addAction(commentAction)
                alert.addAction(linkAction)
                self.present(alert, animated: true, completion: nil)
            //既に追加された要素をタップしたら
            } else {
                let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
                //編集
                let editAction = UIAlertAction(title: "編集", style: .default) { (action) in
//                    let editAlert = UIAlertController(title: ", message: <#T##String?#>, preferredStyle: <#T##UIAlertController.Style#>)
                }
                //削除
                let deleteAction = UIAlertAction(title: "削除", style: .default) { (action) in
                    self.objects.remove(at: indexPath.row)
                    tableView.deleteRows(at: [indexPath], with: .fade)
                }
                //キャンセル
                let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel) { (action) in
                    alert.dismiss(animated: true, completion: nil)
                    tableView.deselectRow(at: indexPath, animated: true)
                }
//                alert.addAction(editAction)
                alert.addAction(deleteAction)
                alert.addAction(cancelAction)
                self.present(alert, animated: true, completion: nil)
            }
        //編集画面でないなら
        } else {
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    //themeImageViewのタップジェスチャー
    @objc @IBAction func themeImageAction(_ sender: UITapGestureRecognizer) {
        identification_imagePicker = "theme"
        album()
    }
    
    //IconImageViewのタップジェスチャー
    @IBAction func iconImageAction(_ sender: UITapGestureRecognizer) {
        identification_imagePicker = "icon"
        album()
    }
    
    //twitterのタップジェスチャー
    @IBAction func twitterIconAction(_ sender: UITapGestureRecognizer) {
        name_sns = "twitter"
        alert_sns()
    }
    
    //instagramのタップジェスチャー
    @IBAction func instagramIconAction(_ sender: UITapGestureRecognizer) {
        name_sns = "instagram"
        alert_sns()
    }
    
    //facebookのタップジェスチャー
    @IBAction func facebookIconAction(_ sender: UITapGestureRecognizer) {
        name_sns = "facebook"
        alert_sns()
    }
    
    
    //"マイページを編集"ボタン
    @IBAction func editUserPage(_ sender: Any) {
        //編集画面ではない時
        if isEditMode == false {
            //リンクカラーボタンを表示
            linkcolorButton.isHidden = false
            //imageViewをタップ可能にする
            themeImage.isUserInteractionEnabled = true
            iconImage.isUserInteractionEnabled = true
            //３つのSNSをタップ可能にする
            twitterIcon.isUserInteractionEnabled = true
            instagramIcon.isUserInteractionEnabled = true
            facebookIcon.isUserInteractionEnabled = true
            //profileを編集可能に
            profileLabel.isEditable = true
            //tableView
            //"マイページを保存する"の表示を変更
            editUserPage.setTitle("マイページを保存", for: .normal)
            isEditMode = true
            //更新
            tableView.reloadData()
        //編集画面の時
        } else {
            linkcolorButton.isHidden = true
            themeImage.isUserInteractionEnabled = false
            iconImage.isUserInteractionEnabled = false
            //３つのSNSリンクボタンにタップジェスチャーを追加
            twitterIcon.isUserInteractionEnabled = false
            instagramIcon.isUserInteractionEnabled = false
            facebookIcon.isUserInteractionEnabled = false
            profileLabel.isEditable = false
            editUserPage.setTitle("マイページを編集", for: .normal)
            isEditMode = false
            //更新
            tableView.reloadData()
        }
        
    }
    
    //SelectColorViewControllerで選択した色を取得
    func recieve(color: UIColor) {
        //取得
        self.cell_color = color
        //tableViewを更新
        tableView.reloadData()
    }
    
    //アルバムを起動する
    func album() {
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
    
    //アラームを起動
    func alert_sns() {
        let alert = UIAlertController(title: "リンクを追加", message:  "\(name_sns)のURLを入力してください", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { (action) in
            //textFieldを配列に格納
            guard let textfield:[UITextField] = alert.textFields else {return}
            //配列からテキストを取り出す
            for textField in textfield {
                switch textField.tag {
                case 1:
                    switch self.name_sns {
                    case "twitter":
                        self.twitterURL = textField.text!
                    case "instagram":
                        self.instagramURL = textField.text!
                    case "facebook":
                        self.facebookURL = textField.text!
                    default:
                        break
                    }
                default:
                    break
                }
            }
        }
        let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel) { (action) in
            alert.dismiss(animated: true, completion: nil)
        }
        alert.addTextField { (text:UITextField!) in
            text.placeholder = "\(self.name_sns)のURL"
            text.tag = 1
        }
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
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
        //ログアウト
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
        //退会
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
    
    //キーボードを閉じる
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        textView.resignFirstResponder()
        return true
    }
    
}
