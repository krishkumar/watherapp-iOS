//
//  BundleInfo.swift
//  weatherapp
//
//  Created by Krishna Kumar on 5/17/23.
//

import Foundation
class BundleInfo {
    static let apikey: String? = {
        guard let path = Bundle.main.path(forResource: "APIInfo", ofType: "plist"),
              let dict = NSDictionary(contentsOfFile: path) as? [String: Any],
              let accessCode = dict["apikey"] as? String
        else {
            return nil
        }
        return accessCode
    }()
}
