//
//  CoreDataManager.swift
//  SportTeamManager
//
//  Created by Вероника Данилова on 19/11/2018.
//  Copyright © 2018 Veronika Danilova. All rights reserved.
//

import CoreData

final class CoreDataManager {
    
    static let instance = CoreDataManager(modelName: "SportTeam")
    
    private let modelName: String
    
    private init(modelName: String) {
        self.modelName = modelName
    }
    
    private lazy var persistentContainer: NSPersistentContainer = {
        
        let container = NSPersistentContainer(name: modelName)
        
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error - \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    public func getContext() -> NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    public func save(context: NSManagedObjectContext) {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let error = error as NSError
                fatalError("Unresolved error - \(error), \(error.userInfo)")
            }
        }
    }
    
    public func createObject<T: NSManagedObject>(from entity: T.Type) -> T {
        let context = getContext()
        let object = NSEntityDescription.insertNewObject(forEntityName: String(describing: entity), into: context) as! T
        return object
    }
    
    public func delete(object: NSManagedObject) {
        let context = getContext()
        context.delete(object)
        save(context: context)
    }
    
    public func fetchDataWithController<T: NSManagedObject>(for entity: T.Type, sectionNameKeyPath: String? = nil, predicate: NSCompoundPredicate? = nil) -> NSFetchedResultsController<T>{
        
        let context = getContext()
        let request: NSFetchRequest<T>

        if #available(iOS 10.0, *) {
            request = entity.fetchRequest() as! NSFetchRequest<T>
        } else {
            let entityName = String(describing: entity)
            request = NSFetchRequest(entityName: entityName)
        }
        
        let positionSortDescriptor = NSSortDescriptor(key: "team.name", ascending: true)
        let nameSortDescriptor = NSSortDescriptor(key: "fullname", ascending: true, selector: #selector(NSString.localizedStandardCompare(_:)))
        
        request.predicate = predicate
        request.sortDescriptors = [positionSortDescriptor, nameSortDescriptor]
        
        let controller = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: sectionNameKeyPath, cacheName: nil)
        
        do {
            try controller.performFetch()
        } catch {
            debugPrint("Couldn't fetch \(error.localizedDescription)")
        }
        
        return controller
    }
    
    public func findPlayer(withID id: UUID) -> [Player] {
        
        let context = getContext()
        
        let request: NSFetchRequest<Player>
        var fetchedResult = [Player]()
        
        if #available(iOS 10.0, *) {
            request = Player.fetchRequest()
        } else {
            let entityName = String(describing: Player.self)
            request = NSFetchRequest(entityName: entityName)
        }
        
        let predicate = NSPredicate(format: "id = '\(id)'")
        request.predicate = predicate
        
        do {
            fetchedResult = try context.fetch(request)
        } catch {
            debugPrint("Couldn't fetch \(error.localizedDescription)")
        }
        
        return fetchedResult
    }
    
}
