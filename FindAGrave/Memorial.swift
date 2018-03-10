//
//  Memorial.swift
//  FindAGrave
//
//  Created by Anastasios Grigoriou on 3/9/18.
//  Copyright © 2018 Grigoriou. All rights reserved.
//

import Foundation

struct MemorialList: Codable {
   var total, hasMoreRows: String?
   var memorial: [MemorialDetail]?
   var memorialSummary: MemorialDetail?
}

struct MemorialDetail: Codable {
   let memorialID: String
   let firstName, middleName, lastName, maidenName: String
   let memorialPrefix: String
   let suffix: String
   let birthMonth, birthDay, birthYear, deathMonth: String
   let deathDay, deathYear: String
   let cemeteryID: String
   let cemeteryName: String
   let cemeteryCityName: String
   let cemeteryCountyName: String
   let cemeteryStateName: String
   let cemeteryStateAbbrev: String
   let cemeteryCountryName: String
   let cemeteryCountryAbbrev: String
   let intermentHasPhoto: String
   let distance: String
   let thumbnailURL: String
   
   enum CodingKeys: String, CodingKey {
      case memorialID = "memorialId"
      case firstName, middleName, lastName, maidenName
      case memorialPrefix = "prefix"
      case suffix, birthMonth, birthDay, birthYear, deathMonth, deathDay, deathYear
      case cemeteryID = "cemeteryId"
      case cemeteryName, cemeteryCityName, cemeteryCountyName, cemeteryStateName, cemeteryStateAbbrev, cemeteryCountryName, cemeteryCountryAbbrev, intermentHasPhoto, distance
      case thumbnailURL = "thumbnailUrl"
   }
}
































