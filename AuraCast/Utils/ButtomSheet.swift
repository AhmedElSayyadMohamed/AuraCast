//
//  ButtomSheet.swift
//  AuraCast
//
//  Created by Ahmed El Sayyad Mohamed on 11/06/2026.
//

import Foundation
import SwiftUI

enum BottomSheetPosition: CGFloat, CaseIterable {
    case top    = 0.83
    case middle = 0.385
}
 
struct BottomSheet<Content: View>: View {
    let screenHeight: CGFloat
    @Binding var position: BottomSheetPosition
    @Binding var translation: CGFloat
    @Binding var hasDragged: Bool

    @ViewBuilder var content: () -> Content

    @GestureState private var dragState: CGFloat = 0

    private var currentFraction: CGFloat {
        min(
            max(translation + dragState / screenHeight,
                BottomSheetPosition.middle.rawValue),
            BottomSheetPosition.top.rawValue
        )
    }

    private var sheetHeight: CGFloat {
        currentFraction * screenHeight
    }

    var body: some View {
        VStack(spacing: 0) {
            content()
        }
        .frame(maxWidth: .infinity)
        .frame(height: sheetHeight, alignment: .top)
        .frame(maxHeight: .infinity, alignment: .bottom)
        .gesture(
            DragGesture(minimumDistance: 10)
                .updating($dragState) { value, state, _ in
                    state = -value.translation.height
                }
                .onEnded { value in
                    let velocity = -value.predictedEndTranslation.height / screenHeight
                    let projectedFraction = translation + velocity

                    let snappedPosition = BottomSheetPosition.allCases.min {
                        abs($0.rawValue - projectedFraction) <
                        abs($1.rawValue - projectedFraction)
                    } ?? .middle

                    withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                        position = snappedPosition
                        translation = snappedPosition.rawValue
                        hasDragged = snappedPosition == .top
                    }
                }
        )
        .onChange(of: position) { newPos in
            withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                translation = newPos.rawValue
            }
        }
    }
}
