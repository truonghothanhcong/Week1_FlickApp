//
//  TabBarViewController.swift
//  FlickApp
//
//  Created by CongTruong on 10/11/16.
//  Copyright © 2016 congtruong. All rights reserved.
//

import UIKit

class TabBarViewController: UITabBarController, UITabBarControllerDelegate {
    
    let prefixUrlStringNowPlaying = "https://api.themoviedb.org/3/movie/now_playing?api_key="
    let prefixUrlStringTopRate = "https://api.themoviedb.org/3/movie/top_rated?api_key="
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
//    // UITabBarDelegate
//    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
//        print("aaaa Selected item")
//        print(item)
//    }
    
    // UITabBarControllerDelegate
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        if viewController.tabBarItem.title == "Top Rate" {
            Global.prefixUrlStringRequest = self.prefixUrlStringTopRate
            
            return
        }
        
        Global.prefixUrlStringRequest = self.prefixUrlStringNowPlaying
    }

}
