//
//  SwiftUIMoviesCacheIntegrationTests.swift
//  SwiftUIMoviesCacheIntegrationTests
//
//  Created by Nadheer on 09/08/2021.
//

import XCTest
import SwiftUIMovies

class SwiftUIMoviesCacheIntegrationTests: XCTestCase {

    override func setUp() {
        super.setUp()
        
        setupEmptyStoreState()
    }
    
    override func tearDown() {
        super.tearDown()
        
        undoStoreSideEffects()
    }

    func test_load_deliversNoItemsOnEmptyCache() {
        let sut = makeSUT()
        
        let exp = expectation(description: "Wait for load completion")
        
        sut.load { result in
            switch result {
            
            case let .success(movies):
                XCTAssertEqual(movies, [], "Expected empty movies result")
                
            case let .failure(error):
                XCTFail("Expected successful movies result, got \(error) instead")
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_load_deliversItemsSavedOnSeparateInstance() {
        let sutToPerfomSave = makeSUT()
        let sutToPerformLoad = makeSUT()
        let movies = uniqueItems().models
        
        let saveExp = expectation(description: "Wait for save completion")
        sutToPerfomSave.save(movies) { saveError in
            XCTAssertNil(saveError, "Expected to save successfully")
            saveExp.fulfill()
        }
        wait(for: [saveExp], timeout: 1.0)

        
        let loadExp = expectation(description: "Wait for load completion")
        sutToPerformLoad.load { loadResult in
            switch loadResult {
            case let .success(imageFeed):
                XCTAssertEqual(imageFeed, movies)
            case let .failure(error):
                XCTFail("Expected successful feed result, got \(error) instead")
            }
            
            loadExp.fulfill()
        }
        
        wait(for: [loadExp], timeout: 1.0)
    }
    
    // - MARK: Helpers
    
    private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #file, line: UInt = #line) -> LocalMovieLoader {
        let store = CodableMovieStore(storeURL: testSpecificStoreURL())
        let sut = LocalMovieLoader(store: store, currentDate: currentDate)
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)

        return sut
    }
    
    private func setupEmptyStoreState() {
        deleteStoreArtifacts()
    }
    
    private func undoStoreSideEffects() {
        deleteStoreArtifacts()
    }
    
    private func deleteStoreArtifacts() {
        try? FileManager.default.removeItem(at: testSpecificStoreURL())
    }

    private func testSpecificStoreURL() -> URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("\(type(of: self)).store")
    }
    
    private func cachesDirectory() -> URL {
        return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
    }


}
