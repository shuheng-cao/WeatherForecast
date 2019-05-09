//
//  File.swift
//  Weather?
//
//  Created by shuster on 2019/4/26.
//  Copyright © 2019 曹书恒. All rights reserved.
//

import UIKit
import Foundation

class CityListController: UIViewController {
    var cityList: [String] = []
    var allCities: [String] = []
    @IBOutlet weak var tableView: UITableView!
    var delegate: DataPassingDelegate?
    
    @IBAction func add(_ sender: Any) {
        let alert = UIAlertController(title: "Add New City", message: nil, preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        let OKAction = UIAlertAction(title: "OK", style: .default) { (_) in
            if let name = alert.textFields?.first?.text {
                let newAlert = UIAlertController(title: "Successfully Added", message: nil, preferredStyle: .alert)
                newAlert.addAction(cancelAction)
                if self.allCities.contains(name) {
                    if self.cityList.contains(name) {
                        alert.dismiss(animated: true, completion: nil)
                        newAlert.title = "City Already In List"
                        self.present(newAlert, animated: true, completion: nil)
                    } else {
                        alert.dismiss(animated: true, completion: nil)
                        self.cityList.append(name)
                        self.tableView.reloadData()
                        self.present(newAlert, animated: true, completion: nil)
                    }
                } else {
                    alert.dismiss(animated: true, completion: nil)
                    newAlert.title = "City Does Not Exist"
                    self.present(newAlert, animated: true, completion: nil)
                }
            }
        }
        
        alert.addAction(cancelAction)
        alert.addAction(OKAction)
        
        alert.addTextField { (textField) in
            textField.placeholder = "New York"
        }
        
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func back(_ sender: Any) {
        delegate?.updateCities(newCities: cityList)
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.backgroundColor = .black
        self.tableView.separatorColor = UIColor.white

        tableView.rowHeight = 60.0
        for identifier in TimeZone.knownTimeZoneIdentifiers {
            allCities.append(convertLocationString(identifier: identifier))
        }
    }
    
    override func viewDidLayoutSubviews() {
        self.tableView.reloadData()
    }
    
    private func convertLocationString(identifier: String) -> String {
        let location = String(identifier.split(separator: "/").last!)
        return location.replacingOccurrences(of: "_", with: " ", options: .literal, range: nil)
    }
}


extension CityListController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cityList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let result = cityList[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CityListCell") as? CityListCell
        //        cell.enableButton()
        cell!.setCityButton(city: result)
        cell!.delegate = self
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            print("Deleted")
            
            self.cityList.remove(at: indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath[1])
        self.dismiss(animated: true, completion: nil)
        delegate?.goToPage(index: indexPath[1])
    }
}

extension CityListController: DataPassingDelegate {
    func updateCities(newCities: [String]) {
        self.dismiss(animated: true, completion: nil)
        delegate?.updateCities(newCities: newCities)
    }
    
    func goToPage(index: Int) {
    }
}

class CityListCell: UITableViewCell {
    var delegate: DataPassingDelegate?
    var cityName: String?
    @IBOutlet weak var cityLabel: UILabel!
    
    func setCityButton(city: String) {
        print(city)
        cityLabel.text = city
    }
}

