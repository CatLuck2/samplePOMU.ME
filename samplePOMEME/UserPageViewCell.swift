//
//  UserPageViewCell.swift
//  samplePOMEME
//
//  Created by 藤澤洋佑 on 2018/12/17.
//  Copyright © 2018年 NEKOKICHI. All rights reserved.
//

import UIKit

class UserPageViewCell: UITableViewCell {
    
    @IBOutlet weak var linkImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        //丸くする
        linkImageView.layer.cornerRadius = 20
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
