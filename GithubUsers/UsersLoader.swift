//
//  UsersLoader.swift
//  GithubUsers
//
//  Created by Lyoka on 2/2/17.
//  Copyright © 2017 Elena Podorozhnaya. All rights reserved.
//

import Foundation
import SwiftyJSON

class UsersLoader: MainLoader {
    
    let baseUrlString = "https://api.github.com/users"
    let usersPerPage = 10
    var page = 1
    var since = 1586960 // 1586960 is initial user id - users on the main screen will be loaded since this id (so the first user in table view will be epodorozhnaya)

    var url: URL? {
        return URL(string: "\(baseUrlString)?per_page=\(usersPerPage)&since=\(since)")
    }

    
    // MARK: -
    
    func prepareForTheNextLoading(_ json: [JSON]) throws {
        if json.count > 0 {
            let lastUser = json[json.count - 1]
            guard let lastUserId = lastUser["id"].int else {
                throw LoaderError.wrongJsonFormat
            }
            self.since = lastUserId
        }
    }
    
}




