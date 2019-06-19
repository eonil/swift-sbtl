//
//  SBTLMockBasedUnitTests.swift
//  SBTLUnitTests
//
//  Created by Henry on 2019/06/17.
//

import XCTest
@testable import SBTL

class SBTLMockBasedUnitTests: XCTestCase {
    func test1() {
        var m = SBTLMock()
        let n = 4096
        for _ in 0..<n {
            m.stepRandom()
            XCTAssertEqual(m.sys.count, m.impl.count)
            XCTAssertEqual(m.sys, Array(m.impl))
        }
        let wa = m.sys.reduce(0, +)
        for _ in 0..<n {
            let w = m.random() % wa
            let a = m.sysIndexAndOffset(for: w)
            let b = m.implIndexAndOffset(for: w)
            XCTAssertEqual(a.index, b.index)
            XCTAssertEqual(a.offset, b.offset)
        }
    }
    func testCase1() {
        var m = SBTLMock()
        m.runRandom(2050)
        m.stepRandom()
        XCTAssertEqual(m.sys.count, m.impl.count)
        for i in 0..<m.sys.count {
            XCTAssertEqual(m.sys[i], m.impl[i])
        }
    }

    func testBalancingCase1() {
        var m = SBTLMock()
        for _ in 0..<4096 {
            m.appendRandom()
            XCTAssertTrue(m.impl.isWellBalanced())
        }
        XCTAssertEqual(m.sys, Array(m.impl))
        m.appendRandom()
        XCTAssertTrue(m.impl.isWellBalanced())
        XCTAssertEqual(m.sys, Array(m.impl))
    }
    func testBalancingCase2() {
        var m = SBTLMock()
        for _ in 0..<6144 {
            m.appendRandom()
            XCTAssertTrue(m.impl.isEmpty || !m.impl.containsAnyEmptyLeaf())
            XCTAssertTrue(m.impl.isWellBalanced())
        }
        XCTAssertEqual(m.sys, Array(m.impl))
        m.appendRandom()
        XCTAssertTrue(m.impl.isEmpty || !m.impl.containsAnyEmptyLeaf())
        XCTAssertTrue(m.impl.isWellBalanced())
        XCTAssertEqual(m.sys, Array(m.impl))
    }
    func testEqualityCase1() {
        var m = SBTLMock()
        for _ in 0..<6144 {
            m.appendRandom()
        }
        XCTAssertTrue(m.impl.isEmpty || !m.impl.containsAnyEmptyLeaf())
        XCTAssertTrue(m.impl.isWellBalanced())
        XCTAssertEqual(m.sys, Array(m.impl))

        m.appendRandom()
        XCTAssertTrue(m.impl.isEmpty || !m.impl.containsAnyEmptyLeaf())
        XCTAssertTrue(m.impl.isWellBalanced())
        XCTAssertEqual(m.sys.count, m.impl.count)
        for i in 0..<m.sys.count {
            // Previously failed at i = 3072
            XCTAssertEqual(m.sys[i], m.impl[i])
        }
    }
    func testBalancingCase3() {
        var m = SBTLMock()
        for _ in 0..<8192 {
            m.appendRandom()
            XCTAssertTrue(m.impl.isEmpty || !m.impl.containsAnyEmptyLeaf())
            XCTAssertTrue(m.impl.isWellBalanced())
        }
        XCTAssertNil(m.impl.unbalanceNodePath())
        XCTAssertEqual(m.sys, Array(m.impl))
        m.appendRandom()

        XCTAssertTrue(m.impl.isEmpty || !m.impl.containsAnyEmptyLeaf())
        XCTAssertNil(m.impl.unbalanceNodePath())
        XCTAssertTrue(m.impl.isWellBalanced())
        XCTAssertEqual(m.sys, Array(m.impl))
    }
    func testAppendManyRandom() {
        var m = SBTLMock()
        for i in 0..<(100_000) {
            m.appendRandom()
            XCTAssertTrue(m.impl.isEmpty || !m.impl.containsAnyEmptyLeaf())
            XCTAssertTrue(m.impl.isWellBalanced())
            if i % 10_000 == 0 {
                print("\(#function) #\(i), count: \(m.impl.count)")
                XCTAssertEqual(m.sys, Array(m.impl))
            }
        }
        XCTAssertTrue(m.impl.isEmpty || !m.impl.containsAnyEmptyLeaf())
        XCTAssertTrue(m.impl.isWellBalanced())
        XCTAssertEqual(m.sys, Array(m.impl))
    }
    func testRandomMany() {
        var m = SBTLMock()
        for _ in 0..<(100_000) {
            m.appendRandom()
        }
        XCTAssertTrue(m.impl.isEmpty || !m.impl.containsAnyEmptyLeaf())
        XCTAssertTrue(m.impl.isWellBalanced())
        XCTAssertEqual(m.sys, Array(m.impl))
        for i in 0..<(100_000) {
            m.stepRandom()
            XCTAssertTrue(m.impl.isEmpty || !m.impl.containsAnyEmptyLeaf())
            XCTAssertTrue(m.impl.isWellBalanced())
            if i % 10_000 == 0 {
                print("\(#function) #\(i), count: \(m.impl.count)")
                XCTAssertEqual(m.sys, Array(m.impl))
            }
        }
        XCTAssertTrue(m.impl.isEmpty || !m.impl.containsAnyEmptyLeaf())
        XCTAssertTrue(m.impl.isWellBalanced())
        XCTAssertEqual(m.sys, Array(m.impl))
    }
}

