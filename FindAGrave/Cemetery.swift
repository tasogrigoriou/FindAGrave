//
//  Welcome.swift
//  FindAGrave
//
//  Created by Anastasios Grigoriou on 3/8/18.
//  Copyright © 2018 Grigoriou. All rights reserved.
//

import Foundation

struct CemeteryList: Codable {
   let total, hasMoreRows: String
   let cemetery: [CemeterySummary]
}

struct CemeterySummary: Codable {
   let cemeteryID, cemeteryName, latitude, longitude: String
   let streetAddress, streetZip, hasPhoto, phone: String
   let publicNote, approxInterments, approxPhotoRequests, countryName: String
   let countryAbbrev, stateName, stateAbbrev, countyName: String
   let cityName, noMorePhotos: String
//   let url: String
//   let alsoKnownAs: [String]
   
   enum CodingKeys: String, CodingKey {
      case cemeteryID = "cemeteryId"
      case cemeteryName, latitude, longitude, streetAddress, streetZip, hasPhoto, phone, publicNote, approxInterments, approxPhotoRequests, countryName, countryAbbrev, stateName, stateAbbrev, countyName, cityName, noMorePhotos
//      case url = "URL"
//      case alsoKnownAs
   }
}


extension CemeteryList {
   
   static func endpointForCemeteryList() -> String {
      return "https://www.findagrave.com/cgi-bin/api.cgi?mode=cemetery&cemeteryName=mead&limit=25&skip=0"
   }

   static func endpointForCemeteryID(_ cemeteryId: String) -> String {
      return "https://www.findagrave.com/cgi-bin/api.cgi?mode=cemeterySummary&cemeteryId=" + cemeteryId
   }
   
   static func parseCemeteriesList(completionHandler: @escaping (CemeteryList?, Error?) -> Void) {
      // set up URLRequest with URL
      let endpoint = CemeteryList.endpointForCemeteryList()
      guard let url = URL(string: endpoint) else {
         print("Error: cannot create URL")
         let error = BackendError.urlError(reason: "Could not construct URL")
         completionHandler(nil, error)
         return
      }
      let urlRequest = URLRequest(url: url)
      
      // Make request
      let session = URLSession.shared
      let task = session.dataTask(with: urlRequest, completionHandler: {
         (data, response, error) in
         
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
            let cemeteryList = try decoder.decode(CemeteryList.self, from: responseData)
            completionHandler(cemeteryList, nil)
         } catch {
            print("error trying to convert data to JSON")
            print(error)
            completionHandler(nil, error)
         }
      })
      task.resume()
   }

   static func cemeteryById(_ cemeteryId: String, completionHandler: @escaping (CemeterySummary?, Error?) -> Void) {
      // set up URLRequest with URL
      let endpoint = CemeteryList.endpointForCemeteryID(cemeteryId)
      guard let url = URL(string: endpoint) else {
         print("Error: cannot create URL")
         let error = BackendError.urlError(reason: "Could not construct URL")
         completionHandler(nil, error)
         return
      }
      let urlRequest = URLRequest(url: url)

      // Make request
      let session = URLSession.shared
      let task = session.dataTask(with: urlRequest, completionHandler: {
         (data, response, error) in

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
            let cemetery = try decoder.decode(CemeterySummary.self, from: responseData)
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
