//
//  DataPassingDelegate.swift
//  Weather?
//
//  Created by shuster on 2019/4/27.
//  Copyright © 2019 曹书恒. All rights reserved.
//

import Foundation

protocol DataPassingDelegate {
    func updateCities(newCities: [String])
    func goToPage(index: Int)
}

