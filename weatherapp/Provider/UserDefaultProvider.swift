//
//  UserDefaultProvider.swift
//  archapp
//
//  Created by Krishna Kumar on 5/16/23.
//

import Foundation
protocol UserDefaultProvider {
    func saveLastSearchedCity(city: String)
    func getLastSearchedCity() -> String?
}

class DefaultUserDefaultProvider: UserDefaultProvider {
    private let defaults: UserDefaults
    private let lastSearchedCityKey = "lastSearchedCity"

    init(defaults: UserDefaults = UserDefaults.standard) {
        self.defaults = defaults
    }

    func saveLastSearchedCity(city: String) {
        defaults.set(city, forKey: lastSearchedCityKey)
    }

    func getLastSearchedCity() -> String? {
        defaults.string(forKey: lastSearchedCityKey)
    }
}
