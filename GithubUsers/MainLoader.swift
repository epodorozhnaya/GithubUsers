//
//  MainLoader.swift
//  GithubUsers
//
//  Created by Lyoka on 2/6/17.
//  Copyright © 2017 Elena Podorozhnaya. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON


enum LoaderError: Error {
    case cannotFormUrl
    case wrongJsonFormat
    case noInternetConnection
    case other
    
    func alertAttributes() -> (title: String, message: String) {
        switch self {
        case .cannotFormUrl:
            return ("Error", "Request URL cannot be formed")
        case .wrongJsonFormat:
            return ("Error", "Wrong JSON format")
        case .noInternetConnection:
            return ("No Internet Connection", "Please check internet connection")
        case .other:
            return ("Error", "Some error occurred. Please try again later.")
        }
    }
}


protocol MainLoader {
    var url: URL? { get }
    var page: Int { get set }
    var usersPerPage: Int { get }
    func prepareForTheNextLoading(_ json: [JSON]) throws
}

extension MainLoader {
    
    var lastLoadedUserIndex: Int {
        return usersPerPage * page
    }
    
    // MARK: -
    
    mutating func loadNextUsers(completion: @escaping ([User]?, LoaderError?) -> Void) {
        page += 1
        loadUsers(completion: completion)
    }
    
    mutating func setPageCounterToPreviousState() {
        page -= 1
    }
    
    func loadUsers(completion: @escaping ([User]?, LoaderError?) -> Void) {
        
        guard let validUrl = url else {
            completion(nil, LoaderError.cannotFormUrl)
            return
        }
        
        Alamofire.request(validUrl).validate().responseJSON { dataResponse in
            
            switch dataResponse.result {
            case .success(let value):
                
                guard let json = JSON(value).array else {
                    completion(nil, LoaderError.wrongJsonFormat)
                    return
                }
                
                do {
                    let users = try self.getUsersFromJson(json)
                    try self.prepareForTheNextLoading(json)
                    completion(users, nil)
                    
                } catch let error {
                    if let loaderError = error as? LoaderError {
                        completion(nil, loaderError)
                    } else {
                        completion(nil, LoaderError.other)
                    }
                }
                
            case .failure(let error):
                print("Error occurred: \(error.localizedDescription)")
                
                if let urlError = error as? URLError, urlError.code == URLError.Code.notConnectedToInternet {
                    completion(nil, LoaderError.noInternetConnection)
                } else {
                    completion(nil, LoaderError.other)
                }
            }
        }
    }
    
    
    // MARK: -
    
    private func getUsersFromJson(_ json: [JSON]) throws -> [User] {
        var users: [User] = []
        
        for user in json {
            guard
                let id = user["id"].int,
                let login = user["login"].string,
                let htmlUrlString = user["html_url"].string,
                let avatarUrlString = user["avatar_url"].string,
                let followersUrlString = user["followers_url"].string
            else {
                throw LoaderError.wrongJsonFormat
            }
            
            let user = User(id: id, login: login, htmlUrlString: htmlUrlString, avatarUrlString: avatarUrlString, followersUrlString: followersUrlString)
            users.append(user)
        }
        
        return users
    }
}


