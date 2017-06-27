//
//  LoginViewController.swift
//  FirebaseSample
//
//  Created by Aya-m on 2017/05/18.
//  Copyright © 2017年 Aya-m. All rights reserved.
//

import UIKit

// 以下、認証に必要なimport
import Firebase
import TwitterKit
import FBSDKLoginKit

class LoginViewController: UIViewController {
    
    @IBOutlet weak var twitterButton: UIButton!
    @IBOutlet weak var facebookButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkLoggedinStatus()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        transitionToStorageView()
    }
    
    // Firebaseにログイン済みだったら、storageViewへ遷移
    func transitionToStorageView() {
        if let _ = Auth.auth().currentUser {
            let storyboard: UIStoryboard = self.storyboard!
            let nextView = storyboard.instantiateViewController(withIdentifier: "storageView")
            present(nextView, animated: true, completion: nil)
        }
    }
    
    @IBAction func twitterButtonTapped(_ sender: Any) {
        // Firebaseにログイン済みか確認
        if let _ = Auth.auth().currentUser {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
                self.showAlert(title: "Link Twitter", message: "現在ログインしているFacebookユーザにTwitterユーザーを連携しますか？",
                               completion: { () in
                                Twitter.sharedInstance().logIn(completion: { (session:TWTRSession?, error:Error?) in
                                    if(!(error != nil)){
                                        let credential = TwitterAuthProvider.credential(withToken: session!.authToken, secret: session!.authTokenSecret)
                                        self.linkToCurrentUser(credential: credential)
                                    }
                                })
                },
                               cancelCompletion: { () in
                                self.loginWithTwitter()
                })
            }
        } else {
            loginWithTwitter()
        }
    }
    
    @IBAction func facebookButtonTapped(_ sender: Any) {
        // Firebaseにログイン済みか確認
        if let _ = Auth.auth().currentUser {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
                self.showAlert(title: "Link Facebook", message: "現在ログインしているTwitterユーザにFacebookユーザーを連携しますか？",
                               completion: { () in
                                let facebookLoginManager: FBSDKLoginManager = FBSDKLoginManager()
                                
                                // パーミッションに「email」をリクエストすることで、そのまま認証をうければ、メールアドレスが取得されます。ただし、この認証画面は認証する内容をユーザが編集でき、メールアドレスをオフにすることも可能なようです。
                                facebookLoginManager.logIn(withReadPermissions: ["public_profile","email"], from: self, handler: { (result:FBSDKLoginManagerLoginResult?, error:Error?) in
                                    let credential:AuthCredential = FacebookAuthProvider.credential(withAccessToken: (result?.token.tokenString)!)
                                    self.linkToCurrentUser(credential: credential)
                                })
                },
                               cancelCompletion: { () in
                                self.loginWithFacebook()
                })
            }
            
        } else {
            loginWithFacebook()
        }
    }
    
    // サインアウト処理
    @IBAction func signOutButtonTapped(_ sender: Any) {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
        checkLoggedinStatus()
    }
    
    // ユーザー アカウントから認証プロバイダのリンクを解除
    // fromProviderの引数に解除したいプロバイダを渡す
    @IBAction func unlinkButtonTapped(_ sender: Any) {
        Auth.auth().currentUser?.unlink(fromProvider: "facebook.com" ) { (user, error) in
            self.checkLoggedinStatus()
        }
        Auth.auth().currentUser?.unlink(fromProvider: "twitter.com" ) { (user, error) in
            self.checkLoggedinStatus()
        }
    }
    
    // Twitterログイン処理
    func loginWithTwitter() {
        Twitter.sharedInstance().logIn(completion: { (session:TWTRSession?, error:Error?) in
            if (!(error != nil)){
                let credential = TwitterAuthProvider.credential(withToken: session!.authToken, secret: session!.authTokenSecret)
                self.login(credential: credential)
            }
        })
    }
    
    // Facebookログイン処理
    func loginWithFacebook() {
        let facebookLoginManager: FBSDKLoginManager = FBSDKLoginManager()
        facebookLoginManager.logIn(withReadPermissions: ["public_profile","email"], from: self, handler: { (result:FBSDKLoginManagerLoginResult?, error:Error?) in
            if (!(result?.isCancelled)!){
                let credential = FacebookAuthProvider.credential(withAccessToken: (result?.token.tokenString)!)
                self.login(credential: credential)
            }
        })
    }
    
    // 認証プロバイダをリンク
    func linkToCurrentUser(credential:AuthCredential) {
        Auth.auth().currentUser?.link(with: credential, completion: { (user:User?, error:Error?) in
            if let user = user {
                self.showLoggedInAlert(user: user)
            } else {
                print("user nil")
            }
        })
    }
    
    // Firebaseにログイン
    func login(credential:AuthCredential) {
        Auth.auth().signIn(with: credential, completion: { (user:User?, error:Error?) in
            if let user = user {
                self.showLoggedInAlert(user: user)
            } else {
                print("user nil")
            }
        })
    }
    
    // ログインアラート表示
    func showLoggedInAlert(user: User?) {
        self.showAlert(title: "Logged In", message: "User \(user!.displayName!) has logged in",
            completion: { () in
                self.transitionToStorageView()
        }, cancelCompletion: nil)
        checkLoggedinStatus()
    }
    
    // ただログイン状態を確認のために作った関数
    func checkLoggedinStatus() {
        var loggedinProviders: [String] = []
        if let user = Auth.auth().currentUser {
            loggedinProviders = user.providerData.map{$0.providerID}
            print("loggedin Providers", loggedinProviders)
            print("loggedin UserNames", user.providerData.map{$0.displayName})
            
        } else {
            print("CurrentUser Zero")
        }
        twitterButton.isEnabled = !loggedinProviders.contains("twitter.com")
        facebookButton.isEnabled = !loggedinProviders.contains("facebook.com")
    }
}
