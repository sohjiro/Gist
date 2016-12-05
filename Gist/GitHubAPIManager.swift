//
//  GitHubAPIManager.swift
//  Gist
//
//  Created by MakingDevs on 05/12/16.
//  Copyright © 2016 MakingDevs. All rights reserved.
//

import Foundation
import Alamofire

struct GitHubAPIManager {

  static let sharedInstance = GitHubAPIManager()

  func printPublicGists() -> Void {
    Alamofire.request(GistRouter.getPublic()).responseString { response in
      if let receivedString = response.result.value {
        print(receivedString)
      }
    }
  }
}
