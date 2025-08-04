//
//  NutrientDetailSection.swift
//  Meditory
//
//  Created by Jaehun Kim on 8/4/25.
//

import SwiftUI

struct NutrientDetailSection: View {
    let name: String
    let tags: [String]
    let descriptionTitle: String
    let summary: String
    let detail: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(name)
                    .font(.custom("NotoSansKR-Bold.ttf", size: 30))
                    .fontWeight(.bold)

                Spacer()
                
                Button {

                } label: {
                    Image(systemName: "star")
                }
            }
            .padding(.bottom, 16)

            ForEach(tags, id: \.self) { tag in
                Text("# \(tag)")
                    .font(.custom("NotoSansKR-Bold.ttf", size: 15))
                    .fontWeight(.bold)
            }

            Text("🧪 \(descriptionTitle)")
                .font(.custom("NotoSansKR-Bold.ttf", size: 18))
                .fontWeight(.bold)
            .padding(.vertical, 16)

            Text(summary)
                .font(.custom("NotoSansKR-Bold.ttf", size: 15))
                .fontWeight(.bold)
                .padding(.bottom, 8)

            Text(detail)
                .font(.custom("NotoSansKR-Medium.ttf", size: 15))
        }
        .padding(.vertical)
    }
}


