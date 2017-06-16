//
//  AddViewController.swift
//  Assignment3
//
//  Created by NISUM on 6/13/17.
//  Copyright © 2017 Nisum Macbook. All rights reserved.
//

import UIKit

class AddViewController: UIViewController , NameProtocol {
    var name: String = ""

    @IBOutlet weak var textField: UITextField!
    
    @IBOutlet weak var saveButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        saveButton.addTarget(self, action: #selector(saveHandler), for: .touchUpInside)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //Save button action
    func saveHandler(sender:UIButton){
        name = textField.text!
        performSegue(withIdentifier: "unwindToMainView", sender: self)
        
    }

}
