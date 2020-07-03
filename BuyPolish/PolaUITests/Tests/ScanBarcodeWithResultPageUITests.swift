import XCTest

final class ScanBarcodeWithResultPageUITests: PolaPerformanceTestCase {
    func testOpenGustawCompanyPage() {
        measureAfterOpen { startPage in
            startPage
                .enterCodeAndWaitForResult(codeData: CodeData.Gustaw)
                .done()
        }
    }
}
