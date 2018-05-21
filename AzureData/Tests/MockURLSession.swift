//
//  MockURLSession.swift
//  AzureData
//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

class MockURLSession: URLSession {

    private var response: URLResponse?
    private var data: Data?
    private var error: Error?

    func shouldReturnResponse(_ response: URLResponse) {
        self.response = response
    }

    func shouldReturnData(_ data: Data) {
        self.data = data
    }

    func shouldReturnError(_ error: Error) {
        self.error = error
    }

    override func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        return MockURLSessionDataTask { [weak self] in
            completionHandler(self?.data, self?.response, self?.error)
        }
    }
}

class MockURLSessionDataTask: URLSessionDataTask {

    private let closure: () -> Void

    init(_ closure: @escaping () -> Void) {
        self.closure = closure
    }

    override func resume() {
        closure()
    }
}
