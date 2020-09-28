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
