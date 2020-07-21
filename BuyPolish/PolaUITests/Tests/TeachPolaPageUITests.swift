import XCTest

final class TeachPolaPageUITests: PolaPerformanceTestCase {
    func testOpenPage() {
        measureAfterOpen { startPage in
            startPage
                .enterCodeAndWaitForResult(codeData: .Naleczowianka)
                .tapHelpPolaButton()
                .done()
        }
    }
}
