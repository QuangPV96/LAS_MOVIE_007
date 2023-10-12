//
//  StreamVC.swift
//  LastMovie007
//
//  Created by Tran Cuong on 04/10/2023.
//

import UIKit

class StreamVC: UIViewController,UITextFieldDelegate {

    @IBOutlet weak var tfLink: UITextField!
    @IBOutlet weak var viewInputLink: GradientView!
    @IBOutlet weak var viewLink: UIView!
    @IBOutlet weak var viewCancel: UIView!
    @IBOutlet weak var viewPlay: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        viewLink.layer.shadowColor = UIColor.black.cgColor // Màu của bóng
        viewLink.layer.shadowOpacity = 0.25 // Độ trong suốt của bóng (0.0 - 1.0)
        viewLink.layer.shadowOffset = CGSize(width: 2, height: -10) // Độ lệch của bóng
        viewLink.layer.shadowRadius = 4.0 // Bán kính của bóng
        viewLink.layer.cornerRadius = 25.0
        
        viewCancel.layer.shadowColor = UIColor.black.cgColor // Màu của bóng
        viewCancel.layer.shadowOpacity = 0.25 // Độ trong suốt của bóng (0.0 - 1.0)
        viewCancel.layer.shadowOffset = CGSize(width: 2, height: -10) // Độ lệch của bóng
        viewCancel.layer.shadowRadius = 4.0 // Bán kính của bóng
        viewCancel.layer.cornerRadius = 25.0
        
        viewPlay.layer.shadowColor = UIColor.black.cgColor // Màu của bóng
        viewPlay.layer.shadowOpacity = 0.25 // Độ trong suốt của bóng (0.0 - 1.0)
        viewPlay.layer.shadowOffset = CGSize(width: 2, height: -10) // Độ lệch của bóng
        viewPlay.layer.shadowRadius = 4.0 // Bán kính của bóng
        viewPlay.layer.cornerRadius = 25.0
        
        viewInputLink.isHidden = true;
        tfLink.delegate = self
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
//        tfLink.endEditing(true)
        
        return true
    }

    @IBAction func actionCancel(_ sender: Any) {
        viewInputLink.isHidden = true;
    }
    
    @IBAction func actionPlay(_ sender: Any) {
        viewInputLink.isHidden = true;
        tfLink.resignFirstResponder()
        let play = PlayStreamVC();
        if let link = tfLink.text, !link.isEmpty {
            play.linkUrl = link;
        }
        
        play.modalPresentationStyle = .fullScreen
        self.present(play, animated: true)
    }
    
    @IBAction func actionStream(_ sender: Any) {
        viewInputLink.isHidden = false;
        tfLink.becomeFirstResponder()
    }
    
}
