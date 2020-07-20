import XCTest

final class ReportBugPageUITests: PolaPerformanceTestCase {
    func testOpenReportBugPage() {
        measureAfterOpen { startPage in
            startPage
                .tapInformationButton()
                .tapReportBugButton()
                .done()
        }
    }
}
