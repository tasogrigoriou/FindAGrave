//
//  MapViewController.swift
//  FindAGrave
//
//  Created by Anastasios Grigoriou on 3/8/18.
//  Copyright © 2018 Grigoriou. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController {
   
   // MARK: - Properties
   
   @IBOutlet weak var mapView: MKMapView!
   
   var cemeteries = [CemeteryDetail]()
   
   let searchBar = UISearchBar()
   let locationManager = CLLocationManager()
   let defaultLocation = CLLocation(latitude: 37.773972, longitude: -122.431297)
   let regionRadius: CLLocationDistance = 10000
   
   // MARK: - View lifecycle

   override func viewDidLoad() {
      super.viewDidLoad()
      
      // create the search bar programatically since you won't be able to drag one onto the navigation bar
      searchBar.delegate = self
      searchBar.sizeToFit()
      searchBar.placeholder = "Enter Cemetery Name or ID"
      
      navigationItem.titleView = searchBar
      
      centerMapOnLocation(location: locationManager.location ?? defaultLocation)
      
//      if let searchText = searchBar.text {
//         getAllCemeteries(searchText) // TODO: fix for when user hits enter!
//      }
   }
   
   override func viewDidAppear(_ animated: Bool) {
      super.viewDidAppear(animated)
      checkLocationAuthorizationStatus()
   }
   
   // MARK: - Cemetery methods
   
   func getCemetery(_ idNumber: String) {
      CemeteryList.cemeteryById(idNumber, completionHandler: { (cemetery, error) in
         if let error = error {
            print(error)
            return
         }
         guard let cemetery = cemetery else {
            print("error getting cemetery: result is nil")
            return
         }
         // success
         print(cemetery)
      })
   }
   
   func getAllCemeteries(_ cemeteryName: String) {
      CemeteryList.parseCemeteriesList(cemeteryName, completionHandler: { (cemeteryList, error) in
         if let error = error {
            // got an error in getting the data
            print(error)
            return
         }
         guard let cemeteryList = cemeteryList else {
            print("error getting cemetery list: result is nil")
            return
         }
         // success
         self.cemeteries = cemeteryList.cemeteries!
         DispatchQueue.main.async {
//            self.tableView.reloadData
//            mapView.addAnnotation(self.cemeteries)
         }
         
         for cem in self.cemeteries {
            
            if let latitude = Double(cem.latitude), let longitude = Double(cem.longitude) {
               
               let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
               let mapAnnotation = MapAnnotation(coordinate: coordinate, title: cem.cemeteryName, subtitle: cem.cemeteryID)
               
               self.mapView.addAnnotation(mapAnnotation)
            }
         }
      })
   }
   
   // MARK: - Helper methods
   
   func checkLocationAuthorizationStatus() {
      if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
         mapView.showsUserLocation = true
      } else {
         locationManager.requestWhenInUseAuthorization()
      }
   }
   
   func centerMapOnLocation(location: CLLocation) {
      let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, regionRadius, regionRadius)
      mapView.setRegion(coordinateRegion, animated: true)
   }
   
}

// MARK: - MKMapViewDelegate

extension MapViewController: MKMapViewDelegate {
   
}

// MARK: - UISearchBarDelegate

extension MapViewController: UISearchBarDelegate {
   
   func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
      guard let searchText = searchBar.text else { return }
      
      getAllCemeteries(searchText.components(separatedBy: .whitespaces).joined())
      searchBar.endEditing(true)
   }
   
}
















