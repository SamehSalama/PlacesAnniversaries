//
//  UITextView+Extension.swift
//  Places Anniversaries
//
//  Created by Sameh Salama on 10/24/19.
//  Copyright © 2019 Sameh Salama. All rights reserved.
//

import UIKit

extension UITextView {
    
    func addDoneCancelButtons(doneTitle: String, cancelTitle:String, target: Any, doneSelector: Selector, cancelSelector:Selector) {
        let toolBar = UIToolbar(frame: CGRect(x: 0.0, y: 0.0, width: UIScreen.main.bounds.size.width, height: 44.0))
        let flexible = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneBarButton = UIBarButtonItem(title: doneTitle, style: .plain, target: target, action: doneSelector)
        let cancelBarButton = UIBarButtonItem(title: cancelTitle, style: .plain, target: target, action: cancelSelector)
        toolBar.setItems([cancelBarButton, flexible, doneBarButton], animated: false)
        self.inputAccessoryView = toolBar
    }
}
