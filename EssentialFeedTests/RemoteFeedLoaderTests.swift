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
        
        expect(sut: sut, toCompleteWithResult: .failure(.connectivity), when: {
            let clientError = NSError(domain: "Test", code: 0)
            client.complete(with: clientError, at: 0)
        })
    }
    
    func test_load_deliversErrorOnNon200HTTPResponse() {
        let (sut, client) = makeSUT()
        
        let samples = [199, 201, 300, 400, 500].enumerated()
        
        samples.forEach({ index, sample in
            expect(sut: sut, toCompleteWithResult: .failure(.invalidData), when: {
                let data = makeItemsJSON([])
                client.complete(withStatusCode: sample, data: data, at: index)
            })
        })
    }
    
    func test_load_deliversErrorOnNon200HTTPResponse_withInvalidJSON() {
        let (sut, client) = makeSUT()
        
        expect(sut: sut, toCompleteWithResult: .failure(.invalidData), when: {
            let invalidJSON = "invalid json".data(using: .utf8)!
            client.complete(withStatusCode: 200, data: invalidJSON)
        })
    }
    
    func test_load_deliversNoItemsOn200HTTPResponse_withEmptyJSONList() {
        let (sut, client) = makeSUT()
        
        expect(sut: sut, toCompleteWithResult: .success([]), when: {
            let emptyListJson = makeItemsJSON([])
            
            client.complete(withStatusCode: 200, data: emptyListJson)
        })
    }
    
    func test_load_deliversNoItemsOn200HTTPResponse_withJSONList() {
        let (sut, client) = makeSUT()
        
        let feedItem1 = makeItem(id: UUID(),
                                 description: nil,
                                 location: nil,
                                 imageURL: URL(string: "http://a-url.com")!)
        
        let feedItem2 = makeItem(id: UUID(),
                                 description: "description",
                                 location: "location",
                                 imageURL: URL(string: "http://a-url.com")!)
        
        expect(sut: sut, toCompleteWithResult: .success([feedItem1.model, feedItem2.model]), when: {
            let json = makeItemsJSON([feedItem1.json, feedItem2.json])
            client.complete(withStatusCode: 200, data: json)
        })
    }
    
    // MARK: - Helpers
    
    private func makeSUT(url: URL = URL(string: "https://theurl.com")!) -> (sut: RemoteFeedLoader, client: HTTPClientSpy) {
        
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(url: url, client: client)
        return (sut, client)
    }
    
    private func makeItem(id: UUID,
                          description: String?,
                          location: String?,
                          imageURL: URL) -> (model: FeedItem, json: [String: Any]) {
        
        let item = FeedItem(id: id, description: description, location: location, imageURL: imageURL)
        
        let itemJSON = [
            "id": item.id.uuidString,
            "description": item.description,
            "location": item.location,
            "image": item.imageURL.absoluteString
        ].compactMapValues({ $0 as Any })
        
        return (item, itemJSON)
    }
    
    private func makeItemsJSON(_ items: [[String: Any]]) -> Data {
        let json = [
            "items": items
        ]
        
        return try! JSONSerialization.data(withJSONObject: json)
    }
    
    private func expect(sut: RemoteFeedLoader, toCompleteWithResult result: RemoteFeedLoader.Result, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
        
        var capturedResults = [RemoteFeedLoader.Result]()
        sut.load { capturedResults.append($0) }
        
        action()
        
        XCTAssertEqual(capturedResults, [result], file: file, line: line)
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
        
        func complete(withStatusCode code: Int, data: Data, at index: Int = 0) {
            let response = HTTPURLResponse(url: requestedURLs[index],
                                           statusCode: code,
                                           httpVersion: nil,
                                           headerFields: nil)!
            
            messages[index].completion(.success(data, response))
        }
        
    }
    
}
