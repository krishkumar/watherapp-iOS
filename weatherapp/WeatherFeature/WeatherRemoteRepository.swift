//
//  WeatherRemoteRepository.swift
//  weatherapp
//
//  Created by Krishna Kumar on 5/17/23.
//

import Foundation

protocol WeatherRemoteRepository {
    var webService: WeatherWebService { get }
    func fetchWeatherData(
        queue: DispatchQueue,
        forCity city: String,
        completion: @escaping (Result<WeatherData, Error>) -> Void
    )
    func fetchWeatherData(
        queue: DispatchQueue,
        forLatitude latitude: Double,
        longitude: Double,
        completion: @escaping (Result<WeatherData, Error>) -> Void
    )
}

class DefaultWeatherRemoteRepository: WeatherRemoteRepository {
    let webService: WeatherWebService

    init(webService: WeatherWebService) {
        self.webService = webService
    }

    func fetchWeatherData(queue: DispatchQueue, forCity city: String, completion: @escaping (Result<WeatherData, Error>) -> Void) {
        webService.fetchWeatherData(queue: queue, forCity: city, completion: completion)
    }

    func fetchWeatherData(queue: DispatchQueue, forLatitude latitude: Double, longitude: Double, completion: @escaping (Result<WeatherData, Error>) -> Void) {
        webService.fetchWeatherData(queue: queue, forLatitude: latitude, longitude: longitude, completion: completion)
    }
}
