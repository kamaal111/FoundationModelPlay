//
//  ItineraryPlanner.swift
//  FoundationModelPlay
//
//  Created by Kamaal M Farah on 6/20/26.
//

import Foundation
import Observation
import FoundationModels

@Observable
final class ItineraryPlanner {
    private(set) var itinerary: Itinerary?
    private(set) var error: Error?
    private(set) var errorMessage: String?

    let landmark: Landmark

    private let researchSession: LanguageModelSession
    private let itinerarySession: LanguageModelSession

    init(landmark: Landmark) {
        self.landmark = landmark
        self.researchSession = Self.createResearchSession(landmark: landmark)
        self.itinerarySession = Self.createItinerarySession(landmark: landmark)
    }

    func suggestItinerary(dayCount: Int) async {
        let pointOfInterestSummary: String
        do {
            pointOfInterestSummary = try await researchPointOfInterestSummary()
        } catch {
            setError(error)
            return
        }

        let response: LanguageModelSession.Response<Itinerary>
        do {
            response = try await itinerarySession.respond(generating: Itinerary.self) {
                """
                Generate a complete \(dayCount)-day itinerary to \(landmark.name).

                You must fill every required property:
                - title
                - destinationName
                - description
                - rationale
                - exactly \(dayCount) days
                - exactly 3 activities per day

                Use \(landmark.name) as destinationName.
                Give it a fun title and description.
                """

                """
                Use these point-of-interest search results when they are relevant:
                \(pointOfInterestSummary)
                """
            }
        } catch {
            setError(error)
            return
        }

        itinerary = response.content
    }

    private func researchPointOfInterestSummary() async throws -> String {
        let response = try await researchSession.respond {
            """
            Research useful points of interest for a \(landmark.name) itinerary.

            Use the findPointsOfInterest tool for restaurant, hotel, campground, \
            museum, and nationalMonument. Summarize the useful findings in plain \
            English. If a category has no results, say that directly. Do not create \
            the itinerary.
            """
        }

        return response.content
    }

    private func setError(_ error: Error) {
        self.error = error
        errorMessage = Self.message(for: error)
    }

    private static func createResearchSession(landmark: Landmark) -> LanguageModelSession {
        let pointOfInterestTool = FindPointsOfInterestTool(landmark: landmark)

        return LanguageModelSession(tools: [pointOfInterestTool]) {
            """
            Your job is to research travel context for \(landmark.name). Use tools when \
            useful, then answer only in concise plain English. Do not generate structured \
            itinerary data.
            """
        }
    }

    private static func createItinerarySession(landmark: Landmark) -> LanguageModelSession {
        LanguageModelSession {
            """
            Your job is to create an itinerary for the user. Return a complete \
            itinerary with all required fields populated. Do not leave any required field empty.
            """

            """
            Here is the description of \(landmark.name) for your reference \
            when considering what activities to generate:
            """
            landmark.promptDescription

            "Here is an example:"
            Itinerary.exampleTripToJapan
        }
    }

    private static func message(for error: Error) -> String {
        if error.localizedDescription.contains("The assets required for the session are unavailable.") {
            return """
            This device does not support Apple Intelligence, so itinerary generation is \
            unavailable here.
            """
        }

        if error.localizedDescription.contains("maximum allowed context size") {
            return """
            The itinerary prompt was too large for the local model. Try again with a shorter \
            landmark description or fewer requested details.
            """
        }

        return """
        I couldn't generate an itinerary for this landmark. The local model or MapKit lookup \
        failed while planning. Please try again.
        """
    }
}

private extension Landmark {
    var promptDescription: String {
        let maxCharacters = 1_200
        guard description.count > maxCharacters else { return description }

        return shortDescription + "\n\n" + description.prefix(maxCharacters)
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
