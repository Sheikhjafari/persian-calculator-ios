// Integer digit arithmetic preserves every decimal place, like the web version.
struct Calculator {
    private(set) var value = "0"
    private(set) var left: String?
    private(set) var operation: String?
    private(set) var fresh = false
    private(set) var expression = ""

    mutating func press(_ key: String) {
        if key == "clear" { self = Calculator(); return }
        if key.count == 1 && "0123456789.".contains(key) {
            if fresh {
                value = "0"; fresh = false
                if operation == nil { expression = "" }
            }
            if key == "." {
                if !value.contains(".") { value += "." }
                return
            }
            if value.filter({ $0.isNumber }).count >= 18 { return }
            value = value == "0" ? key : value == "-0" ? "-" + key : value + key
        } else if key == "sign" {
            if fresh && operation != nil { value = "-0"; fresh = false }
            else { value = value.hasPrefix("-") ? String(value.dropFirst()) : "-" + value; fresh = false }
        } else if key == "back" {
            if fresh { return }
            value = String(value.dropLast())
            if value.isEmpty || value == "-" { value = "0" }
        } else if key == "+" || key == "-" {
            if let op = operation, let lhs = left, !fresh {
                value = Self.calculate(lhs, value, op)
            }
            left = value; operation = key; fresh = true
            expression = value + " " + key
        } else if key == "=", let op = operation, let lhs = left, !fresh {
            expression = lhs + " " + op + " " + value + " ="
            value = Self.calculate(lhs, value, op)
            operation = nil; left = nil; fresh = true
        }
    }

    static func calculate(_ a: String, _ b: String, _ op: String) -> String {
        let ap = a.split(separator: ".", omittingEmptySubsequences: false)
        let bp = b.split(separator: ".", omittingEmptySubsequences: false)
        let scale = max(ap.count > 1 ? ap[1].count : 0, bp.count > 1 ? bp[1].count : 0)
        func digits(_ parts: [Substring]) -> [Int] {
            let fraction = parts.count > 1 ? String(parts[1]) : ""
            let text = parts[0].filter { $0 != "-" } + fraction + String(repeating: "0", count: scale - fraction.count)
            var result = text.compactMap { $0.wholeNumberValue }
            while result.count > 1 && result.first == 0 { result.removeFirst() }
            return result
        }
        let x = digits(ap), y = digits(bp)
        let an = a.hasPrefix("-"), bn = b.hasPrefix("-") != (op == "-")
        var result: [Int] = []
        var negative = an
        if an == bn {
            let xr = Array(x.reversed()), yr = Array(y.reversed())
            var carry = 0
            for i in 0..<max(xr.count, yr.count) {
                let sum = (i < xr.count ? xr[i] : 0) + (i < yr.count ? yr[i] : 0) + carry
                result.append(sum % 10); carry = sum / 10
            }
            if carry > 0 { result.append(carry) }
        } else {
            let smaller = x.count != y.count ? x.count < y.count : x.lexicographicallyPrecedes(y)
            let large = Array((smaller ? y : x).reversed())
            let small = Array((smaller ? x : y).reversed())
            negative = smaller ? bn : an
            var borrow = 0
            for i in 0..<large.count {
                var n = large[i] - (i < small.count ? small[i] : 0) - borrow
                borrow = n < 0 ? 1 : 0
                if n < 0 { n += 10 }
                result.append(n)
            }
        }
        while result.count > 1 && result.last == 0 { result.removeLast() }
        if result.allSatisfy({ $0 == 0 }) { return "0" }
        var text = result.reversed().map(String.init).joined()
        if scale > 0 {
            if text.count <= scale { text = String(repeating: "0", count: scale + 1 - text.count) + text }
            text.insert(".", at: text.index(text.endIndex, offsetBy: -scale))
            while text.last == "0" { text.removeLast() }
            if text.last == "." { text.removeLast() }
        }
        return (negative ? "-" : "") + text
    }
}
