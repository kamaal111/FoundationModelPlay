//
//  LandmarkDescriptionView.swift
//  FoundationModelPlay
//
//  Created by Kamaal M Farah on 6/20/26.
//

import os
import SwiftUI
import FoundationModels

struct LandmarkDescriptionView: View {
    @State private var generatedTags: TaggingResponse.PartiallyGenerated?

    let landmark: Landmark

    private let contentTaggingModel = SystemLanguageModel(useCase: .contentTagging)

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("\(landmark.name)")
                .padding(.top, 150)
                .font(.largeTitle)
                .fontWeight(.bold)
            
            FlowLayout(alignment: .leading) {
                if let tags = generatedTags?.tags {
                    ForEach(tags, id: \.self) { tag in
                        Text("#" + tag)
                            .tagStyle()
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            Text("\(landmark.shortDescription)")
        }
        .animation(.default, value: generatedTags)
        .transition(.opacity)
        .padding(.horizontal)
        .frame(maxWidth: .infinity, alignment: .leading)
        .task {
            guard contentTaggingModel.isAvailable else { return }

            let session = LanguageModelSession(model: contentTaggingModel)
            let stream = session.streamResponse(
                to: landmark.description,
                generating: TaggingResponse.self,
                options: GenerationOptions(sampling: .greedy)
            )

            do {
                for try await newTags in stream {
                    generatedTags = newTags.content
                }
            } catch {
                Logging.general.error("\(error.localizedDescription)")
            }
        }
    }
}

@Generable
struct TaggingResponse: Equatable {
    @Guide(.count(5))
    @Guide(description: "Most important topics in the input text")
    let tags: [String]
}

#Preview {
    LandmarkDescriptionView(landmark: Landmarks.first)
}
