//
//  PhotoLibraryViewModelTests.swift
//  DemoRoomvuTests
//
//  Created by Sparrow on 2024-02-24.
//

import XCTest
@testable import DemoRoomvu
import Photos

class MockPhotoLibraryViewModelDelegate: PhotoLibraryViewModelDelegate {
    var didFetchPhotosExpectation: XCTestExpectation?
    var didEncounterErrorExpectation: XCTestExpectation?

    func didFetchPhotos(_ photos: [UIImage]) {
        didFetchPhotosExpectation?.fulfill()
    }

    func didEncounterError(_ error: PhotoLibraryError) {
        didEncounterErrorExpectation?.fulfill()
    }
}

class PhotoLibraryViewModelTests: XCTestCase {
    var viewModel: PhotoLibraryViewModel!
    var mockDelegate: MockPhotoLibraryViewModelDelegate!

    override func setUpWithError() throws {
        viewModel = PhotoLibraryViewModel()
        mockDelegate = MockPhotoLibraryViewModelDelegate()
        viewModel.delegate = mockDelegate
    }

    override func tearDownWithError() throws {
        viewModel = nil
        mockDelegate = nil
    }

    func testFetchPhotosAuthorized() {
        mockDelegate.didFetchPhotosExpectation = expectation(description: "Did fetch photos")
        
        viewModel.fetchPhotos()

        waitForExpectations(timeout: 5, handler: nil)
    }

    func testFetchPhotosNotDetermined() {
        mockDelegate.didFetchPhotosExpectation = expectation(description: "Did fetch photos")
        viewModel.fetchPhotos()

        waitForExpectations(timeout: 5, handler: nil)
    }


}
