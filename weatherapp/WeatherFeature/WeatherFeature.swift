//
//  WeatherFeature.swift
//  archapp
//
//  Created by Krishna Kumar on 5/15/23.
//

import CoreLocation
import UIKit

// MARK: - Weather Feature

protocol WeatherFeatureCoordinator {
    var navigationPresenter: NavigationPresentation { get }
    var delegate: WeatherFeatureCoordinatorDelegate? { get set }
    var navigationController: UINavigationController? { get set }

    func navigateToWeather()
}

protocol WeatherFeatureCoordinatorDelegate: AnyObject {}

// MARK: - Model

struct WeatherData: Codable {
    let weather: [Weather]
    let main: Main
    let name: String

    struct Weather: Codable {
        let id: Int
        let main: String
        let description: String
        let icon: String
    }

    struct Main: Codable {
        let temp: Double
        let feelsLike: Double
        let tempMin: Double
        let tempMax: Double
        let pressure: Int
        let humidity: Int

        enum CodingKeys: String, CodingKey {
            case temp
            case feelsLike = "feels_like"
            case tempMin = "temp_min"
            case tempMax = "temp_max"
            case pressure
            case humidity
        }
    }
}

// MARK: - Concrete Implementation

final class DefaultWeatherFeatureCoordinator: WeatherFeatureCoordinator {
    let navigationPresenter: NavigationPresentation
    var delegate: WeatherFeatureCoordinatorDelegate?
    var navigationController: UINavigationController?

    init(
        navigationPresenter: NavigationPresentation = NavigationPresenter(),
        delegate: WeatherFeatureCoordinatorDelegate? = nil,
        navigationController: UINavigationController?
    ) {
        self.navigationPresenter = navigationPresenter
        self.delegate = delegate
        self.navigationController = navigationController
    }

    func navigateToWeather() {
        let weatherViewController = DefaultWeatherFeatureFactory().makeWeatherViewController()
        navigationPresenter.pushViewController(weatherViewController, from: navigationController)
    }
}

// MARK: - Factory

class DefaultWeatherFeatureFactory {
    public func makeWeatherViewController() -> WeatherViewController {
        WeatherViewController(
            viewModel: makeViewModel(),
            locationManager: CLLocationManager()
        )
    }

    func makeWebService() -> WeatherWebService {
        DefaultWeatherWebService()
    }

    func makeRemoteRepository() -> WeatherRemoteRepository {
        DefaultWeatherRemoteRepository(webService: makeWebService())
    }

    func makeViewModel() -> WeatherViewModel {
        DefaultWeatherViewModel(
            repository: makeRemoteRepository(),
            userDefaultProvider: makeUserDefaultProvider()
        )
    }

    func makeUserDefaultProvider() -> UserDefaultProvider {
        DefaultUserDefaultProvider()
    }
}
