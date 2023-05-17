//
//  WeatherViewModel.swift
//  archapp
//
//  Created by Krishna Kumar on 5/16/23.
//

import Foundation

protocol WeatherViewModel {
    var repository: WeatherRemoteRepository { get set }
    var weatherData: WeatherData? { get set }
    var lastSearchedCity: String? { get set }

    func fetchWeatherData(forCity city: String?, completion: @escaping (Result<WeatherData, Error>) -> Void)
    func fetchWeatherData(forLatitude latitude: Double, longitude: Double, completion: @escaping (Result<WeatherData, Error>) -> Void)
    func getContent() -> WeatherView.Content?
}

class DefaultWeatherViewModel: WeatherViewModel {
    var repository: WeatherRemoteRepository
    var weatherData: WeatherData?
    var lastSearchedCity: String?
    var userDefaultProvider: UserDefaultProvider

    init(repository: WeatherRemoteRepository, userDefaultProvider: UserDefaultProvider) {
        self.repository = repository
        self.userDefaultProvider = userDefaultProvider
    }

    func fetchWeatherData(forLatitude latitude: Double, longitude: Double, completion: @escaping (Result<WeatherData, Error>) -> Void) {
        repository.fetchWeatherData(queue: .main, forLatitude: latitude, longitude: longitude) { result in
            switch result {
            case let .success(weatherData):
                self.weatherData = weatherData
                completion(.success(weatherData))
            case let .failure(error):
                self.weatherData = nil
                completion(.failure(error))
            }
        }
    }

    func fetchWeatherData(forCity city: String? = nil, completion: @escaping (Result<WeatherData, Error>) -> Void) {
        let cityName = city ?? userDefaultProvider.getLastSearchedCity()
        guard let targetCity = cityName else {
            completion(.failure(RepositoryError.noData))
            return
        }
        lastSearchedCity = targetCity
        repository.fetchWeatherData(queue: .main, forCity: targetCity) { result in
            switch result {
            case let .success(weatherData):
                self.weatherData = weatherData
                self.lastSearchedCity = targetCity
                self.userDefaultProvider.saveLastSearchedCity(city: targetCity)
                completion(.success(weatherData))
            case let .failure(error):
                self.weatherData = nil
                completion(.failure(error))
            }
        }
    }

    func getContent() -> WeatherView.Content? {
        if let weatherData = weatherData {
            let roundedTemperature = Int(round(weatherData.main.temp))
            let content = WeatherView.Content(
                title: weatherData.name,
                weatherCardContent: WeatherCardView.Content(
                    cityName: weatherData.name,
                    temperatureText: "\(roundedTemperature) °F",
                    descriptionText: "\(weatherData.weather.first?.description.localizedCapitalized ?? "Not Available")",
                    icon: weatherData.weather.first?.icon ?? ""
                )
            )
            return content
        }

        return nil
    }
}
