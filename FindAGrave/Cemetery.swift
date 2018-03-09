//
//  Welcome.swift
//  FindAGrave
//
//  Created by Anastasios Grigoriou on 3/8/18.
//  Copyright © 2018 Grigoriou. All rights reserved.
//

import Foundation

struct Cemetery: Codable {
   let cemeterySummary: CemeterySummary
}

struct CemeterySummary: Codable {
   let cemeteryID, cemeteryName, latitude, longitude: String
   let streetAddress, streetZip, hasPhoto, phone: String
   let publicNote, approxInterments, approxPhotoRequests, countryName: String
   let countryAbbrev, stateName, stateAbbrev, countyName: String
   let cityName, noMorePhotos, url: String
   
   enum CodingKeys: String, CodingKey {
      case cemeteryID = "cemeteryId"
      case cemeteryName, latitude, longitude, streetAddress, streetZip, hasPhoto, phone, publicNote, approxInterments, approxPhotoRequests, countryName, countryAbbrev, stateName, stateAbbrev, countyName, cityName, noMorePhotos
      case url = "URL"
   }
}


extension Cemetery {

   static func endpointForID(_ cemeteryId: String) -> String {
      return "https://www.findagrave.com/cgi-bin/api.cgi?mode=cemeterySummary&cemeteryId=" + cemeteryId
   }

   // TODO : change completionHandler paramater to [Cemetery] instead of Cemetery
   static func cemeteryById(_ cemeteryId: String, completionHandler: @escaping (Cemetery?, Error?) -> Void) {
      // set up URLRequest with URL
      let endpoint = Cemetery.endpointForID(cemeteryId)
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
            let cemetery = try decoder.decode(Cemetery.self, from: responseData)
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




extension Cemetery {
   init(data: Data) throws {
      self = try JSONDecoder().decode(Cemetery.self, from: data)
   }
   
   init(_ json: String, using encoding: String.Encoding = .utf8) throws {
      guard let data = json.data(using: encoding) else {
         throw NSError(domain: "JSONDecoding", code: 0, userInfo: nil)
      }
      try self.init(data: data)
   }
   
   init(fromURL url: URL) throws {
      try self.init(data: try Data(contentsOf: url))
   }
   
   func jsonData() throws -> Data {
      return try JSONEncoder().encode(self)
   }
   
   func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
      return String(data: try self.jsonData(), encoding: encoding)
   }
}

extension CemeterySummary {
   init(data: Data) throws {
      self = try JSONDecoder().decode(CemeterySummary.self, from: data)
   }
   
   init(_ json: String, using encoding: String.Encoding = .utf8) throws {
      guard let data = json.data(using: encoding) else {
         throw NSError(domain: "JSONDecoding", code: 0, userInfo: nil)
      }
      try self.init(data: data)
   }
   
   init(fromURL url: URL) throws {
      try self.init(data: try Data(contentsOf: url))
   }
   
   func jsonData() throws -> Data {
      return try JSONEncoder().encode(self)
   }
   
   func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
      return String(data: try self.jsonData(), encoding: encoding)
   }
}

// MARK: Encode/decode helpers

class JSONNull: Codable {
   public init() {}
   
   public required init(from decoder: Decoder) throws {
      let container = try decoder.singleValueContainer()
      if !container.decodeNil() {
         throw DecodingError.typeMismatch(JSONNull.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for JSONNull"))
      }
   }
   
   public func encode(to encoder: Encoder) throws {
      var container = encoder.singleValueContainer()
      try container.encodeNil()
   }
}

class JSONCodingKey: CodingKey {
   let key: String
   
   required init?(intValue: Int) {
      return nil
   }
   
   required init?(stringValue: String) {
      key = stringValue
   }
   
   var intValue: Int? {
      return nil
   }
   
   var stringValue: String {
      return key
   }
}

class JSONAny: Codable {
   public let value: Any
   
   static func decodingError(forCodingPath codingPath: [CodingKey]) -> DecodingError {
      let context = DecodingError.Context(codingPath: codingPath, debugDescription: "Cannot decode JSONAny")
      return DecodingError.typeMismatch(JSONAny.self, context)
   }
   
   static func encodingError(forValue value: Any, codingPath: [CodingKey]) -> EncodingError {
      let context = EncodingError.Context(codingPath: codingPath, debugDescription: "Cannot encode JSONAny")
      return EncodingError.invalidValue(value, context)
   }
   
   static func decode(from container: SingleValueDecodingContainer) throws -> Any {
      if let value = try? container.decode(Bool.self) {
         return value
      }
      if let value = try? container.decode(Int64.self) {
         return value
      }
      if let value = try? container.decode(Double.self) {
         return value
      }
      if let value = try? container.decode(String.self) {
         return value
      }
      if container.decodeNil() {
         return JSONNull()
      }
      throw decodingError(forCodingPath: container.codingPath)
   }
   
