import XCTest

final class EnterBarcodePageUITests: PolaPerformanceTestCase {
    func testOpenEnterBarcodePage() {
        measureAfterOpen { startPage in
            startPage
                .tapEnterBarcodeButton()
                .done()
        }
    }

}
