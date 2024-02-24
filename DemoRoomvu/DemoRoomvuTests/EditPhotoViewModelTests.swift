//
//  EditPhotoViewModelTests.swift
//  DemoRoomvuTests
//
//  Created by Sparrow on 2024-02-24.
//

import XCTest
@testable import DemoRoomvu

class EditPhotoViewModelTests: XCTestCase {
    
    var viewModel: EditPhotoViewModel!
    var mockDelegate: MockEditPhotoViewModelDelegate!
    
    override func setUp() {
        super.setUp()
        viewModel = EditPhotoViewModel()
        mockDelegate = MockEditPhotoViewModelDelegate(expectation: nil)
        viewModel.delegate = mockDelegate
    }
    
    override func tearDown() {
        viewModel = nil
        mockDelegate = nil
        super.tearDown()
    }
    func testYourImageLoadingFunction() {
        let bundle = Bundle(for: type(of: self))
        guard let testImageURL = bundle.url(forResource: "testImage", withExtension: "png"),
              let testImage = UIImage(contentsOfFile: testImageURL.path) else {
            XCTFail("Test image not found")
            return
        }
    }
    func testImageUploadSuccess() {
        guard let testImage = UIImage(named: "testImage", in: Bundle(for: type(of: self)), compatibleWith: nil) else {
            XCTFail("Test image not found")
            return
        }
        
        let testToken = "AHpzZnQjHfPaRd9NMCq8"
        
        let expectation = XCTestExpectation(description: "Image upload success")
        
        mockDelegate.expectation = expectation
        
        viewModel.uploadImage(image: testImage, authToken: testToken) { progress in
        }
        
        wait(for: [expectation], timeout: 5.0)
        
        XCTAssertTrue(mockDelegate.didReceiveImageUploadSuccessCalled)
    }
    
    func testImageUploadFailure() {
        guard let testImage = UIImage(named: "testImage", in: Bundle(for: type(of: self)), compatibleWith: nil) else {
            XCTFail("Test image not found")
            return
        }
        
        let invalidToken = "AHpzZnQjHfPaRd9NMC78"
        
        let expectation = XCTestExpectation(description: "Image upload failure")
        mockDelegate.expectation = expectation
        
        viewModel.uploadImage(image: testImage, authToken: invalidToken) { progress in
            // Implement if needed for progress testing
        }
        
        wait(for: [expectation], timeout: 5.0)
        
        XCTAssertTrue(mockDelegate.didReceiveImageUploadFailureCalled)
        
        if let receivedError = mockDelegate.receivedError {
            XCTAssertEqual(receivedError, "Invalid token", "Error message mismatch")
        } else {
            XCTFail("Received error is nil")
        }
    }
    
}

class MockEditPhotoViewModelDelegate: EditPhotoViewModelDelegate {
    
    var didReceiveImageUploadSuccessCalled = false
    var didReceiveImageUploadFailureCalled = false
    var receivedError: String?
    var expectation: XCTestExpectation?
    
    init(expectation: XCTestExpectation? = nil) {
        self.expectation = expectation
    }
    
    func imageUploadSuccess() {
        didReceiveImageUploadSuccessCalled = true
        expectation?.fulfill()
    }
    
    func imageUploadFailure(error: Error) {
        didReceiveImageUploadFailureCalled = true
        receivedError = error.localizedDescription
        expectation?.fulfill()
    }
}
