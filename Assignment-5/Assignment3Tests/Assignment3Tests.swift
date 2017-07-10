//
//  Assignment3Tests.swift
//  Assignment3Tests
//
//  Created by NISUM on 6/13/17.
//  Copyright © 2017 Nisum Macbook. All rights reserved.
//

import XCTest
import CoreData

@testable import Assignment3

class Assignment3Tests: XCTestCase {
    
    let coreDataFetch = CoreDataFetch()
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = true
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func coreDataBackgroundLoad()   {
        let backgroundDataCoordinator = BackgroundDataCoordinator()
        let backgroundDataCoordinatorExpectation = expectation(description: "BackgroundDataCoordinator loads Item in background")
        backgroundDataCoordinator.requestAndLoadEntities(entityType: EntityType.Item) {
            (success:Bool) in
            XCTAssert(success)
            backgroundDataCoordinatorExpectation.fulfill()
        }
        waitForExpectations(timeout: 1) {
            error in
            if let error = error {
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            }
        }
    }
    
    func testCoreDataFetchEntityById()  {
        coreDataBackgroundLoad()
        //Test happy path:
        let testId = 1
        var item:Item? = coreDataFetch.fetchEntity(byId: NSNumber.init(value: testId))
        XCTAssert(Int(item!.id) == testId)
        //Test no object path:
        item = coreDataFetch.fetchEntity(byId: NSNumber.init(value: 123))
        XCTAssertNil(item)
        // TODO: test error path:
        let entityBase:EntityBase? = coreDataFetch.fetchEntity(byId: NSNumber.init(value: 123))
        XCTAssertNil(entityBase)
    }
    
    func testCoreDataFetchEntityByName()  {
        coreDataBackgroundLoad()
        //Test happy path:
        let testName = "Item 1"
        var item:Item? = coreDataFetch.fetchEntity(byName: testName)
        XCTAssert(item?.name == testName)
        //Test no object path:
        item = coreDataFetch.fetchEntity(byName: "Something bogus")
        XCTAssertNil(item)
        // TODO: test error path:
        let entityBase:EntityBase? = coreDataFetch.fetchEntity(byId: NSNumber.init(value: 123))
        XCTAssertNil(entityBase)
    }
    
    func testCoreDataFetchedResultsController() {
        coreDataBackgroundLoad()
        var fetchedResultsController: NSFetchedResultsController<Item>!
        fetchedResultsController = coreDataFetch.getFetchedResultsController()
        do {
            try fetchedResultsController.performFetch()
            XCTAssert((fetchedResultsController.fetchedObjects?.count)! > 0)
        } catch {
            fatalError("Failed to initialize FetchedResultsController: \(error)")
        }
    }
    
}
  
