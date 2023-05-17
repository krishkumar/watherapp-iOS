//
//  WeatherFeature+Errors.swift
//  weatherapp
//
//  Created by Krishna Kumar on 5/16/23.
//

import Foundation
/// Errors

enum WebServiceError: Error {
    case missingKey
    case invalidURL
    case noData
}

enum RepositoryError: Error, Equatable {
    case noData
    case timeout(description: String)
    case noInternetConnection(description: String)
    case serialization(description: String)
}
