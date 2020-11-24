import Foundation

extension String: LocalizedError {
    public var errorDescription: String? { return self }
}

extension Int: LocalizedError {
    public var errorDescription: String? { return String(self) }
}

extension Int32: LocalizedError {
    public var errorDescription: String? { return String(self) }
}

extension Int64: LocalizedError {
    public var errorDescription: String? { return String(self) }
}

extension Data {
    func base64URLEncodedString() -> String {
        let base64String = base64EncodedString()
        let base64UrlString = base64String.replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "=", with: "")
        return base64UrlString
    }
}
