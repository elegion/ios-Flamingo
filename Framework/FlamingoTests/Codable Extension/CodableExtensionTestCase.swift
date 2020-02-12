//
//  CodableExtensionTestCase.swift
//  FlamingoTests
//
//  Created by Dmitrii Istratov on 05-04-2018.
//  Copyright © 2018 ELN. All rights reserved.
//

import XCTest
@testable import Flamingo

private struct Person: Decodable {
    
    let name: String
    let age: Int?
    let transformedDesc: String?
    let transformedOptionalDesc: String?

    private enum CodingKeys: String, CodingKey {
        case name
        case age
        case transformedDesc = "desc"
        case transformedOptionalDesc = "optionalDesc"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(.name)
        age = try container.decodeIfPresent(.age)
        transformedDesc = try container.decode(.transformedDesc) {
            (desc: String) -> String in
            
            return "\(desc) Transformed"
        }
        transformedOptionalDesc = try container.decodeIfPresent(.transformedOptionalDesc) {
            (desc: String) -> String in
            
            return "\(desc) Transformed"
        }
    }
}

private struct RegexWrapper: Codable {
    
    let regex: NSRegularExpression

    private enum CodingKeys: String, CodingKey {
        case regex
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        regex = try container.decode(.regex, transformer: RegexCodableTransformer())
    }

    func encode(to encoder: Encoder) throws {
        var container =  encoder.container(keyedBy: CodingKeys.self)
        try container.encode(regex, forKey: .regex, transformer: RegexCodableTransformer())
    }
}

private struct OptionalRegexWrapper: Decodable {
    
    let regex: NSRegularExpression?

    private enum CodingKeys: String, CodingKey {
        case regex
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        regex = try? container.decode(.regex, transformer: RegexCodableTransformer())
    }
}
// swiftlint:disable force_try force_unwrapping
final class Tests: XCTestCase {
    
    func testDecodingStandardType() {
        let json = """
        {
            "name": "James Ruston",
            "desc": "Description"
        }
        """.data(using: .utf8)!

        let person = try! JSONDecoder().decode(Person.self, from: json)

        XCTAssertEqual(person.name, "James Ruston")
        XCTAssertNil(person.age)
        XCTAssertEqual(person.transformedDesc, "Description Transformed")
        XCTAssertNil(person.transformedOptionalDesc)
    }
    
    func testDecodingWithUnkeyedContainer() {
        
    }

    func testCustomTransformer() {
        let json = """
        {
            "regex": ".*"
        }
        """.data(using: .utf8)!

        let wrapper = try! JSONDecoder().decode(RegexWrapper.self, from: json)

        XCTAssertEqual(wrapper.regex.pattern, ".*")
    }

    func testInvalidType() {
        let json = """
        {
            "regex": true
        }
        """.data(using: .utf8)!

        let wrapper = try? JSONDecoder().decode(RegexWrapper.self, from: json)

        XCTAssertNil(wrapper)
    }

    func testInvalidRegex() {
        let json = """
        {
            "regex": "["
        }
        """.data(using: .utf8)!

        let wrapper = try! JSONDecoder().decode(OptionalRegexWrapper.self, from: json)

        XCTAssertNil(wrapper.regex)
    }

    func testEncoding() {
        let jsonString = "{\"regex\":\".*\"}"
        let json = jsonString.data(using: .utf8)!

        let wrapper = try! JSONDecoder().decode(RegexWrapper.self, from: json)
        let encoded = try! JSONEncoder().encode(wrapper)

        let output = String(data: encoded, encoding: .utf8)!

        XCTAssertEqual(jsonString, output)
    }
}
// swiftlint:enable force_try force_unwrapping
