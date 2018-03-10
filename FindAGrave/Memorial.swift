//
//  Memorial.swift
//  FindAGrave
//
//  Created by Anastasios Grigoriou on 3/10/18.
//  Copyright © 2018 Grigoriou. All rights reserved.
//

import Foundation

struct MemorialList: Codable {
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
   let intermentHasPhoto: String
   let distance: String
   let thumbnailURL: String
   
   enum CodingKeys: String, CodingKey {
      case memorialID = "memorialId"
      case firstName, middleName, lastName, maidenName
      case memorialPrefix = "prefix"
      case suffix, birthMonth, birthDay, birthYear, deathMonth, deathDay, deathYear
      case cemeteryID = "cemeteryId"
      case cemeteryName, intermentHasPhoto, distance
      case thumbnailURL = "thumbnailUrl"
   }
}

extension MemorialList {
   
   // MARK: - Endpoint URLs
   
   static func endpointForCemeteryID(_ cemeteryID: String) -> String {
      return "https://www.findagrave.com/cgi-bin/api.cgi?mode=name&cemeteryId=\(cemeteryID)&limit=25&skip=0&includeThumb=1"
   }
   
   // MARK: - Parse JSON methods
   
   static func memorialListById(_ cemeteryId: String, completionHandler: @escaping (MemorialList?, Error?) -> Void) {
      // set up URLRequest with URL
      let endpoint = MemorialList.endpointForCemeteryID(cemeteryId)
      guard let url = URL(string: endpoint) else {
         let error = BackendError.urlError(reason: "Could not construct URL")
         completionHandler(nil, error)
         return
      }
      let urlRequest = URLRequest(url: url)
      
      // Make request
      let session = URLSession.shared
      let task = session.dataTask(with: urlRequest, completionHandler: { (data, response, error) in
         
         // handle response to request
         // check for error
         guard error == nil else {
            completionHandler(nil, error!)
            return
         }
         
         // make sure we got data in the response
         guard let responseData = data else {
            print("Error: did not receive data")
            let error = BackendError.objectSerialization(reason: "No data in response")
            completionHandler(nil, error)
            return
         }
         
         let decoder = JSONDecoder()
         do {
            let cemetery = try decoder.decode(MemorialList.self, from: responseData)
            completionHandler(cemetery, nil)
         } catch {
            print("error trying to convert data to JSON")
            print(error)
            completionHandler(nil, error)
         }
      })
      task.resume()
   }
   
}
