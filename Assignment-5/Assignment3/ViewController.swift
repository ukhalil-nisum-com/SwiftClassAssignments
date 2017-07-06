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

    let coreDataFetch = CoreDataFetch()
    var fetchUtility = FetchUtility()

    
    
    enum ActionType {
        case Create
        case Update
        case Delete
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        navigationBar.topItem?.title = "Assignment 6"
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Search", style: .plain, target: self, action: #selector(searchHandler(sender:)))
        
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

    func searchHandler(sender: UIBarButtonItem) {
        self.performSegue(withIdentifier: "searchSegue", sender: nil)

    }
    
    //Text filed delegate Method
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        var isEditing = false
        switch textField {
        case self.locationText:
            self.pickerData = (fetchUtility.fetchSortedLocation()?.map(
                {
                    (value: Location) -> String in
                    return value.name!
            }))!
            pickerView.reloadAllComponents()
            self.pickerView.isHidden = false
            if self.locationText.text != nil && !self.locationText.text!.isEmpty  {
                self.pickerView.selectRow(pickerData.index(of: self.locationText.text!)!, inComponent:0, animated: false)
            }
            else {
                self.pickerView.selectRow(0, inComponent:0, animated: false)
            }
            isEditing = false
        case self.binText:
            //                self.pickerData = binArray
            pickerView.reloadAllComponents()
            self.pickerView.isHidden = false
            if self.binText.text != nil && !self.binText.text!.isEmpty  {
                self.pickerView.selectRow(pickerData.index(of: self.binText.text!)!, inComponent:0, animated: false)
            }
            else {
                self.pickerView.selectRow(0, inComponent:0, animated: false)
            }
            isEditing = false
        default: self.pickerView.isHidden = true
        }
        
        self.pickerRowSelectHandler = {(selectedIndex:Int) -> Void in
            var entityType: EntityType?
            switch textField {
            case self.locationText:
                entityType = EntityType.Location
                self.locationText.text = self.pickerData[selectedIndex]
            case self.binText:
                entityType = EntityType.Bin
                self.binText.text = self.pickerData[selectedIndex]
            default: break
            }
            print("\(String(describing: entityType)) selected: \(selectedIndex)")
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
        self.showAddEntityAlertView(entityType: .Bin, actionType: .Create)

    }
    
    //navigate to addViewController
    func addLocationHandler(sender:UIButton){
       // self.performSegue(withIdentifier: "addVC", sender: self)
        self.showAddEntityAlertView(entityType: .Location, actionType: .Create)


    }
    
    func updateTitle(actionType:ActionType) {
        navigationBar.topItem?.title = "\(String(describing:actionType)) Item"
    }
    
    func updateFields(fromItem:Item)    {
       // self.textFiledOne.text = fromItem.name
        self.textFieldTwo.text = String(fromItem.qty)
        self.locationText.text = fromItem.itemToBinFK?.binToLocationFK?.name
        self.binText.text = fromItem.itemToBinFK?.name
        self.updateTitle(actionType: ActionType.Update)
    }
    
    func updateFields(fromBin:Bin)    {
        //        self.locationText.text = fromBin.location?.name
        //        self.binText.text = fromBin.name
    }
    
    func updateFields(fromLocation:Location)    {
        self.locationText.text = fromLocation.name
    }

    //add alertview
    func showAddEntityAlertView(entityType:EntityType, actionType:ActionType)    {
        let alert = UIAlertController(title: "\(actionType) \(entityType)", message: "Enter \(entityType) name", preferredStyle: .alert)
        alert.addTextField { (textField) in textField.placeholder = "\(entityType) name"}
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {
            [weak alert, weak self] (_) in
            let textField = alert!.textFields![0] // Force unwrapping because we know it exists.
            print("Text field: \(String(describing: textField.text))")
            let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
            context.reset()
            var isError = false
            var errorMsg = ""
            if entityType == EntityType.Bin {
                
                let bin = Bin(context: context)
                bin.name = textField.text!
                bin.entityType = EntityType.Bin
                let  text:String = self!.locationText.text!
                let location = self!.fetchUtility.fetchLocation(byName:text)
                bin.binToLocationFK = location
                
                do {
                    try bin.validateForInsert()
                } catch {
                    isError = true
                    errorMsg = error.localizedDescription
                }
            } else if entityType == EntityType.Location {
                let location = Location(context: context)
                location.name = textField.text!
                location.entityType = EntityType.Location
            }
            
            if !isError {
                (UIApplication.shared.delegate as! AppDelegate).saveContext()
            } else {
                UIAlertController(title: "\(actionType) \(entityType)", message: errorMsg, preferredStyle: .alert)
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