   static func decode(from container: inout UnkeyedDecodingContainer) throws -> Any {
      if let value = try? container.decode(Bool.self) {
         return value
      }
      if let value = try? container.decode(Int64.self) {
         return value
      }
      if let value = try? container.decode(Double.self) {
         return value
      }
      if let value = try? container.decode(String.self) {
         return value
      }
      if let value = try? container.decodeNil() {
         if value {
            return JSONNull()
         }
      }
      if var container = try? container.nestedUnkeyedContainer() {
         return try decodeArray(from: &container)
      }
      if var container = try? container.nestedContainer(keyedBy: JSONCodingKey.self) {
         return try decodeDictionary(from: &container)
      }
      throw decodingError(forCodingPath: container.codingPath)
   }
   
   static func decode(from container: inout KeyedDecodingContainer<JSONCodingKey>, forKey key: JSONCodingKey) throws -> Any {
      if let value = try? container.decode(Bool.self, forKey: key) {
         return value
      }
      if let value = try? container.decode(Int64.self, forKey: key) {
         return value
      }
      if let value = try? container.decode(Double.self, forKey: key) {
         return value
      }
      if let value = try? container.decode(String.self, forKey: key) {
         return value
      }
      if let value = try? container.decodeNil(forKey: key) {
         if value {
            return JSONNull()
         }
      }
      if var container = try? container.nestedUnkeyedContainer(forKey: key) {
         return try decodeArray(from: &container)
      }
      if var container = try? container.nestedContainer(keyedBy: JSONCodingKey.self, forKey: key) {
         return try decodeDictionary(from: &container)
      }
      throw decodingError(forCodingPath: container.codingPath)
   }
   
   static func decodeArray(from container: inout UnkeyedDecodingContainer) throws -> [Any] {
      var arr: [Any] = []
      while !container.isAtEnd {
         let value = try decode(from: &container)
         arr.append(value)
      }
      return arr
   }
   
   static func decodeDictionary(from container: inout KeyedDecodingContainer<JSONCodingKey>) throws -> [String: Any] {
      var dict = [String: Any]()
      for key in container.allKeys {
         let value = try decode(from: &container, forKey: key)
         dict[key.stringValue] = value
      }
      return dict
   }
   
   static func encode(to container: inout UnkeyedEncodingContainer, array: [Any]) throws {
      for value in array {
         if let value = value as? Bool {
            try container.encode(value)
         } else if let value = value as? Int64 {
            try container.encode(value)
         } else if let value = value as? Double {
            try container.encode(value)
         } else if let value = value as? String {
            try container.encode(value)
         } else if value is JSONNull {
            try container.encodeNil()
         } else if let value = value as? [Any] {
            var container = container.nestedUnkeyedContainer()
            try encode(to: &container, array: value)
         } else if let value = value as? [String: Any] {
            var container = container.nestedContainer(keyedBy: JSONCodingKey.self)
            try encode(to: &container, dictionary: value)
         } else {
            throw encodingError(forValue: value, codingPath: container.codingPath)
         }
      }
   }
   
   static func encode(to container: inout KeyedEncodingContainer<JSONCodingKey>, dictionary: [String: Any]) throws {
      for (key, value) in dictionary {
         let key = JSONCodingKey(stringValue: key)!
         if let value = value as? Bool {
            try container.encode(value, forKey: key)
         } else if let value = value as? Int64 {
            try container.encode(value, forKey: key)
         } else if let value = value as? Double {
            try container.encode(value, forKey: key)
         } else if let value = value as? String {
            try container.encode(value, forKey: key)
         } else if value is JSONNull {
            try container.encodeNil(forKey: key)
         } else if let value = value as? [Any] {
            var container = container.nestedUnkeyedContainer(forKey: key)
            try encode(to: &container, array: value)
         } else if let value = value as? [String: Any] {
            var container = container.nestedContainer(keyedBy: JSONCodingKey.self, forKey: key)
            try encode(to: &container, dictionary: value)
         } else {
            throw encodingError(forValue: value, codingPath: container.codingPath)
         }
      }
   }
   
   static func encode(to container: inout SingleValueEncodingContainer, value: Any) throws {
      if let value = value as? Bool {
         try container.encode(value)
      } else if let value = value as? Int64 {
         try container.encode(value)
      } else if let value = value as? Double {
         try container.encode(value)
      } else if let value = value as? String {
         try container.encode(value)
      } else if value is JSONNull {
         try container.encodeNil()
      } else {
         throw encodingError(forValue: value, codingPath: container.codingPath)
      }
   }
   
   public required init(from decoder: Decoder) throws {
      if var arrayContainer = try? decoder.unkeyedContainer() {
         self.value = try JSONAny.decodeArray(from: &arrayContainer)
      } else if var container = try? decoder.container(keyedBy: JSONCodingKey.self) {
         self.value = try JSONAny.decodeDictionary(from: &container)
      } else {
         let container = try decoder.singleValueContainer()
         self.value = try JSONAny.decode(from: container)
      }
   }
   
   public func encode(to encoder: Encoder) throws {
      if let arr = self.value as? [Any] {
         var container = encoder.unkeyedContainer()
         try JSONAny.encode(to: &container, array: arr)
      } else if let dict = self.value as? [String: Any] {
         var container = encoder.container(keyedBy: JSONCodingKey.self)
         try JSONAny.encode(to: &container, dictionary: dict)
      } else {
         var container = encoder.singleValueContainer()
         try JSONAny.encode(to: &container, value: self.value)
      }
   }
}


