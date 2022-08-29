//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by Chad Games on 25/08/2022.
//

import Foundation

public enum LoadFeedResult {
    case success([FeedItem])
    case failure(Error)
}

public protocol FeedLoader {
    func load(completion: @escaping (LoadFeedResult) -> Void)
}
