import SwiftUI
import Combine

struct ScientificCalculatorView: View {
    @State private var input = ""                  // the text buffer
    @State private var showPiMenu = false          // for the π–e dropdown
    @FocusState private var isFocused: Bool        // to autofocus the field
    
    private let buttons: [[String]] = [
      ["C", "( )", "%", "π–e"],
      ["xʸ","√", "log", "÷"],
      ["7",   "8",   "9",  "×"],
      ["4",   "5",   "6",  "−"],
      ["1",   "2",   "3",  "+"],
      ["+/-","0",   ".",  "="]
    ]
    
    var body: some View {
        VStack(spacing: 16) {
            // ── Input Field ────────────────────
            BlinkingCursorField(text: $input)
                .font(.system(size: 36, weight: .medium, design: .monospaced))
                .padding(.vertical, 12)
                .padding(.horizontal, 8)
                .background(Color.clear)
                .cornerRadius(8)
            
            // ── Backspace ──────────────────────
            HStack {
                Spacer()
                Button {
                    guard !input.isEmpty else { return }
                    input.removeLast()
                } label: {
                    Image(systemName: "delete.left")
                        .font(.system(size: 28))
                        .foregroundColor(.accentOrange)
                }
                .buttonStyle(.plain)
                .frame(width: 50, height: 50)
            }
            
            Divider()
                .background(Color.white.opacity(0.25))
            
            // ── Button Grid ────────────────────
            VStack(spacing: 8) {
                ForEach(buttons, id: \.self) { row in
                    HStack(spacing: 8) {
                        ForEach(row, id: \.self) { label in
                            button(for: label)
                        }
                    }
                }
            }
        }
        .padding(16)
        .background(Color.black.edgesIgnoringSafeArea(.all))
    }
    
