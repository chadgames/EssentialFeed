//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by Chad Games on 27/08/2022.
//

import Foundation

public enum HTTPResponseType {
    case success(Data, HTTPURLResponse)
    case failure(Error)
}

public protocol HTTPClient {
    func get(from url: URL, completion: @escaping (HTTPResponseType) -> Void)
}

public final class RemoteFeedLoader {
    
    private let url: URL
    private let client: HTTPClient
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
//    public enum Result: Equatable {
//        case success([FeedItem])
//        case failure(Error)
//    }
    
    public typealias Result = Swift.Result<[FeedItem], Error>
    
    public init(url: URL, client: HTTPClient) {
        self.client = client
        self.url = url
    }
    
    public func load(completion: @escaping (Result) -> Void) {
        client.get(from: url) { result in
            
            switch result {
            case .success(let data, let response):
                if let items = try? FeedItemsMapper.map(data, response) {
                    completion(.success(items))
                    
                } else {
                    completion(.failure(.invalidData))
                }
                
            case .failure:
                completion(.failure(.connectivity))
            }
        }
    }
    
}

private class FeedItemsMapper {
    
    struct Root: Decodable {
        let items: [Item]
    }

    struct Item: Decodable {
        
        let id: UUID
        let description: String?
        let location: String?
        let image: URL

        var feedItem: FeedItem {
            return FeedItem(id: id,
                            description: description,
                            location: location,
                            imageURL: image)
        }
        
    }
    
    static func map(_ data: Data, _ response: HTTPURLResponse) throws -> [FeedItem] {
        
        guard response.statusCode == 200 else {
            throw RemoteFeedLoader.Error.invalidData
        }
        
        let root = try JSONDecoder().decode(Root.self, from: data)
        
        return root.items.map { $0.feedItem }
    }
    
}

