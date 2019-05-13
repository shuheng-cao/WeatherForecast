//
//  DataViewController.swift
//  Rubbish
//
//  Created by shuster on 2019/3/7.
//  Copyright © 2019 曹书恒. All rights reserved.
//

import UIKit
import Foundation

class DataViewController: UIViewController, UIScrollViewDelegate {

    @IBOutlet weak var scrollingView: UIScrollView!
    @IBOutlet weak var longView: UIView!
    @IBOutlet weak var topPlaceHolder: UILabel!
    @IBOutlet weak var topName: UILabel!
    @IBOutlet weak var buttonPlaceHolder: UILabel!
    @IBOutlet weak var buttonName: UILabel!
    @IBOutlet weak var weatherCondition: UILabel!
    @IBOutlet var dateColumn:[UILabel]!
    @IBOutlet var weatherColumn:[UIButton]!
    @IBOutlet var probabilityColumn:[UILabel]!
    @IBOutlet var temperatureColumn:[UILabel]!
    
    var dataObject: DataController!
    
    var allowAPI = true
    let dispatchGroup = DispatchGroup()
    var last_called: DispatchTime = .now()
    
    // build the loading indicator
    lazy var refresher: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = .white
        let main_string = "Pull To Refresh"
        let range = (main_string as NSString).range(of: main_string)
        let attribute = NSMutableAttributedString.init(string: main_string)
        attribute.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.white, range: range)
        refreshControl.attributedTitle = attribute
        refreshControl.addTarget(self, action: #selector(requestData), for: .valueChanged)
        return refreshControl
    } ()

    
    override func viewDidLoad() {
        DispatchQueue.main.async {
            self.dataFetching() {
                super.viewDidLoad()
                self.scrollingView.delegate = self
                
                self.colorSetup()
                
                self.scrollingView.refreshControl = self.refresher
                
                self.animationSetup()
                self.scrollViewDidScroll(self.scrollingView)
            }
        }
    }

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollingView.contentOffset.y < -200 {
            refresher.beginRefreshing()
            requestData()
        } else if last_called + DispatchTimeInterval.seconds(1) < DispatchTime.now() {
            if scrollingView.contentOffset.y > 200 {
                buttonAnimation()
            } else {
                topAnimation()
            }
            last_called = .now()
        }
    }

    @objc func requestData() {
        self.dataFetching() {
            DispatchQueue.main.async {
                DispatchQueue.main.asyncAfter(deadline: .now() + DispatchTimeInterval.seconds(2)) {
                    print("requesting data")
                    self.refresher.endRefreshing()
                }
            }
        }
    }
    
    func colorSetup() {
        // scrolling view and header should be transparent
        longView.backgroundColor = UIColor(white: 1, alpha: 0.0)
        
        // Set up the attributed label
        topPlaceHolder.backgroundColor = UIColor(white: 1, alpha: 0.0)
        topPlaceHolder.textColor = .white
        topPlaceHolder.font = UIFont.init(name: "Zapfino", size: 20.0)
        topPlaceHolder.lineBreakMode = .byWordWrapping
        topPlaceHolder.numberOfLines = 0
        buttonPlaceHolder.lineBreakMode = .byWordWrapping
        buttonPlaceHolder.numberOfLines = 0
    }
    
    func animationSetup() {
//        choose a random quote for top and button
        var index: Int = Int(arc4random_uniform(UInt32(Quotes.count)))
        var name: String = Array(Quotes.keys)[index]
        topName.text = "- " + name
        index = Int(arc4random_uniform(UInt32(Quotes[name]!.count)))
        topPlaceHolder.text = Quotes[name]![index]
        
        index = Int(arc4random_uniform(UInt32(Quotes.count)))
        name = Array(Quotes.keys)[index]
        buttonName.text = "- " + name
        index = Int(arc4random_uniform(UInt32(Quotes[name]!.count)))
        buttonPlaceHolder.text = Quotes[name]![index]
        
        
        topPlaceHolder.animate(newText: topPlaceHolder.text!, characterDelay: 0.3, beginDelay: 0.0)
        var tmp = topPlaceHolder.text!.split(separator: " ")
        topName.animate(newText: topName.text!, characterDelay: 0.5, beginDelay: Double(tmp.count) * 0.3)
        buttonPlaceHolder.animate(newText: buttonPlaceHolder.text!, characterDelay: 0.3, beginDelay: 0.0)
        tmp = buttonPlaceHolder.text!.split(separator: " ")
        buttonName.animate(newText: buttonName.text!, characterDelay: 0.5, beginDelay: Double(tmp.count) * 0.3)
        topAnimation()
    }
    
    func topAnimation() {
//        clean up last few rows of table
        for i in 2...5 {
            dateColumn[i].alpha = 0
            weatherColumn[i].alpha = 0
            probabilityColumn[i].alpha = 0
            temperatureColumn[i].alpha = 0
        }
    }
    
    func buttonAnimation() {
        DispatchQueue.main.async {
            for i in 2...5 {
                DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.5) {
                    self.dateColumn[i].alpha = 1
                    self.weatherColumn[i].alpha = 1
                    self.probabilityColumn[i].alpha = 1
                    self.temperatureColumn[i].alpha = 1
                }
            }
        }
    }
    
    func dataFetching(completion: @escaping () -> Void) {
            print("\(self.dataObject.cityName)")
            print("\t\(self.probabilityColumn[0].text!),\(self.temperatureColumn[0].text!)")
            self.dataObject.update(allowAPI: self.allowAPI) {
                print("escaping handler")
                print(self.dataObject.weatherData.info.count)
                for (item, weather) in self.dataObject.weatherData.info.enumerated() {
                    DispatchQueue.main.async {
                        if item == 6 {
                            self.weatherCondition.text = "\(weather.lowTemp)°C \(weather.icon)"
                        } else {
                            self.weatherColumn[item].setImage(UIImage(named: weather.icon), for: .normal)
                            self.probabilityColumn[item].text = String(weather.probability) + "%"
                            if weather.probability == 100 {
                                self.probabilityColumn[item].text = "99%"
                            }
                            self.temperatureColumn[item].text = String(weather.lowTemp) + "°/" + String(weather.highTemp) + "°"
                            if weather.lowTemp < -9 || weather.highTemp < -9 {
                                self.temperatureColumn[item].text = String(weather.lowTemp) + "/" + String(weather.highTemp)
                            }
                            print("\t\(self.probabilityColumn[item].text!),\(self.temperatureColumn[item].text!)")
                        }
                        
                    }
                }
            }
        
        completion()
    }
}


