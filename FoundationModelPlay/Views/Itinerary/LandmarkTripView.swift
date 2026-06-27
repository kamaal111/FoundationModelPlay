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
        if let errorMessage = planner?.errorMessage {
            MessageView(landmark: landmark, message: errorMessage)
        } else {
            ScrollView {
                if !requestedItinerary {
                    LandmarkDescriptionView(landmark: landmark)
                }
                if let itinerary = planner?.itinerary {
                    ItineraryView(landmark: landmark, itinerary: itinerary)
                        .padding()
                }
            }
            .headerStyle(landmark: landmark)
            .safeAreaInset(edge: .bottom) {
                ItineraryButton { await requestItinerary() }
            }
            .scrollDisabled(!requestedItinerary)
            .task {
                planner = ItineraryPlanner(landmark: landmark)
                planner?.prewarm()
            }
        }
    }

    func requestItinerary() async {
        requestedItinerary = true
        await planner?.suggestItinerary(dayCount: 3)
    }
}

private struct ItineraryButton: View {
    @State private var showButton: Bool = false

    let closure: () async -> Void

    var body: some View {
        VStack {
            Button(action: handlePress) {
                Label("Generate Itinerary", systemImage: "sparkles")
                    .fontWeight(.bold)
                    .padding()
            }
            .buttonStyle(.bordered)
            .padding()
            .opacity(showButton ? 1 : 0)
            .animation(.easeInOut(duration: 0.5), value: showButton)
            .onAppear(perform: handleOnAppear)
            .transition(.opacity)
        }
        .frame(maxWidth: .infinity, alignment: .bottom)
    }

    private func handlePress() {
        showButton = false
        Task { @MainActor in await closure() }
    }

    private func handleOnAppear() {
        showButton = true
    }
}

#Preview {
    LandmarkTripView(landmark: Landmarks.landmarks.first!)
}
