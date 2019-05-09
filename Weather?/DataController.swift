//
//  File.swift
//  Weather?
//
//  Created by shuster on 2019/3/15.
//  Copyright © 2019 曹书恒. All rights reserved.
//

import Foundation
import CoreLocation


class DataController {
    var cityName: String = ""
    var currentTime: String = TimeZone.current.abbreviation()!
    var weatherData: WeatherInfo!
    
    lazy var geocoder = CLGeocoder()
    var latitude: Double!
    var longitude: Double!
    let dispatchGroup = DispatchGroup()
    
    init(_ city: String,_ time: String) {
        if city != "" {
            cityName = city
        }
        if time != "" {
            currentTime = time
        }
        update(allowAPI: true) {}
    }
    
    func update(allowAPI: Bool, completion: @escaping () -> Void) {
        self.dispatchGroup.enter()
        updateLocation()
        self.dispatchGroup.notify(queue: .main, execute: {
            print("\(self.cityName), \(self.latitude!), \(self.longitude!)")
            self.weatherData = WeatherInfo(allowAPI: allowAPI, latitude: self.latitude, longitude: self.longitude) {
                print("calling completion with \(self.weatherData.info.count) items")
                completion()
                print("finishing update")
            }
        })
        print("return from update")
    }
    
    
    
    func updateLocation() {
        // Create Address String
        let address = ", \(cityName), "
        
        // Geocode Address String
        geocoder.geocodeAddressString(address) { (placemarks, error) in
            // Process Response
            self.processResponse(withPlacemarks: placemarks, error: error)
        }
    }
    
    private func processResponse(withPlacemarks placemarks: [CLPlacemark]?, error: Error?) {
        if let error = error {
            latitude = 0
            longitude = 0
            print("Unable to Forward Geocode Address (\(error))")
        } else {
            var location: CLLocation?
            
            if let placemarks = placemarks, placemarks.count > 0 {
                location = placemarks.first?.location
            }
            
            let coordinate = location!.coordinate
            latitude = coordinate.latitude
            longitude = coordinate.longitude
        }
        self.dispatchGroup.leave()
    }
}

class WeatherInfo {
    var info: [Weather] = []
    enum SerializationError:Error {
        case missing(String)
        case invalid(String, Any)
    }
    
    init(allowAPI: Bool, latitude: Double, longitude: Double, completion: @escaping () -> Void) {
        if (allowAPI) {
            constructInfo(latitude: latitude, longitude: longitude) { (results:[Weather]) in
                self.info = Array(results[0..<7])
                completion()
            }
        } else {
            // TODO: connect to local server
        }
    }
    
    func constructInfo(latitude: Double, longitude: Double, completion: @escaping ([Weather]) -> ()) {
        let basePath = "https://api.darksky.net/forecast/10e08d045423d75673a8129ff5ad26c5/"
        let url = basePath + "\(latitude),\(longitude)"
        let request = URLRequest(url: URL(string: url)!)
        
        let task = URLSession.shared.dataTask(with: request) { (data:Data?, response:URLResponse?, error:Error?) in
            
            var forecastArray:[Weather] = []
            
            if let data = data {
                
                // MARK: 3 kinds of weather data, currently, next hour and next few days
                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String:Any] {
                        if let hourlyForecasts = json["hourly"] as? [String:Any] {
                            if let hourlyData = hourlyForecasts["data"] as? [[String:Any]] {
                                if let weatherObject = try? Weather(json: hourlyData[0]) {
                                    forecastArray.append(weatherObject)
                                }
                            }
                        }
                        
                        if let dailyForecasts = json["daily"] as? [String:Any] {
                            if let dailyData = dailyForecasts["data"] as? [[String:Any]] {
                                for dataPoint in dailyData {
                                    if let weatherObject = try? Weather(json: dataPoint) {
                                        forecastArray.append(weatherObject)
                                    }
                                }
                            }
                        }
                        
                        if let currentWeather = json["currently"] as? [String:Any] {
                            if let weatherObject = try? Weather(json: currentWeather) {
                                forecastArray.append(weatherObject)
                            }
                        }
                        
                    }
                }catch {
                    print(error.localizedDescription)
                }
                
                completion(forecastArray)
                
            }
            
            
        }
        
        task.resume()
    }
}

class Weather {
    var icon: String = ""
    var probability: Int = 0
    var lowTemp: Int = 0
    var highTemp: Int = 0
    
    init(json:[String:Any]) {
        let condition = json["icon"] as! String
        let prob = json["precipProbability"] as! Double
        var low: Double = 0
        var high: Double = 0
        if json.keys.contains("temperatureLow") {
            low = json["temperatureLow"] as! Double
            high = json["temperatureHigh"] as! Double
        } else {
            low = floor(min(json["apparentTemperature"] as! Double, json["temperature"] as! Double))
            high = ceil(max(json["apparentTemperature"] as! Double, json["temperature"] as! Double))
        }
        
        if (condition == "clear-day" || condition == "clear-night") {
            self.icon = "sunny"
        } else if (condition == "partly-cloudy-day" || condition == "partly-cloudy-night") {
            self.icon = "partly cloudy"
        } else if (condition == "rain") {
            self.icon = "rainy"
        } else if (condition == "snow") {
            self.icon = "snowy"
        } else {
            self.icon = "cloudy"
        }
        
        self.probability = Int(prob * 100)
        self.lowTemp = convert(low)
        self.highTemp = convert(high)
    }
}

private func convert(_ fahrenheit: Double) -> Int {
    return Int((fahrenheit-32) * 5 / 9)
}







