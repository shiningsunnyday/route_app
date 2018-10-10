//
//  AboutViewController.swift
//  aiRun
//
//  Created by Michael Sun on 10/6/18.
//  Copyright © 2018 Michael Sun. All rights reserved.
//

import Foundation
import UIKit
import MessageUI

class AboutViewController: UIViewController, MFMailComposeViewControllerDelegate {
    
    @IBAction func email(_ sender: Any) {
        
        let mailComposeViewController = configureMailController()
        if MFMailComposeViewController.canSendMail() {
            self.present(mailComposeViewController, animated: true, completion: nil)
        } else {
            showMailError()
        }
    }
    
    func configureMailController() -> MFMailComposeViewController {
        let mailComposerVC = MFMailComposeViewController()
        
        mailComposerVC.mailComposeDelegate = self
        
        mailComposerVC.setToRecipients(["msun415@stanford.edu", "michaelsun18@yahoo.com"])
        mailComposerVC.setSubject("From a user of aiRoute")
        mailComposerVC.setMessageBody("", isHTML: false)
        
        return mailComposerVC
    }
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
        
        switch result.rawValue {
            
        case 0:
            let sendMailErrorAlert = UIAlertController(title: "Mail discarded.", message: "Please make my inbox less lonely in the future.", preferredStyle: .alert)
            let dismiss = UIAlertAction(title: "I'll see about that.", style: .default, handler: nil)
            sendMailErrorAlert.addAction(dismiss)
            self.present(sendMailErrorAlert, animated: true, completion: nil)
            
        case 1:
            
            let sendMailErrorAlert = UIAlertController(title: "Mail didn't save.", message: "Because the developer doesn't know how to.", preferredStyle: .alert)
            let dismiss = UIAlertAction(title: "Haha ok.", style: .default, handler: nil)
            sendMailErrorAlert.addAction(dismiss)
            self.present(sendMailErrorAlert, animated: true, completion: nil)
            
        case 2:
            
            let sendMailErrorAlert = UIAlertController(title: "Mail received.", message: "Now go for a run!", preferredStyle: .alert)
            let dismiss = UIAlertAction(title: "Sounds good", style: .default, handler: nil)
            sendMailErrorAlert.addAction(dismiss)
            self.present(sendMailErrorAlert, animated: true, completion: nil)
            
        default:
            return
        }
    }
    
    func showMailSuccess() {
        
        let sendMailErrorAlert = UIAlertController(title: "Mail received.", message: "Now go for a run!", preferredStyle: .alert)
        let dismiss = UIAlertAction(title: "Sounds good", style: .default, handler: nil)
        sendMailErrorAlert.addAction(dismiss)
        self.present(sendMailErrorAlert, animated: true, completion: nil)
    }
    
    func showMailError() {
        let sendMailErrorAlert = UIAlertController(title: "Can't send!", message: "Your device could not send email", preferredStyle: .alert)
        let dismiss = UIAlertAction(title: "Sigh ok", style: .default, handler: nil)
        sendMailErrorAlert.addAction(dismiss)
        self.present(sendMailErrorAlert, animated: true, completion: nil)
    }
    
    @IBAction func facebook(_ sender: Any) {
        
        UIApplication.shared.open(URL(string: "https://www.facebook.com/profile.php?id=100012022903836")! as URL, options: [:], completionHandler: nil)
        
    }
    
    
    @IBAction func linkedIn(_ sender: Any) {
        
        UIApplication.shared.open(URL(string: "https://www.linkedin.com/in/michael-sun-1610b2155/")! as URL, options: [:], completionHandler: nil)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    
    }
    
}
