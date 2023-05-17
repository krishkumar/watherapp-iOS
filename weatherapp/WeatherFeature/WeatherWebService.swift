//
//  WeatherWebService.swift
//  weatherapp
//
//  Created by Krishna Kumar on 5/17/23.
//

import Foundation

protocol WeatherWebService {
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

class DefaultWeatherWebService: WeatherWebService {
    func fetchWeatherData(queue: DispatchQueue, forCity city: String, completion: @escaping (Result<WeatherData, Error>) -> Void) {
        guard let encodedCity = city.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            completion(.failure(WebServiceError.invalidURL))
            return
        }

        guard let apiKey = BundleInfo.apikey else {
            queue.async {
                completion(.failure(WebServiceError.missingKey))
            }
            return
        }

        let endpoint = "https://api.openweathermap.org/data/2.5/weather?q=\(encodedCity)&units=imperial&appid=\(apiKey)"
        var weatherData: WeatherData?
        var webServiceError: Error?
        guard let url = URL(string: endpoint) else {
            completion(.failure(URLError(.badURL)))
            return
        }

        let dispatchGroup = DispatchGroup()
        dispatchGroup.enter()
        URLSession.shared.dataTask(with: url) { data, _, error in
            defer { dispatchGroup.leave() }
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(URLError(.badServerResponse)))
                return
            }

            do {
                weatherData = try JSONDecoder().decode(WeatherData.self, from: data)
            } catch {
                webServiceError = error
            }
        }.resume()
        dispatchGroup.notify(queue: .main) {
            if let data = weatherData {
                completion(.success(data))
            } else if let error = webServiceError {
                completion(.failure(error))
            }
        }
    }

    func fetchWeatherData(queue: DispatchQueue, forLatitude latitude: Double, longitude: Double, completion: @escaping (Result<WeatherData, Error>) -> Void) {
        guard let apiKey = BundleInfo.apikey else {
            queue.async {
                completion(.failure(WebServiceError.missingKey))
            }
            return
        }
        let endpoint = "https://api.openweathermap.org/data/2.5/weather?lat=\(latitude)&lon=\(longitude)&units=imperial&appid=\(apiKey)"
        var weatherData: WeatherData?
        var webServiceError: Error?
        guard let url = URL(string: endpoint) else {
            queue.async {
                completion(.failure(WebServiceError.invalidURL))
            }
            return
        }

        let dispatchGroup = DispatchGroup()
        dispatchGroup.enter()
        URLSession.shared.dataTask(with: url) { data, _, error in
            defer { dispatchGroup.leave() }
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(URLError(.badServerResponse)))
                return
            }

            do {
                weatherData = try JSONDecoder().decode(WeatherData.self, from: data)
            } catch {
                webServiceError = error
            }
        }.resume()
        dispatchGroup.notify(queue: .main) {
            if let data = weatherData {
                completion(.success(data))
            } else if let error = webServiceError {
                completion(.failure(error))
            }
        }
    }
}
