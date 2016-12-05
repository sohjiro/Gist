//
//  Gist.swift
//  Gist
//
//  Created by MakingDevs on 05/12/16.
//  Copyright © 2016 MakingDevs. All rights reserved.
//

import Foundation

struct Gist {

  var id: String?
  var description: String?
  var ownerLogin: String?
  var ownerAvatarURL: String?
  var url: String?

  init() { }

  init?(json: [String: Any]) {
    guard let description = json["description"] as? String,
          let idValue     = json["id"] as? String,
          let url         = json["url"] as? String else {
            return nil
          }

    self.description = description
    self.id = idValue
    self.url = url

    if let ownerJson = json["owner"] as? [String: Any] {
      self.ownerLogin = ownerJson["login"] as? String
      self.ownerAvatarURL = ownerJson["avatar_url"] as? String
    }
  }

}
