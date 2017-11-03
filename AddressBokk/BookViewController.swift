//
//  BookViewController.swift
//  AddressBokk
//  http://www.jianshu.com/p/f2ab70d3c658来自
//  Created by lsq on 2017/11/2.
//  Copyright © 2017年 罗石清. All rights reserved.
//

import UIKit
import AddressBook
import AddressBookUI




class BookViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    deinit {
        print("BookViewController->释放")
    }
    //选择通讯录回调
    public var addressBookTouchHandle: ((AddressBookModel)->Swift.Void)?
    
    fileprivate var addressBookArray = [AddressModel]()//数据源
    fileprivate var keyArray = [String]()
    fileprivate var myTabView: UITableView?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        self.navigationItem.title = "通讯录"
        self.view.backgroundColor = UIColor.white
        self.loadTabView()

        //获取通讯录
        LSQAddressBook.shared.getSequenceAddressBook(adderssBooks: { (models,keys) in
            self.addressBookArray = models
            self.keyArray = keys
            self.myTabView?.reloadData()
        }) { (error) in
            print("没有授权")
        }
    }

    fileprivate func loadTabView(){
        let rect = self.view.bounds
        myTabView = UITableView(frame: rect, style: .plain)
        myTabView?.delegate = self
        myTabView?.dataSource = self
        myTabView?.backgroundColor = UIColor.white
        myTabView?.separatorColor = UIColor.groupTableViewBackground
        myTabView?.sectionIndexBackgroundColor = UIColor.clear
        self.view.addSubview(myTabView!)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.addressBookArray.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.addressBookArray[section].books.count
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }

    //右侧索引
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.keyArray[section]
    }
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return self.keyArray
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let idf = "idfcell"
        var cell = tableView.dequeueReusableCell(withIdentifier: idf)
        if cell == nil{
            cell = UITableViewCell(style: .default, reuseIdentifier: idf)
        }
        cell?.textLabel?.text = self.addressBookArray[indexPath.section].books[indexPath.row].name
        return cell!
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let model = self.addressBookArray[indexPath.section]
        let m = model.books[indexPath.row]
        
        self.addressBookTouchHandle?(m)
        
        self.navigationController?.popViewController(animated: true)
    }
}
