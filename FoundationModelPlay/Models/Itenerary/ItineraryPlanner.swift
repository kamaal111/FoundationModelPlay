//
//  ItineraryPlanner.swift
//  FoundationModelPlay
//
//  Created by Kamaal M Farah on 6/20/26.
//

import Observation
import FoundationModels

@Observable
final class ItineraryPlanner {
    private(set) var itinerary: Itinerary?
    private(set) var error: Error?

    let landmark: Landmark

    private let session: LanguageModelSession

    init(landmark: Landmark) {
        self.landmark = landmark
        self.session = Self.createSession(landmark: landmark)
    }

    func suggestItinerary(dayCount: Int) async {
        let response: LanguageModelSession.Response<Itinerary>
        do {
            response = try await session.respond(generating: Itinerary.self) {
                "Generate a \(dayCount)-day itinerary to \(landmark.name)."
                "Give it a fun title and description."
            }
        } catch {
            self.error = error
            return
        }

        itinerary = response.content
    }

    private static func createSession(landmark: Landmark) -> LanguageModelSession {
        let pointOfInterestTool = FindPointsOfInterestTool(landmark: landmark)

        return LanguageModelSession(tools: [pointOfInterestTool]) {
            "Your job is to create an itinerary for the user."

            """
            Use the \(pointOfInterestTool.name) tool to find various \
            businesses and activities in \(landmark.name).

            These point of interest categories mayb include \
            \(FindPointsOfInterestTool.formattedCategories)
            """

            """
            Here is the description of \(landmark.name) for your reference \
            when considering what activities to generate:
            """
            landmark.description

            "Here is an example:"
            Itinerary.exampleTripToJapan
        }
    }
}

extension Itinerary {
    fileprivate static let exampleTripToJapan = Itinerary(
        title: "Onsen Trip to Japan",
        destinationName: "Mt. Fuji",
        description: "Sushi, hot springs, and ryokan with a toddler!",
        rationale:
            """
            You are traveling with a child, so climbing Mt. Fuji is probably not an option, \
            but there is lots to do around Kawaguchiko Lake, including Fujikyu. \
            I recommend staying in a ryokan because you love hotsprings.
            """,
        days: [
            DayPlan(
                title: "Sushi and Shopping Near Kawaguchiko",
                subtitle: "Spend your final day enjoying sushi and souvenir shopping.",
                destination: "Kawaguchiko Lake",
                activities: [
                    Activity(
                        type: .foodAndDining,
                        title: "The Restaurant serving Sushi",
                        description: "Visit an authentic sushi restaurant for lunch."
                    ),
                    Activity(
                        type: .shopping,
                        title: "The Plaza",
                        description: "Enjoy souvenir shopping at various shops."
                    ),
                    Activity(
                        type: .sightseeing,
                        title: "The Beautiful Cherry Blossom Park",
                        description: "Admire the beautiful cherry blossom trees in the park."
                    ),
                    Activity(
                        type: .hotelAndLodging,
                        title: "The Hotel",
                        description:
                            "Spend one final evening in the hotspring before heading home."
                    )
                ]
            )
        ]
    )
}
