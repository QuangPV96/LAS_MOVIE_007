//
//  HomeMoreDialog.swift
//  LastMovie007
//
//  Created by Tran Cuong on 04/10/2023.
//

import UIKit

class HomeMoreDialog: UIViewController {
    var dismissCallback: (() -> Void)?
    var optionSelectedCallback: ((Int) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()

     
    }

    @IBAction func actionShareVideo(_ sender: Any) {
        self.dismissCallback?()
        dismiss(animated: true) {
            self.optionSelectedCallback?(1)
        }
    }
    
    
    @IBAction func actionAddMyFavourite(_ sender: Any) {
        self.dismissCallback?()
        dismiss(animated: true) {
            self.optionSelectedCallback?(2)
        }
    }
    
    @IBAction func actionDelete(_ sender: Any) {
        self.dismissCallback?()
        dismiss(animated: true) {
            self.optionSelectedCallback?(3)
        }
    }
    
    @IBAction func actionDismiss(_ sender: Any) {
        self.dismissCallback?()
        dismiss(animated: true, completion: nil)
    }
}

