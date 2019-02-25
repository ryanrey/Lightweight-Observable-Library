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
    
    func testObservationSchedulerIsRespected() {
        let mainThreadExpectation = XCTestExpectation(description: "mainThreadExpectation")
        let serialQueueExpectation = XCTestExpectation(description: "serialQueueExpectation")
        
        observable
            .debug()
            .observeOn(.main)
            .subscribeOn(.serial).subscribe(
                onNext: { _ in
                    XCTAssert(Thread.isMainThread)
            },
                onError: { _ in

            },
                onCompleted: {
                    XCTAssert(Thread.isMainThread)
                    mainThreadExpectation.fulfill()
            })
        
        observable
            .debug()
            .observeOn(.serial)
            .subscribeOnCompleted(queue: .concurrent) {
                XCTAssert(!Thread.isMainThread)
                serialQueueExpectation.fulfill()
            }


        wait(for: [mainThreadExpectation, serialQueueExpectation ], timeout: 5)
    }
    
    func test() {
        let expectation1 = XCTestExpectation(description: "expectation1")
        let expectation2 = XCTestExpectation(description: "expectation2")
        let expectation3 = XCTestExpectation(description: "expectation3")
        
        observable
            .debug()
            .observeOn(.main)
            .subscribeOn(.serial).subscribe(
                onNext: { _ in
                    XCTAssert(Thread.isMainThread)
            },
                onError: { _ in
                    
            },
                onCompleted: {
                    XCTAssert(Thread.isMainThread)
                    expectation1.fulfill()
            })
        
        observable
            .debug()
            .observeOn(.main)
            .subscribeOn(.serial).subscribe(
                onNext: { _ in
                    XCTAssert(Thread.isMainThread)
            },
                onError: { _ in
                    
            },
                onCompleted: {
                    XCTAssert(Thread.isMainThread)
                    expectation2.fulfill()
            })
        
        observable
            .debug()
            .observeOn(.main)
            .subscribeOn(.serial).subscribe(
                onNext: { _ in
                    XCTAssert(Thread.isMainThread)
            },
                onError: { _ in
                    
            },
                onCompleted: {
                    XCTAssert(Thread.isMainThread)
                    expectation3.fulfill()
            })
        
        wait(for: [expectation1, expectation2, expectation3], timeout: 5)
    }
    
    func testColdObservable() {
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

        XCTAssert(subscriptionBlockCompletions == 3)
    }
    
    func testHotObservable() {
        // TODO
    }

    func testStartingValue() {
        let variable = Variable(1)
        let expectation = XCTestExpectation(description: "hi")
        
        variable.subscribeOnNext { nextInt in
            print("first: \(nextInt)")
        }

        variable.asObserver().onNext(2)
        
        variable.subscribeOnNext { nextInt in
            print("second: \(nextInt)")
        }

        variable.asObserver().onNext(3)
        
        variable.subscribeOnNext { nextInt in
            print("third: \(nextInt)")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }

    func testLatestValuesOnly() {
        let variable = Variable(1)
        variable.subscribeOnNext { nextInt in
            print("first: \(nextInt)")
        }

        variable.asObserver().onNext(2)
        variable.subscribeOnNext { nextInt in
            print("second: \(nextInt)")
        }

        variable.asObserver().onNext(3)
        observable.subscribeOnNext { nextInt in
            print("third: \(nextInt)")
        }

        variable.asObserver().onNext(4)
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
    }
}
