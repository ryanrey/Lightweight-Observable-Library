//
//  ViewController.swift
//  Lightweight Observable Library
//
//  Created by Ark on 12/14/18.
//  Copyright © 2018 Ark. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var name = Observable("ViewController Initial value")
    @IBOutlet weak var label: UILabel!
    
    @IBAction func goToNext(_ sender: Any) {
        let testVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TestVC") as! TestVC
        
       navigationController?.pushViewController(testVC, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupSubscriptions()
    }
    
    deinit {
         print("💩 ViewController deinit")
      //  disposeBag.dispose()
    }
    
    private func setupSubscriptions() {
        name.subscribeOnNext { value in
            print("ViewController next: \(value)")
        }.addToDisposeBag(disposeBag)
        
        name.subscribe(
            onNext: { value in
                print("ViewController next:: \(value)")
        },
            onError: { error in
                print("ViewController error: \(error)")
        },
            onCompleted: {
                print("ViewController onCompleted")
        }).addToDisposeBag(disposeBag)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        name.value = "ViewController appeared"
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        name.value = "ViewController disappeared"
    }
}

