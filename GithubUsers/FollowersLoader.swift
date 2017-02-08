//
//  FollowersLoader.swift
//  GithubUsers
//
//  Created by Lyoka on 2/6/17.
//  Copyright © 2017 Elena Podorozhnaya. All rights reserved.
//

import Foundation
import SwiftyJSON

class FollowersLoader: MainLoader {
    
    let baseUrlString: String
    let usersPerPage = 10
    var page = 1

    init(urlString: String) {
        baseUrlString = urlString
    }

    var url: URL? {
        return URL(string: "\(baseUrlString)?per_page=\(usersPerPage)&page=\(page)")
    }

    
    // MARK: -
    
    func prepareForTheNextLoading(_ json: [JSON]) throws { }
    
}
