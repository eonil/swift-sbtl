//
//  SBTLTest.swift
//  SBTLTest
//
//  Created by Henry on 2019/06/17.
//

import XCTest
@testable import SBTL

class SBTLTest: XCTestCase {
    func test1() {
        typealias L = SBTL<Int>
        var a = L()
        XCTAssertEqual(a.count, 0)

        a.append(111)
        XCTAssertEqual(a.count, 1)
        XCTAssertEqual(a.sum, 111)
        XCTAssertEqual(Array(a), [111])

        a.removeLast()
        XCTAssertEqual(a.count, 0)
        XCTAssertEqual(a.sum, 0)
        XCTAssertEqual(Array(a), [])
    }
    func test100() {
        typealias L = SBTL<Int>
        var a = L()
        XCTAssertEqual(a.count, 0)
        XCTAssertEqual(a.sum, 0)

        for i in 0..<100 {
            a.append(i)
        }
        XCTAssertEqual(a.count, 100)
        XCTAssertEqual(a.sum, (0..<100).reduce(0, +))
        XCTAssertEqual(Array(a), Array(0..<100))

        for _ in 0..<100 {
            a.removeLast()
        }
        XCTAssertEqual(a.count, 0)
        XCTAssertEqual(a.sum, 0)
        XCTAssertEqual(Array(a), [])
    }
    func testCase1() {
        typealias L = SBTL<Int>
        var a = L()
        XCTAssertEqual(a.count, 0)
        XCTAssertEqual(a.sum, 0)
        let n = 2048
        for i in 0..<n {
            a.append(i)
        }
        XCTAssertEqual(Array(a), Array(0..<n))
        XCTAssertEqual(a.sum, (0..<n).reduce(0, +))

        do {
            a.insert(999, at: a.count)
            let b = a[a.count-1]
            XCTAssertEqual(b, 999)
        }

        do {
            a.insert(2222, at: a.count)
            let b = a[a.count-1]
            XCTAssertEqual(b, 2222)
        }
    }
    func testCase2() {
        typealias L = SBTL<Int>
        var a = L()
        var b = [Int]()
        XCTAssertEqual(a.count, 0)
        let n = 4096
        for i in 0..<n {
            a.append(i)
            b.append(i)
        }
        XCTAssertEqual(Array(a), b)

        do {
            a.insert(999, at: a.count)
            b.insert(999, at: b.count)
            let x = a[a.count-1]
            XCTAssertEqual(x, 999)
            XCTAssertEqual(Array(a), b)
        }

        do {
            a.insert(2222, at: a.count)
            b.insert(2222, at: b.count)
            let x = a[a.count-1]
            XCTAssertEqual(x, 2222)
            XCTAssertEqual(Array(a), b)
        }
    }
    func test10000() {
        typealias L = SBTL<Int>
        var a = L()
        XCTAssertEqual(a.count, 0)

        let n = 10000
        for i in 0..<n {
            a.append(i)
            if i % 1000 == 0 {
                print(i)
                XCTAssertEqual(a.count, i+1)
                XCTAssertEqual(a.sum, (0...i).reduce(0, +))
                XCTAssertEqual(Array(a), Array(0...i))
            }
        }
        XCTAssertEqual(a.count, n)
        XCTAssertEqual(a.sum, (0..<n).reduce(0, +))
        XCTAssertEqual(Array(a), Array(0..<n))

        for i in 0..<n {
            a.removeLast()
            if i % 1000 == 0 {
                print(i)
            }
        }
        XCTAssertEqual(a.count, 0)
        XCTAssertEqual(a.sum, 0)
        XCTAssertEqual(Array(a), [])
    }
}
