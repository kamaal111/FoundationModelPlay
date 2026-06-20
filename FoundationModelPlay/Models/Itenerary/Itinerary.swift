//
//  Itinerary.swift
//  FoundationModelPlay
//
//  Created by Kamaal M Farah on 6/19/26.
//

import FoundationModels

@Generable
struct Itinerary: Hashable {
    @Guide(description: "An exciting name for the trip.")
    let title: String

    @Guide(.anyOf(Landmarks.landmarkNames))
    let destinationName: String
    let description: String

    @Guide(description: "An explanation of how the itinerary meets the users's special requests")
    let rationale: String

    @Guide(description: "A list of day-by-day plans")
    @Guide(.count(3))
    let days: [DayPlan]
}

@Generable
struct DayPlan: Hashable {
    @Guide(description: "A unique and exciting title for this day plan")
    let title: String
    let subtitle: String
    let destination: String

    @Guide(.count(3))
    let activities: [Activity]
}

@Generable
struct Activity: Hashable {
    let type: ActivityKind
    let title: String
    let description: String
}

@Generable
enum ActivityKind {
    case sightseeing
    case foodAndDining
    case shopping
    case hotelAndLodging

    var symbolName: String {
        switch self {
        case .sightseeing: "binoculars.fill"
        case .foodAndDining: "fork.knife"
        case .shopping: "bag.fill"
        case .hotelAndLodging: "bed.double.fill"
        }
    }
}
