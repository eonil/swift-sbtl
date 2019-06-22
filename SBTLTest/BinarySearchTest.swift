//
//  BinarySearchTest.swift
//  SBTLTest
//
//  Created by Henry on 2019/06/22.
//

import XCTest
@testable import SBTL

class BinarySearchTest: XCTestCase {
    func testCase1() {
        let a = [10,20,30,40,50]
        let b = a.binarySearch.index(of: 20)
        let c = a.binarySearch.indexToPlace(20)
        let d = a.binarySearch.indexAndElement(of: 20)
        XCTAssertEqual(b, 1)
        XCTAssertEqual(c, 1)
        XCTAssertEqual(d?.index, 1)
    }
    func testCase2() {
        let a = [10,20,30,40,50]
        let b = a.binarySearch.index(of: 25)
        let c = a.binarySearch.indexToPlace(25)
        let d = a.binarySearch.indexAndElement(of: 25)
        XCTAssertEqual(b, nil)
        XCTAssertEqual(c, 2)
        XCTAssertEqual(d?.index, nil)
        XCTAssertEqual(a.binarySearch.indexToPlace(19), 1)
        XCTAssertEqual(a.binarySearch.indexToPlace(20), 1)
        XCTAssertEqual(a.binarySearch.indexToPlace(21), 2)
        XCTAssertEqual(a.binarySearch.indexToPlace(29), 2)
        XCTAssertEqual(a.binarySearch.indexToPlace(30), 2)
        XCTAssertEqual(a.binarySearch.indexToPlace(31), 3)
    }
    func testMany1() {
        let a = Array(0..<10000)
        for i in a.indices {
            let x = a.binarySearch.index(of: a[i])
            let y = a.binarySearch.indexAndElement(of: a[i])
            XCTAssertEqual(x, i)
            XCTAssertEqual(y?.index, i)
        }
    }
    func testCase3() {
        var m = SBTLMock()
        for _ in 0..<5 {
            m.insertRandom()
        }
        m.sort()
        let v = m.sys[0]
        m.validateBinarySearch(for: v)
    }
    func testMany2() {
        var m = SBTLMock()

        for _ in 0..<5 {
            m.insertRandom()
        }
        m.sort()
        for _ in 0..<5 {
            m.validateBinarySearchRandom()
        }
    }
    func testMany3() {
        var m = SBTLMock()
        for _ in 0..<100_000 {
            m.insertRandom()
        }
        m.sort()
        for _ in 0..<1000 {
            m.validateBinarySearchRandom()
//            print("\(#function) #\(i) c=\(m.impl.count)")
        }
    }
}
