//
//  FollowersTableViewController.swift
//  GithubUsers
//
//  Created by Lyoka on 2/2/17.
//  Copyright © 2017 Elena Podorozhnaya. All rights reserved.
//

import UIKit

class FollowersTableViewController: UsersTableViewController {
    
    var username: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        GithubNetworkManager.shared.getFollowers(forUser: username) { users, error in
            guard error == nil else { return }
            self.users = users
            self.tableView.reloadData()
        }
    }

}
