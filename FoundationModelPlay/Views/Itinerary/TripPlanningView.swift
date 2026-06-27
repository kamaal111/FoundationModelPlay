//
//  TripPlanningView.swift
//  FoundationModelPlay
//
//  Created by Kamaal M Farah on 6/27/26.
//

import SwiftUI
import FoundationModels

struct TripPlanningView: View {
    let landmark: Landmark

    private let model = SystemLanguageModel.default

    var body: some View {
        switch model.availability {
        case .available:
            LandmarkTripView(landmark: landmark)
        case .unavailable(.appleIntelligenceNotEnabled):
            MessageView(
                landmark: landmark,
                message: """
                Trip Planner is unavailable because \
                Apple Intelligence has not been turned on.
                """
            )
        case .unavailable(.modelNotReady):
            MessageView(
                landmark: landmark,
                message: """
                Trip Planner isn't ready yet. Try again later.
                """
            )
        default:
            ScrollView {
                LandmarkDescriptionView(landmark: landmark)
                    .headerStyle(landmark: landmark)
            }
        }
    }
}

#Preview {
    TripPlanningView(landmark: Landmarks.fuji)
}
