//
//  DeckDetailTableViewController.swift
//  Hearthdeck
//
//  Created by Andrea Franchini on 29/05/15.
//  Copyright (c) 2015 Qubex_. All rights reserved.
//

import UIKit
import CoreData

class DeckDetailTableViewController: UITableViewController {

    // Core data
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    let appDel = (UIApplication.sharedApplication().delegate as! AppDelegate)
    
    // Card arrays for quantity
    var pickedCards = [String]()
    var pickedCardsQuantity = [Int]()
    
    // Utility for prepareforsegue:
    var deckTitle: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        loadCards()
        self.tableView.reloadData()
        self.navigationController?.setToolbarHidden(true, animated: true)
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setToolbarHidden(true, animated: true)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return pickedCards.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("DeckCardCell", forIndexPath: indexPath) as! DeckCardCell
        
        let fetchRequest: NSFetchRequest = NSFetchRequest(entityName: "Card")
        fetchRequest.predicate = NSPredicate(format: "id = %@", pickedCards[indexPath.row])
        
        if let results = self.managedObjectContext?.executeFetchRequest(fetchRequest, error: nil) {
            let card = results[0] as! Card
            
            // set labels
            cell.nameLabel.text = card.name
            cell.quantityLabel.text = String(pickedCardsQuantity[indexPath.row])
            cell.costLabel.text = card.cost.description // String() doesn't work
            if card.hasImage {
                cell.cardImage.image = UIImage(data: card.image)
            } else {
                // If current card has no image
                // Download image
                var downloadImageError: NSError?
                var imageError: NSError?
                let baseUrl = "http://wow.zamimg.com/images/hearthstone/cards/enus/medium/" + card.id + ".png"
                card.image = NSData(contentsOfURL: NSURL(string: baseUrl)!, options: NSDataReadingOptions.DataReadingMappedIfSafe, error: &imageError)!
                card.hasImage = true
                println("Downloaded image")
                self.managedObjectContext!.save(&downloadImageError)
                if downloadImageError != nil {
                    println(downloadImageError)
                }
                
                cell.cardImage.image = UIImage(data: card.image)
            }
        }
        
        
        return cell
    }

    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }

    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            
            pickedCards.removeAtIndex(indexPath.row)
            pickedCardsQuantity.removeAtIndex(indexPath.row)
            
            // UPDATE:
            let fetchRequest = NSFetchRequest(entityName: "Deck")
            fetchRequest.predicate = NSPredicate(format: "name = %@", deckTitle!)
            
            // Parse the 2 picked cards array into one string.
            // " " divides two cards, quantity is expressed by "@_" and a number
            var resultString: String = ""
            for var i = 0; i < pickedCards.count; i++ {
                let block = pickedCards[i] + "@_" + String(pickedCardsQuantity[i])
                resultString += block + " "
            }
            
            // Save data
            if let fetchResults = self.appDel.managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [Deck] {
                if fetchResults.count != 0 {
                    var managedObject = fetchResults[0]
                    
                    managedObject.setValue(resultString, forKey: "cards")
                    self.managedObjectContext!.save(nil)
                }
            }
            
            self.managedObjectContext!.save(nil)
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
            
        }
    }

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "pickSomeCardsSegue" {
            
            let nc = segue.destinationViewController as! UINavigationController
            let vc = nc.topViewController as! CardListTableViewController
            
            vc.isPickingCard = true
            vc.deckName = deckTitle
            
        }
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }

    @IBAction func pickSomeCards(sender: AnyObject) {
        
        performSegueWithIdentifier("pickSomeCardsSegue", sender: self)
        
    }
    
    func loadCards() {
        
        //reset
        pickedCards = []
        pickedCardsQuantity = []
        
        //fetch
        let fetchRequest = NSFetchRequest(entityName: "Deck")
        fetchRequest.predicate = NSPredicate(format: "name = %@", deckTitle!)
        
        if let fetchResults = self.appDel.managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [Deck] {
            if fetchResults.count != 0 {

                var managedObject = fetchResults[0]
                let cardsOfDeck: String = managedObject.cards
                
                // Parse string into array
                if cardsOfDeck != "" {
                    var cardsArrayRaw = cardsOfDeck.componentsSeparatedByString(" ")
                    cardsArrayRaw.removeLast()
                    for card in cardsArrayRaw {
                        let cardRaw = card.componentsSeparatedByString("@_")
                        
                        // SETUP CARDS IN CELLS
                        pickedCards.append(cardRaw[0])
                        pickedCardsQuantity.append(cardRaw[1].toInt()!)
                    }
                }
            }
        }
        println(pickedCards)
    }
    
}
