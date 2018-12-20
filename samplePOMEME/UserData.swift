//
//  UserData.swift
//  samplePOMEME
//
//  Created by 藤澤洋佑 on 2018/12/20.
//  Copyright © 2018年 NEKOKICHI. All rights reserved.
//

import UIKit

class UserData: NSObject {
    
    var themeImageURl = String() //テーマ画像
    var iconImageURl = String() //アイコン画像
    var profile = String() //プロフィール文
    var twitterURL = String() //twitterURL
    var instagramURL = String() //instagramURL
    var facebookURL = String() //facebookURL
    var itemArray = [Item]() //アイテム(URL,コメント)
    var itemColor = String() //アイテムの背景色

}
