import XCTest

class UILaunchTests: PolaPerformanceTestCase {
    func testLaunchPerformance() {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, *) {
            let options = XCTMeasureOptions.default
            options.iterationCount = iterations
            measure(metrics: [XCTOSSignpostMetric.applicationLaunch], options: options) {
                launchApp().done()
            }
        }
    }
}
