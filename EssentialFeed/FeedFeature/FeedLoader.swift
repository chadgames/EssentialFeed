//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by Chad Games on 25/08/2022.
//

import Foundation

enum LoadFeedResult {
    case success([FeedItem])
    case error(Error)
}

protocol FeedLoader {
    func load(completion: @escaping (LoadFeedResult) -> Void)
}
