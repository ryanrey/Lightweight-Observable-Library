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

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testSubscriptionBlockRunsOnce() {
        var subscriptionBlockCompletions = 0
        
        let observable = Observable<Int>.create { (observer: AnyObserver<Int>) in
            subscriptionBlockCompletions += 1
            observer.onNext(1)
            sleep(1)
            observer.onNext(2)
            sleep(1)
        }
        
        observable.subscribeOnNext { nextInt in
            print("first: \(nextInt)")
        }
        
        observable.subscribeOnNext { nextInt in
            print("second: \(nextInt)")
        }
        
        observable.subscribeOnNext { nextInt in
            print("third: \(nextInt)")
        }
        
        observable.value = 3
        
        XCTAssert(subscriptionBlockCompletions == 1)
    }
    
    func testStartingValue() {
        let observable = Observable(1)
        
        observable.subscribeOnNext { nextInt in
            print("first: \(nextInt)")
        }
        
        observable.subscribeOnNext { nextInt in
            print("second: \(nextInt)")
        }
        
        observable.subscribeOnNext { nextInt in
            print("third: \(nextInt)")
        }
        
        observable.value = 4
    }
    
    func testLatestValuesOnly() {
        let observable = Observable(1)
        observable.subscribeOnNext { nextInt in
            print("first: \(nextInt)")
        }
        
        observable.value = 2
        observable.subscribeOnNext { nextInt in
            print("second: \(nextInt)")
        }
        
        observable.value = 3
        observable.subscribeOnNext { nextInt in
            print("third: \(nextInt)")
        }
        
        observable.value = 4
    }
    
    func testSingleDispose() {
        let observable = Observable<Int>.create { (observer: AnyObserver<Int>) in
            observer.onNext(1)
            observer.onNext(2)
        }
        
        observable.subscribeOnNext { nextInt in
            print("first: \(nextInt)")
        }.dispose()
        
        observable.subscribeOnNext { nextInt in
            print("second: \(nextInt)")
        }
        
        observable.value = 3
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
