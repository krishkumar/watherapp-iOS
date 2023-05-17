//
//  weatherappTests.swift
//  weatherappTests
//
//  Created by Krishna Kumar on 5/16/23.
//

import CoreLocation
@testable import weatherapp
import XCTest

class WeatherViewControllerTests: XCTestCase {
    var sut: WeatherViewController!
    var mockViewModel: MockWeatherViewModel!
    var mockLocationManagerDelegate: MockLocationManagerDelegate!

    override func setUp() {
        super.setUp()
        mockViewModel = MockWeatherViewModel()
        sut = WeatherViewController(viewModel: mockViewModel, locationManager: CLLocationManager())
        mockLocationManagerDelegate = MockLocationManagerDelegate()
        sut.locationManager.delegate = mockLocationManagerDelegate
        sut.loadViewIfNeeded()
    }

    override func tearDown() {
        sut = nil
        mockViewModel = nil
        mockLocationManagerDelegate = nil
        super.tearDown()
    }

    func testFetchData_WithCityName() {
        sut.fetchData(cityName: "Test City")
        XCTAssertTrue(mockViewModel.getContent() != nil)
    }

    func testLocationManagerDelegate_DidUpdateLocations() {
        mockLocationManagerDelegate.locationManager(sut.locationManager, didUpdateLocations: [CLLocation(latitude: 0, longitude: 0)])
        XCTAssertTrue(mockLocationManagerDelegate.didUpdateLocationsCalled)
    }

    func testLocationManagerDelegate_DidFailWithError() {
        mockLocationManagerDelegate.locationManager(sut.locationManager, didFailWithError: NSError(domain: "Test", code: 0, userInfo: nil))
        XCTAssertTrue(mockLocationManagerDelegate.didFailWithErrorCalled)
    }

    func testLocationManagerDelegate_DidChangeAuthorization() {
        mockLocationManagerDelegate.locationManager(sut.locationManager, didChangeAuthorization: .authorizedWhenInUse)
        XCTAssertTrue(mockLocationManagerDelegate.didChangeAuthorizationCalled)
    }
}

class WeatherViewModelTestsFailures: XCTestCase {
    var mockWebService: MockWeatherWebService!
    var mockUserDefaultProvider: MockUserDefaultProvider!
    var viewModel: DefaultWeatherViewModel!

    override func setUp() {
        super.setUp()
        mockWebService = MockWeatherWebService()
        mockUserDefaultProvider = MockUserDefaultProvider()
        viewModel = DefaultWeatherViewModel(repository: DefaultWeatherRemoteRepository(webService: mockWebService), userDefaultProvider: mockUserDefaultProvider)
    }

    override func tearDown() {
        viewModel = nil
        mockWebService = nil
        mockUserDefaultProvider = nil
        super.tearDown()
    }

    func testFetchWeatherDataForCityFailure() {
        // Given
        let city = "Invalid City"
        let expectedError = NSError(domain: "TestError", code: 1, userInfo: nil)
        mockWebService.fetchWeatherDataForCityError = expectedError

        // When
        let expectation = expectation(description: "FetchWeatherDataForCityFailure")
        viewModel.fetchWeatherData(forCity: city) { result in
            // Then
            switch result {
            case .success:
                XCTFail("Expected failure, but got success")
            case let .failure(error as NSError):
                XCTAssertEqual(error, expectedError)
            }
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1, handler: nil)
    }

    func testFetchWeatherDataForCoordinatesFailure() {
        // Given
        let latitude = 0.0
        let longitude = 0.0
        let expectedError = NSError(domain: "TestError", code: 1, userInfo: nil)
        mockWebService.fetchWeatherDataForCoordinatesError = expectedError

        // When
        let expectation = expectation(description: "FetchWeatherDataForCoordinatesFailure")
        viewModel.fetchWeatherData(forLatitude: latitude, longitude: longitude) { result in
            // Then
            switch result {
            case .success:
                XCTFail("Expected failure, but got success")
            case let .failure(error as NSError):
                XCTAssertEqual(error, expectedError)
            }
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1, handler: nil)
    }
}

class WeatherViewModelTests: XCTestCase {
    var viewModel: DefaultWeatherViewModel!
    var mockRepository: MockWeatherRemoteRepository!
    var mockUserDefaultProvider: MockUserDefaultProvider!

