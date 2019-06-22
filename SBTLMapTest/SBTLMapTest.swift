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
    func testBasicsInRandomOrder() {
        typealias X = SBTLMap<String,Int>
        var x = X()
        x["ccc"] = 33
        XCTAssertEqual(x[0].key, "ccc")
        XCTAssertEqual(x[0].value, 33)
        XCTAssertEqual(x["ccc"], 33)
        x["aaa"] = 11
        XCTAssertEqual(x[0].key, "aaa")
        XCTAssertEqual(x[0].value, 11)
        XCTAssertEqual(x[1].key, "ccc")
        XCTAssertEqual(x[1].value, 33)
        XCTAssertEqual(x["aaa"], 11)
        XCTAssertEqual(x["ccc"], 33)
        x["bbb"] = 22
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
        let n = 100_000
        var r = ReproducibleRPNG(n)
        var x = SBTLMap<Int,String>()
        var y = [Int]()
        for _ in 0..<n {
            let k = r.nextWithRotation()
            x[k] = "\(k)"
            y.append(k)
        }
        let a = x.impl.map({ $0.element.key })
        let b = y.sorted()
        XCTAssertEqual(a, b)
        for i in 0..<n {
            let k = a[i]
            XCTAssertEqual(x[k], "\(k)")
        }
    }




    func testCornerCase1() {
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
    func testMockCase2() {
        var m = SBTLMapMock()
        for _ in 0..<(6440) {
            m.insertRandom()
        }
        m.validate()
        m.insert(1454468357, 3757351609)
        XCTAssertEqual(m.impl[1469267839]?.value ?? -1, 4082850292)
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
        for i in 0..<(40_000) {
            m.insertRandom()
            if i % 1_000 == 0 {
                print("\(#function) #\(i) c=\(m.impl.count)")
                m.validate()
            }
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

