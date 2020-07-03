import XCTest

final class InformationPageUITests: PolaPerformanceTestCase {
    func testOpenInformationPage() {
        measureAfterOpen { startPage in
            startPage
                .tapInformationButton()
                .done()
        }
    }
}
