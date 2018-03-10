//
//  MapAnnotation.swift
//  FindAGrave
//
//  Created by Anastasios Grigoriou on 3/10/18.
//  Copyright © 2018 Grigoriou. All rights reserved.
//

import Foundation
import MapKit

class MapAnnotation: NSObject, MKAnnotation {
   var coordinate: CLLocationCoordinate2D
   var title: String?
   var subtitle: String?
   let cemeteryID: String
   
   init(coordinate: CLLocationCoordinate2D, title: String, subtitle: String, cemeteryID: String) {
      self.coordinate = coordinate
      self.title = title
      self.subtitle = subtitle
      self.cemeteryID = cemeteryID
   }
}
