//
//  CardDetailViewController.swift
//  Hearthdeck
//
//  Created by Andrea Franchini on 04/05/15.
//  Copyright (c) 2015 Qubex_. All rights reserved.
//

import UIKit
import CoreData

class CardDetailViewController: UIViewController {

    // MOC
    let moc = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    let appDel = UIApplication.sharedApplication().delegate as! AppDelegate
    
    @IBOutlet var titleBarLabel: UINavigationItem!
    @IBOutlet var costLabel: UILabel!
    @IBOutlet var healthLabel: UILabel!
    @IBOutlet var attackLabel: UILabel!
    @IBOutlet var idLabel: UILabel!
    @IBOutlet var playerClassLabel: UILabel!
    @IBOutlet var rarityLabel: UILabel!
    @IBOutlet var typeLabel: UILabel!
    @IBOutlet var textLabel: UILabel!
    @IBOutlet var cardImageView: UIImageView!
    @IBOutlet var backgroundImage: UIImageView!
    @IBOutlet var descriptionContainer: UIVisualEffectView!
    @IBOutlet var loadingImageIndicator: UIActivityIndicatorView!

    @IBOutlet var attackDescLabel: UILabel!
    @IBOutlet var healthDescLabel: UILabel!
    
    // to check if player owns that card
    @IBOutlet var ownedCheckbox: UIButton!
    var ownedCheckboxSelected: Bool = false
    // test feature
    @IBOutlet var ownedCardLabel: UILabel!
    
    var card: Card!
    
    var titleBar: String?
    var cost: String?
    var health: String?
    var attack: String?
    var id: String! // From here it fetch
    var playerClass: String?
    var rarity: String?
    var type: String?
    var text: String?
    var imageData: NSData?
    var durability: String?
    var flavor: String?
    var owned: Bool?
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.LightContent
        
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.translucent = true
        self.navigationController?.navigationBar.backgroundColor = UIColor.clearColor()
        self.navigationController!.navigationBar.barTintColor = UIColor.clearColor()
        self.navigationController!.navigationBar.tintColor = UIColor.whiteColor()
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        titleBarLabel.titleView?.tintColor = UIColor.whiteColor()
        
        if card.hasImage {
            cardImageView.image = UIImage(data: imageData!)
            backgroundImage.image = UIImage(data: imageData!)
        }
        
        downloadImage()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.Default
        
        //setup UI
        self.navigationController?.navigationBar.setBackgroundImage(nil, forBarMetrics: UIBarMetrics.Default)
        self.navigationController?.navigationBar.shadowImage = nil
        self.navigationController?.navigationBar.translucent = true
        self.navigationController?.navigationBar.backgroundColor = UIColor.whiteColor()
        self.navigationController!.navigationBar.barTintColor = UIColor.whiteColor()
        self.navigationController!.navigationBar.tintColor = UIColor(red:0, green:0.422, blue:0.969, alpha:1)
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.blackColor()] //aqua color
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchCard()
        
        titleBarLabel.title = titleBar
        costLabel.text = cost
        healthLabel.text = health
        attackLabel.text = attack
        idLabel.text = id
        playerClassLabel.text = playerClass
        rarityLabel.text = rarity
        typeLabel.text = type
        
        if type == "Spell" {
            attackLabel.hidden = true
            attackDescLabel.hidden = true
            healthLabel.hidden = true
            healthDescLabel.hidden = true
        } else if type == "Weapon" {
            healthLabel.text = durability
            healthLabel.textColor = UIColor(red:0.504, green:0.504, blue:0.504, alpha:1)
            healthDescLabel.text = "Durability:"
            healthDescLabel.textColor = UIColor(red:0.504, green:0.504, blue:0.504, alpha:1)
        }
        
        descriptionContainer.layer.cornerRadius = 10
        descriptionContainer.clipsToBounds = true
        
        backgroundImage.backgroundColor = UIColor(red:0.304, green:0.28, blue:0.346, alpha:1)
        
        textLabel.attributedText = convertText(text!, sizeInPt: 15)
        
        let checkboxImage = UIImage(named: "Checkbox.png")?.imageWithRenderingMode(.AlwaysTemplate)
        let checkboxImageChecked = UIImage(named: "Checkbox-Checked.png")?.imageWithRenderingMode(.AlwaysTemplate)

        ownedCheckbox.setImage(checkboxImage, forState: .Normal)
        ownedCheckbox.setImage(checkboxImageChecked, forState: .Selected)
        ownedCheckbox.setImage(checkboxImageChecked, forState: .Highlighted)
        ownedCheckbox.imageView?.tintColor = UIColor.whiteColor()
        ownedCheckbox.adjustsImageWhenHighlighted = true
        ownedCheckbox.selected = owned!
    }

    @IBAction func ownedCheckboxChanged(sender: AnyObject) {
        // If checkbox is touched, change state
        ownedCheckboxSelected = !ownedCheckboxSelected
        ownedCheckbox.selected = ownedCheckboxSelected
        
        // own card feature
        if ownedCheckboxSelected {
            ownedCardLabel.text = "You own this card"
        } else {
            ownedCardLabel.text = ""
        }
        
        do {
            card.owned = ownedCheckboxSelected
            try moc.save()
        } catch {
            print(error)
        }
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func fetchCard() {
        
        let fetchRequest: NSFetchRequest = NSFetchRequest(entityName: "Card")
        let sorter: NSSortDescriptor = NSSortDescriptor(key: "id" , ascending: true)
        fetchRequest.predicate = NSPredicate(format: "id = %@", id)
        fetchRequest.sortDescriptors = [sorter]
        fetchRequest.returnsObjectsAsFaults = true
        
        do {
            let results = try moc.executeFetchRequest(fetchRequest)
            let cards = results as! [Card]
            card = cards[0]
            titleBar = card.name
            cost = card.cost.stringValue
            health = card.health.stringValue
            attack = card.attack.stringValue
            playerClass = card.playerClass
            rarity = card.rarity
            type = card.type
            text = card.text
            imageData = card.image
            durability = card.durability.stringValue
            flavor = card.flavor
            owned = card.owned
            
        } catch {
            print("Fetch failed: \(error)")
        }
    }
    
    func downloadImage() {
        loadingImageIndicator.hidden = true
        if !card.hasImage {
            loadingImageIndicator.hidden = false
            loadingImageIndicator.startAnimating()
            let quality = "medium"
            let baseUrl = "http://wow.zamimg.com/images/hearthstone/cards/enus/" + quality + "/" + card.id + ".png"
            do {
                card.image = try NSData(contentsOfURL: NSURL(string: baseUrl)!, options: NSDataReadingOptions.DataReadingMappedIfSafe)
                var tempImg = UIImage(data: card.image)
                var h: CGFloat!
                if card.type == "Spell" {
                    h = 70
                } else {
                    h = 50
                }
                tempImg = Toucan.Util.croppedImageWithRect(tempImg!, rect: CGRectMake(tempImg!.size.width/2-35, h, 70, 70))
                tempImg = Toucan(image: tempImg!).maskWithEllipse().image
                
                card.thumbnail =  UIImagePNGRepresentation(tempImg!)!
                card.hasImage = true
                do {
                    try moc.save()
                } catch {
                    print("Cannot save: \(error)")
                }
            } catch {
                print("Cannot convert image!")
            }
            loadingImageIndicator.stopAnimating()
            loadingImageIndicator.hidden = true

            cardImageView.image = UIImage(data: card.image)
            backgroundImage.image = UIImage(data: card.image)
        }
    }
}
