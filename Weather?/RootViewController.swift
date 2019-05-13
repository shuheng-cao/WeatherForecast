//
//  RootViewController.swift
//  Rubbish
//
//  Created by shuster on 2019/3/7.
//  Copyright © 2019 曹书恒. All rights reserved.
//

import UIKit

class RootViewController: UIViewController, UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    var pageData: [DataController] = []
    var timeZoneMapping: [String : TimeZone] = [:]
    var currentIndex = 0
    var pageViewController: UIPageViewController?
    @IBOutlet weak var header: UIView!
    @IBOutlet weak var menuButton: UIButton!
    @IBOutlet weak var devButton: UIButton!
    @IBOutlet weak var locationabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataInitialization()
        // Do any additional setup after loading the view, typically from a nib.
        // Configure the page view controller and add it as a child view controller.
        pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)

        let startingViewController: DataViewController = self.viewControllerAtIndex(0, storyboard: self.storyboard!)!
        pageViewController!.setViewControllers([startingViewController], direction: .forward, animated: false, completion: {done in })

        pageViewController!.dataSource = self
        pageViewController!.delegate = self

        self.addChild(pageViewController!)
        self.view.addSubview(pageViewController!.view)

        // Set the page view controller's bounds, the offset is for header
        var pageViewRect = self.view.bounds
        pageViewRect = CGRect(x: pageViewRect.minX, y: pageViewRect.minY + CGFloat(120), width: pageViewRect.width, height: pageViewRect.height - CGFloat(120))
        pageViewController!.view.frame = pageViewRect

        pageViewController!.didMove(toParent: self)
        
        colorSetup()
        // label setup
        updateTimeAndLocation()
    }
    
    @IBAction func showCityList(_ sender: Any) {
        showCityListVC()
    }
    
    @IBAction func showDeveloper(_ sender: Any) {
        showDeveloperVC()
    }
    
    func showDeveloperVC() {
        //change view controllers
        
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let resultViewController = storyBoard.instantiateViewController(withIdentifier: "DeveloperModeController") as! DeveloperModeController
        
        resultViewController.modalTransitionStyle = .coverVertical
        self.present(resultViewController, animated: true, completion: nil)
    }
    
    func showCityListVC() {
        //change view controllers
        
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        
        let resultViewController = storyBoard.instantiateViewController(withIdentifier: "CityListController") as! CityListController
        
        // passing history table
        for data in pageData {
            resultViewController.cityList.append(data.cityName)
        }
        
        resultViewController.modalTransitionStyle = .coverVertical
        resultViewController.delegate = (self as DataPassingDelegate)
        
        self.present(resultViewController, animated: true, completion: nil)
    }

    func dataInitialization() {
        let timeZoneIdentifiers = TimeZone.knownTimeZoneIdentifiers
        for identifier in timeZoneIdentifiers {
            timeZoneMapping.updateValue(TimeZone(identifier: identifier)!, forKey: convertLocationString(identifier: identifier))
        }
        // MARK: For debugging
        timeZoneMapping.updateValue(timeZoneMapping["Toronto"]!, forKey: "Waterloo")
        timeZoneMapping.updateValue(timeZoneMapping["Toronto"]!, forKey: "Ottawa")
        for city in ["Vancouver", "Waterloo", "Toronto", "Ottawa", "Yellowknife", "New York", "Los Angeles", "Montreal", "Panama", "Tahiti", "Honolulu", "Rome", "Paris", "Moscow", "Dublin", "Amsterdam", "Darwin", "Tokyo", "Shanghai", "Hong Kong"] {
            let timeZone = timeZoneMapping[city]
            
            pageData.append(DataController(city, trimDate(timeZone: timeZone!)))
        }
    }
    
    func convertLocationString(identifier: String) -> String {
        let location = String(identifier.split(separator: "/").last!)
        return location.replacingOccurrences(of: "_", with: " ", options: .literal, range: nil)
    }
    
    func trimDate(timeZone: TimeZone) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .none
        dateFormatter.timeStyle = .short
        dateFormatter.timeZone = timeZone
        return dateFormatter.string(from: Date())
    }
    
    // helper functions for page view controller
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        print("index -1")
        var index = self.indexOfViewController(viewController as! DataViewController)
        if (index == 0) || (index == NSNotFound) {
            return nil
        }
        
        index -= 1
        return self.viewControllerAtIndex(index, storyboard: viewController.storyboard!)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        print("index +1")
        var index = self.indexOfViewController(viewController as! DataViewController)
        if index == NSNotFound {
            return nil
        }
        
        index += 1
        if index == self.pageData.count {
            return nil
        }
        return self.viewControllerAtIndex(index, storyboard: viewController.storyboard!)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        //        if finished || completed {
        updateTimeAndLocation()
        //        }
    }
    
    func viewControllerAtIndex(_ index: Int, storyboard: UIStoryboard) -> DataViewController? {
        // Return the data view controller for the given index.
        if (self.pageData.count == 0) || (index >= self.pageData.count) {
            return nil
        }
        
        // Create a new view controller and pass suitable data.
        let dataViewController = storyboard.instantiateViewController(withIdentifier: "DataViewController") as! DataViewController
        dataViewController.dataObject = self.pageData[index]
        currentIndex = index
        return dataViewController
    }
    
    func indexOfViewController(_ viewController: DataViewController) -> Int {
        // Return the index of the given data view controller.
        // For simplicity, this implementation uses a static array of model objects and the view controller stores the model object; you can therefore use the model object to identify the index.
        return currentIndex
    }
    
    
    // Setups
    func colorSetup() {
        let topColor = Colors.black
        let bottomColor = Colors.veryDarkGrey
        header.backgroundColor = UIColor(white: 1, alpha: 0.0)
        view.setGradientBackground(colorOne: bottomColor, colorTwo: topColor)
    }
    
    func updateTimeAndLocation() {
        locationabel.text = pageData[currentIndex].cityName
        timeLabel.text = pageData[currentIndex].currentTime
        locationabel.textColor = .white
        timeLabel.textColor = .white
    }
}

extension RootViewController: DataPassingDelegate {
    func goToPage(index: Int) {
        print("calling go to page")
        pageViewController?.setViewControllers([self.viewControllerAtIndex(index, storyboard: self.storyboard!)!], direction: .forward, animated: false, completion: nil)
        DispatchQueue.main.async() {
            self.updateTimeAndLocation()
            self.pageViewController!.dataSource = nil
            self.pageViewController!.dataSource = self
        }
    }
    
    func updateCities(newCities: [String]) {
        pageData = []
        for city in newCities {
            pageData.append(DataController(city, trimDate(timeZone: timeZoneMapping[city]!)))
        }
    }
}
