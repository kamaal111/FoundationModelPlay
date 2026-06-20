//
//  ItineraryView.swift
//  FoundationModelPlay
//
//  Created by Kamaal M Farah on 6/20/26.
//

import SwiftUI
import FoundationModels

struct ItineraryView: View {
    let landmark: Landmark
    let itinerary: Itinerary

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading) {
                Text(itinerary.title)
                    .contentTransition(.opacity)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                Text(itinerary.description)
                    .contentTransition(.opacity)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            HStack(alignment: .top) {
                Image(systemName: "sparkles")
                Text(itinerary.rationale)
                    .contentTransition(.opacity)
            }
            .rationaleStyle()
            ForEach(itinerary.days, id: \.self) { plan in
                DayView(landmark: landmark, plan: plan)
                    .transition(.blurReplace)
            }
        }
        .animation(.easeOut, value: itinerary)
        .itineraryStyle()
    }
}

private struct DayView: View {
    @State private var map = LocationLookup()

    let landmark: Landmark
    let plan: DayPlan

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            ZStack(alignment: .bottom) {
                LandmarkDetailMapView(
                    landmark: landmark,
                    landmarkMapItem: map.item
                )
                .onChange(of: plan.destination) {
                    if !plan.destination.isEmpty {
                        map.performLookup(location: plan.destination)
                    }
                }

                VStack(alignment: .leading) {
                    Text(weatherForecast)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Text(plan.title)
                        .contentTransition(.opacity)
                        .font(.headline)
                    Text(plan.subtitle)
                        .contentTransition(.opacity)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .blurredBackground()
            }
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .frame(maxWidth: .infinity)
            .frame(height: 200)
            .padding([.horizontal, .top], 4)
            ActivityList(activities: plan.activities)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
        }
        .padding(.bottom)
        .geometryGroup()
        .card()
        .animation(.easeInOut, value: plan)
    }

    var weatherForecast: LocalizedStringKey {
        if let forecast = map.temperatureString {
            "\(Image(systemName: "cloud.fill")) \(forecast)"
        } else {
            " "
        }
    }
}

private struct ActivityList: View {
    let activities: [Activity]

    var body: some View {
        ForEach(activities, id: \.self) { activity in
            HStack(alignment: .top, spacing: 12) {
                ActivityIcon(symbolName: activity.type.symbolName)
                VStack(alignment: .leading) {
                    Text(activity.title)
                        .contentTransition(.opacity)
                        .font(.headline)
                    Text(activity.description)
                        .contentTransition(.opacity)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
}
