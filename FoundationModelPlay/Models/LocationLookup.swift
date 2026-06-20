//
//  LocationLookup.swift
//  FoundationModelPlay
//
//  Created by Kamaal M Farah on 6/20/26.
//

import os
import MapKit
import WeatherKit
import Observation

@Observable
final class LocationLookup {
    private(set) var item: MKMapItem?
    private(set) var temperatureString: String?

    private let weatherFormatter: MeasurementFormatter

    init() {
        self.weatherFormatter = Self.makeWeatherFormatter()
    }

    func performLookup(location: String) {
        Task {
            let item = await mapItem(atLocation: location)
            guard let location = item?.location else { return }

            temperatureString = await weather(atLocation: location)
        }
    }

    private func mapItem(atLocation location: String) async -> MKMapItem? {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = location
        
        let search = MKLocalSearch(request: request)
        do {
            return try await search.start().mapItems.first
        } catch {
            Logging.general.error("Failed to look up location: \(location). Error: \(error)")
        }
        return nil
    }

    private func weather(atLocation location: CLLocation) async -> String {
        let weather: CurrentWeather
        do {
            weather = try await WeatherService.shared.weather(for: location, including: .current)
        } catch {
            Logging.general.error("Couldn't fetch weather: \(error.localizedDescription)")
            return "unavailable"
        }

        return weatherFormatter.string(from: weather.temperature)
    }

    private static func makeWeatherFormatter() -> MeasurementFormatter {
        let weatherFormatter = MeasurementFormatter()
        weatherFormatter.unitOptions = .providedUnit
        weatherFormatter.numberFormatter.maximumFractionDigits = 1

        return weatherFormatter
    }
}
