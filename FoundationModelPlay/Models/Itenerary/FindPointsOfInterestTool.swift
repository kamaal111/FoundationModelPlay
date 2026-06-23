//
//  FindPointsOfInterestTool.swift
//  FoundationModelPlay
//
//  Created by Kamaal M Farah on 6/21/26.
//

import MapKit
import FoundationModels

struct FindPointsOfInterestTool: Tool {
    let name = "findPointsOfInterest"
    let description = "Finds points of interest for a landmark."

    let landmark: Landmark

    static var formattedCategories: String { Category.allCases.map(\.rawValue).joined(separator: ", ") }

    @Generable
    enum Category: String, CaseIterable {
        case restaurant
        case campground
        case hotel
        case cafe
        case museum
        case marina
        case nationalMonument

        var toMapKitCategory: MKPointOfInterestCategory {
            switch self {
            case .restaurant: .restaurant
            case .campground: .campground
            case .hotel: .hotel
            case .cafe: .cafe
            case .museum: .museum
            case .marina: .marina
            case .nationalMonument: .nationalMonument
            }
        }

        var searchQuery: String {
            switch self {
            case .restaurant: "restaurant"
            case .campground: "campground"
            case .hotel: "hotel"
            case .cafe: "cafe"
            case .museum: "museum"
            case .marina: "marina"
            case .nationalMonument: "national monument"
            }
        }
    }

    @Generable
    struct Arguments {
        @Guide(description: "The type of destination to look for.")
        let pointOfInterest: Category

        @Guide(description: "The natural language query of what to search for.")
        let naturalLanguageQuery: String
    }

    func call(arguments: Arguments) async throws -> String {
        let items = await pointsOfInterest(nearby: landmark.locationCoordinate, arguments: arguments)
        let results = items.prefix(10).compactMap(\.name)

        guard !results.isEmpty else {
            return """
            MapKit found no \(arguments.pointOfInterest.rawValue) results for \
            \(landmark.name). Continue planning \
            with well-known places and general travel knowledge for this landmark.
            """
        }

        return "There are these \(arguments.pointOfInterest) in \(landmark.name): \(results.formatted())"
    }

    private func pointsOfInterest(nearby location: CLLocationCoordinate2D, arguments: Arguments) async -> [MKMapItem] {
        for request in requests(nearby: location, arguments: arguments) {
            do {
                let items = try await MKLocalSearch(request: request).start()
                    .mapItems
                    .filter { item in
                        let itemLocation = item.location
                        let distance = itemLocation
                            .distance(from: CLLocation(latitude: location.latitude, longitude: location.longitude))

                        return distance <= 1_500_000
                    }
                if !items.isEmpty {
                    return items
                }
            } catch {
                continue
            }
        }

        return []
    }

    private func requests(nearby location: CLLocationCoordinate2D, arguments: Arguments) -> [MKLocalSearch.Request] {
        let regionalDistances: [CLLocationDistance] = [
            20_000,
            100_000,
            300_000,
            800_000
        ]

        let requests = regionalDistances.map { distance in
            let request = MKLocalSearch.Request()
            request.naturalLanguageQuery = arguments.naturalLanguageQuery
            request.resultTypes = .pointOfInterest
            request.pointOfInterestFilter = .init(including: [arguments.pointOfInterest.toMapKitCategory])
            request.region = MKCoordinateRegion(
                center: location,
                latitudinalMeters: distance,
                longitudinalMeters: distance
            )
            return request
        }

        return requests
    }
}
