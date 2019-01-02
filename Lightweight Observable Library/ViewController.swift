//
//  ViewController.swift
//  Lightweight Observable Library
//
//  Created by Ark on 12/14/18.
//  Copyright © 2018 Ark. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var name = Observable("Initial value")
    var disposables: [Disposable] = []
    @IBOutlet weak var label: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        name.subscribeOnNext { value in
            print("value: \(value)")
        }
        
        name.subscribe(
            onNext: { value in
                print("value: \(value)")
        },
            onError: { error in
                print("error: \(error)")
        },
            onCompleted: {
                print("onCompleted")
        })
    }
    
    deinit {
        disposables.removeAll()
    }
    
    private func setupSubscriptions() {
        let disposable = name.subscribe(
            onNext: { value in
                print("value: \(value)")
        },
            onError: { error in
                print("error: \(error)")
        },
            onCompleted: {
                print("onCompleted")
        })
        
        disposables.append(disposable)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        name.value = "hello"
    }
}

