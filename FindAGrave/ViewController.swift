//
//  ViewController.swift
//  FindAGrave
//
//  Created by Anastasios Grigoriou on 3/8/18.
//  Copyright © 2018 Grigoriou. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
   
   var cemeteries = [CemeterySummary]()

   override func viewDidLoad() {
      super.viewDidLoad()
      
//      getCemetery("15559")
      getAllCemeteries()
   }

   override func didReceiveMemoryWarning() {
      super.didReceiveMemoryWarning()
      // Dispose of any resources that can be recreated.
   }
   
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
         debugPrint(cemetery)
         print(cemetery)
      })
   }
   
   func getAllCemeteries() {
      CemeteryList.parseCemeteriesList { (cemeteryList, error) in
         if let error = error {
            // got an error in getting the data
            print(error)
            return
         }
         guard let cemeteryList = cemeteryList else {
            print("error getting cemetery list: result is nil")
            return
         }
         // success :)
//         debugPrint(cemeteryList.cemetery)
         self.cemeteries = cemeteryList.cemetery
         print(self.cemeteries[0].cemeteryName)
      }
   }
   
}

enum BackendError: Error {
   case urlError(reason: String)
   case objectSerialization(reason: String)
}
















