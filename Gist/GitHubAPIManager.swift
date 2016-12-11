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
  
  func fetchPublicGists(pageToLoad: String?, completionHandler: @escaping (Result<[Gist]>, String?) -> Void) {
    if let urlString = pageToLoad {
      fetchGists(GistRouter.getAtPath(urlString), completionHandler: completionHandler)
    } else {
      fetchGists(GistRouter.getPublic(), completionHandler: completionHandler)
    }
  }
  
  func fetchGists(_ urlRequest: URLRequestConvertible, completionHandler: @escaping (Result<[Gist]>, String?) -> Void) {
    Alamofire.request(urlRequest).responseJSON { response in
      let result = self.gistArrayFromResponse(response: response)
      let next = self.parseNextPageFromHeaders(response: response.response)
      completionHandler(result, next)
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
  
  private func parseNextPageFromHeaders(response: HTTPURLResponse?) -> String? {
    guard let linkHeader = response?.allHeaderFields["Link"] as? String else {
      return nil
    }
    /* looks like: <https://...?page=2>; rel="next", <https://...?page=6>; rel="last" */
    // so split on ","
    let components = linkHeader.characters.split { $0 == "," }.map { String($0) }
    // now we  have 2 lines like '<https://...?page=2>; rel="next"'
    
    for item in components {
      let rangeOfNext = item.range(of: "rel=\"next\"", options: [])
      guard rangeOfNext != nil else {
        continue
      }
      
      let rangeOfPaddedURL = item.range(of: "<(.*)>;", options: .regularExpression, range: nil, locale: nil)
      guard let range = rangeOfPaddedURL else {
        return nil
      }
      
      let nextURL = item.substring(with: range)
      
      // strip off the < and >;
      let start = nextURL.index(range.lowerBound, offsetBy: 1)
      let end = nextURL.index(range.upperBound, offsetBy: -2)
      
      let trimmedRange = start ..< end
      return nextURL.substring(with: trimmedRange)
    }
    
    return nil
  }
}





















