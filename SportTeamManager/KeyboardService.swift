//
//  KeyboardService.swift
//  SportTeamManager
//
//  Created by Вероника Данилова on 22/11/2018.
//  Copyright © 2018 Veronika Danilova. All rights reserved.
//

import UIKit

class KeyboardService {
    
    let controller: UIViewController!
    
    init(_ viewController: UIViewController) {
        self.controller = viewController
    }
    
    var textFieldRealYPosition: CGFloat = 0.0
    
    public func addKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            let distanceBetweenTextfielAndKeyboard = controller.view.frame.height - textFieldRealYPosition - keyboardSize.height
            if distanceBetweenTextfielAndKeyboard < 0 {
                UIView.animate(withDuration: 0.4) {
                    self.controller.view.transform = CGAffineTransform(translationX: 0.0, y: distanceBetweenTextfielAndKeyboard)
                }
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        UIView.animate(withDuration: 0.4) {
            self.controller.view.transform = .identity
        }
    }
    
}
