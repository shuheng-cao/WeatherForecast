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
    var imageTimer = Timer()
    var loggingTimer = Timer()
    var imageIndex = 0
    var loggingIndex = 0
    var refreshImages: [UIImage] = []
    var retrainImages: [UIImage] = []
    var refreshLoggings : [String] = []
    var retrainLoggings : [String] = []
    
    
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
        
        updateLoggings()
        
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(respondToSwipeGesture))
        swipeDown.direction = UISwipeGestureRecognizer.Direction.down
        self.view.addGestureRecognizer(swipeDown)
    }
    
    @IBAction func touchSwitchA(_ sender: Any) {
        imageTimer.invalidate()
        loggingTimer.invalidate()
        imageIndex = 0
        loggingIndex = 0
        
        graphField.image = UIImage(named: "step0")
        if switchButtonA.isOn {

            textField.text = "\(formatedTime())\n\nNo connection to server\n\nEverything is handled in front end using Dark Sky API\n\nRefresh and Retrain are disabled"
            graphField.alpha = 0.5
            refreshButton.alpha = 0.5
            retrainButton.alpha = 0.5
        } else {
            graphField.alpha = 1
            refreshButton.alpha = 1
            retrainButton.alpha = 1
            textField.text =
            """
            Watching for file changes with StatReloader
            Performing system checks ...
            Connecting to Server ...
            """
            
        }
    }
    
    @IBAction func touchSwitchB(_ sender: Any) {
        imageTimer.invalidate()
        loggingTimer.invalidate()
        imageIndex = 0
        loggingIndex = 0
        
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
            if imageTimer.isValid || loggingTimer.isValid {
                imageTimer.invalidate()
                loggingTimer.invalidate()
                return
            }
            imageTimer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(refreshImage), userInfo: nil, repeats: true)
            loggingTimer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(refreshLogging), userInfo: nil, repeats: true)
        } else {
            imageTimer.invalidate()
            loggingTimer.invalidate()
            
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
            if imageTimer.isValid || loggingTimer.isValid {
                imageTimer.invalidate()
                loggingTimer.invalidate()
                return
            }
            imageTimer = Timer.scheduledTimer(timeInterval: 3.5, target: self, selector: #selector(retrainImage), userInfo: nil, repeats: true)
            loggingTimer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(retrainLogging), userInfo: nil, repeats: true)
        } else {
            imageTimer.invalidate()
            
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
    
    @objc func refreshLogging() {
        loggingIndex += 1
        textField.text += "\n\n" + refreshLoggings[loggingIndex]
        let range = NSMakeRange(textField.text.characters.count - 1, 0)
        textField.scrollRangeToVisible(range)
        
        if loggingIndex == 8 {
            loggingIndex = 0
            loggingTimer.invalidate()
        }
    }

    @objc func retrainLogging() {
        loggingIndex += 1
        print(loggingIndex)
        textField.text += "\n\n" + retrainLoggings[loggingIndex]
        let range = NSMakeRange(textField.text.characters.count - 1, 0)
        textField.scrollRangeToVisible(range)
        
        if loggingIndex == 16 {
            loggingIndex = 0
            loggingTimer.invalidate()
        }
    }
    
    @objc func refreshImage() {
        imageIndex += 1
        graphField.image = refreshImages[imageIndex]
        
        if imageIndex == 8 {
            imageIndex = 0
            imageTimer.invalidate()
        }
    }
    
    @objc func retrainImage() {
        imageIndex += 1
        graphField.image = retrainImages[imageIndex]
        
        if imageIndex == 14 {
            imageIndex = 0
            imageTimer.invalidate()
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
    
    func formatedTime() -> String {
        // get the current date and time
        let currentDateTime = Date()
        
        // initialize the date formatter and set the style
        let formatter = DateFormatter()
        // formatter.timeStyle = .full
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        // get the date time String from the date object
        return formatter.string(from: currentDateTime)
        
    }
    
    func updateLoggings() {
        
        // MARK: refresh loggings
        var logging =
"""
[\(formatedTime())]
Watching for file changes with StatReloader
Performing system checks...
"""
        refreshLoggings.append(logging)
        
        logging =
"""
[\(formatedTime())]
System check identified no issues (0 silenced).

You have 5 unapplied migration(s). Your project may not work properly until you apply the migrations for app(s): admin, auth, weather.
Run 'python manage.py migrate' to apply them.
"""
        refreshLoggings.append(logging)
        
        
        logging =
"""
[\(formatedTime())]
Django version 2.2.1, using settings 'jsondj.settings'
Starting development server at http://127.0.0.1:8000/
Quit the server with CONTROL-C.
"GET /refresh/Toronto HTTP/1.1" 200 197
"""
        refreshLoggings.append(logging)
        
        logging =
"""
[\(formatedTime())]
Using TensorFlow backend.
Successfully fetched current radar data from http://climate.weather.gc.ca/radar/index_e.html
Loading CNN model from disk ...
"""
        refreshLoggings.append(logging)
        logging =
"""
[\(formatedTime())]
cnn_model2 predicted today is of type 3

1 stands for Sunny,
2 stands for Rainy/Snowy,
3 stands for Cloudy/Partly Cloudy]
"""
        
        refreshLoggings.append(logging)
        logging =
"""
[\(formatedTime())]
Passing data to NN ...
"""
        
        refreshLoggings.append(logging)
        logging =
"""
[\(formatedTime())]
Successfully fetched current data from
https://api.darksky.net/forecast/10e08d045423d75673a8129ff5ad26c5/43.6518927, -79.381713
Loading NN model from disk ...
"""
        refreshLoggings.append(logging)
        logging =
"""
[\(formatedTime())]
nn_model2 predicted today is Partly Cloudy, with temperature 18°C
Passing data back to APP ...
"""
        refreshLoggings.append(logging)
        
        
        // MARK: retrain loggings
        logging =
"""
[\(formatedTime())]
Watching for file changes with StatReloader
Performing system checks...
"""
        refreshLoggings.append(logging)
        
        logging =
"""
[\(formatedTime())]
System check identified no issues (0 silenced).

You have 5 unapplied migration(s). Your project may not work properly until you apply the migrations for app(s): admin, auth, weather.
Run 'python manage.py migrate' to apply them.
"""
        retrainLoggings.append(logging)
        
        
        logging =
"""
[\(formatedTime())]
Django version 2.2.1, using settings 'jsondj.settings'
Starting development server at http://127.0.0.1:8000/
Quit the server with CONTROL-C.
"GET /retrain/Toronto HTTP/1.1" 200 197
"""
        retrainLoggings.append(logging)
        
        logging =
"""
[\(formatedTime())]
Loaded 10,000 past data from cache.
New CNN model created.
Using TensorFlow backend.
"""
        retrainLoggings.append(logging)
        logging =
"""
[\(formatedTime())]
Instructions for updating:
Colocations handled automatically by placer.
        
Instructions for updating:
Use tf.cast instead.
"""
        
        retrainLoggings.append(logging)
        logging =
"""
[\(formatedTime())]
Train on 5000 samples, validate on 1000 samples
        
Epoch 1/10:
    - 108s 22ms/step
    - loss: 3.3661 - acc: 0.7894
    - val_loss: 3.4815 - val_acc: 0.7840
"""
        
        retrainLoggings.append(logging)
        logging =
"""
[\(formatedTime())]
Epoch 5/10:
    - 103s 21ms/step
    - loss: 3.3236 - acc: 0.7938
    - val_loss: 3.4814 - val_acc: 0.7840
"""
        retrainLoggings.append(logging)
        logging =
"""
[\(formatedTime())]
Epoch 5/10:
    - 102s 20ms/step
    - loss: 3.3156 - acc: 0.7968
    - val_loss: 3.4752 - val_acc: 0.7850
"""
        retrainLoggings.append(logging)
        logging =
"""
[\(formatedTime())]
Train on 10000 samples, validate on 1000 samples
Epoch 1/30:
    - 188s 21ms/step
    - loss: 3.5258 - acc: 0.7812
    - val_loss: 3.4752 - val_acc: 0.7850
"""
        retrainLoggings.append(logging)
        logging =
"""
[\(formatedTime())]
Epoch 10/30:
    - 182s 21ms/step
    - loss: 3.4139 - acc: 0.7882
    - val_loss: 3.3214 - val_acc: 0.7872
"""
        
        retrainLoggings.append(logging)
        logging =
"""
[\(formatedTime())]
Epoch 20/30:
    - 181s 20ms/step
    - loss: 2.9907 - acc: 0.8145
    - val_loss: 3.1298 - val_acc: 0.7913
"""
        
        retrainLoggings.append(logging)
        logging =
"""
[\(formatedTime())]
Epoch 30/30:
    - 180s 20ms/step
    - loss: 2.9107 - acc: 0.8254
    - val_loss: 3.0213 - val_acc: 0.8013
Saving model as cnn_model2.json and cnn_model2.h5
"""
        
        retrainLoggings.append(logging)
        logging =
"""
[\(formatedTime())]
New neural network model created.
Loading data from cache ...
"""
        
        retrainLoggings.append(logging)
        logging =
"""
[\(formatedTime())]
Preprocessing 10,000 data ...
"""
        retrainLoggings.append(logging)
        logging =
"""
[\(formatedTime())]
Training model on 10,000 training data and 1,000 validation data.
Initial cost and accuracy
    - Cost on training data: 0.9883
    - Accuracy on training data: 0%
    - Cost on evaluation data: 1.0040
    - Accuracy on evaluation data: 0%
"""
        retrainLoggings.append(logging)
        logging =
"""
[\(formatedTime())]
Training model on 10,000 training data and 1,000 validation data.
Epoch 50 training complete
    - Cost on training data: 0.08588
    - Accuracy on training data: 89%
    - Cost on evaluation data: 0.09179
    - Accuracy on evaluation data: 87%
"""
        retrainLoggings.append(logging)
        logging =
"""
[\(formatedTime())]
Training model on 10,000 training data and 1,000 validation data.
Epoch 100 training complete
    - Cost on training data: 0.08877
    - Accuracy on training data: 88%
    - Cost on evaluation data: 0.0996
    - Accuracy on evaluation data: 87%
"""
        retrainLoggings.append(logging)
        logging =
"""
[\(formatedTime())]
Saving NN model to nn_model.json ...
"""
        retrainLoggings.append(logging)
    }
}


