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
   
   let searchBar = UISearchBar()
   
   var cemeteries = [CemeteryDetail]()
   
   let locationManager = CLLocationManager()
   let defaultLocation = CLLocation(latitude: 37.773972, longitude: -122.431297)
   let regionRadius: CLLocationDistance = 10000
   var cemeteryID: String?
   
   // MARK: - View Lifecycle

   override func viewDidLoad() {
      super.viewDidLoad()
      
      searchBar.delegate = self
      searchBar.sizeToFit()
      searchBar.placeholder = "Enter Cemetery ID"
      navigationItem.titleView = searchBar
      
      displayCemeteriesInRange()
   }
   
   override func viewDidAppear(_ animated: Bool) {
      super.viewDidAppear(animated)
      checkLocationAuthorizationStatus()
   }
   
   // MARK: - Navigation
   
   override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
      if let cemeteryID = cemeteryID,
         let detailViewController = segue.destination as? DetailViewController {
         detailViewController.cemeteryID = cemeteryID
      }
   }
   
   // MARK: - Cemetery method
   
   func getCemeteryByID(_ idNumber: String) {
      CemeteryList.cemeteryById(idNumber, completionHandler: { (cemeteryList, error) in
         if let error = error {
            print(error)
            return
         }
         guard let cemeteryList = cemeteryList else {
            print("error getting cemeteryList: result is nil")
            return
         }
         // success
         if let cemetery = cemeteryList.cemeteryDetail {
            if let latitude = Double(cemetery.latitude), let longitude = Double(cemetery.longitude) {
               
               let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
               let subtitle = "\(cemetery.countyName), \(cemetery.stateName)"
               let mapAnnotation = MapAnnotation(coordinate: coordinate, title: cemetery.cemeteryName, subtitle: subtitle, cemeteryID: cemetery.cemeteryID)
               
               DispatchQueue.main.async {
                  self.mapView.addAnnotation(mapAnnotation)
                  self.centerMapOnLocation(location: CLLocation(latitude: latitude, longitude: longitude))
               }
            }
         }
         
      })
   }
   
   func getAllCemeteries(_ cemeteryName: String?, _ latitude: String?, _ longitude: String?) {
      
      CemeteryList.parseCemeteriesList(cemeteryName, latitude, longitude, completionHandler: { (cemeteryList, error) in
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
         
         for cemetery in self.cemeteries {
            
            if let latitude = Double(cemetery.latitude), let longitude = Double(cemetery.longitude) {
               
               let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
               let subtitle = "\(cemetery.countyName), \(cemetery.stateName)"
               let mapAnnotation = MapAnnotation(coordinate: coordinate, title: cemetery.cemeteryName, subtitle: subtitle, cemeteryID: cemetery.cemeteryID)
               
               DispatchQueue.main.async {
                  self.mapView.addAnnotation(mapAnnotation)
               }
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
   
   func displayCemeteriesInRange() {
      centerMapOnLocation(location: locationManager.location ?? defaultLocation)
      
      let latitude = String(describing: locationManager.location?.coordinate.latitude ?? defaultLocation.coordinate.latitude)
      let longitude = String(describing: locationManager.location?.coordinate.longitude ?? defaultLocation.coordinate.longitude)
      
      getAllCemeteries(nil, latitude, longitude)
   }
   
}

// MARK: - MKMapViewDelegate

extension MapViewController: MKMapViewDelegate {

   func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
      // Guard against other types of annotations
      guard let annotation = annotation as? MapAnnotation else { return nil }
      
      let identifier = "mapAnnotation"
      var view: MKMarkerAnnotationView
      
      if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
         as? MKMarkerAnnotationView {
         dequeuedView.annotation = annotation
         view = dequeuedView
      } else {
         view = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
         view.canShowCallout = true
         view.calloutOffset = CGPoint(x: -5, y: 5)
         view.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
      }
      
      return view
   }
   
   func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView,
                calloutAccessoryControlTapped control: UIControl) {
      let identifier = "showDetailViewController"
      
      let mapAnnotation = view.annotation as? MapAnnotation
      cemeteryID = mapAnnotation?.cemeteryID
      
      performSegue(withIdentifier: identifier, sender: nil)
   }
   
   func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
      let latitude = String(describing: mapView.region.center.latitude)
      let longitude = String(describing: mapView.region.center.longitude)
      getAllCemeteries(nil, latitude, longitude)
   }
   
}

// MARK: - UISearchBarDelegate

extension MapViewController: UISearchBarDelegate {
   
   func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
      guard let searchText = searchBar.text else { return }
      
      getCemeteryByID(searchText)
      
      searchBar.endEditing(true)
   }
   
}
