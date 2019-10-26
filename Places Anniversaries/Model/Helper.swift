//
//  Helper.swift
//  Places Anniversaries
//
//  Created by Sameh Salama on 10/26/19.
//  Copyright © 2019 Sameh Salama. All rights reserved.
//

import UIKit

class Helper {
    
    class func alert(title:String?, message:String?, actionTitle:String, presenter:UIViewController, action:(() -> Void)?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: actionTitle, style: .default, handler: { (_) in
            action?()
        }))
        DispatchQueue.main.async {
            presenter.present(alert, animated: true)
        }
    }
}
