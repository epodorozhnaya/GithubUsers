//
//  UsersTableViewController.swift
//  GithubUsers
//
//  Created by Lyoka on 2/1/17.
//  Copyright © 2017 Elena Podorozhnaya. All rights reserved.
//

import UIKit
import AlamofireImage


class UsersTableViewController: UITableViewController {
    
    var loader: MainLoader = UsersLoader()
    var users: [User]?
    
    
    // MARK: - Buttons
    
    @IBOutlet weak var retryButton: UIBarButtonItem!
    @IBAction func retryToLoadUsers(_ sender: UIBarButtonItem) {
        initialUsersLoading()
    }
    
    
    // MARK: -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialUsersLoading()
    }
    
    private func initialUsersLoading() {
        retryButton.isEnabled = false
        showActivityIndicator()
        
        loader.loadUsers { users, error in
            self.hideActivityIndicator()
            
            guard error == nil else {
                self.presentAlert(withError: error!)
                self.retryButton.isEnabled = true
                return
            }
            guard users?.count != 0 else {
                self.showNoUsersMessage()
                return
            }
            
            self.users = users
            self.tableView.reloadData()
        }
    }
    
    
    // MARK: - UITableViewDataSource

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "userCellIdentifier", for: indexPath) as! UserTableViewCell
        
        let currentUser = users![indexPath.row]
        
        cell.loginLabel.text = currentUser.login
        cell.htmlUrlLabel.text = currentUser.htmlUrlString
    
        let placeholder = UIImage(named: "GithubDefault")
        if let imageUrl = URL(string: currentUser.avatarUrlString) {
            cell.avatarImageView.af_setImage(withURL: imageUrl, placeholderImage: placeholder)
        } else {
            cell.avatarImageView.image = placeholder
        }

        return cell
    }
    
    
    // MARK: - UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let followersViewController = storyboard.instantiateViewController(withIdentifier: "UsersViewControllerIdentifier") as! UsersTableViewController
        
        let followersBaseUrl = users![indexPath.row].followersUrlString
        followersViewController.loader = FollowersLoader(urlString: followersBaseUrl)
        followersViewController.navigationItem.title = users![indexPath.row].login
        
        navigationController?.pushViewController(followersViewController, animated: true)
    }

    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {

        if indexPath.row == loader.lastLoadedUserIndex - 1 {
            
            showActivityIndicator()
            loader.loadNextUsers { users, error in
                self.hideActivityIndicator()
                
                guard error == nil else {
                    self.loader.setPageCounterToPreviousState()
                    self.presentAlert(withError: error!)
                    return
                }
                
                if let usersArray = users {
                    self.users! += usersArray
                    self.tableView.reloadData()
                }
            }
        }
    }

    
    // MARK: - Activity Indicator

    private func showActivityIndicator() {
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        activityIndicator.startAnimating()
        activityIndicator.frame = CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 60)
        tableView.tableFooterView = activityIndicator
    }
    
    private func hideActivityIndicator() {
        tableView.tableFooterView = nil
    }
    
    
    // MARK: - Error Messages
    
    private func presentAlert(withError error: LoaderError) {
        let title = error.alertAttributes().title
        let message = error.alertAttributes().message
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
    
    private func showNoUsersMessage() {
        let labelFrame = CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: tableView.bounds.size.height)
        let noDataLabel: UILabel = UILabel(frame: labelFrame)
        noDataLabel.text = "User has no followers"
        noDataLabel.textColor = .gray
        noDataLabel.textAlignment = .center
        tableView.backgroundView = noDataLabel
        tableView.separatorStyle = .none
    }
    
}

