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
                .foregroundColor(.white)
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
                .font(.system(size: fontSize, weight: .regular))
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

    private var buttonColor: Color {
        if label == "=" {
            return Color(red: 1.0, green: 0.3882353, blue: 0.0) // #FF6300
        } else if label.rangeOfCharacter(from: .decimalDigits) != nil || label == "." || label == "+/-" {
            return Color(white: 0.09)
        } else if ["÷", "×", "+", "−"].contains(label) {
            return Color.gray
        } else {
            return Color(white: 0.18)
        }
    }

    private var contentColor: Color {
        if label == "=" {
            return .white
        } else if label.rangeOfCharacter(from: .decimalDigits) != nil || label == "." || label == "+/-" {
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
        .background(Color.black)
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
        let opens = text.filter { $0 == "(" }.count
        let closes = text.filter { $0 == ")" }.count
        text += opens > closes ? ")" : "("
    }

    private func toggleSign() {
        if text.starts(with: "-") { text.removeFirst() }
        else { text = "-" + text }
    }

    private func evaluate() {
        // Replace '%' with multiplication by 0.01 to handle percentages
        var expr = text.replacingOccurrences(of: "×", with: "*")
            .replacingOccurrences(of: "÷", with: "/")
            .replacingOccurrences(of: "−", with: "-")
        expr = expr.replacingOccurrences(of: "%", with: "*0.01")

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

