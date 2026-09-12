import SwiftUI

struct ContentView: View {
    @State private var calculator = Calculator()
    private let mint = Color(red: 0.65, green: 0.93, blue: 0.81)
    private let background = Color(red: 0.078, green: 0.098, blue: 0.145)

    private func persian(_ text: String) -> String {
        let digits = Array("۰۱۲۳۴۵۶۷۸۹")
        return text.map { character in
            if let n = character.wholeNumberValue { return String(digits[n]) }
            return character == "." ? "٫" : character == "-" ? "−" : String(character)
        }.joined()
    }

    var body: some View {
        GeometryReader { geometry in
            let height: CGFloat = geometry.size.height < 700 ? 54 : 64
            ScrollView {
                VStack(spacing: 20) {
                    HStack(spacing: 14) {
                        Text("±")
                            .font(.system(size: 32))
                            .frame(width: 48, height: 48)
                            .background(mint, in: RoundedRectangle(cornerRadius: 16))
                            .foregroundStyle(background)
                        VStack(alignment: .leading, spacing: 5) {
                            Text("جمع و تفریق").font(.title3.bold())
                            Text("ساده، سریع، دقیق").font(.caption).foregroundStyle(.secondary)
                        }
                        Spacer(minLength: 0)
                    }
                    .environment(\.layoutDirection, .rightToLeft)

                    VStack(alignment: .trailing, spacing: 12) {
                        ScrollView(.horizontal, showsIndicators: false) {
                            Text(persian(calculator.expression.isEmpty ? " " : calculator.expression))
                                .font(.callout).foregroundStyle(mint)
                                .environment(\.layoutDirection, .leftToRight)
                        }
                        .environment(\.layoutDirection, .rightToLeft)
                        ScrollView(.horizontal, showsIndicators: false) {
                            Text(persian(calculator.value))
                                .font(.system(size: 48, weight: .medium, design: .rounded))
                                .monospacedDigit()
                                .environment(\.layoutDirection, .leftToRight)
                                .textSelection(.enabled)
                                .accessibilityLabel("نتیجه: " + persian(calculator.value))
                        }
                        .environment(\.layoutDirection, .rightToLeft)
                    }
                    .padding(20)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .background(Color.black.opacity(0.22), in: RoundedRectangle(cornerRadius: 24))

                    VStack(spacing: 12) {
                        HStack(spacing: 12) {
                            key("clear", "AC", "پاک کردن همه", height: height)
                            key("sign", "±", "تغییر علامت", height: height)
                            key("back", "⌫", "حذف آخرین رقم", height: height)
                            key("-", "−", "تفریق", height: height)
                        }
                        HStack(spacing: 12) {
                            digit("7", height); digit("8", height); digit("9", height)
                            key("+", "+", "جمع", height: height)
                        }
                        HStack(spacing: 12) {
                            VStack(spacing: 12) {
                                HStack(spacing: 12) { digit("4", height); digit("5", height); digit("6", height) }
                                HStack(spacing: 12) { digit("1", height); digit("2", height); digit("3", height) }
                                GeometryReader { row in
                                    HStack(spacing: 12) {
                                        digit("0", height).frame(width: (row.size.width - 24) / 3 * 2 + 12)
                                        key(".", "٫", "ممیز", height: height)
                                    }
                                }.frame(height: height)
                            }
                            .frame(maxWidth: .infinity)
                            key("=", "=", "محاسبه", height: height * 3 + 24)
                                .frame(width: max(44, (min(geometry.size.width - 40, 380) - 36) / 4))
                        }
                    }
                    Text("فقط دو عمل؛ هر حسابی ساده‌تر.")
                        .font(.caption).foregroundStyle(.secondary)
                }
                .frame(maxWidth: 380)
                .padding(.horizontal, 20)
                .padding(.vertical, 24)
                .frame(maxWidth: .infinity, minHeight: geometry.size.height)
            }
            .background {
                LinearGradient(colors: [Color(red: 0.145, green: 0.208, blue: 0.282), background], startPoint: .topTrailing, endPoint: .bottomLeading)
                    .ignoresSafeArea()
            }
        }
        .environment(\.layoutDirection, .leftToRight)
    }

    private func digit(_ value: String, _ height: CGFloat) -> some View {
        key(value, persian(value), persian(value), height: height)
    }

    private func key(_ value: String, _ title: String, _ label: String, height: CGFloat) -> some View {
        let isOperator = value == "+" || value == "-"
        let selected = isOperator && calculator.operation == value
        let highlighted = value == "=" || selected
        let utility = ["clear", "sign", "back"].contains(value)
        return Button { calculator.press(value) } label: {
            Text(title)
                .font(.system(size: utility ? 23 : 30, weight: .medium))
                .frame(maxWidth: .infinity, minHeight: height, maxHeight: height)
                .foregroundStyle(highlighted ? background : isOperator ? mint : .white)
                .background(highlighted ? mint : isOperator ? Color(red: 0.22, green: 0.35, blue: 0.31) : utility ? Color(red: 0.22, green: 0.25, blue: 0.33) : Color(red: 0.145, green: 0.176, blue: 0.235), in: RoundedRectangle(cornerRadius: 22))
        }
        .buttonStyle(.plain)
        .accessibilityLabel(label)
        .accessibilityAddTraits(selected ? .isSelected : [])
    }
}
