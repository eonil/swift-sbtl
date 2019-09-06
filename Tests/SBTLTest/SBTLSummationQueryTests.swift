//
//  File.swift
//  
//
//  Created by Henry Hathaway on 9/6/19.
//

import XCTest
@testable import SBTL

class SBTLSummationQueryTests: XCTestCase {
    func testOffsetQuery() {
        var a = SBTL<Int>()
        a.append(contentsOf: [100,200,300])
        XCTAssertEqual(a.indexAndOffset(for: 0).index, 0)
        XCTAssertEqual(a.indexAndOffset(for: 0).offset, 0)
        XCTAssertEqual(a.indexAndOffset(for: 1).index, 0)
        XCTAssertEqual(a.indexAndOffset(for: 1).offset, 1)
        XCTAssertEqual(a.indexAndOffset(for: 99).index, 0)
        XCTAssertEqual(a.indexAndOffset(for: 99).offset, 99)
        XCTAssertEqual(a.indexAndOffset(for: 100).index, 1)
        XCTAssertEqual(a.indexAndOffset(for: 100).offset, 0)
        XCTAssertEqual(a.indexAndOffset(for: 101).index, 1)
        XCTAssertEqual(a.indexAndOffset(for: 101).offset, 1)
        XCTAssertEqual(a.indexAndOffset(for: 188).index, 1)
        XCTAssertEqual(a.indexAndOffset(for: 188).offset, 88)
        XCTAssertEqual(a.indexAndOffset(for: 299).index, 1)
        XCTAssertEqual(a.indexAndOffset(for: 299).offset, 199)
        XCTAssertEqual(a.indexAndOffset(for: 300).index, 2)
        XCTAssertEqual(a.indexAndOffset(for: 300).offset, 0)
        XCTAssertEqual(a.indexAndOffset(for: 599).index, 2)
        XCTAssertEqual(a.indexAndOffset(for: 599).offset, 299)
        // Query for `600` should crash.
    }
}
