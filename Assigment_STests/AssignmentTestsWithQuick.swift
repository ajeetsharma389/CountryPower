//
//  Assignment_STestsWithQuick.swift
//  Assigment_STests
//
//  Created by Ajeet on 04/12/19.
//  Copyright © 2019 CG. All rights reserved.
//


import Quick
import Nimble

@testable import AssigmentSingapore

class AssignmentTestsWithQuick: QuickSpec {
    
    override func spec() {
        var subject: LandingPageController!
        var utilClass: Utils!
        var checkDate : String?
        context("ViewController itemsDataSource count"){
            afterEach {
                subject = nil
            }
            beforeEach {
                subject = UIStoryboard(name: "Main",
                                       bundle: nil).instantiateViewController(withIdentifier: "ViewController") as? LandingPageController
                
                _ = subject.view
            }
            it("should have items_DataSource  count equal to zero at initial stage") {
                expect(subject.itemsDataSource.count).to(equal(0))
            }
        }
        
        //////
        context("Checking the Request URL") {
            
            beforeEach {
                ///Nothing
            }
            it("should have items_DataSource  count equal to zero") {
                expect(baseUrl).to(equal("https://api.data.gov.sg/v1/environment/psi"))
            }
        }
        
        ///
        context("Check Current Date") {
            afterEach {
                utilClass = nil
                checkDate = nil
            }
            beforeEach {
                utilClass = Utils.init()
            }
            it("Has some default date string to check") {
                checkDate = utilClass.getCurrentDate()
                expect(checkDate).to(equal("2019-12-05"))
            }
            
        }
    }
    
}

