//
//  Effects.swift
//  FoundationModelPlay
//
//  Created by Kamaal M Farah on 6/20/26.
//

import SwiftUI

private struct HeaderStyle: ViewModifier {
    let landmark: Landmark
    
    func body(content: Content) -> some View {
        content
            .background(alignment: .top) {
                ItineraryHeader(destination: landmark)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

private struct TagStyleModifier: ViewModifier {
    @Environment(\.colorScheme) var colorScheme

    func body(content: Content) -> some View {
        content
            .font(.subheadline)
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .fontWeight(.semibold)
            .foregroundColor(.secondary)
            .clipShape(Capsule())
            .background(colorScheme == .dark ? AnyShapeStyle(.thinMaterial) : AnyShapeStyle(.white.opacity(0.3)))
            .clipShape(Capsule())
    }
}

private struct RationaleModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.subheadline)
            .foregroundStyle(.secondary)
            .transition(.blurReplace)
            .padding(12)
            .card()
            .padding(.top)
    }
}

private struct CardModifier: ViewModifier {
    @Environment(\.colorScheme) var colorScheme

    func body(content: Content) -> some View {
        content
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(colorScheme == .dark ? AnyShapeStyle(.thinMaterial) : AnyShapeStyle(.white))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: .black.opacity(colorScheme == .dark ? 0.2 : 0.08), radius: 4, y: 2)
            .shadow(color: .black.opacity(colorScheme == .dark ? 0.12 : 0.08), radius: 32, y: 12)
    }
}

private struct ItineraryModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, 120)
            .padding(.bottom)
    }
}

private struct BlurredBackgroundModifier: ViewModifier {
    @Environment(\.colorScheme) var colorScheme

    func body(content: Content) -> some View {
        content
            .padding(.top, 16)
            .background {
                Rectangle()
                    .fill(.ultraThinMaterial)
                    .mask {
                        LinearGradient(colors: [.clear, .white, .white], startPoint: .top, endPoint: .bottom)
                    }
                    .overlay {
                        LinearGradient(colors: [
                            overlayColor.opacity(0),
                            overlayColor.opacity(0.6)
                        ], startPoint: .top, endPoint: .bottom)
                    }
            }
    }

    private var overlayColor: Color {
        if colorScheme == .light {
            return .white
        } else {
            #if os(macOS)
            return Color(nsColor: .windowBackgroundColor)
            #else
            return Color(uiColor: .systemBackground)
            #endif
        }
    }
}

extension View {
    func blurredBackground() -> some View {
        modifier(BlurredBackgroundModifier())
    }

    func itineraryStyle() -> some View {
        modifier(ItineraryModifier())
    }

    func card() -> some View {
        modifier(CardModifier())
    }

    func rationaleStyle() -> some View {
        modifier(RationaleModifier())
    }

    func tagStyle() -> some View {
        modifier(TagStyleModifier())
    }

    func headerStyle(landmark: Landmark) -> some View {
        modifier(HeaderStyle(landmark: landmark))
    }
}
