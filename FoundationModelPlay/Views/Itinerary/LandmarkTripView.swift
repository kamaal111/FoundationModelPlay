//
//  LandmarkTripView.swift
//  FoundationModelPlay
//
//  Created by Kamaal M Farah on 6/20/26.
//

import SwiftUI

struct LandmarkTripView: View {
    @State private var requestedItinerary = false
    @State private var planner: ItineraryPlanner?

    let landmark: Landmark

    var body: some View {
        if let error = planner?.error {
            MessageView(error: error, landmark: landmark)
        } else {
            ScrollView {
                if !requestedItinerary {
                    LandmarkDescriptionView(landmark: landmark)
                }
                if let itinerary = planner?.itinerary {
                    ItineraryView(landmark: landmark, itinerary: itinerary)
                }
            }
            .headerStyle(landmark: landmark)
            .scrollDisabled(!requestedItinerary)
            .task {
                planner = ItineraryPlanner(landmark: landmark)
            }
        }
    }

    func requestItinerary() async {
        requestedItinerary = true
        await planner?.suggestItinerary(dayCount: 3)
    }
}

#Preview {
    LandmarkTripView(landmark: Landmarks.landmarks.first!)
}
