//
//  DashboardViewModelTests.swift
//  DemoRoomvuTests
//
//  Created by Sparrow on 2024-02-24.
//

import XCTest
@testable import DemoRoomvu

class DashboardViewModelTests: XCTestCase {

    // Mock delegate for testing
    class MockDashboardViewModelDelegate: DashboardViewModelDelegate {
        var expectation: XCTestExpectation?
        var receivedImage: UIImage?

        init(expectation: XCTestExpectation) {
            self.expectation = expectation
        }

        func didReceiveEnhancedImage(_ image: UIImage) {
            receivedImage = image
            expectation?.fulfill()
        }
    }

    var viewModel: DashboardViewModel!

    override func setUp() {
        super.setUp()
        viewModel = DashboardViewModel()
    }

    override func tearDown() {
        viewModel = nil
        super.tearDown()
    }

    func testProcessEnhancedImage() {
        let expectation = XCTestExpectation(description: "Expectation for didReceiveEnhancedImage")

        let mockDelegate = MockDashboardViewModelDelegate(expectation: expectation)
        viewModel.delegate = mockDelegate

        let testImage = UIImage(named: "testImage")!

        viewModel.processEnhancedImage(testImage)

        wait(for: [expectation], timeout: 5.0)

        XCTAssertEqual(mockDelegate.receivedImage, testImage)
    }
}
