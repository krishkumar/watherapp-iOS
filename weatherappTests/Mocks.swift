//
//  Mocks.swift
//  weatherappTests
//
//  Created by Krishna Kumar on 5/17/23.
//

import CoreLocation
import Foundation
@testable import weatherapp

class MockWeatherRemoteRepository: WeatherRemoteRepository {
    var webService: WeatherWebService = MockWeatherWebService()
    var fetchWeatherDataCalled = false

    func fetchWeatherData(queue: DispatchQueue, forCity city: String, completion: @escaping (Result<WeatherData, Error>) -> Void) {
        fetchWeatherDataCalled = true
        webService.fetchWeatherData(queue: queue, forCity: city, completion: completion)
    }

    func fetchWeatherData(queue: DispatchQueue, forLatitude latitude: Double, longitude: Double, completion: @escaping (Result<WeatherData, Error>) -> Void) {
        fetchWeatherDataCalled = true
        webService.fetchWeatherData(queue: queue, forLatitude: latitude, longitude: longitude, completion: completion)
    }
}

class MockUserDefaultProvider: UserDefaultProvider {
    var lastSearchedCity: String?

    func getLastSearchedCity() -> String? {
        lastSearchedCity
    }

    func saveLastSearchedCity(city: String) {
        lastSearchedCity = city
    }
}

class MockWeatherWebService: WeatherWebService {
    var weatherData: WeatherData? = Mocks.mockWeatherData
    var fetchWeatherDataForCityError: Error?
    var fetchWeatherDataForCoordinatesError: Error?

    func fetchWeatherData(queue _: DispatchQueue, forCity _: String, completion: @escaping (Result<WeatherData, Error>) -> Void) {
        if let error = fetchWeatherDataForCityError {
            completion(.failure(error))
        } else if let weatherData = weatherData {
            completion(.success(weatherData))
        }
    }

    func fetchWeatherData(queue _: DispatchQueue, forLatitude _: Double, longitude _: Double, completion: @escaping (Result<WeatherData, Error>) -> Void) {
        if let error = fetchWeatherDataForCoordinatesError {
            completion(.failure(error))
        } else if let weatherData = weatherData {
            completion(.success(weatherData))
        }
    }
}

class MockWeatherViewModel: WeatherViewModel {
    var repository: WeatherRemoteRepository = MockWeatherRemoteRepository()
    var weatherData: WeatherData?
    var lastSearchedCity: String?

    func fetchWeatherData(forCity _: String?, completion: @escaping (Result<WeatherData, Error>) -> Void) {
        completion(.success(Mocks.mockWeatherData))
    }

    func fetchWeatherData(forLatitude _: Double, longitude _: Double, completion: @escaping (Result<WeatherData, Error>) -> Void) {
        completion(.success(Mocks.mockWeatherData))
    }

    func getContent() -> WeatherView.Content? {
        WeatherView.Content(title: "Test City", weatherCardContent: WeatherCardView.Content(cityName: "Test City", temperatureText: "70 °F", descriptionText: "Sunny", icon: "01d"))
    }
}

class MockLocationManagerDelegate: NSObject, CLLocationManagerDelegate {
    var didUpdateLocationsCalled = false
    var didFailWithErrorCalled = false
    var didChangeAuthorizationCalled = false

    func locationManager(_: CLLocationManager, didUpdateLocations _: [CLLocation]) {
        didUpdateLocationsCalled = true
    }

    func locationManager(_: CLLocationManager, didFailWithError _: Error) {
        didFailWithErrorCalled = true
    }

    func locationManager(_: CLLocationManager, didChangeAuthorization _: CLAuthorizationStatus) {
        didChangeAuthorizationCalled = true
    }
}

enum Mocks {
    static let mockWeatherData = WeatherData(
        weather: [
            WeatherData.Weather(
                id: 801,
                main: "Clouds",
                description: "few clouds",
                icon: "02d"
            ),
        ],
        main: WeatherData.Main(
            temp: 71.6,
            feelsLike: 69.8,
            tempMin: 71.6,
            tempMax: 71.6,
            pressure: 1016,
            humidity: 64
        ),
        name: "Test City"
    )

    static let mockWeatherJSON = """
    {
        "weather": [
            {
                "id": 801,
                "main": "Clouds",
                "description": "few clouds",
                "icon": "02d"
            }
        ],
        "main": {
            "temp": 71.6,
            "feels_like": 69.8,
            "temp_min": 71.6,
            "temp_max": 71.6,
            "pressure": 1016,
            "humidity": 64
        },
        "name": "Test City"
    }
    """
}
