//
//  ScanBarcodeWithResultPageUITests.swift
//  PolaUITests
//
//  Created by Marcin Stepnowski on 17/04/2019.
//  Copyright © 2019 PJMS. All rights reserved.
//

import XCTest

class ScanBarcodeWithResultPageUITests: PolaUITestCase {
    
    override func setUp() {
        super.setUp()
        recordMode = false
    }
        
    func testGustawCompanyShouldBeMarkedAsPolaFriends() {
        testResultPage(company: Company.Gustaw)
    }
    
    func testStaropramenCompanyShouldNotBeMarkedAsPolaFriends() {
        testResultPage(company: Company.Staropramen)
    }

    func testResultPage(company: Company, file: StaticString = #file, line: UInt = #line) {
        startingPageObject
            .tapEnterBarcodeButton()
            .inputBarcode(company.barcode)
            .tapOkButton()
            .waitForResultPage(companyName: company.name)
            .done()
        
        snapshotVerifyView(file: file, line: line)
    }
    
    func testISBNCode() {
        startingPageObject
            .tapEnterBarcodeButton()
            .inputBarcode(ISBNCode)
            .tapOkButton()
            .waitForISBNResultPage()
            .done()
        
        snapshotVerifyView()
    }

}
