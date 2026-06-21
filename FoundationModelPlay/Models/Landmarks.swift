//
//  Landmarks.swift
//  FoundationModelPlay
//
//  Created by Kamaal M Farah on 6/20/26.
//

import Foundation

enum Landmarks {
    nonisolated static var landmarkNames: [String] { landmarks.map(\.name) }
    nonisolated static var first: Landmark { landmarks.first! }
    nonisolated static let landmarks: [Landmark] = parseLandmarks(fileName: "landmarkData.json")
    nonisolated static var fuji: Landmark { landmarks[14] }

    private static func parseLandmarks(fileName: String) -> [Landmark] {
        guard let file = Bundle.main.url(forResource: fileName, withExtension: nil) else {
            fatalError("Couldn't find \(fileName) in main bundle.")
        }

        let data: Data
        do {
            data = try Data(contentsOf: file)
        } catch {
            fatalError("Couldn't read \(fileName):\n\(error)")
        }

        let decoder = JSONDecoder()

        do {
            return try decoder.decode([Landmark].self, from: data)
        } catch {
            fatalError("Couldn't parse \(fileName):\n\(error)")
        }
    }
}
