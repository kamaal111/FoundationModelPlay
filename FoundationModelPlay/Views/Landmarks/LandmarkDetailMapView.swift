//
//  LandmarkDetailMapView.swift
//  FoundationModelPlay
//
//  Created by Kamaal M Farah on 6/20/26.
//

import MapKit
import SwiftUI

struct LandmarkDetailMapView: View {
    let landmark: Landmark
    var landmarkMapItem: MKMapItem?

    var body: some View {
        Map(initialPosition: .region(landmark.coordinateRegion), interactionModes: []) {
            if let landmarkMapItem = landmarkMapItem {
                Marker(item: landmarkMapItem)
            }
        }
        .disabled(true)
    }
}
