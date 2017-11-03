//
//  ViewController.swift
//  AddressBokk
//
//  Created by lsq on 2017/11/2.
//  Copyright © 2017年 罗石清. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var bookBtn: UIButton!

    
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var phoneLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    @IBAction func gotoBook(_ sender: UIButton) {
        let bookVC = BookViewController()
        bookVC.addressBookTouchHandle = { [weak self](model: AddressBookModel) in
            let name = model.name
            print("姓名:\(name)")
            var p = ""
            let phone = model.phones
            if !phone.isEmpty{
                p = phone[0]
                print("电话:\(p)")
            }
            self?.nameLabel.text = name
            self?.phoneLabel.text = p
        }
        self.navigationController?.pushViewController(bookVC, animated: true)
        
    }

   
   }

