//
//  GroupManagerTest.swift
//  CopyBoard
//
//  Created by zhoubo on 2017/1/13.
//  Copyright © 2017年 zhoubo. All rights reserved.
//

import XCTest

class GroupManagerTest: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
        let tests = (0..<10).map { (index) -> TestGroupClass in
            TestGroupClass()
        }
        
        let manage = GroupManager()
        let s = manage.createDictArray(objects: tests)
        XCTAssertEqual(s?.count, 10)
        XCTAssertEqual(s?.first?.count, 3)
        XCTAssertNotNil(s?.first)
        XCTAssertEqual((s?.first)!, ["name": "Name",
                                     "age": "1",
                                     "createdAt": "\(Date(timeIntervalSince1970: 100000))"]
        )
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}

class TestGroupClass: ObjectMirrorDelegate {
    var name = "Name"
    var age = 1
    var createdAt = Date(timeIntervalSince1970: 100000)

    func objectValueKeys() -> Array<String> {
        return ["name", "age", "createdAt"]
    }
    
    func transformational(label: String) -> String? {
        switch label {
        case "createdAt":
            return "\(self.createdAt)"
        default:
            return nil
        }
    }
    
    func childTypes() -> [Any.Type] {
        return [String.self, Int.self, Date.self]
    }
}
