//
//  Lightweight_Observable_LibraryTests.swift
//  Lightweight Observable LibraryTests
//
//  Created by Ark on 12/14/18.
//  Copyright © 2018 Ark. All rights reserved.
//

import XCTest
@testable import Lightweight_Observable_Library

class Lightweight_Observable_LibraryTests: XCTestCase {
    let observable = Observable<Int>.of(1, 2, 3)
    
    
    func testObservationQueue() {
        let mainThreadExpectation = XCTestExpectation(description: "mainThreadExpectation")
        let serialQueueExpectation = XCTestExpectation(description: "serialQueueExpectation")
        
        observable
            .debug()
            .observeOn(.main)
            .subscribeOnCompleted(queue: .serial) {
                XCTAssert(Thread.isMainThread)
                mainThreadExpectation.fulfill()
        }
        
        observable
            .debug()
            .observeOn(.serial)
            .subscribeOnCompleted(queue: .concurrent) {
                XCTAssert(!Thread.isMainThread)
                serialQueueExpectation.fulfill()
            }


        wait(for: [mainThreadExpectation, serialQueueExpectation ], timeout: 1)
    }
    
    func testSubsriptionQueue() {
        // TODO
    }
    
    func testColdObservable() {
        var subscriptionBlockCompletions = 0

        let observable = Observable<Int>.create { (observer: AnyObserver<Int>) in
            subscriptionBlockCompletions += 1
            observer.onNext(1)
            observer.onNext(2)
        }

        observable.subscribeOnNext { _ in
           
        }

        observable.subscribeOnNext { _ in
           
        }

        observable.subscribeOnNext { _ in
           
        }

        XCTAssert(subscriptionBlockCompletions == 3)
    }
    
    func testHotObservable() {
        // TODO
    }
}
