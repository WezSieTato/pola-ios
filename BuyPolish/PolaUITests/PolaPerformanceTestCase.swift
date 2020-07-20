import XCTest

class PolaPerformanceTestCase: XCTestCase {
    let iterations: Int = 3

    func launchApp() -> ScanBarcodePage {
        let app = XCUIApplication()
        app.launchEnvironment = ["POLA_URL": "http://localhost:8888"]
        app.launch()

        return ScanBarcodePage(app: app)
    }

    func measureTime(block: () -> Void) {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, *) {
            let options = XCTMeasureOptions.default
            options.iterationCount = iterations
            measureMetrics([XCTPerformanceMetric.wallClockTime],
                           automaticallyStartMeasuring: true,
                           for: block)
        }
    }

    func measureAfterOpen(block: (ScanBarcodePage) -> Void) {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, *) {
            let options = XCTMeasureOptions.default
            options.iterationCount = iterations
            measureMetrics([XCTPerformanceMetric.wallClockTime],
                           automaticallyStartMeasuring: false) {
                let page = launchApp()
                startMeasuring()
                block(page)
                stopMeasuring()
            }
        }
    }
}
