//
//  ScoredetailView.swift
//  Meditory
//
//  Created by Jaehun Kim on 8/6/25.
//

import SwiftUI

struct ScoredetailView: View {
  @Environment(\.dismiss) private var dismiss
  @Environment(\.colorScheme) private var colorScheme

  var score: Double = 65

  @State private var animatedProgress: Double = 0

  var body: some View {
    VStack {
      HStack {
        Button {
          dismiss()
        } label: {
          Image(systemName: "chevron.left")
            .foregroundColor(Color.white)
        }

        Spacer()

      }
      .padding(.horizontal, 16)
      .padding(.vertical, 12)

      HStack {
        Text("영양제 분석 리포트")
          .font(.notoSans(weight: .bold, size: 25))
          .foregroundColor(Color.white)

        Spacer()

        Image("share")
          .renderingMode(.template)
          .resizable()
          .scaledToFit()
          .frame(width: 25, height: 25)
          .foregroundColor(.white)
      }
      .padding(16)

      ZStack {
        RoundedRectangle(cornerRadius: 20)
          .fill(colorScheme == .dark ? Color.black : Color.white.opacity(0.98))
          .shadow(color: .black.opacity(0.08), radius: 10, x: 0, y: 4)
          .padding(.bottom, -80)
          .ignoresSafeArea(.container, edges: .bottom)

          ScrollView {
            VStack(spacing: 16) {

              ZStack(alignment: .center) {
                Circle()
                  .trim(from: 0, to: 1)
                  .stroke(colorScheme == .dark ? Color.white : Color.gray.opacity(0.3), style: StrokeStyle(lineWidth: 30, lineCap: .round)
                  )
                  .rotationEffect(.degrees(-90))


                Circle()
                  .trim(from: 0, to: animatedProgress)
                  .stroke(Color.main, style: StrokeStyle(lineWidth: 40, lineCap: .butt)
                  )
                  .rotationEffect(.degrees(-90))

                  HStack(alignment: .firstTextBaseline, spacing: 0) {
                    Text("\(Int(score))")
                      .font(.notoSans(weight: .medium, size: 50))

                    Text("점")
                      .font(.notoSans(weight: .medium, size: 20))
                  }
              }
              .padding(.vertical, 16)
              .frame(maxWidth: .infinity)
              .frame(height: 250)

              ZStack {
                VStack(spacing: 16) {
                  Text("AI 분석결과")
                    .font(.notoSans(weight: .bold, size: 15))
                    .foregroundColor(Color.accent)
                    .padding(.top, 16)

//                    .background(
//                      RoundedRectangle(cornerRadius: 20)
//                        .fill(colorScheme == .dark
//                              ? Color.sub
//                              : Color.sub.opacity(0.3))
//                        .shadow(color: .black.opacity(0.08),
//                                radius: 10, x: 0, y: 4)
//                    )

                  HStack {
                    ZStack {
                      RoundedRectangle(cornerRadius: 12)
                        .fill(colorScheme == .dark
                              ? Color.white.opacity(0.3)
                              : Color.white)
                        .shadow(color: .black.opacity(0.08),
                                radius: 10, x: 0, y: 4)
                      HStack {
                        Text("부족")
                          .font(.notoSans(weight: .bold, size: 12))
                          .foregroundColor(Color.pink)
                          .padding(.horizontal, 8)
                          .padding(.vertical, 4)
                          .background (
                            RoundedRectangle(cornerRadius: 20)
                              .fill(colorScheme == .dark
                                    ? Color.pink.opacity(0.1)
                                    : Color.pink.opacity(0.2))

                          )

                        Spacer()
                        // 나중에 수정
                        Text("0 개")
                          .font(.notoSans(weight: .medium, size: 12))
                      }
                      .padding(16)
                    }

                    ZStack {
                      RoundedRectangle(cornerRadius: 12)
                        .fill(colorScheme == .dark
                              ? Color.white.opacity(0.3)
                              : Color.white)
                        .shadow(color: .black.opacity(0.08),
                                radius: 10, x: 0, y: 4)
                      HStack {
                        Text("주의")
                          .font(.notoSans(weight: .bold, size: 12))
                          .foregroundColor(Color.yellow)
                          .padding(.horizontal, 8)
                          .padding(.vertical, 4)
                          .background (
                            RoundedRectangle(cornerRadius: 20)
                              .fill(colorScheme == .dark
                                    ? Color.yellow.opacity(0.1)
                                    : Color.yellow.opacity(0.2))

                          )

                        Spacer()
                        // 나중에 수정
                        Text("0 개")
                          .font(.notoSans(weight: .medium, size: 12))
                      }
                      .padding(16)
                    }
                  }

                  HStack {
                    ZStack {
                      RoundedRectangle(cornerRadius: 12)
                        .fill(colorScheme == .dark
                              ? Color.white.opacity(0.3)
                              : Color.white)
                        .shadow(color: .black.opacity(0.08),
                                radius: 10, x: 0, y: 4)
                      HStack {
                        Text("최적")
                          .font(.notoSans(weight: .bold, size: 12))
                          .foregroundColor(Color.accent)
                          .padding(.horizontal, 8)
                          .padding(.vertical, 4)
                          .background (
                            RoundedRectangle(cornerRadius: 20)
                              .fill(colorScheme == .dark
                                    ? Color.blue.opacity(0.1)
                                    : Color.blue.opacity(0.2))
                          )

                        Spacer()
                        // 나중에 수정
                        Text("14 개")
                          .font(.notoSans(weight: .medium, size: 12))
                      }
                      .padding(16)
                    }

                    ZStack {
                      RoundedRectangle(cornerRadius: 12)
                        .fill(colorScheme == .dark
                              ? Color.white.opacity(0.3)
                              : Color.white)
                        .shadow(color: .black.opacity(0.08),
                                radius: 10, x: 0, y: 4)
                      HStack {
                        Text("충족")
                          .font(.notoSans(weight: .bold, size: 12))
                          .foregroundColor(Color.green)
                          .padding(.horizontal, 8)
                          .padding(.vertical, 4)
                          .background (
                            RoundedRectangle(cornerRadius: 20)
                              .fill(colorScheme == .dark
                                    ? Color.green.opacity(0.1)
                                    : Color.green.opacity(0.2))

                          )

                        Spacer()
                        // 나중에 수정
                        Text("6 개")
                          .font(.notoSans(weight: .medium, size: 12))
                      }
                      .padding(16)
                    }
                  }
                }
              }
            }
            .padding(.top, 50)
          }
          .scrollIndicators(.hidden)

      }
    }
    .navigationBarHidden(true)
    .background(colorScheme == .dark ? Color.black : Color.main)

    .onAppear {
      animatedProgress = 0
      withAnimation(.easeOut(duration: 1.0)) {
        animatedProgress = score / 100
      }
    }
  }
}

#Preview {
  ScoredetailView()
}
