//
//  Card.swift
//  
//
//  Created by Andrea Franchini on 10/05/15.
//
//

import Foundation
import CoreData

class Card: NSManagedObject {

    @NSManaged var attack: NSNumber
    @NSManaged var cost: NSNumber
    @NSManaged var durability: NSNumber
    @NSManaged var flavor: String
    @NSManaged var health: NSNumber
    @NSManaged var id: String
    @NSManaged var name: String
    @NSManaged var playerClass: String
    @NSManaged var rarity: String
    @NSManaged var text: String
    @NSManaged var type: String
    @NSManaged var image: NSData
    @NSManaged var hasImage: Bool
    @NSManaged var collectible: Bool
    @NSManaged var thumbnail: NSData
    @NSManaged var owned: Bool
    
    // Save card function
    class func createCardInManagedObjectContext(moc: NSManagedObjectContext, name: String, id: String, cost: Int, type: String, rarity: String, text: String, flavor: String, attack: Int, health: Int, playerClass: String, durability: Int, image: NSData, hasImage: Bool, collectible: Bool, thumbnail: NSData, owned: Bool) -> Card {
        
        let newCard = NSEntityDescription.insertNewObjectForEntityForName("Card", inManagedObjectContext: moc) as! Card
        
        newCard.name = name
        newCard.id = id
        newCard.cost = cost
        newCard.type = type
        newCard.rarity = rarity
        newCard.text = text
        newCard.flavor = flavor
        newCard.attack = attack
        newCard.health = health
        newCard.playerClass = playerClass
        newCard.durability = durability
        newCard.image = image
        newCard.hasImage = hasImage
        newCard.collectible = collectible
        newCard.thumbnail = thumbnail
        newCard.owned = owned
        
        do {
            try moc.save()
        } catch {
            print("Error saving: \(error)")
        }
        
        return newCard
    }
    
}
