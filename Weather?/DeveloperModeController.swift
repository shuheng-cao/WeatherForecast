//
//  DeveloperViewController.swift
//  Weather?
//
//  Created by shuster on 2019/5/5.
//  Copyright © 2019 曹书恒. All rights reserved.
//

import UIKit
import Foundation

class DeveloperModeController: UIViewController {
    @IBOutlet weak var refreshButton: UIButton!
    @IBOutlet weak var retrainButton: UIButton!
    @IBOutlet weak var textField: UITextView!
    @IBOutlet weak var graphField: UIImageView!
    @IBOutlet weak var switchButtonA: UISwitch!
    @IBOutlet weak var switchButtonB: UISwitch!
    var timer = Timer()
    var index = 0
    var refreshImages: [UIImage] = []
    var retrainImages: [UIImage] = []
    
    
    override func viewDidLoad() {
        refreshButton.layer.cornerRadius = 5
        retrainButton.layer.cornerRadius = 5
        for i in 0...8 {
            refreshImages.append(UIImage(named: "step\(i)")!)
        }
        for i in 0...2 {
            retrainImages.append(UIImage(named: "step\(i)")!)
        }
        
        for i in 3...14 {
            retrainImages.append(UIImage(named: "step\(i)'")!)
        }
        
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(respondToSwipeGesture))
        swipeDown.direction = UISwipeGestureRecognizer.Direction.down
        self.view.addGestureRecognizer(swipeDown)
    }
    
    @IBAction func touchSwitchA(_ sender: Any) {
        timer.invalidate()
        index = 0
        
        graphField.image = UIImage(named: "step0")
        if switchButtonA.isOn {
            // get the current date and time
            let currentDateTime = Date()
            
            // initialize the date formatter and set the style
            let formatter = DateFormatter()
//            formatter.timeStyle = .full
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            
            // get the date time String from the date object
            let cur = formatter.string(from: currentDateTime)
            textField.text = "\(cur)\n\nNo connection to server\n\nEverything is handled in front end using Dark Sky API\n\nRefresh and Retrain are disabled"
            graphField.alpha = 0.5
            refreshButton.alpha = 0.5
            retrainButton.alpha = 0.5
        } else {
            graphField.alpha = 1
            refreshButton.alpha = 1
            retrainButton.alpha = 1
            textField.text = """
            Watching for file changes with StatReloader
            Performing system checks...
            
            System check identified no issues (0 silenced).
            
            You have 5 unapplied migration(s). Your project may not work properly until you apply the migrations for app(s): admin, auth, weather.
            Run 'python manage.py migrate' to apply them.
            
            May 03, 2019 - 16:57:34
            Django version 2.2.1, using settings 'jsondj.settings'
            Starting development server at http://127.0.0.1:8000/
            Quit the server with CONTROL-C.
            """
            
        }
    }
    
    @IBAction func touchSwitchB(_ sender: Any) {
        timer.invalidate()
        index = 0
        
        graphField.image = UIImage(named: "step0")
        if switchButtonB.isOn {
            
        } else {
            #if targetEnvironment(simulator)
            // your simulator code
            #else
            let alert = UIAlertController(title: "ERROR", message: "Currently only simulator can connect to my local server. Sorry for any inconvenience.", preferredStyle: .alert)
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            
            alert.addAction(cancelAction)
            
            present(alert, animated: true, completion: nil)
            
            switchButtonB.isOn = true
            #endif
        }
    }
    
    
    @IBAction func refreshAction(_ sender: Any) {
        if switchButtonB.isOn {
            if timer.isValid {
                timer.invalidate()
                return
            }
            timer = Timer.scheduledTimer(timeInterval: 1.5, target: self, selector: #selector(refresh), userInfo: nil, repeats: true)
        } else {
            timer.invalidate()
            
            let url = URL(string: "http://127.0.0.1:8000/refresh/Toronto")! 
            
            //create the session object
            let session = URLSession.shared
            
            //now create the URLRequest object using the url object
            let request = URLRequest(url: url)
            
            //create dataTask using the session object to send data to the server
            let task = session.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
                
                guard error == nil else {
                    return
                }
                
                guard let data = data else {
                    return
                }
                
                do {
                    print(response as Any)
                    //create json object from data
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                        print(json)
                    }
                } catch let error {
                    print(error.localizedDescription)
                }
            })
            
            task.resume()
        }
    }
    
    @IBAction func retrainAction(_ sender: Any) {
        if switchButtonB.isOn {
            if timer.isValid {
                timer.invalidate()
                return
            }
            timer = Timer.scheduledTimer(timeInterval: 1.5, target: self, selector: #selector(retrain), userInfo: nil, repeats: true)
        } else {
            timer.invalidate()
            
            let url = URL(string: "http://127.0.0.1:8000/retrain/Toronto")!
            
            //create the session object
            let session = URLSession.shared
            
            //now create the URLRequest object using the url object
            let request = URLRequest(url: url)
            
            //create dataTask using the session object to send data to the server
            let task = session.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
                
                guard error == nil else {
                    return
                }
                
                guard let data = data else {
                    return
                }
                
                do {
                    print(response as Any)
                    //create json object from data
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                        print(json)
                    }
                } catch let error {
                    print(error.localizedDescription)
                }
            })
            
            task.resume()
        }
    }
    
    
    @objc func refresh() {
        index += 1
        graphField.image = refreshImages[index]
        
        if index == 8 {
            index = 0
            timer.invalidate()
        }
    }
    
    @objc func retrain() {
        index += 1
        graphField.image = retrainImages[index]
        
        if index == 14 {
            index = 0
            timer.invalidate()
        }
    
    }
    
    @objc func respondToSwipeGesture(gesture: UIGestureRecognizer) {
        
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            
            switch swipeGesture.direction {
                
            case UISwipeGestureRecognizer.Direction.down:
                
                self.dismiss(animated: true, completion: nil)
                
            default:
                break
            }
        }
    }
}


