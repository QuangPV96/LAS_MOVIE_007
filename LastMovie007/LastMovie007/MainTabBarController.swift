//
//  MainTabBarController.swift
//  LastMovie007
//
//  Created by Tran Cuong on 04/10/2023.
//

import UIKit

class MainTabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tabBar = self.tabBar
        
        let homeSelectImage: UIImage! = UIImage(named: "home_selected")?.withRenderingMode(.alwaysOriginal)
        let streamSelectImage: UIImage! = UIImage(named: "stream_selected")?.withRenderingMode(.alwaysOriginal)
        let settingSelectImage: UIImage! = UIImage(named: "setting_selected")?.withRenderingMode(.alwaysOriginal)
        
        (tabBar.items![0]).selectedImage = homeSelectImage
        (tabBar.items![1]).selectedImage = streamSelectImage
        (tabBar.items![2]).selectedImage = settingSelectImage
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        let safeAreaHeight = UIApplication.shared.windows.first?.safeAreaInsets.bottom ?? 0
        let tabBarHeight: CGFloat = 80 + safeAreaHeight
        
        let newTabBarHeight: CGFloat = tabBarHeight
        var tabBarFrame = tabBar.frame
        tabBarFrame.size.height = newTabBarHeight
        tabBarFrame.origin.y = view.frame.size.height - newTabBarHeight
        tabBar.frame = tabBarFrame
        
        tabBar.backgroundColor = UIColor(hex: "E4F0B5");
        
        let maskPath = UIBezierPath(roundedRect: tabBar.bounds, byRoundingCorners: [.topLeft, .topRight], cornerRadii: CGSize(width: 30, height: 20))
        let maskLayer = CAShapeLayer()
        maskLayer.path = maskPath.cgPath
        tabBar.layer.mask = maskLayer
    }
}
