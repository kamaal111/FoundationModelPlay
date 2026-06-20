//
//  Landmark.swift
//  FoundationModelPlay
//
//  Created by Kamaal M Farah on 6/20/26.
//

import MapKit
import CoreLocation

struct Landmark: Hashable, Codable, Identifiable {
    var id: Int
    var name: String
    var continent: String
    var description: String
    var shortDescription: String
    var latitude: Double
    var longitude: Double
    var span: Double
    var placeID: String?

    var backgroundImageName: String { "\(id)" }

    var thumbnailImageName: String { "\(id)-thumb" }

    var locationCoordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    var coordinateRegion: MKCoordinateRegion {
        MKCoordinateRegion(
            center: locationCoordinate,
            span: .init(latitudeDelta: span, longitudeDelta: span)
        )
    }
}
