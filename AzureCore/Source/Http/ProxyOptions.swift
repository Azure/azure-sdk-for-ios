//
//  ProxyOptions.swift
//  AzureCore
//
//  Created by Travis Prescott on 8/22/19.
//

import Foundation

/**
 * proxy configuration.
 */
@objc class ProxyOptions: NSObject {
    
    @objc let address: String  // should be the equivalent of Java's InetSocketAddress
    @objc let type: ProxyType
    
    /**
     * Creates ProxyOptions.
     *
     * @param type the proxy type
     * @param address the proxy address (ip and port number)
     */
    @objc init(type: ProxyType, address: String) {
        self.type = type
        self.address = address
    }
    
    /**
     * The type of the proxy.
     */
    @objc enum ProxyType: UInt {
        /**
         * HTTP proxy type.
         */
        case HTTP
        /**
         * SOCKS4 proxy type.
         */
        case SOCKS4
        /**
         * SOCKS5 proxy type.
         */
        case SOCKS5
    }
}
