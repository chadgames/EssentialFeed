//
//  HTTPClient.swift
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
