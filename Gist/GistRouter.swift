//
//  GistRouter.swift
//  Gist
//
//  Created by MakingDevs on 05/12/16.
//  Copyright © 2016 MakingDevs. All rights reserved.
//

import Foundation
import Alamofire

enum GistRouter: URLRequestConvertible {

  static let baseURLString = "https://api.github.com/"

  case getPublic()
  case getAtPath(String)

  func asURLRequest() throws -> URLRequest {
    var method: HTTPMethod {
      switch self {
      case .getPublic, .getAtPath:
        return .get
      }
    }

    let url: URL = {
      let relativePath: String
      switch self {
      case .getAtPath(let path):
        return URL(string: path)!
      case .getPublic():
        relativePath = "gists/public"
      }

      var url = URL(string: GistRouter.baseURLString)!
      url.appendPathComponent(relativePath)
      return url
    }()

    let params: ([String: Any]?) = {
      switch self {
      case .getPublic, .getAtPath:
        return nil
      }
    }()

    var urlRequest = URLRequest(url: url)
    urlRequest.httpMethod = method.rawValue

    let encoding = JSONEncoding.default
    return try encoding.encode(urlRequest, with: params)
  }
}
