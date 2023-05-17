//
//  WeatherViewController.swift
//  archapp
//
//  Created by Krishna Kumar on 5/16/23.
//

import CoreLocation
import UIKit

class WeatherViewController: UIViewController {
    let viewModel: WeatherViewModel
    var rootView: WeatherView { view as! WeatherView }
    let locationManager: CLLocationManager

    init(viewModel: WeatherViewModel, locationManager: CLLocationManager) {
        self.viewModel = viewModel
        self.locationManager = locationManager
        super.init(nibName: nil, bundle: nil)
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
    }

    override func loadView() {
        view = WeatherView()
        rootView.delegate = self
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = nil
        navigationItem.hidesBackButton = true
        fetchData()
    }

    func fetchData(cityName: String? = nil) {
        rootView.showLoadingIndicator()
        if locationManager.authorizationStatus == .denied || locationManager.authorizationStatus == .restricted || !(cityName?.isEmpty ?? true) {
            viewModel.fetchWeatherData(forCity: cityName) { _ in
                self.handleWeatherDataResponse()
            }
        } else if locationManager.authorizationStatus == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
        } else {
            locationManager.startUpdatingLocation()
        }
    }

    private func handleWeatherDataResponse() {
        if let content = viewModel.getContent() {
            rootView.populate(content: content)
        } else {
            rootView.showAlert(title: "Error", message: "Weather information is unavailable")
        }
        rootView.hideLoadingIndicator()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension WeatherViewController: WeatherViewDelegate {
    func getWeatherFor(_ city: String) {
        fetchData(cityName: city)
    }

    func weatherView(_: WeatherView, showAlertWithTitle title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
}

extension WeatherViewController: CLLocationManagerDelegate {
    func locationManager(_: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            locationManager.stopUpdatingLocation()
            viewModel.fetchWeatherData(forLatitude: location.coordinate.latitude, longitude: location.coordinate.longitude) { _ in
                if let content = self.viewModel.getContent() {
                    self.rootView.populate(content: content)
                } else {
                    self.rootView.showAlert(title: "Error", message: "Weather information is unavailable. Try again")
                }
                self.rootView.hideLoadingIndicator()
            }
        }
    }

    func locationManager(_: CLLocationManager, didFailWithError error: Error) {
        print("Error: \(error.localizedDescription)")
        locationManager.stopUpdatingLocation()
        rootView.hideLoadingIndicator()
    }

    func locationManager(_: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.startUpdatingLocation()
        case .denied, .restricted:
            rootView.showAlert(title: "No Location Access", message: "Search for your city to get latest weather")
            fetchData()
        default:
            break
        }
    }
}
