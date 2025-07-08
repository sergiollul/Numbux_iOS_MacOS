//
//  BasicCalculatorView.swift
//  numbux
//
//  Created by Sergio Sánchez on 8/7/25.
//

import SwiftUI

/// A blinking-cursor text display field (read-only BasicTextField equivalent)
struct BlinkingCursorField: View {
    @Binding var text: String
    @State private var showCursor = true
    private let timer = Timer.publish(every: 0.45, on: .main, in: .common).autoconnect()

    var body: some View {
        ZStack(alignment: .trailing) {
            Text(text)
                .font(.system(size: 40, weight: .regular, design: .default))
                .frame(maxWidth: .infinity, alignment: .trailing)

            if showCursor {
                Rectangle()
                    .frame(width: 2, height: 40)
                    .foregroundColor(Color.orange)
                    .padding(.trailing, 4)
            }
        }
        .onReceive(timer) { _ in showCursor.toggle() }
    }
}

/// A reusable button for the calculator keypad
struct CalculatorButton: View {
    let label: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(label)
                .font(.system(size: fontSize, weight: fontWeight))
                .frame(maxWidth: .infinity, maxHeight: 64)
                .background(buttonColor)
                .foregroundColor(contentColor)
                .cornerRadius(32)
        }
    }

    private var fontSize: CGFloat {
        switch label {
        case "÷", "×", "+", "−", "=": return 32
        case "%", "C": return 28
        default: return 24
        }
    }

    private var fontWeight: Font.Weight { .regular }

    private var buttonColor: Color {
        if label.rangeOfCharacter(from: .decimalDigits) != nil || label == "." || label == "+/-" {
            return Color(white: 0.09)
        } else if ["÷", "×", "+", "−"].contains(label) {
            return Color.gray
        } else {
            return Color(white: 0.18)
        }
    }

    private var contentColor: Color {
        if label.rangeOfCharacter(from: .decimalDigits) != nil || label == "." || label == "+/-" {
            return .white
        } else if label == "C" || label == "%" {
            return .white
        } else {
            return .black
        }
    }
}

/// The main calculator view with buttons and display
struct BasicCalculatorView: View {
    @State private var text: String = ""

    private let buttons: [[String]] = [
        ["C", "( )", "%", "÷"],
        ["7", "8", "9", "×"],
        ["4", "5", "6", "−"],
        ["1", "2", "3", "+"],
        ["+/-", "0", ".", "="]
    ]

    var body: some View {
        VStack(spacing: 14) {
            // Display with blinking cursor
            BlinkingCursorField(text: $text)
                .frame(height: 50)
                .padding(.horizontal, 16)

            // Divider separator
            Divider()
                .background(Color.white.opacity(0.25))
                .frame(height: 2)
                .padding(.horizontal, 16)

            Spacer().frame(height: 30)

            // Keypad rows
            ForEach(buttons, id: \.self) { row in
                HStack(spacing: 8) {
                    ForEach(row, id: \.self) { label in
                        CalculatorButton(label: label) {
                            handlePress(label)
                        }
                    }
                }
                .padding(.horizontal, 16)
            }
        }
    }

    private func handlePress(_ label: String) {
        switch label {
        case "C": text = ""
        case "( )": insertParenthesis()
        case "%": text += "%"
        case "+/-": toggleSign()
        case "=": evaluate()
        default: text += label
        }
    }

    private func insertParenthesis() {
        let openCount = text.filter { $0 == "(" }.count
        let closeCount = text.filter { $0 == ")" }.count
        text += openCount > closeCount ? ")" : "("
    }

    private func toggleSign() {
        if text.first == "-" { text.removeFirst() }
        else { text = "-" + text }
    }

    private func evaluate() {
        let expr = text
            .replacingOccurrences(of: "×", with: "*")
            .replacingOccurrences(of: "÷", with: "/")
            .replacingOccurrences(of: "−", with: "-")
        let result = NSExpression(format: expr).expressionValue(with: nil, context: nil) as? NSNumber
        text = result?.stringValue ?? "Error"
    }
}

struct BasicCalculatorView_Previews: PreviewProvider {
    static var previews: some View {
        BasicCalculatorView()
            .preferredColorScheme(.dark)
            .previewLayout(.sizeThatFits)
    }
}
