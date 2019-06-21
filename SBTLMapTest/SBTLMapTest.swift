//
//  SBTLMapTest.swift
//  SBTLMapTest
//
//  Created by Henry on 2019/06/21.
//

import XCTest
@testable import SBTL

class SBTLMapTest: XCTestCase {
    func testBasics() {
        typealias X = SBTLMap<String,Int>
        var x = X()
        x["aaa"] = 11
        XCTAssertEqual(x[0].key, "aaa")
        XCTAssertEqual(x[0].value, 11)
        XCTAssertEqual(x["aaa"], 11)
        x["bbb"] = 22
        XCTAssertEqual(x[0].key, "aaa")
        XCTAssertEqual(x[0].value, 11)
        XCTAssertEqual(x[1].key, "bbb")
        XCTAssertEqual(x[1].value, 22)
        XCTAssertEqual(x["aaa"], 11)
        XCTAssertEqual(x["bbb"], 22)
        x["ccc"] = 33
        XCTAssertEqual(x[0].key, "aaa")
        XCTAssertEqual(x[0].value, 11)
        XCTAssertEqual(x[1].key, "bbb")
        XCTAssertEqual(x[1].value, 22)
        XCTAssertEqual(x[2].key, "ccc")
        XCTAssertEqual(x[2].value, 33)
        XCTAssertEqual(x["aaa"], 11)
        XCTAssertEqual(x["bbb"], 22)
        XCTAssertEqual(x["ccc"], 33)
    }
    func testCase1() {
        typealias X = SBTLMap<Int,Int>
        var x = X()
        x[644955193] = 85615556
        x[2487920172] = 2424722190
        XCTAssertEqual(x[2487920172], 2424722190)
    }
    func testCase2() {
        typealias X = SBTLMap<Int,Int>
        var x = X()
        x[2] = 222
        x[1] = 111
        print(x[2] as Int? ?? -1)
        XCTAssertEqual(x[2], 222)
    }
    func testCase3() {
        typealias X = SBTLMap<Int,Int>
        var x = X()
        x[3617481367] = 3892534839
        print(x[3617481367] as Int? ?? -1)
        x[3617481367] = nil
        XCTAssertEqual(x[3617481367], nil)
    }
    func testMockCase1() {
        var m = SBTLMapMock()
        for i in 0..<8 {
            m.stepRandom()
            m.validate()
            print("\(i)")
        }
        print(m.sysSortedKVs)
        print(m.implSortedKVs)
        m.stepRandom()

        print(m.sysSortedKVs)
        print(m.implSortedKVs)
        m.validate()
    }
    func testWithFewElements() {
        var m = SBTLMapMock()
        for i in 0..<(10_000) {
            m.stepRandom()
            if i % 1_000 == 0 {
                print("\(#function) #\(i) c=\(m.impl.count)")
                m.validate()
            }
        }
    }
    func testWithManyElements() {
        var m = SBTLMapMock()
        for _ in 0..<(40_000) {
            m.insertRandom()
        }
        for i in 0..<(10_000) {
            m.stepRandom()
            if i % 1_000 == 0 {
                print("\(#function) #\(i) c=\(m.impl.count)")
                m.validate()
            }
        }
    }
}

