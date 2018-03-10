//
//  Cemetery.swift
//  FindAGrave
//
//  Created by Anastasios Grigoriou on 3/8/18.
//  Copyright © 2018 Grigoriou. All rights reserved.
//

import Foundation

struct CemeteryList: Codable {
   var cemeteries: [CemeteryDetail]?
   var cemeteryDetail: CemeteryDetail?
   
   enum CodingKeys: String, CodingKey {
      case cemeteries = "cemetery"
      case cemeteryDetail = "cemeterySummary"
   }
}

struct CemeteryDetail: Codable {
   let cemeteryID, cemeteryName: String
   let latitude, longitude: String
   let streetAddress, streetZip, hasPhoto: String
   let countryName: String
   let countryAbbrev, stateName, stateAbbrev, countyName: String
   let cityName, noMorePhotos: String
   var url: String?
   
   enum CodingKeys: String, CodingKey {
      case cemeteryID = "cemeteryId"
      case cemeteryName, latitude, longitude, streetAddress, streetZip, hasPhoto, countryName, countryAbbrev, stateName, stateAbbrev, countyName, cityName, noMorePhotos
      case url = "URL"
   }
}

// MARK: - BackendError enum

enum BackendError: Error {
   case urlError(reason: String)
   case objectSerialization(reason: String)
}

extension CemeteryList {
   
   // MARK: - Endpoint URLs
   
   static func endpointForCemeteryName(_ cemeteryName: String) -> String {
      return "https://www.findagrave.com/cgi-bin/api.cgi?mode=cemetery&cemeteryName=\(cemeteryName)&limit=25&skip=0"
   }
   
   static func endpointForCoordinates(_ latitude: String, _ longitude: String) -> String {
      return "https://www.findagrave.com/cgi-bin/api.cgi?mode=cemetery&cemeteryLatitude=\(latitude)&cemeteryLongitude=\(longitude)&rangeInMiles=50&limit=25&skip=0"
   }
   
   static func endpointForCemeteryID(_ cemeteryID: String) -> String {
      return "https://www.findagrave.com/cgi-bin/api.cgi?mode=cemeterySummary&cemeteryId=\(cemeteryID)"
   }
   
   // MARK: - Parse JSON methods
   
   static func parseCemeteriesList(_ cemeteryName: String?, _ latitude: String?, _ longitude: String?, completionHandler: @escaping (CemeteryList?, Error?) -> Void) {
      
      var endpoint = ""
      if let cemeteryName = cemeteryName {
         endpoint = CemeteryList.endpointForCemeteryName(cemeteryName)
      } else if let latitude = latitude, let longitude = longitude {
         endpoint = CemeteryList.endpointForCoordinates(latitude, longitude)
      }
      
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

   static func cemeteryById(_ cemeteryId: String, completionHandler: @escaping (CemeteryList?, Error?) -> Void) {
      // set up URLRequest with URL
      let endpoint = CemeteryList.endpointForCemeteryID(cemeteryId)
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
            let cemetery = try decoder.decode(CemeteryList.self, from: responseData)
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
