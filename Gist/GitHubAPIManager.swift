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
  
  func imageFrom(urlString: String, completionHandler: @escaping (UIImage?, Error?) -> Void) {
    let _ = Alamofire.request(urlString).response { dataResponse in
      // use the generic response serializer that return Data
      guard let data = dataResponse.data else {
        completionHandler(nil, dataResponse.error)
        return
      }
      
      let image = UIImage(data: data)
      completionHandler(image, nil)
    }
  }
}
