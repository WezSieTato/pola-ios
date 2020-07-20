import XCTest

final class RecordVideoPageUITests: PolaPerformanceTestCase {
    func testOpenPage() {
        measureAfterOpen { startPage in
            startPage
                .enterCodeAndWaitForResult(codeData: .Naleczowianka)
                .tapHelpPolaButton()
                .tapRecordVideoButton()
                .done()
        }
    }
}
