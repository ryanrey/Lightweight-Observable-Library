//
//  TestVC.swift
//
//  Copyright © 2019 Ark. All rights reserved.
//

import UIKit

class TestVC: UIViewController {
    
    var name = Observable("Initial TestVC value")
    
    @IBAction func goToNext(_ sender: Any) {
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupSubscriptions()
    }
    
    deinit {
        print("💩 TestVC deinit")
        //  disposeBag.dispose()
    }
    
    private func setupSubscriptions() {
        name.subscribeOnNext { value in
            print("TestVC next: \(value)")
        }.addToDisposeBag(disposeBag)
        
        name.subscribe(
            onNext: { value in
                print("TestVC next:: \(value)")
        },
            onError: { error in
                print("TestVC error: \(error)")
        },
            onCompleted: {
                print("TestVC onCompleted")
        }).addToDisposeBag(disposeBag)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        name.value = "TestVC appeared"
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        name.value = "TestVC disappeared"
    }
}

