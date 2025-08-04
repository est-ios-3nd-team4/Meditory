//
//  SlideInView.swift
//  Meditory
//
//  Created by hyunsic on 8/4/25.
//
import SwiftUI

struct SlideInView: View {
    @State private var showView = false

    var body: some View {
        ZStack {
            Color.white.edgesIgnoringSafeArea(.all)
            
            if showView {
                Rectangle()
                    .fill(Color.green)
                    .frame(width: 300, height: 200)
                    .transition(.move(edge: .leading))
                    .animation(.easeInOut(duration: 0.4), value: showView)
            }

            VStack {
                Spacer()
                Button("Toggle Slide") {
                    withAnimation {
                        showView.toggle()
                    }
                }
                .padding()
            }
        }
    }
}

#Preview {
  SlideInView()
}
