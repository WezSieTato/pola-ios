import XCTest

final class CompanyPageUITests: PolaPerformanceTestCase {
    func testOpenCompanyPage() {
        measureAfterOpen { startPage in
            startPage
                .enterCodeAndOpenCompanyResult(codeData: CodeData.Radziemska)
                .done()
        }
    }

    func testOpenReportPageFromCompanyPage() {
        measureAfterOpen { startPage in
            startPage
                .enterCodeAndOpenCompanyResult(codeData: CodeData.Koral)
                .tapReportButton()
                .done()
        }
    }
}
