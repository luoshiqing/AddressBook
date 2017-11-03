//
//  LSQAddressBook.swift
//  AddressBokk
//
//  Created by lsq on 2017/11/2.
//  Copyright © 2017年 罗石清. All rights reserved.
//

import UIKit
import AddressBook

struct AddressModel {
    let title: String
    let books: [AddressBookModel]
}

struct AddressBookModel {
    let lastName    : String    //姓
    let firstName   : String    //名
    let name        : String    //全名
    let phones      : [String]  //电话
    /*
    let nickName    : String    //昵称
    let organization: String    //公司(组织)
    let jobTitle    : String    //职位
    
    let department  : String    //部门
    let note        : String    //备注
    let emails      : [String]  //邮件
    let memorializes: [String]  //纪念日
     */
}

class LSQAddressBook: NSObject {
    
    static var shared = LSQAddressBook()
    fileprivate override init() {
        super.init()
    }
    
    fileprivate var addressBook: ABAddressBook?
//    fileprivate var bookArray = [AddressModel]()
//    fileprivate var keyArray = [String]()
    
    public func getSequenceAddressBook(adderssBooks: (([AddressModel],[String])->Swift.Void)?,failure: ((String)->Swift.Void)?){
  
//        if !self.bookArray.isEmpty && !self.keyArray.isEmpty{
//            adderssBooks?(self.bookArray,self.keyArray)
//            return
//        }
        DispatchQueue.global().async {
            var error: Unmanaged<CFError>?
            if let assd = ABAddressBookCreateWithOptions(nil, &error) {
                self.addressBook = assd.takeRetainedValue()
            }
            //发出授权信息
            let sysAddressBookStatus = ABAddressBookGetAuthorizationStatus()
            switch sysAddressBookStatus {//如果没授权
            case .notDetermined:
                //弹框授权
                ABAddressBookRequestAccessWithCompletion(self.addressBook, { (success, error) in
                    if success{//授权成功
                        let (modelArray,keys) = self.getSortModelAndKeys()
//                        self.bookArray = modelArray
//                        self.keyArray = keys
                        DispatchQueue.main.sync {
                            adderssBooks?(modelArray,keys)
                        }
                    }else{
                        print("取消授权")
                    }
                })
            case .denied,.restricted:
                //上一次没有授权
                failure?("没有授权")
            case .authorized://已经授权
                let (modelArray,keys) = self.getSortModelAndKeys()
//                self.bookArray = modelArray
//                self.keyArray = keys
                DispatchQueue.main.sync {
                    adderssBooks?(modelArray,keys)
                }
            }
    
        }
   
    }
    
