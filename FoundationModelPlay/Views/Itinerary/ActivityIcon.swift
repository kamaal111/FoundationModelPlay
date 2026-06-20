//
//  ActivityIcon.swift
//  FoundationModelPlay
//
//  Created by Kamaal M Farah on 6/20/26.
//

import SwiftUI

struct ActivityIcon: View {
    @ScaledMetric var iconSize: CGFloat = 32

    let symbolName: String?

    var body: some View {
        if let symbolName {
            Image(systemName: symbolName)
                .foregroundStyle(.white)
                .frame(minWidth: iconSize, minHeight: iconSize)
                .background {
                    Circle()
                        .fill(
                            RadialGradient(
                                gradient: Gradient(colors: [.indigo, .indigo.mix(with: .black, by: 0.2)]),
                                center: .init(x: 0.3, y: 0.3),
                                startRadius: 0,
                                endRadius: 32
                            )
                        )
                        .shadow(color: .indigo.opacity(0.3), radius: 8, x: 2, y: 4)
                }
                .transition(.scale)
        }
    }
}

#Preview {
    ActivityIcon(symbolName: "binoculars.fill")
}
