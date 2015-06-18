//
//  DeckDetailViewController.swift
//  Hearthdeck
//
//  Created by Andrea Franchini on 29/05/15.
//  Copyright (c) 2015 Qubex_. All rights reserved.
//

import UIKit
import CoreData
import Spring

class DeckDetailViewController: UIViewController {

    // Core Data
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    let appDel = (UIApplication.sharedApplication().delegate as! AppDelegate)
    
    @IBOutlet var deckTitle: UINavigationItem!
    
    @IBOutlet var characterImage: UIImageView!
    @IBOutlet var characterName: UILabel!
    @IBOutlet var characterType: UILabel!
    
    @IBOutlet var promptClassPicker: UIVisualEffectView!
    @IBOutlet var classScrollView: UIScrollView!
    var classPickerState = false
    
    var prova: String?
    let charactersNames = ["Jaina", "Anduin", "Thrall", "Valeera", "Garrosh", "Gul'dan", "Uther", "Rexxar", "Malfurion"]
    let playerClasses = ["Mage", "Priest", "Shaman", "Rogue", "Warrior", "Warlock", "Paladin", "Hunter", "Druid"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        characterName.userInteractionEnabled = true
        characterType.userInteractionEnabled = true
        //characterImage.userInteractionEnabled = true
        
//        // Tap to change -- naaah
//        //let tapGestureTitle = UITapGestureRecognizer(target: self, action: "changeDeckTitle:")
//        let tapGestureType = UITapGestureRecognizer(target: self, action: "classPickerAction:")
//        characterName.addGestureRecognizer(tapGestureType)
//        //characterType.addGestureRecognizer(tapGestureType)
//        //characterImage.addGestureRecognizer(tapGestureType)
        
        // Hide promptClassPicker
        self.promptClassPicker.hidden = true
        
        let moc = self.managedObjectContext
        let fetchRequest = NSFetchRequest(entityName: "Deck")
        fetchRequest.predicate = NSPredicate(format: "name = %@", deckTitle.title!)
        
        if let fetchResults = self.appDel.managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [Deck] {
            if fetchResults.count != 0 {
                
                var managedObject = fetchResults[0]
                let type = managedObject.type
                let name = charactersNames[find(playerClasses, managedObject.type)!]
                self.characterType.text = type
                self.characterName.text = name
                self.characterImage.image = UIImage(named: name+".png")

            } else {
                self.characterType.text = "Name"
                self.characterName.text = "Type"
            }
        }
        
        for index in 0...playerClasses.count-1 {
            let button = UIButton.buttonWithType(UIButtonType.Custom) as! UIButton
            let image = UIImage(named: (playerClasses[index]+".png")) as UIImage?
            button.setImage(image, forState: .Normal)
            button.setTitle(playerClasses[index], forState: .Normal)
            var btnCGx: CGFloat?
            if index == 0 {
                btnCGx = 15
            } else {
                btnCGx = CGFloat(15 * index+100 * index)
            }
            let btnCGy = CGFloat((classScrollView.bounds.height)/2-50)
            button.frame = CGRectMake(btnCGx!, btnCGy, 100, 100)
            button.addTarget(self, action: "didSelectClass:", forControlEvents: .TouchUpInside)
            self.classScrollView.contentSize.width += CGFloat(115)
            self.classScrollView.addSubview(button)
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.setToolbarHidden(true, animated: animated)
    }
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.navigationController?.setToolbarHidden(true, animated: animated)
        
    }
    
