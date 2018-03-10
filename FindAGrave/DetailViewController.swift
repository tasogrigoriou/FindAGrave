//
//  DetailViewController.swift
//  FindAGrave
//
//  Created by Anastasios Grigoriou on 3/10/18.
//  Copyright © 2018 Grigoriou. All rights reserved.
//

import UIKit

let cemeteryCellIdentifier = "CemeteryTableViewCell"
let memorialCellIdentifier = "MemorialTableViewCell"

class DetailViewController: UIViewController {
   
   // MARK: - Properties
   
   @IBOutlet weak var tableView: UITableView!
   
   var cemeteryID: String?
   var cemetery: CemeteryDetail?
   
   let sectionHeaders = ["Cemetery Info", "Memorials"]
   
   var cemeteryKeys = ["Name", "ID", "GPS", "Address", "City Name", "County Name", "State Name", "Country Name", "Zip code"]
   var cemeteryValues = [String]()
   
   var memorials: [MemorialDetail]?
   
   // MARK: - View Lifecycle
   
   override func viewDidLoad() {
      super.viewDidLoad()
   }
   
   override func viewWillAppear(_ animated: Bool) {
      if let cemeteryID = cemeteryID {
         getCemeteryByID(cemeteryID)
         getMemorialListByID(cemeteryID)
      }
   }
   
   // MARK: - Parse JSON Methods
   
   func getCemeteryByID(_ idNumber: String) {
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
         self.cemetery = cemetery.cemeteryDetail
         
         DispatchQueue.main.async {
            self.mapPropertyValues()
            self.navigationItem.title = self.cemetery?.cemeteryName
            self.tableView.reloadData()
         }
         
      })
   }
   
   func getMemorialListByID(_ idNumber: String) {
      MemorialList.memorialListById(idNumber, completionHandler: { (memorialList, error) in
         if let error = error {
            print(error)
            return
         }
         guard let memorialList = memorialList else {
            print("error getting memorialList: result is nil")
            return
         }
         // success
         self.memorials = memorialList.memorial
         
         DispatchQueue.main.async {
            self.tableView.reloadData()
         }
         
      })
   }
   
   // MARK: - Helper methods
   
   func mapPropertyValues() {
      cemeteryValues.append(cemetery?.cemeteryName ?? "")
      cemeteryValues.append(cemetery?.cemeteryID ?? "")
      cemeteryValues.append("\(cemetery?.latitude ?? ""), \(cemetery?.longitude ?? "")")
      cemeteryValues.append(cemetery?.streetAddress ?? "")
      cemeteryValues.append(cemetery?.cityName ?? "")
      cemeteryValues.append(cemetery?.countyName ?? "")
      cemeteryValues.append(cemetery?.stateName ?? "")
      cemeteryValues.append(cemetery?.countryName ?? "")
      cemeteryValues.append(cemetery?.streetZip ?? "")
   }
   
}

// MARK: - UITableViewDataSource

extension DetailViewController: UITableViewDataSource {
   
   func numberOfSections(in tableView: UITableView) -> Int {
      return 2
   }
   
   func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
      return sectionHeaders[section]
   }

   func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      switch section {
      case 0:
         return cemeteryValues.count
      case 1:
         return memorials?.count ?? 0
      default:
         return 0
      }
   }
   
   func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      var cell: UITableViewCell
      
      if indexPath.section == 0 {
         cell = tableView.dequeueReusableCell(withIdentifier: cemeteryCellIdentifier, for: indexPath)
         cell.textLabel?.text = cemeteryValues[indexPath.row]
         cell.detailTextLabel?.text = cemeteryKeys[indexPath.row]
      } else {
         cell = tableView.dequeueReusableCell(withIdentifier: memorialCellIdentifier, for: indexPath)
         let memorial = memorials?[indexPath.row]
         cell.textLabel?.text = "\(memorial?.firstName ?? "") \(memorial?.middleName ?? "") \(memorial?.lastName ?? "")"
         cell.detailTextLabel?.text = "\(memorial?.birthYear ?? "Unknown") - \(memorial?.deathYear ?? "Present")"
      }
      
      return cell
   }
   
}

// MARK: - UITableViewDelegate

extension DetailViewController: UITableViewDelegate {
   
}
