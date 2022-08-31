//
//  MainTabbarController.swift
//  PineoneTutorials
//
//  Created by 이재혁 on 2022/08/11.
//

import UIKit

class MainTabbarController: UITabBarController {
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViewControllers()
    }
    
    // MARK: - Helpers
    
    private func configureViewControllers() {
        view.backgroundColor = .clear
        
        let newBook = configureNavigationController(title: "New", tabbarImage: UIImage(systemName: "book") ?? UIImage(), rootViewController: NewBooksViewController())
        let searchBook = configureNavigationController(title: "Search", tabbarImage: UIImage(systemName: "magnifyingglass") ?? UIImage(), rootViewController: SearchViewController())
        
        viewControllers = [newBook, searchBook]
        tabBar.tintColor = .systemBlue
    }
    
    private func configureNavigationController(title: String, tabbarImage: UIImage, rootViewController: UIViewController) -> UINavigationController {
        let nav = UINavigationController(rootViewController: rootViewController)
        nav.tabBarItem.title = title
        nav.tabBarItem.image = tabbarImage
        nav.navigationBar.tintColor = .systemBlue
        return nav
    }
}
