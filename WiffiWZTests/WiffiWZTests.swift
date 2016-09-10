//
//  WiffiWZTests.swift
//  WiffiWZTests
//
//  Created by Thomas Kluge on 09.09.16.
//  Copyright © 2016 kSquare.de. All rights reserved.
//

import XCTest
@testable import WiffiWZ

class WiffiWZTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testFetch() {

      let readyExpectation = expectation(description: "ready")

      let manager = WiffiManager()
      manager.fetchMeasurements { (error, measurement) in
        XCTAssertNil(error, "There was an error");
        XCTAssert(measurement?.sensor_ip != "invalid" , "Invalid IP Fetched")
        readyExpectation.fulfill();
      }
    
      waitForExpectations(timeout: 60, handler: { error in
        XCTAssertNil(error, "Time out Error")
      })
      
    }
  
  func testCalibrateCO2() {
    
    let readyExpectation = expectation(description: "ready")
    
    let manager = WiffiManager()
    manager.calibareCO2Sensor { (error) in
      XCTAssertNil(error, "There was an error");
      readyExpectation.fulfill();
    }
    
    waitForExpectations(timeout: 60, handler: { error in
      XCTAssertNil(error, "Time out Error")
    })
    
  }
  
  
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