    override func setUp() {
        super.setUp()
        mockRepository = MockWeatherRemoteRepository()
        mockUserDefaultProvider = MockUserDefaultProvider()
        viewModel = DefaultWeatherViewModel(repository: mockRepository, userDefaultProvider: mockUserDefaultProvider)
    }

    override func tearDown() {
        viewModel = nil
        mockRepository = nil
        mockUserDefaultProvider = nil
        super.tearDown()
    }

    func testFetchWeatherDataForCity() {
        let city = "Test City"
        let expectation = expectation(description: "FetchWeatherDataForCity")

        viewModel.fetchWeatherData(forCity: city) { result in
            switch result {
            case let .success(weatherData):
                XCTAssertEqual(weatherData.name, city)
            case .failure:
                XCTFail("Expected to fetch weather data for city")
            }
            expectation.fulfill()
        }

        waitForExpectations(timeout: 5, handler: nil)
        XCTAssertTrue(mockRepository.fetchWeatherDataCalled)
    }

    func testFetchWeatherDataForCoordinates() {
        let latitude = 40.7128
        let longitude = -74.0060
        let expectation = expectation(description: "FetchWeatherDataForCoordinates")

        viewModel.fetchWeatherData(forLatitude: latitude, longitude: longitude) { result in
            switch result {
            case let .success(weatherData):
                XCTAssertNotNil(weatherData)
            case .failure:
                XCTFail("Expected to fetch weather data for coordinates")
            }
            expectation.fulfill()
        }

        waitForExpectations(timeout: 5, handler: nil)
        XCTAssertTrue(mockRepository.fetchWeatherDataCalled)
    }

    func testGetContent() {
        let city = "Test City"
        XCTAssertNil(viewModel.getContent())

        let expectation = expectation(description: "FetchWeatherDataAndGetContent")

        viewModel.fetchWeatherData(forCity: city) { result in
            switch result {
            case .success:
                let content = self.viewModel.getContent()
                XCTAssertNotNil(content)
                XCTAssertEqual(content?.title, city)
            case .failure:
                XCTFail("Expected to fetch weather data and get content")
            }
            expectation.fulfill()
        }

        waitForExpectations(timeout: 5, handler: nil)
    }
}

class WeatherWebServiceTests: XCTestCase {
    var mockWebService: MockWeatherWebService!
    var jsonData: Data!

    override func setUp() {
        super.setUp()
        mockWebService = MockWeatherWebService()

        let jsonString = Mocks.mockWeatherJSON
        jsonData = jsonString.data(using: .utf8)
    }

    override func tearDown() {
        mockWebService = nil
        jsonData = nil
        super.tearDown()
    }

    func testFetchWeatherDataForCitySuccess() {
        let expectation = expectation(description: "FetchWeatherDataForCity")

        mockWebService.weatherData = try? JSONDecoder().decode(WeatherData.self, from: jsonData)

        mockWebService.fetchWeatherData(queue: .main, forCity: "Test City") { result in
            switch result {
            case let .success(weatherData):
                XCTAssertEqual(weatherData.name, "Test City")
                XCTAssertEqual(weatherData.weather.first?.description, "few clouds")
                XCTAssertEqual(weatherData.main.temp, 71.6)
            case .failure:
                XCTFail("FetchWeatherDataForCity succeed")
            }
            expectation.fulfill()
        }

        waitForExpectations(timeout: 5, handler: nil)
    }

    func testFetchWeatherDataForCoordinatesSuccess() {
        let expectation = expectation(description: "FetchWeatherDataForCoordinates")

        mockWebService.weatherData = try? JSONDecoder().decode(WeatherData.self, from: jsonData)

        mockWebService.fetchWeatherData(queue: .main, forLatitude: 40.7128, longitude: -74.0060) { result in
            switch result {
            case let .success(weatherData):
                XCTAssertEqual(weatherData.name, "Test City")
                XCTAssertEqual(weatherData.weather.first?.description, "few clouds")
                XCTAssertEqual(weatherData.main.temp, 71.6)
            case .failure:
                XCTFail("FetchWeatherDataForCoordinates succeed")
            }
            expectation.fulfill()
        }

        waitForExpectations(timeout: 5, handler: nil)
    }
}
