//
//  Extension.swift
//  FirebaseSample
//
//  Created by Aya-m on 2017/05/22.
//  Copyright © 2017年 Aya-m. All rights reserved.
//

import UIKit

extension UIViewController {
    
    // OK/Cancelボタンを表示 (cancelCompletionをnilにすればOKボタンのみに)
    func showAlert(title: String, message:String?, completion: (() -> Void)?, cancelCompletion: (() -> Void)?) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let defaultAction = UIAlertAction(title: "OK", style: .default, handler: { (action: UIAlertAction!) in
            if completion != nil {
                completion!()
            }
        })
        alertController.addAction(defaultAction)
        
        if cancelCompletion != nil {
            let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: { (action: UIAlertAction!) in
                if cancelCompletion != nil {
                    cancelCompletion!()
                }
            })
            alertController.addAction(cancelAction)
        }
        self.present(alertController, animated: true, completion: nil)
    }
}
