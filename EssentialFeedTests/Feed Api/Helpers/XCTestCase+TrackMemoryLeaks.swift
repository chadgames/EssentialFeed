//
//  XCTestCase+TrackMemoryLeaks.swift
//  EssentialFeedTests
//
//  Created by Chad Games on 02/09/2022.
//

import XCTest

extension XCTestCase {
    
    func trackForMemoryLeaks(_ instance: AnyObject, file: StaticString = #filePath, line: UInt = #line) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance,
                         "Test for memory leak",
                         file: file,
                         line: line)
        }
    }
    
}
