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
        
        expect(sut, toLoad: [])
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

        expect(sutToPerformLoad, toLoad: movies)
    }
    
    func test_save_overridesItemsSavedOnASeparateInstance() {
        let sutToPerfomFirstSave = makeSUT()
        let sutToPerfomLastSave = makeSUT()
        let sutToPerformLoad = makeSUT()
        let firstMovies = uniqueItems().models
        let latestMovies = uniqueItems().models
        
        let saveExp1 = expectation(description: "Wait for save completion")
        sutToPerfomFirstSave.save(firstMovies) { saveError in
            XCTAssertNil(saveError, "Expected to save successfully")
            saveExp1.fulfill()
        }
        
        wait(for: [saveExp1], timeout: 1.0)
        
        let saveExp2 = expectation(description: "Wait for save completion")
        sutToPerfomLastSave.save(latestMovies) { saveError in
            XCTAssertNil(saveError, "Expected to save successfully")
            saveExp2.fulfill()
        }
        
        wait(for: [saveExp2], timeout: 1.0)
        
        expect(sutToPerformLoad, toLoad: latestMovies)
    }

    
    // - MARK: Helpers
    
    private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #file, line: UInt = #line) -> LocalMovieLoader {
        let store = CodableMovieStore(storeURL: testSpecificStoreURL())
        let sut = LocalMovieLoader(store: store, currentDate: currentDate)
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)

        return sut
    }
    
    private func expect(_ sut: LocalMovieLoader, toLoad expectedMovies: [Movie], file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "Wait for load completion")
        
        sut.load { result in
            switch result {
            case let .success(loadedMovies):
                XCTAssertEqual(loadedMovies, expectedMovies, file: file, line: line)
            case let .failure(error):
                XCTFail("Expected successful movies result, got \(error) instead", file: file, line: line)
            }
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
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