    // MARK: – Build each button
    private func button(for label: String) -> some View {
        // 1. Compute your colors up front
        let backgroundColor: Color
        let foreground: Color
        switch label {
        case "C", "( )", "%":
            backgroundColor = Color(UIColor.darkGray)
            foreground       = .white
        case "÷","×","+","−","xʸ","√","log":
            backgroundColor = Color(UIColor.lightGray)
            foreground       = .black
        default:
            backgroundColor = Color(.systemGray6).opacity(0.1)
            foreground       = .white
        }

        // 2. Return the view
        return Group {
            if label == "π–e" {
                Menu {
                    Button("π")    { insert("π") }
                    Button("e")    { insert("e") }
                    Button("ln(")  { insert("ln(") }
                    Button("sin(") { insert("sin(") }
                    Button("cos(") { insert("cos(") }
                    Button("tan(") { insert("tan(") }
                } label: {
                    Text("π–e")
                        .font(.system(size: 24, weight: .medium))
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                .menuStyle(BorderlessButtonMenuStyle())
            } else {
                Button {
                    tap(label)
                } label: {
                    Text(label)
                        .font(.system(size: labelFontSize(label), weight: .medium))
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                .buttonStyle(.plain)
            }
        }
        .frame(height: 60)
        .background(backgroundColor)      // ← use your computed Color here
        .foregroundColor(foreground)
        .cornerRadius(8)
    }
    
    // MARK: – Handle taps
    private func tap(_ label: String) {
        switch label {
        case "C":
            input = ""
        case "+/-":
            toggleSign()
        case "=":
            input = evaluateExpression(input)
        case "( )":
            insertParenthesis()
        case "+","−","×","÷","%","√","xʸ","log":
            insert(labelMapping(label))
        default:
            insert(label)
        }
    }
    
    private func insert(_ s: String) {
        input += s
    }
    
    private func toggleSign() {
        if input.hasPrefix("-") { input.removeFirst() }
        else { input = "-" + input }
    }
    
    private func insertParenthesis() {
        // simple heuristic: if more opens than closes insert “)”, else “(”
        let openCount  = input.filter{ $0=="(" }.count
        let closeCount = input.filter{ $0==")" }.count
        insert(openCount > closeCount ? ")" : "(")
    }
    
    private func labelMapping(_ op: String) -> String {
        switch op {
        case "×": return "*"
        case "÷": return "/"
        case "−": return "-"
        case "xʸ": return "^"
        default:   return op
        }
    }
    
    // MARK: – Font sizing for different labels
    private func labelFontSize(_ label: String) -> CGFloat {
        switch label {
        case "+/-":      return 20
        case "C","( )":  return 24
        case "%":       return 24
        case "÷","×","+","−","√":
            return 28
        case "xʸ":      return 24
        case "=":       return 30
        default:        return 24
        }
    }
}

// MARK: – Expression evaluation (RPN)
fileprivate func evaluateExpression(_ exprInput: String) -> String {
    var expr = exprInput
        .replacingOccurrences(of: "×", with: "*")
        .replacingOccurrences(of: "÷", with: "/")
        .replacingOccurrences(of: "−", with: "-")
        .replacingOccurrences(of: "√", with: "sqrt")
        .replacingOccurrences(of: "xʸ", with: "^")
        .replacingOccurrences(of: "%", with: "/100")
        .trimmingCharacters(in: .whitespacesAndNewlines)
    
    expr = balanceParentheses(expr)
    let rpn = toRPN(expr)
    let result = evalRPN(rpn)
    
    if result.isInfinite || result.isNaN {
        return "Error"
    } else if result.truncatingRemainder(dividingBy: 1) == 0 {
        return String(format: "%.0f", result)
    } else {
        return String(result)
    }
}

fileprivate func balanceParentheses(_ input: String) -> String {
    let open = input.filter{ $0=="(" }.count
    let close = input.filter{ $0==")" }.count
    return open > close ? input + String(repeating: ")", count: open - close) : input
}

fileprivate func toRPN(_ expr: String) -> [String] {
    var output = [String]()
    var ops    = [String]()
    
    func prec(_ op: String) -> Int {
        switch op {
        case "sin","cos","tan","log","ln","sqrt": return 5
        case "^": return 4
        case "*","/","%": return 3
        case "+","-": return 2
        default: return 0
        }
    }
    func leftAssoc(_ op: String) -> Bool { op != "^" }
    
    var i = expr.startIndex
    while i < expr.endIndex {
        let c = expr[i]
        if c.isWhitespace {
            i = expr.index(after: i); continue
        }
        if c.isNumber || c == "." {
            let start = i
            while i < expr.endIndex && (expr[i].isNumber || expr[i]==".") {
                i = expr.index(after: i)
            }
            output.append(String(expr[start..<i]))
            continue
        }
        // functions & constants
        if c.isLetter {
            let start = i
            while i < expr.endIndex && (expr[i].isLetter) {
                i = expr.index(after: i)
            }
            let token = String(expr[start..<i])
            if ["π","e"].contains(token) {
                output.append(token)
            } else {
                ops.insert(token, at: 0)
            }
            continue
        }
        if c == "(" {
            ops.insert("(", at: 0)
            i = expr.index(after: i)
            continue
        }
        if c == ")" {
            while let top = ops.first, top != "(" {
                output.append(top); ops.removeFirst()
            }
            if ops.first == "(" { ops.removeFirst() }
            if let fn = ops.first, ["sin","cos","tan","log","ln","sqrt"].contains(fn) {
                output.append(fn); ops.removeFirst()
            }
            i = expr.index(after: i)
            continue
        }
        // operators
        let s = String(c)
        if ["+","-","*","/","^","%"].contains(s) {
            // unary minus?
            let isUnary = s=="-" && (i==expr.startIndex || expr[expr.index(before: i)]=="(")
            if isUnary {
                ops.insert("u-", at: 0)
            } else {
                while let top = ops.first,
                      (prec(top) > prec(s)) ||
                      (prec(top)==prec(s) && leftAssoc(s))
                {
                    output.append(top); ops.removeFirst()
                }
                ops.insert(s, at: 0)
            }
            i = expr.index(after: i)
            continue
        }
        // skip anything else
        i = expr.index(after: i)
    }
    // drain
    while let top = ops.first {
        if top != "(" && top != ")" {
            output.append(top)
        }
        ops.removeFirst()
    }
    return output
}

fileprivate func evalRPN(_ tokens: [String]) -> Double {
    var stack = [Double]()
    for tok in tokens {
        switch tok {
        case "π": stack.insert(.pi, at: 0)
        case "e": stack.insert(M_E, at: 0)
        case "u-":
            if let x = stack.first {
                stack[0] = -x
            }
        case "+","-","*","/","^","%":
            guard stack.count >= 2 else { break }
            let b = stack.removeFirst(), a = stack.removeFirst()
            let res: Double = {
                switch tok {
                case "+": return a + b
                case "-": return a - b
                case "*": return a * b
                case "/": return a / b
                case "^": return pow(a, b)
                case "%": return a * (b / 100.0)
                default:  return 0
                }
            }()
            stack.insert(res, at: 0)
        case "sin","cos","tan","log","ln","sqrt":
            if let x = stack.first {
                let res: Double = {
                    switch tok {
                    case "sin":  return sin(x)
                    case "cos":  return cos(x)
                    case "tan":  return tan(x)
                    case "log":  return log10(x)
                    case "ln":   return log(x)
                    case "sqrt": return sqrt(x)
                    default:     return x
                    }
                }()
                stack[0] = res
            }
        default:
            if let num = Double(tok) {
                stack.insert(num, at: 0)
            }
        }
    }
    return stack.first ?? 0
}


