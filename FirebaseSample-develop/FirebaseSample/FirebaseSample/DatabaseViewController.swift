//
//  DatabaseViewController.swift
//  FirebaseSample
//
//  Created by masuda-a on 2017/05/26.
//  Copyright © 2017年 masuda-a. All rights reserved.
//

import UIKit

// 以下、Databaseに必要なimport
import Firebase
import FirebaseDatabase

class DatabaseViewController: UIViewController {
    
    // Firebase Realtime Database の初期化
    var ref: DatabaseReference!
    var contentArray: [DataSnapshot] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // データベースへの参照
        ref = Database.database().reference()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // ログインユーザーデータ書き込み
    @IBAction func writeButtonTapped(_ sender: Any) {
        if let user = Auth.auth().currentUser {
            ref.child("Users").child((user.uid)).setValue(["uid": user.uid, "name": user.displayName ?? "" , "mail": user.email ?? "", "date": ServerValue.timestamp()])
        }
    }
    
    // ログインユーザーデータ読み込み
    @IBAction func readButtonTapped(_ sender: Any) {
        ref.child("Users").child((Auth.auth().currentUser?.uid)!).observe(.value, with: {(snapShot) in
            if snapShot.children.allObjects is [DataSnapshot] {
                // 読み込んだデータをプリント
                print("結果...\(snapShot)")
                    if let snapShot = snapShot.value as? NSDictionary! {
                        self.showUserData(user: snapShot)
                }
            }
        })
    }
    
    // 全データ読み込み
    @IBAction func allReadButtonTapped(_ sender: Any) {
        let _: DatabaseHandle = ref.observe(DataEventType.value, with: { (snapshot) in
            print("snapshot" ,snapshot)
        })
    }

    // 更新 (今回は名前を"Update_Test"へ)
    @IBAction func updateButtonTapped(_ sender: Any) {
        ref.keepSynced(true)
        ref.child("Users").child((Auth.auth().currentUser?.uid)!).updateChildValues(["name": "Update_Test"])
    }
    
    // 削除
    @IBAction func removeButtonTapped(_ sender: Any) {
        ref.child("Users").child((Auth.auth().currentUser?.uid)!).removeValue()
    }
    
    // 読み込んだユーザーデータ読み込み
    func showUserData(user: NSDictionary) {
        let date = retrieveDate(number: (user["date"] as? TimeInterval)!/1000)
        
        self.showAlert(title: "User Data",
                       message: "Name: \(user["name"]!)\n" +
                        "Mail: \(user["mail"]!)\n" +
                        "Uid: \(user["uid"]!)\n" +
            "Date: \(date)",
            completion: { () in
        }, cancelCompletion: nil)
        
    }
    
    // timestampで保存されている1970年1月1日からの形式的な経過秒数を日時に表示形式を変換する
    func retrieveDate(number: TimeInterval) -> String {
        let date = Date(timeIntervalSince1970: number)
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm"
        return formatter.string(from: date)
    }
}
