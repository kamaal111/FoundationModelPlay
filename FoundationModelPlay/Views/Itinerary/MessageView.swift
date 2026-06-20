//
//  MessageView.swift
//  FoundationModelPlay
//
//  Created by Kamaal M Farah on 6/21/26.
//

import SwiftUI

struct MessageView: View {
    let error: Error?
    let landmark: Landmark
    let message: String?

    init(error: Error? = nil, landmark: Landmark, message: String? = nil) {
        self.error = error
        self.landmark = landmark
        self.message = message
    }

    var body: some View {
        VStack {
            Spacer()
            if let error {
                Text("\(error.localizedDescription)")
                    .foregroundStyle(.red)
                    .padding(5)
            } else if let message {
                Text("\(message)")
                    .foregroundStyle(.black)
                    .font(.title3)
                    .padding(15)
            }
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(alignment: .top) {
            ItineraryHeader(destination: landmark)
                .opacity(0.6)
        }
    }
}

#Preview {
    MessageView(landmark: Landmarks.first)
}
