//
//  Assigment_STests.swift
//  Assigment_STests
//
//  Created by Ajeet on 01/12/19.
//  Copyright © 2019 CG. All rights reserved.
//

import XCTest

@testable import AssigmentSingapore

class AssigmentSTests: XCTestCase {
    
    var testViewController: LandingPageController?
    var utilClass: Utils?
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        testViewController = LandingPageController()
        utilClass = Utils()
        
    }
    //// Test cases from Utils class
    func testCheckDateAndTime() {
        
        let checkDateTime = utilClass!.getCurrentDateTime()
        XCTAssertEqual("2019-12-04T14:31:50", checkDateTime)
    }
    
    func testGetCurrentDate() {
        let today = Date()
        // create dateFormatter with current time format
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let curentDate = dateFormatter.string(from: today)
        let checkDateTime = utilClass!.getCurrentDate()
        XCTAssertEqual(curentDate, checkDateTime, "Test Passed")
    }
    
    // API releted Test cases
    func testRequestWithURL() {
        
        guard let url = URL(string: "https://api.data.gov.sg/v1/environment/psi?") else {
            XCTFail("Url can not be Empty")
            return
        }
        let resource = (url: URL(string:baseUrl)!)
        
        XCTAssert(resource.url == url)
        
    }
    
    // Check Response data has proper json format or not
    func testIsAPIReturningCorrectData() {
        
        // Send Wrong parameter
        let params = "date_time=2019-12-03T"
        
        let urlString = baseUrl+params
        let url = URL(string: urlString)
        
        let expectationFromAPI = expectation(description: "Is returning correct data format?")
        
        let dataTask = URLSession.shared.dataTask(with: url!) { data, response, error in
            
            if let error = error {
                XCTFail("Error: \(error.localizedDescription)")
                return
            } else if let statusCode = (response as? HTTPURLResponse)?.statusCode {
                
                /// No valid json data coming
                if JSONSerialization.isValidJSONObject(data as Any) {
                    expectationFromAPI.fulfill()
                    
                } else {
                    
                    XCTFail("Status code: \(statusCode)")
                }
            }
        }
        dataTask.resume()
        wait(for: [expectationFromAPI], timeout: 5)
    }
    
    
    // Check Response Code is 200 or not
    func testValidAPIGetHTTPStatusCode() {
        
        let params = "date_time=\(utilClass!.getCurrentDateTime())"
        
        let urlString = baseUrl+params
        let url = URL(string: urlString)
        
        let expectationFromAPI = expectation(description: "Is status code: 200")
        
        let dataTask = URLSession.shared.dataTask(with: url!) { data, response, error in
            
            if let error = error {
                XCTFail("Error: \(error.localizedDescription)")
                return
            } else if let statusCode = (response as? HTTPURLResponse)?.statusCode {
                if statusCode == 200 {
                    
                    expectationFromAPI.fulfill()
                } else {
                    XCTFail("Status code: \(statusCode)")
                }
            }
        }
        dataTask.resume()
        wait(for: [expectationFromAPI], timeout: 5)
    }
    
    override func tearDown() {
        testViewController = nil
        utilClass = nil
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    
}