    @IBAction func goToDeckCards(sender: AnyObject) {
        performSegueWithIdentifier("goToDeckCards", sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "goToDeckCards" {
            let nc = segue.destinationViewController as! UINavigationController
            let tvc = nc.topViewController as! DeckDetailTableViewController
            
            tvc.deckTitle = deckTitle.title!
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func changeDeck(sender: AnyObject) {
        let alertController = UIAlertController(title: nil, message: "Want to change the title or the type of the deck?", preferredStyle: .ActionSheet)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (action) in
            // ...
        }
        alertController.addAction(cancelAction)
        
        let ChangeTitleAction = UIAlertAction(title: "Change Title", style: .Default) { (action) in
            self.changeDeckTitle()
        }
        let ChangeClassAction = UIAlertAction(title: "Change Class", style: .Default) { (action) in
            self.classPickerAction()
        }
        alertController.addAction(ChangeTitleAction)
        alertController.addAction(ChangeClassAction)
        
        self.presentViewController(alertController, animated: true) {
            // ...
        }
    }
    
    
    
    
    // MARK: - Utility functions
    
    func changeDeckTitle() {
        // fetch request
        let moc = self.managedObjectContext
        let fetchRequest = NSFetchRequest(entityName: "Deck")
        fetchRequest.predicate = NSPredicate(format: "name = %@", deckTitle.title!)
        
        
        let alertController = UIAlertController(title: deckTitle.title, message: "Change name?", preferredStyle: .Alert)
        
        let deckEditAction = UIAlertAction(title: "Rename", style: .Default) { (_) in
            let deckNameTextField = alertController.textFields![0] as! UITextField
            
            if let fetchResults = self.appDel.managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [NSManagedObject] {
                if fetchResults.count != 0{
                    
                    var managedObject = fetchResults[0]
                    managedObject.setValue(deckNameTextField.text, forKey: "name")
                    self.deckTitle.title = deckNameTextField.text
                    
                    moc!.save(nil)
                }
            }
        }
        deckEditAction.enabled = false
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (_) in }
        
        alertController.addTextFieldWithConfigurationHandler { (textField) in
            textField.placeholder = "Name"
            
            // Listen for change
            NSNotificationCenter.defaultCenter().addObserverForName(UITextFieldTextDidChangeNotification, object: textField, queue: NSOperationQueue.mainQueue()) { (notification) in
                deckEditAction.enabled = textField.text != ""
            }
        }
        
        alertController.addAction(deckEditAction)
        alertController.addAction(cancelAction)
        
        self.presentViewController(alertController, animated: true) {
            println("changing name...")
        }
    }
    func classPickerAction() {
        if classPickerState {
            dismissClassPicker()
        } else {
            showClassPicker()
        }
        
    }
    
    func showClassPicker() {
        UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: UIViewAnimationOptions.CurveLinear, animations: {
            self.promptClassPicker.hidden = false
            self.promptClassPicker.center.y -= self.promptClassPicker.bounds.height
            }, completion: {
                (_) in
        })
        
        println("showing classes...")
        
        classPickerState = true
    }
    func dismissClassPicker() {
        UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: UIViewAnimationOptions.CurveLinear, animations: {
            self.promptClassPicker.center.y += self.promptClassPicker.bounds.height
            }, completion: {
                (_) in
                self.promptClassPicker.hidden = true
        })
        classPickerState = false
    }
    func didSelectClass(sender: UIButton) {
        if let type = sender.titleLabel?.text {
            
            let name = charactersNames[find(playerClasses, type)!]
            
            let moc = self.managedObjectContext
            let fetchRequest = NSFetchRequest(entityName: "Deck")
            fetchRequest.predicate = NSPredicate(format: "name = %@", deckTitle.title!)
            
            if let fetchResults = self.appDel.managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [NSManagedObject] {
                if fetchResults.count != 0{
                    
                    var managedObject = fetchResults[0]
                    managedObject.setValue(type, forKey: "type") //"type" has first letter uppercase
                    self.characterType.text = type
                    self.characterName.text = name
                    self.characterImage.image = UIImage(named: name+".png")
                    moc!.save(nil)
                    
                    dismissClassPicker()
                }
            }
        }
        
}
    
    @IBAction func closeClassPickerButton(sender: AnyObject) {
        dismissClassPicker()
    }
}