    fileprivate func getSortModelAndKeys()->([AddressModel],[String]){
        var modelArray = self.readRecords()
        var keyArray = [String]()
        //进行排序
        modelArray.sort(by: { (m1, m2) -> Bool in
            let n1 = self.getFirstLetter(str: m1.name)
            let n2 = self.getFirstLetter(str: m2.name)
            
            if !keyArray.contains(n1){
                keyArray.append(n1)
            }
            if !keyArray.contains(n2){
                keyArray.append(n2)
            }
            return n1 < n2
        })
        
        keyArray.sort(by: { (s1, s2) -> Bool in
            return s1 < s2
        })
        
        var array = [AddressModel]()
        for key in keyArray{
            var books = [AddressBookModel]()
            for model in modelArray{
                
                let first = self.getFirstLetter(str: model.name)
                
                if key == first {
                    books.append(model)
                }
            }
            let m = AddressModel(title: key, books: books)
            array.append(m)
        }
        return (array,keyArray)
    }
    
    
    //获取通讯录模型
    fileprivate func readRecords()->[AddressBookModel]{
        let sysContacts = ABAddressBookCopyArrayOfAllPeople(self.addressBook).takeRetainedValue() as! Array<Any>
        var addressBookArray = [AddressBookModel]()
        for ctt in sysContacts{
            let contact = ctt as ABRecord
            //姓(去除空格)
            var lastName = (ABRecordCopyValue(contact, kABPersonLastNameProperty)?.takeRetainedValue() as? String) ?? ""
            lastName = lastName.replacingOccurrences(of: " ", with: "")
            //名(去除空格)
            var firstName = (ABRecordCopyValue(contact, kABPersonFirstNameProperty)?.takeRetainedValue() as? String) ?? ""
            firstName = firstName.replacingOccurrences(of: " ", with: "")
            //全名
            var name = ""
            if lastName.isEmpty{
                name = firstName
            }else{
                name = lastName + " " + firstName
            }
            
            //获取电话
            let phoneValues:ABMutableMultiValue? =
                ABRecordCopyValue(contact, kABPersonPhoneProperty)?.takeRetainedValue()
            var phoneArray = [String]()
            if phoneValues != nil {
                for i in 0 ..< ABMultiValueGetCount(phoneValues){
                    // 获得标签名
                    //                    let phoneLabel = ABMultiValueCopyLabelAtIndex(phoneValues, i).takeRetainedValue() as CFString;
                    // 转为本地标签名（能看得懂的标签名，比如work、home）
                    //                    let localizedPhoneLabel = ABAddressBookCopyLocalizedLabel(phoneLabel).takeRetainedValue() as String
                    let value = ABMultiValueCopyValueAtIndex(phoneValues, i)
                    let phone = (value?.takeRetainedValue() as? String) ?? ""
                    phoneArray.append(phone)
                }
            }
            
            if !name.isEmpty{
                let model = AddressBookModel(lastName: lastName, firstName: firstName, name: name, phones: phoneArray)
                //添加至数组
                addressBookArray.append(model)
            }else{
                print("姓名为空")
            }
            
            /*以下需要的自行打开
            
            //昵称
            let nickName = (ABRecordCopyValue(contact, kABPersonNicknameProperty)?.takeRetainedValue() as? String) ?? ""
            //公司（组织）
            let organization = (ABRecordCopyValue(contact, kABPersonOrganizationProperty)?.takeRetainedValue() as? String) ?? ""
            //职位
            let jobTitle = (ABRecordCopyValue(contact, kABPersonJobTitleProperty)?
                .takeRetainedValue() as? String) ?? ""
            //部门
            let department = (ABRecordCopyValue(contact, kABPersonDepartmentProperty)?
                .takeRetainedValue() as? String) ?? ""
            //备注
            let note = (ABRecordCopyValue(contact, kABPersonNoteProperty)?
                .takeRetainedValue() as? String) ?? ""
            
            //获取Email
            let emailValues:ABMutableMultiValue? =
                ABRecordCopyValue(contact, kABPersonEmailProperty)?.takeRetainedValue()
            var emailArray = [String]()
            if emailValues != nil {
                for i in 0 ..< ABMultiValueGetCount(emailValues){
                    
                    // 获得标签名
                    //                    let label = ABMultiValueCopyLabelAtIndex(emailValues, i).takeRetainedValue() as CFString;
                    //                    let localizedLabel = ABAddressBookCopyLocalizedLabel(label).takeRetainedValue() as String
                    let value = ABMultiValueCopyValueAtIndex(emailValues, i)
                    let email = (value?.takeRetainedValue() as? String) ?? ""
                    emailArray.append(email)
                }
            }
            
            //获取纪念日
            let dateValues:ABMutableMultiValue? =
                ABRecordCopyValue(contact, kABPersonDateProperty)?.takeRetainedValue()
            var memorializeArray = [String]()
            if dateValues != nil {
                for i in 0 ..< ABMultiValueGetCount(dateValues){
                    // 获得标签名
                    //                    let label = ABMultiValueCopyLabelAtIndex(emailValues, i).takeRetainedValue() as CFString;
                    //                    let localizedLabel = ABAddressBookCopyLocalizedLabel(label).takeRetainedValue() as String
                    let value = ABMultiValueCopyValueAtIndex(dateValues, i)
                    let date = (value?.takeRetainedValue() as? NSDate)?.description ?? ""
                    memorializeArray.append(date)
                }
            
            }
             */
            
            
        }
        return addressBookArray
    }
    
    //排序
    fileprivate func getFirstLetter(str: String)->String{
        let mutableString = NSMutableString(string: str)
        CFStringTransform(mutableString, nil, kCFStringTransformToLatin, false)
        let pingyingStr = mutableString.folding(options: .diacriticInsensitive, locale: Locale.current)
        let strPinYin = self.polyphoneStringHandle(aStr: str, pinyinStr: pingyingStr).uppercased()
        if strPinYin.isEmpty{
            return "#"
        }
        let firstStr = (strPinYin as NSString).substring(to: 1)
        let regexA = "^[A-Z]$"
        let predA = NSPredicate(format: "SELF MATCHES %@", regexA)
        let endStr = predA.evaluate(with: firstStr)
        return endStr ? firstStr : "#"
    }
    
    fileprivate func polyphoneStringHandle(aStr: String, pinyinStr: String)->String{
        
        if aStr.hasPrefix("长") {return "chang"}
        if aStr.hasPrefix("沈") {return "shen"}
        if aStr.hasPrefix("厦") {return "xia"}
        if aStr.hasPrefix("地") {return "di"}
        if aStr.hasPrefix("重") {return "chong"}
        return pinyinStr
    }
    
   
}
