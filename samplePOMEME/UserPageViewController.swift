//
//  UserPageViewController.swift
//  samplePOMEME
//
//  Created by 藤澤洋佑 on 2018/12/14.
//  Copyright © 2018年 NEKOKICHI. All rights reserved.
//

import UIKit
import NCMB
import NYXImagesKit
import UITextView_Placeholder

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
    
    //ユーザー
    let user = NCMBUser.current()
    //URLとコメントを持つ配列
    var object = ["",""]
    //配列を格納する配列
    var objects = [[String]]()
    
    //セルの色を格納
    var itemColor = UIColor()
    //NCMBに保存用のセルカラー
    var itemColor_Save = ""
    
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
        //セルの色を取得
        if let _ = user!.object(forKey: "ItemColor") {
            itemColor_Save = user!.object(forKey: "ItemColor") as! String
        } else {
            itemColor_Save = "gray"
        }
        confirmColor2()
        
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
        
        // 仮のサイズでツールバー生成
        let kbToolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 320, height: 40))
        kbToolBar.barStyle = UIBarStyle.default  // スタイルを設定
        kbToolBar.sizeToFit()  // 画面幅に合わせてサイズを変更
        // スペーサー
        let spacer = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: self, action: nil)
        // 閉じるボタン
        let commitButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.done, target: self, action: "commitButtonTapped")
        kbToolBar.items = [spacer, commitButton]
        profileLabel.inputAccessoryView = kbToolBar
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if isEditMode == false {
            
            //取得したユーザーからデータを取得
            if let _ = user!.object(forKey: "Profile") as? String {
                profileLabel.text = (user!.object(forKey: "Profile") as! String)
            }
            
            userID.text = "@" + (user!.userName)!
            
            //SNSのURLを取得
            if let _ = user!.object(forKey: "TwitterURL") as? String {
                twitterURL = user!.object(forKey: "TwitterURL") as! String
                if twitterURL != "" {
                    twitterIcon.alpha = 1.0
                } else {
                    twitterIcon.alpha = 0.5
                }
            }
            
            if let _ = user!.object(forKey: "InstagramURL") as? String {
                instagramURL = user!.object(forKey: "InstagramURL") as! String
                if instagramURL != "" {
                    instagramIcon.alpha = 1.0
                } else {
                    instagramIcon.alpha = 0.5
                }
            }
            
            if let _ = user!.object(forKey: "FacebookURL") as? String {
                facebookURL = user!.object(forKey: "FacebookURL") as! String
                if facebookURL != "" {
                    facebookIcon.alpha = 1.0
                } else {
                    facebookIcon.alpha = 0.5
                }
            }
            
            //アイテムを取得
            let query = NCMBUser.query()
            query?.whereKey("objectId", equalTo: NCMBUser.current().objectId)
            query?.findObjectsInBackground({ (data, error) in
                if error != nil {
                    print(error)
                } else {
                    var users = [NCMBUser]()
                    // 取得した新着50件のユーザーを格納
                    users = data as! [NCMBUser]
                    self.objects = users[0].object(forKey: "Item") as! [[String]]
                    self.tableView.reloadData()
                }
            })
            
            //NCMBから画像を取得
            if let readData_theme = NCMBFile.file(withName: "theme " + NCMBUser.current().objectId, data: nil) as? NCMBFile {
                //テーマ画像を取得
                readData_theme.getDataInBackground { (data, error) in
                    if error != nil {
                        self.themeImage.image = UIImage(named: "icons8-画像-100.png")
                        print(error)
                    } else {
                        self.themeImage.image = UIImage(data: data!)
                    }
                }
            } else {
                //代わりの画像を用意
                self.themeImage.image = UIImage(named: "icons8-画像-100.png")
            }
            
            if let readData_icon = NCMBFile.file(withName: "icon " + NCMBUser.current().objectId, data: nil) as? NCMBFile {
                //アイコン画像を取得
                readData_icon.getDataInBackground { (data, error) in
                    if error != nil {
                        self.iconImage.image = UIImage(named: "icons8-コンタクト-96.png")
                        print(error)
                    } else {
                        self.iconImage.image = UIImage(data: data!)
                    }
                }
            } else {
                //代わりの画像を用意
                self.iconImage.image = UIImage(named: "icons8-コンタクト-96.png")
            }
            
            tableView.reloadData()
        } else {}
        
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return objects.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "userpagecell", for: indexPath) as! UserPageViewCell
        
        //追加するボタンの時
        if objects[indexPath.row][0] == "追加する" {
            cell.linkImageView.backgroundColor = UIColor.blue
            cell.textLabel?.textColor = UIColor.white
            //他の要素の時
        } else {
            //URLの場合
            if objects[indexPath.row][1] != "" {
                cell.textLabel?.textColor = UIColor.white
                cell.linkImageView.backgroundColor = itemColor
                //コメントの場合
            } else {
                cell.textLabel?.textColor = UIColor.black
                cell.linkImageView.backgroundColor = UIColor.white
            }
        }
        //セルにtitlプロパティを代入
        cell.textLabel?.text = objects[indexPath.row][0]
        //セルのテキストを中央揃いにする
        cell.textLabel?.textAlignment = .center
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        //編集画面なら
        if isEditMode == true {
            //"追加する"をタップしたら
            if indexPath.row == objects.count - 1 {
                let alert = UIAlertController(title: "アイテムを追加", message: "どちらを追加しますか?", preferredStyle: .alert)
                let commentAction = UIAlertAction(title: "コメント", style: .default) { (action) in
                    alert.dismiss(animated: true, completion: nil)
                    let commentAlert = UIAlertController(title: "コメントを追加", message: "コメントを入力してください", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: .default, handler: { (action) in
                        //Itemクラスを宣言
                        var object = ["",""]
                        //textFieldを配列に格納
                        guard let textfield:[UITextField] = commentAlert.textFields else {return}
                        //配列からテキストを取り出す
                        for textField in textfield {
                            switch textField.tag {
                            case 1:
                                //textFieldに入力した内容をobjectのcommentプロパティに追加
                                object[0] = textField.text!
                            default: break
                            }
                        }
                        if object[0] != "" {
                            commentAlert.dismiss(animated: true, completion: nil)
                            //objectsにobjectを追加
                            self.objects.insert(object, at: 0)
                            //更新
                            tableView.reloadData()
                        } else {
                            return
                        }
                        
                    })
                    let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel, handler: { (action) in
                        commentAlert.dismiss(animated: true, completion: nil)
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
                        var object = ["",""]
                        //textFieldを配列に格納
                        guard let textfield:[UITextField] = linkAlert.textFields else {return}
                        //配列からテキストを取り出す
                        for textField in textfield {
                            switch textField.tag {
                            case 0:
                                //textFieldに入力した内容をobjectのtitleプロパティに追加
                                object[0] = textField.text!
                            case 1:
                                //textFieldに入力した内容をobjectのプロパティに追加
                                object[1] = textField.text!
                            default: break
                            }
                        }
                        if object[1] != "" && object[0] != "" {
                            //objectsにobjectを追加
                            self.objects.insert(object, at: 0)
                            linkAlert.dismiss(animated: true, completion: nil)
                            //更新
                            tableView.reloadData()
                        } else {
                            return
                        }
                    })
                    let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel, handler: { (action) in
                        linkAlert.dismiss(animated: true, completion: nil)
                        tableView.deselectRow(at: indexPath, animated: true)
                    })
                    //アラートにtextFieldを追加
                    linkAlert.addTextField { (text:UITextField!) in
                        text.placeholder = "URLタイトル"
                        text.tag = 0
                    }
                    linkAlert.addTextField { (text:UITextField!) in
                        text.placeholder = "URLリンク"
                        text.tag = 1
                    }
                    linkAlert.addAction(okAction)
                    linkAlert.addAction(cancelAction)
                    self.present(linkAlert, animated: true, completion: nil)
                }
                alert.addAction(commentAction)
                alert.addAction(linkAction)
                self.present(alert, animated: true, completion: nil)
                //リンクやコメントをタップしたら
            } else {
                let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
                //編集
                let editAction = UIAlertAction(title: "編集", style: .default) { (action) in
                    alert.dismiss(animated: true, completion: nil)
                    let editAlert = UIAlertController(title: "編集する", message: nil, preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: .default, handler: { (action) in
                        //textFieldを配列に格納
                        guard let textfield:[UITextField] = editAlert.textFields else {return}
                        //配列からテキストを取り出す
                        for textField in textfield {
                            switch textField.tag {
                            case 0:
                                //textFieldに入力した内容をobjectのtitleプロパティに追加
                                self.objects[indexPath.row][0] = textField.text!
                            case 1:
                                //textFieldに入力した内容をobjectのプロパティに追加
                                self.objects[indexPath.row][1] = textField.text!
                            case 2:
                                self.objects[indexPath.row][0] = textField.text!
                            default: break
                            }
                        }
                        editAlert.dismiss(animated: true, completion: nil)
                        //更新
                        tableView.reloadData()
                    })
                    let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel, handler: { (action) in
                        editAlert.dismiss(animated: true, completion: nil)
                    })
                    //URLの場合
                    if self.objects[indexPath.row][1] != "" {
                        //アラートにtextFieldを追加
                        editAlert.addTextField { (text:UITextField!) in
                            text.text = self.objects[indexPath.row][0]
                            text.placeholder = "URLタイトル"
                            text.tag = 0
                        }
                        editAlert.addTextField { (text:UITextField!) in
                            text.text = self.objects[indexPath.row][1]
                            text.placeholder = "URLリンク"
                            text.tag = 1
                        }
                        //コメントの場合
                    } else {
                        editAlert.addTextField { (text:UITextField!) in
                            text.text = self.objects[indexPath.row][0]
                            text.placeholder = "コメント"
                            text.tag = 2
                        }
                    }
                    editAlert.addAction(okAction)
                    editAlert.addAction(cancelAction)
                    self.present(editAlert, animated: true, completion: nil)
                }
                //削除
                let deleteAction = UIAlertAction(title: "削除", style: .destructive) { (action) in
                    self.objects.remove(at: indexPath.row)
                    tableView.deleteRows(at: [indexPath], with: .fade)
                }
                //キャンセル
                let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel) { (action) in
                    alert.dismiss(animated: true, completion: nil)
                    tableView.deselectRow(at: indexPath, animated: true)
                }
                alert.addAction(editAction)
                alert.addAction(deleteAction)
                alert.addAction(cancelAction)
                self.present(alert, animated: true, completion: nil)
            }
            //編集画面でないなら
        } else {
            //もしリンクならリンク先を開く
            //アイテム：[[String]]
            //[0]:コメント [1]:リンク
            if objects[indexPath.row][1] != "" {
                openSNSLink(url: objects[indexPath.row][1])
            } else {}
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
        if isEditMode == true {
            alert_sns()
        } else {
            openSNSLink(url: user!.object(forKey: "TwitterURL") as! String)
        }
    }
    
    //instagramのタップジェスチャー
    @IBAction func instagramIconAction(_ sender: UITapGestureRecognizer) {
        name_sns = "instagram"
        if isEditMode == true {
            alert_sns()
        } else {
            openSNSLink(url: user!.object(forKey: "InstagramURL") as! String)
        }
    }
    
    //facebookのタップジェスチャー
    @IBAction func facebookIconAction(_ sender: UITapGestureRecognizer) {
        name_sns = "facebook"
        if isEditMode == true {
            alert_sns()
        } else {
            openSNSLink(url: user!.object(forKey: "FacebookURL") as! String)
        }
    }
    
    
    //"マイページを編集"ボタン
    @IBAction func editUserPage(_ sender: Any) {
        //編集画面ではない時
        if isEditMode == false {
            //"追加する"を表示
            objects.append(["追加する",""])
            //リンクカラーボタンを表示
            linkcolorButton.isHidden = false
            //imageViewをタップ可能にする
            themeImage.isUserInteractionEnabled = true
            iconImage.isUserInteractionEnabled = true
            //３つのSNSボタンをタップ可能にする
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
            objects.remove(at: objects.count - 1)
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
            self.tableView.reloadData()
            //NCMBに画像を保存
            //画像(file)
            let themeImageData = UIImage.pngData(self.themeImage.image!)
            let iconImageData = UIImage.pngData(self.iconImage.image!)
            let themeImageFile = NCMBFile.file(withName: "theme " + NCMBUser.current().objectId, data: themeImageData()) as! NCMBFile
            let iconImageFile = NCMBFile.file(withName: "icon " + NCMBUser.current().objectId, data: iconImageData()) as! NCMBFile
            //テーマ画像を保存
            themeImageFile.saveInBackground({ (error) in
                if error != nil {
                    print(error)
                } else {}
            })
            //アイコン画像を保存
            iconImageFile.saveInBackground({ (error) in
                if error != nil {
                    print(error)
                } else {}
            })
            //アイテムカラー(文字列)を取得
            confirmColor1()
            //NCMBにユーザー情報を保存
            let user = NCMBUser.current()
            user?.setObject(profileLabel.text, forKey: "Profile")
            user?.setObject(twitterURL, forKey: "TwitterURL")
            user?.setObject(instagramURL, forKey: "InstagramURL")
            user?.setObject(facebookURL, forKey: "FacebookURL")
            user?.setObject(objects, forKey: "Item")
            user?.setObject(itemColor_Save, forKey: "ItemColor")
            user?.saveInBackground({ (error) in
                if error != nil {
                    print(error)
                } else {}
            })
            
        }
        
    }
    
    //選択したセルの色(文字列)を取得
    func confirmColor1() {
        switch itemColor {
        case UIColor.black:
            itemColor_Save = "black"
        case UIColor.darkGray:
            itemColor_Save = "darkGray"
        case UIColor.lightGray:
            itemColor_Save = "lightGray"
        case UIColor.gray:
            itemColor_Save = "gray"
        case UIColor.red:
            itemColor_Save = "red"
        case UIColor.green:
            itemColor_Save = "green"
        case UIColor.blue:
            itemColor_Save = "blue"
        case UIColor.cyan:
            itemColor_Save = "cyan"
        case UIColor.yellow:
            itemColor_Save = "yellow"
        case UIColor.magenta:
            itemColor_Save = "magenta"
        case UIColor.orange:
            itemColor_Save = "orange"
        case UIColor.purple:
            itemColor_Save = "purple"
        case UIColor.brown:
            itemColor_Save = "brown"
        default:
            itemColor_Save = "white"
            break
        }
    }
    
    //選択したセルの色（文字列）からセルの色（UIColor）を取得
    func confirmColor2() {
        switch itemColor_Save {
        case "black":
            itemColor = UIColor.black
        case "darkGray":
            itemColor = UIColor.darkGray
        case "lightGray":
            itemColor = UIColor.lightGray
        case "gray":
            itemColor = UIColor.gray
        case "red":
            itemColor = UIColor.red
        case "green":
            itemColor = UIColor.green
        case "blue":
            itemColor = UIColor.blue
        case "cyan":
            itemColor = UIColor.cyan
        case "yellow":
            itemColor = UIColor.yellow
        case "magenta":
            itemColor = UIColor.magenta
        case "orange":
            itemColor = UIColor.orange
        case "purple":
            itemColor = UIColor.purple
        case "brown":
            itemColor = UIColor.brown
        default:
            itemColor = UIColor.white
            break
        }
    }
    
    //SelectColorViewControllerで選択した色を取得
    func recieve(color: UIColor) {
        //取得
        self.itemColor = color
        //tableViewを更新
        tableView.reloadData()
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
    
    //リンクアイテムをsafari経由で開く
    
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
    
    //SNS用のアラート
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
            switch self.name_sns {
            case "twitter":
                text.text = self.twitterURL
            case "instagram":
                text.text = self.instagramURL
            case "facebook":
                text.text = self.facebookURL
            default:
                break
            }
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
        
        //画像を圧縮
        let resizedImage = image.scale(byFactor: 0.4)
        
        //identification_imagePickerの値で分岐
        switch identification_imagePicker {
        case "theme":
            themeImage.image = resizedImage
        case "icon":
            iconImage.image = resizedImage
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
    
    //画像が回転しないように加工
//    func translate(from image: UIImage) -> UIImage? {
//        guard let cgImage1 = image.cgImage else { return nil }
//        let ciImage = CIImage(cgImage: cgImage1)
//        let ciContext = CIContext(options: nil)
//        
//        /* CIImageを使用した画像編集処理 */
//        guard let cgImage2: CGImage = ciContext.createCGImage(image, from: image.extent) else { return nil }
//        let result = UIImage(cgImage: cgImage2, scale: 0.4, orientation: image.imageOrientation)
//        return result
//    }
    
    //ログアウトする際の処理
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
    func commitButtonTapped (){
        self.view.endEditing(true)
    }
}
