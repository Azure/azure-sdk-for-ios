//
//  HttpClient.swift
//  AzureCore
//
//  Created by Travis Prescott on 8/22/19.
//

import Foundation

@objc
protocol HttpClient {

    /**
     * Send the provided request asynchronously.
     *
     * @param request The HTTP request to send
     * @return A {@link Mono} that emits response asynchronously
     */
    @objc func send(request: HttpRequest) -> HttpResponse
    
    /**
     * Create default HttpClient instance.
     *
     * @return the HttpClient
     */
    @objc static func createDefault() -> HttpClient
    
    /**
     * Apply the provided proxy configuration to the HttpClient.
     *
     * @param proxyOptions the proxy configuration
     * @return a HttpClient with proxy applied
     */
    @objc func proxy(options: ProxyOptions) -> HttpClient
    
    /**
     * Apply or remove a wire logger configuration.
     *
     * @param enable wiretap config
     * @return a HttpClient with wire logging enabled or disabled
     */
    @objc func wiretap(enable: Bool) -> HttpClient
    
    /**
     * Set the port that client should connect to.
     *
     * @param port the port
     * @return a HttpClient with port applied
     */
    @objc func port(_ port: Int) -> HttpClient
}
