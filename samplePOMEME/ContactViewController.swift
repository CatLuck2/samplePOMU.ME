//
//  ContactViewController.swift
//  samplePOMEME
//
//  Created by 藤澤洋佑 on 2018/12/14.
//  Copyright © 2018年 NEKOKICHI. All rights reserved.
//

import UIKit
import MessageUI

class ContactViewController: UIViewController,MFMailComposeViewControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func contactForm(_ sender: Any) {
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.setToRecipients(["test@gmail.com"])
            mail.setSubject("ご意見")
            mail.setMessageBody("", isHTML: false)
            mail.mailComposeDelegate = self
            self.navigationController?.present(mail, animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: "No Mail Accounts", message: "Please set up mail accounts", preferredStyle: .alert)
            let dismiss = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alert.addAction(dismiss)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        
        controller.dismiss(animated: true, completion: nil)
        
    }
    
}
