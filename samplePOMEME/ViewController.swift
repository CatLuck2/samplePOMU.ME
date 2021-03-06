//
//  ViewController.swift
//  samplePOMEME
//
//  Created by 藤澤洋佑 on 2018/12/14.
//  Copyright © 2018年 NEKOKICHI. All rights reserved.
//
/*
 
 ViewController:ホーム画面(他ユーザーのページが表示される)
 DetailViewController:他ユーザーのマイページ
 UserPageController:マイページ
 ContactViewController:お問い合わせ
 SignUPController:新規登録
 SignINController:ログイン
 UserPageViewCell:マイページのカスタムセル
 TimeLineViewCellホーム画面のカスタムセル
 
 
 「今見つかっているエラー」
 ・アイコン、テーマで表示したい画像を選択したら、①選択した画像②既に保存された画像、の順に表示される
    ・マイページ画面を再び開くと、更新される
    ・didfinish → ViewWillAppaer なのに
 
 ・画像が回転した状態で表示される
 
 ・アイテムの色を取得できない
    ・UIColorをStringに変換できても、StringをUIColorに変換できない
 
 ・NCMBからNCMBUserを取得できない
 
 */

import UIKit
import NCMB

class ViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate {
    
    //NCMBUser配列の宣言
    var users = [NCMBUser]()
    
    //検索バーの宣言
    var searchBar: UISearchBar!
    
    //インジケーター
    let reflesh = UIRefreshControl()
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //検索バーを設置
        setSearchBar()
        
        //NCMBからデータ取得
        loadUsers(searchText: nil)
        
        tableView.register(UINib(nibName: "TimeLineViewCell", bundle: Bundle.main), forCellReuseIdentifier: "timelinecell")
        //tableViewのセルの高さを設定
        tableView.estimatedRowHeight = 80
        tableView.rowHeight = 80
        tableView.tableFooterView = UIView()
        
        reflesh.tintColor = UIColor.green
        reflesh.attributedTitle = NSAttributedString(string: "更新")
        reflesh.addTarget(self, action: #selector(update), for: .valueChanged)
        tableView.refreshControl = reflesh
        
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "timelinecell", for: indexPath) as! TimeLineViewCell
        
        //ユーザー名を取得
        if let _ = users[indexPath.row].userName {
            
            cell.userName.text = "@" + users[indexPath.row].userName
        }
        //アイコン画像を取得
        if let readData_icon = NCMBFile.file(withName: "icon " + users[indexPath.row].objectId, data: nil) as? NCMBFile {
            readData_icon.getDataInBackground { (data, error) in
                if error != nil {
                    print(error)
                } else {
                    cell.iconImageView.image = UIImage(data: data!)
                }
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //DetailViewControllerのインスタンス
        let DVC = storyboard?.instantiateViewController(withIdentifier: "godetail") as! DetailViewController
        //選択したNCMBUserを渡す
        DVC.user = users[indexPath.row]
        self.navigationController?.pushViewController(DVC, animated: true)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    //メニューボタン
    @IBAction func logout(_ sender: Any) {
        let alert = UIAlertController(title: "メニュー", message:  nil, preferredStyle: .alert)
        let logoutAction = UIAlertAction(title: "ログアウト", style: .default) { (action) in
            NCMBUser.logOutInBackground({ (error) in
                if error != nil {
                    print(error)
                } else {
                    self.syncronize()
                }
            })
        }
        let deleteAction = UIAlertAction(title: "退会", style: .destructive) { (action) in
            let user = NCMBUser.current()
            user?.deleteInBackground({ (error) in
                if error != nil {
                    print(error)
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
    
    //検索バーの設置
    func setSearchBar() {
        // NavigationBarにSearchBarをセット
        if let navigationBarFrame = self.navigationController?.navigationBar.bounds {
            //NavigationBarに適したサイズの検索バーを設置
            let searchBar: UISearchBar = UISearchBar(frame: navigationBarFrame)
            //デリゲート
            searchBar.delegate = self
            //プレースホルダー
            searchBar.placeholder = "ユーザーを検索"
            //検索バーのスタイル
            searchBar.autocapitalizationType = UITextAutocapitalizationType.none
            //NavigationTitleが置かれる場所に検索バーを設置
            navigationItem.titleView = searchBar
            //NavigationTitleのサイズを検索バーと同じにする
            navigationItem.titleView?.frame = searchBar.frame
            //NavigationBarにセット
            self.searchBar = searchBar
        }
    }
    
    //検索バーで入力する時
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        searchBar.setShowsCancelButton(true, animated: true)
        return true
    }
    
    //検索バーのキャンセルがタップされた時
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        loadUsers(searchText: nil)
        searchBar.showsCancelButton = false
        searchBar.resignFirstResponder()
    }
    
    //検索バーでEnterが押された時
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        loadUsers(searchText: searchBar.text)
    }

    //ユーザーを読み込む
    func loadUsers(searchText: String?) {
        let query = NCMBUser.query()
        // 自分を除外
        query?.whereKey("objectId", notEqualTo: false)

        // 検索ワードがある場合
        if let text = searchText {
            query?.whereKey("userName", equalTo: text)
        }

        // 新着ユーザー50人だけ拾う
        query?.limit = 50
        // 降順にソート
        query?.order(byDescending: "createDate")

        query?.findObjectsInBackground({ (result, error) in
            if error != nil {
                print(error)
            } else {
                // 取得した新着50件のユーザーを格納
                self.users = result as! [NCMBUser]
                print("users")
                print(self.users)
                self.tableView.reloadData()
            }
        })
    }
    
    //インジケーター用のloadUser
    @objc func update() {
        self.reflesh.endRefreshing()
        loadUsers(searchText: nil)
    }
    
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
    
}

