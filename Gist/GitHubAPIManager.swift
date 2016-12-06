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

  func fetchPublicGists(completionHandler: @escaping (Result<[Gist]>) -> Void) {
    Alamofire.request(GistRouter.getPublic()).responseJSON { response in
      let result = self.gistArrayFromResponse(response: response)
      completionHandler(result)
    }
  }

  private func gistArrayFromResponse(response: DataResponse<Any>) -> Result<[Gist]> {
    guard response.result.error == nil else {
      print(response.result.error!)
      return .failure(GitHubAPIManagerError.network(error: response.result.error!))
    }

    // check for "message" errors in the JSON because this API does that
    if let jsonDictionary = response.result.value as? [String: Any],
      let errorMessage = jsonDictionary["message"] as? String {
      return .failure(GitHubAPIManagerError.apiProvidedError(reason: errorMessage))
    }

    // make sure we got JSON and it's an array
    guard let jsonArray = response.result.value as? [[String: Any]] else {
      print("didn't get array of gists object as JSON from API")
      return .failure(GitHubAPIManagerError.objectSerialization(reason: "Did not get JSON dictionary in response"))
    }

    // turn JSON into gists
    let gists = jsonArray.flatMap{ Gist(json: $0) }

    return .success(gists)
  }
}
