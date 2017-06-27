//
//  StorageViewController.swift
//  FirebaseSample
//
//  Created by Aya-m on 2017/05/30.
//  Copyright © 2017年 Aya-m. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage

class StorageViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    var imageView: UIImageView?
    
    // ストレージ サービスへの参照を取得
    let storage = Storage.storage()
    
    var storageRef: StorageReference!
    
    // 画像の名前は０からインクリとする
    var count = "0"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // ストレージ サービスへの参照を作成
        storageRef = storage.reference(forURL: "gs://sample-app-27983.appspot.com")
        
        UserDefaults.standard.set(0, forKey: "count")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // インクリメント(画像名に使用)
    func countPhoto() -> String {
        let ud = UserDefaults.standard
        let count = ud.object(forKey: "count") as! Int
        ud.set(count + 1, forKey: "count")
        return String(count)
    }
    
    // MARK: UIImagePickerControllerDelegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
   
        guard let image: UIImage = info[UIImagePickerControllerOriginalImage] as? UIImage else {
            print("Get image failed")
            return
        }
        
        let imageData = UIImagePNGRepresentation(image)!
        
        count = countPhoto()
        
        let photoRef = storageRef.child("image/" + count + ".png")
        
        // メタデータ
        let metadata = StorageMetadata()
        metadata.contentType = "image/png"
        // カスタムデリゲート
        metadata.customMetadata = ["caption" : "Dandelion"]
        
        photoRef.putData(imageData, metadata: metadata).observe(.success) { (snapshot) in
            // アップロードが成功した時に、その画像をdownloadするためのURLが取得できる
            if let downloadUrl = snapshot.metadata?.downloadURL() {
                // downloadUrl & 参照先はFirebase Databaseに保存して管理するのがいいと思います
                print("downloadUrl" ,downloadUrl)
                self.showAlert(title: "", message: "Upload successfully",
                               completion: { () in
                }, cancelCompletion: nil)
            } else {
                print("error")
            }
        }
        dismiss(animated: true, completion: nil)
    }
    
    // downloadUrlから画像を表示
    func showImage(downloadUrl: URL!) {
        imageView?.removeFromSuperview()
        
        do {
            let imageData: NSData = try NSData(contentsOf:downloadUrl!,options: NSData.ReadingOptions.mappedIfSafe)
            let image = UIImage(data:imageData as Data)
            imageView = UIImageView(image:image)
            imageView?.frame =  CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
            imageView?.contentMode = UIViewContentMode.scaleAspectFit
            self.view.addSubview(imageView!)
        } catch {
            print("Error: can't create image.")
        }
    }
    
    // メタデータ取得
    func fetchMetadata() {
        // 参照先を作成
        let forestRef = storageRef.child("image/" + "0" + ".png")
        forestRef.getMetadata { (metadata, error) -> Void in
            if let error = error {
                print("error" ,error)
            } else {
                if let metadata = metadata {
                    print(metadata)
                }
            }
        }
        
    }
    
    // PhotoLibraryへアクセス
    @IBAction func uploadButtonTapped(_ sender: Any) {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let ipc : UIImagePickerController = UIImagePickerController()
            ipc.sourceType = .photoLibrary
            ipc.delegate = self
            self.present(ipc, animated: true, completion: nil)
        } else {
            print("Not available")
        }
    }
    
    // 入力されてる参照先の画像を表示
    @IBAction func downloadButtonTapped(_ sender: Any) {
        // 参照先を作成
        let imageRef = storageRef.child("image/" + count + ".png")
        
        // downloadURLを取得
        imageRef.downloadURL { (url, error) -> Void in
            if let error = error {
                print("error" ,error)
            } else {
                self.fetchMetadata()
                self.showImage(downloadUrl: url)
            }
        }
    }
    
    // 先ほどアップロードした画像を削除
    @IBAction func DeleteButtonTapped(_ sender: Any) {
        let desertRef = storageRef.child("image/" + count + ".png")
        desertRef.delete { (error) -> Void in
            if (error != nil) {
                print("delete error")
            } else {
                self.showAlert(title: "", message: "Delete successfully",
                               completion: { () in
                                self.imageView?.removeFromSuperview()
                }, cancelCompletion: nil)
            }
        }
    }
}
