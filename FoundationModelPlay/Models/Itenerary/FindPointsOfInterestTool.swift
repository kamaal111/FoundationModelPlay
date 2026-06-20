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
    }

    @Generable
    struct Arguments {
        @Guide(description: "This is the type of destination to look for.")
        let pointOfInterest: Category

        @Guide(description: "The natural language query of what to search for.")
        let naturalLanguageQuery: String
    }

    func call(arguments: Arguments) async throws -> String {
        let items = try await pointsOfInterest(nearby: landmark.locationCoordinate, arguments: arguments)
        let results = items.prefix(10).compactMap(\.name)

        return "There are these \(arguments.pointOfInterest) in \(landmark.name): \(results.formatted())"
    }

    private func pointsOfInterest(
        nearby location: CLLocationCoordinate2D,
        arguments: Arguments
    ) async throws -> [MKMapItem] {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = arguments.naturalLanguageQuery
        request.pointOfInterestFilter = .init(including: [arguments.pointOfInterest.toMapKitCategory])
        let distance: CLLocationDistance = 20_000
        request.region = MKCoordinateRegion(center: location, latitudinalMeters: distance, longitudinalMeters: distance)
        let search = MKLocalSearch(request: request)

        return try await search.start().mapItems
    }
}
