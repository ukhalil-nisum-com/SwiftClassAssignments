//
//  ViewController.swift
//  Assignment3
//
//  Created by NISUM on 6/13/17.
//  Copyright © 2017 Nisum Macbook. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {

   
    @IBOutlet weak var navigationBar: UINavigationBar!

    @IBOutlet weak var textFiledOne: UITextField!
    @IBOutlet weak var textFieldTwo: UITextField!
    @IBOutlet weak var binText: UITextField!
    @IBOutlet weak var locationText: UITextField!
    
    @IBOutlet weak var binAddbutton: UIButton!
    @IBOutlet weak var locationAddButton: UIButton!
    @IBOutlet weak var saveBUtton: UIButton!
    
    @IBOutlet weak var pickerView: UIPickerView!
    
    var pickerData = [String]()
    var pickerRowSelectHandler: ((Int) -> Void)?
    
    weak var protocolName : NameProtocol?
    
    var locationArray:[String] =  ["Closet","Basement","Storage"]
    var binArray:[String] = ["Top Shelf","Bottom Drawer","Last Cabinet"]


    enum EntityType{
        case bin
        case location
    }
    
    enum ActionType {
        case Create
        case Update
        case Delete
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        navigationBar.topItem?.title = "Assignment 3"
        
        //setting delegate
        binText.delegate = self
        locationText.delegate = self
        pickerView.delegate = self
        
        pickerView.dataSource = self
        
        pickerView.isHidden = true
        
        //adding targets to button action
        saveBUtton.addTarget(self, action: #selector(saveHandler), for: .touchUpInside)
        binAddbutton.addTarget(self, action: #selector(addBinHandler), for: .touchUpInside)
        locationAddButton.addTarget(self, action: #selector(addLocationHandler), for: .touchUpInside)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        pickerView.isHidden = true
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //Text filed delegate Method
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        var isEditing = false
        switch textField {
            case binText:
                isEditing = true
                pickerData.removeAll()
                pickerData += ["Bin 1", "Bin 2"]
                pickerView.reloadAllComponents()
                pickerView.isHidden = false
                if self.binText.text != nil && !self.binText.text!.isEmpty  {
                    self.pickerView.selectRow(pickerData.index(of: self.binText.text!)!, inComponent:0, animated: false)
                }
                else {
                    self.pickerView.selectRow(0, inComponent:0, animated: false)
            }
            case locationText:
                isEditing = true
                pickerData.removeAll()
                pickerData += ["Location 1", "Location 2"]
                pickerView.reloadAllComponents()
                pickerView.isHidden = false
                if self.locationText.text != nil && !self.locationText.text!.isEmpty  {
                    self.pickerView.selectRow(pickerData.index(of: self.locationText.text!)!, inComponent:0, animated: false)
                }
                else {
                    self.pickerView.selectRow(0, inComponent:0, animated: false)
            }
            default:
                break
        }
        
        pickerRowSelectHandler = { (selectedIndex: Int) -> Void in
            var entityType: EntityType?
            switch textField {
            case self.binText:
                entityType = EntityType.bin
                self.binText.text = self.pickerData[selectedIndex]
            case self.locationText:
                entityType = EntityType.location
                self.locationText.text = self.pickerData[selectedIndex]
            default:
                break
            }
        
        }
        
        return isEditing
    }
    //Save button action
    func saveHandler(sender:UIButton){
        pickerView.isHidden = true
    }
    
    //navigate to addViewController
    func addBinHandler(sender:UIButton){
       // self.performSegue(withIdentifier: "addVC", sender: self)
        self.showAddEntityAlertView(entityType: .bin, actionType: .Create)

    }
    
    //navigate to addViewController
    func addLocationHandler(sender:UIButton){
       // self.performSegue(withIdentifier: "addVC", sender: self)
        self.showAddEntityAlertView(entityType: .location, actionType: .Create)


    }
    
    //add alertview
    func showAddEntityAlertView(entityType:EntityType, actionType:ActionType)    {
        let alert = UIAlertController(title: "\(actionType) \(entityType)", message: "Enter \(entityType) name", preferredStyle: .alert)
        alert.addTextField { (textField) in textField.placeholder = "\(entityType) name"}
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {
            [weak alert, weak self] (_) in
            let textField = alert!.textFields![0] // Force unwrapping because we know it exists.
            print("Text field: \(textField.text)")
            if entityType == EntityType.bin {
                self?.binArray.append(textField.text!)
                self?.binText.text = textField.text
            } else if entityType == EntityType.location {
                self?.locationArray.append(textField.text!)
                self?.locationText.text = textField.text
            }
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    //Pickerview functionality
    // DataSource
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    // Delegate
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        print("Selected value: \(pickerData[row])")
        pickerRowSelectHandler!(row)
    }

    //Unwind segue
    @IBAction func unwindSegueFromAddVC(segue: UIStoryboardSegue) {
    
        let addVC = segue.source as! AddViewController
        let item = addVC.name
        print("New added value is \(item)")
        
    }
}

