//
//  BaseTabBarViewController.swift
//  SwipeDownClose
//
//  Created by 이아연 on 2021/07/07.
//

import UIKit

class BaseTabBarViewController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setVCs()
    }
    
    func setVCs () {
        let contentVC = ContentMainViewController(nibName: "ContentMainViewController", bundle: nil)
        //contentVC.tabBarItem = UITabBarItem(title: "콘텐츠", image: UIImage(named: ""), selectedImage: UIImage(named: ""))

        self.viewControllers = [
            UINavigationController(rootViewController: contentVC),
        ]
    }
}
