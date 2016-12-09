//
//  GitHubAPIManagerError.swift
//  Gist
//
//  Created by Felipe Juarez on 05/12/16.
//  Copyright © 2016 MakingDevs. All rights reserved.
//

import Foundation
import Alamofire

enum GitHubAPIManagerError: Error {
  
  case network(error: Error)
  case apiProvidedError(reason: String)
  case authCouldNot(reason: String)
  case authLost(reason: String)
  case objectSerialization(reason: String)
  

}