// MARK: helper
func percentageColor(_ color1: UIColor,_ color2: UIColor,_ percentage: Float) -> UIColor {
    var (r1, g1, b1, a1) = (CGFloat(0), CGFloat(0), CGFloat(0), CGFloat(0))
    var (r2, g2, b2, a2) = (CGFloat(0), CGFloat(0), CGFloat(0), CGFloat(0))
    
    color1.getRed(&r1, green: &g1, blue: &b1, alpha: &a1)
    color2.getRed(&r2, green: &g2, blue: &b2, alpha: &a2)
    
    // add the components, but don't let them go above 1.0
    return UIColor(red: min(r2 + (r1 - r2) * CGFloat(percentage), 1),
                   green: min(g2 + (g1 - g2) * CGFloat(percentage), 1),
                   blue: min(b2 + (b1 - b2) * CGFloat(percentage), 1),
                   alpha: 1)
}

extension UILabel {
    
    func animate(newText: String, characterDelay: TimeInterval, beginDelay: TimeInterval) {
        
        var cnt: Double = beginDelay
        
        DispatchQueue.main.async {
            
            self.text = ""
            for word in newText.split(separator: " ") {
                cnt += characterDelay
                DispatchQueue.main.asyncAfter(deadline: .now() + cnt) {
                    self.text? += " " + word
                }
            }
        }
    }
    
}
