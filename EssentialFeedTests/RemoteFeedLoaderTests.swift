//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Chad Games on 25/08/2022.
//

import XCTest
import EssentialFeed

class RemoteFeedLoaderTests: XCTestCase {

    func test_init_doesNotRequestDataFromURL() {
        let (_, client) = makeSUT()
        
        XCTAssertTrue(client.requestedURLs.isEmpty)
    }
    
    func test_load_requestDataFromURL() {
        let url = URL(string: "https://theurl.com")!
        let (sut, client) = makeSUT(url: url)
        
        sut.load() { _ in }
        
        XCTAssertEqual(client.requestedURLs, [url])
    }

    func test_loadTwice_requestDataFromURL() {
        let url = URL(string: "https://theurl.com")!
        let (sut, client) = makeSUT(url: url)
        
        sut.load() { _ in }
        sut.load() { _ in }
        
        XCTAssertEqual(client.requestedURLs, [url, url])
    }
    
    func test_load_deliversErrorOnClientError() {
        let (sut, client) = makeSUT()
        
        
        var capturedError = [RemoteFeedLoader.Error]()
        sut.load { capturedError.append($0) }
        
        let clientError = NSError(domain: "Test", code: 0)
        client.complete(with: clientError, at: 0)
        
        XCTAssertEqual(capturedError, [.connectivity])
    }
    
    func test_load_deliversErrorOnNon200HTTPResponse() {
        let (sut, client) = makeSUT()
        
        let samples = [199, 201, 300, 400, 500].enumerated()
        
        samples.forEach({ index, sample in
            var capturedError = [RemoteFeedLoader.Error]()
            sut.load { capturedError.append($0) }
            
            client.complete(withStatusCode: sample, at: index)
            XCTAssertEqual(capturedError, [.invalidData])
        })
    }
    
    // MARK: - Helpers
    
    private func makeSUT(url: URL = URL(string: "https://theurl.com")!) -> (sut: RemoteFeedLoader, client: HTTPClientSpy) {
        
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(url: url, client: client)
        return (sut, client)
    }
    
    class HTTPClientSpy: HTTPClient {
        
        private var messages = [(url: URL, completion: (HTTPResponseType) -> Void)]()
        
        var requestedURLs: [URL] {
            return messages.map({ $0.url })
        }
        
        func get(from url: URL, completion: @escaping (HTTPResponseType) -> Void) {
            messages.append((url, completion))
        }
        
        func complete(with error: Error, at index: Int = 0) {
            messages[index].completion(.failure(error))
        }
        
        func complete(withStatusCode code: Int, at index: Int = 0) {
            let response = HTTPURLResponse(url: requestedURLs[index],
                                           statusCode: code,
                                           httpVersion: nil,
                                           headerFields: nil)!
            
            messages[index].completion(.success(response))
        }
        
    }
    
}
