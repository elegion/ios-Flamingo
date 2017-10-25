//
//  URLRequest+Description.swift
//  Flamingo
//
//  Created by Nikolay Ischuk on 25.10.17.
//  Copyright © 2017 ELN. All rights reserved.
//

import Foundation

extension URLRequest {
    func cURLRepresentation(session: URLSession) -> String {
        var components = ["$ curl -v"]

        guard let url = url,
            let host = url.host
            else {
                return "$ curl command could not be created"
        }

        if let httpMethod = httpMethod, httpMethod != "GET" {
            components.append("-X \(httpMethod)")
        }

        if let credentialStorage = session.configuration.urlCredentialStorage {
            let protectionSpace = URLProtectionSpace(
                host: host,
                port: url.port ?? 0,
                protocol: url.scheme,
                realm: host,
                authenticationMethod: NSURLAuthenticationMethodHTTPBasic
            )

            if let credentials = credentialStorage.credentials(for: protectionSpace)?.values {
                for credential in credentials {
                    guard let user = credential.user, let password = credential.password else { continue }
                    components.append("-u \(user):\(password)")
                }
            }
        }

        if session.configuration.httpShouldSetCookies {
            if
                let cookieStorage = session.configuration.httpCookieStorage,
                let cookies = cookieStorage.cookies(for: url), !cookies.isEmpty
            {
                let string = cookies.reduce("") { $0 + "\($1.name)=\($1.value);" }

                #if swift(>=3.2)
                    components.append("-b \"\(string[..<string.index(before: string.endIndex)])\"")
                #else
                    components.append("-b \"\(string.substring(to: string.characters.index(before: string.endIndex)))\"")
                #endif
            }
        }

        var headers: [AnyHashable: Any] = [:]

        if let additionalHeaders = session.configuration.httpAdditionalHeaders {
            for (field, value) in additionalHeaders where field != AnyHashable("Cookie") {
                headers[field] = value
            }
        }

        if let headerFields = allHTTPHeaderFields {
            for (field, value) in headerFields where field != "Cookie" {
                headers[field] = value
            }
        }

        for (field, value) in headers {
            components.append("-H \"\(field): \(value)\"")
        }

        if let httpBodyData = self.httpBody,
            let httpBody = String(data: httpBodyData, encoding: .utf8) {
            let escapedBody = httpBody.replacingOccurrences(of: "\\\"", with: "\\\\\"")

            components.append("-d \"\(escapedBody)\"")
        }

        components.append("\"\(url.absoluteString)\"")

        return components.joined(separator: " ")
    }
}
