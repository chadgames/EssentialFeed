//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Chad Games on 25/08/2022.
//

import XCTest

class RemoteFeedLoader {
    
    let client: HTTPClient
    let url: URL
    
    init(url: URL, client: HTTPClient) {
        self.client = client
        self.url = url
    }
    
    func load() {
        client.get(from: url)
    }
    
}

protocol HTTPClient {
    func get(from url: URL)
}



class RemoteFeedLoaderTests: XCTestCase {

    func test_init_doesNotRequestDataFromURL() {
        let (_, client) = makeSUT()
        
        XCTAssertNil(client.requestedURL)
    }
    
    func test_load_requestDataFromURL() {
        let url = URL(string: "https://theurl.com")!
        let (sut, client) = makeSUT(url: url)
        
        sut.load()
        
        XCTAssertNotNil(client.requestedURL)
    }

    // MARK: - Helpers
    
    private func makeSUT(url: URL = URL(string: "https://theurl.com")!) -> (sut: RemoteFeedLoader, client: HTTPClientSpy) {
        
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(url: url, client: client)
        return (sut, client)
    }
    
    class HTTPClientSpy: HTTPClient {
        
        var requestedURL: URL?
        
        func get(from url: URL) {
            requestedURL = url
        }
        
    }
    
}
