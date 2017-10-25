//
//  ReadService.swift
//  SAPMDC
//
//  Created by Ouimet, Frederic on 5/19/17.
//  Copyright © 2017 SAP. All rights reserved.
//

import Foundation
import SAPOData
import SAPOfflineOData
class ReadService {

  private static var dataService: DataService<OfflineODataProvider>!

  public static func entityFromParams(_ readParams: ReadParams, dataService: DataService<OfflineODataProvider>, changeSetManager: ChangeSetManager) throws -> EntityValue {
    ReadService.dataService = dataService

    if let readLinkReadParams = readParams as? ReadLinkReadParams {
      return try entityFromReadLinkReadParams(readLinkReadParams, changeSetManager: changeSetManager)
    } else if let queryOptionsReadParams = readParams as? QueryOptionsReadParams {
      return try entityFromQueryOptions(entitySetName: queryOptionsReadParams.entitySetName, queryOptions: queryOptionsReadParams.queryOptions)
    } else {
      return try entityFromQueryOptions(entitySetName: readParams.entitySetName, queryOptions: nil)
    }
  }

  public static func entitiesFromParams(_ readParams: ReadParams, dataService: DataService<OfflineODataProvider>, changeSetManager: ChangeSetManager) throws -> [EntityValue] {
    ReadService.dataService = dataService

    if let readLinkReadParams = readParams as? ReadLinkReadParams {
      return try entitiesFromReadLinkReadParams(readLinkReadParams, changeSetManager: changeSetManager)
    } else if let queryOptionsReadParams = readParams as? QueryOptionsReadParams {
      return try entitiesFromQueryOptions(entitySetName: queryOptionsReadParams.entitySetName, queryOptions: queryOptionsReadParams.queryOptions)
    } else {
      return try entitiesFromQueryOptions(entitySetName: readParams.entitySetName, queryOptions: nil)
    }
  }

  // MARK: private reading functions
  private static func entityFromReadLinkReadParams(_ readLinkReadParams: ReadLinkReadParams, changeSetManager: ChangeSetManager) throws -> EntityValue {
    if readLinkReadParams.isTargetCreatedInSameChangeSet() {
      guard let pendingEntity = changeSetManager.pendingEntityFromPendingChangeSet(withReadLink: readLinkReadParams.readLink) else {
        throw ODataErrors.genericError("Entity with readLink \(readLinkReadParams.readLink) was not found in changeSetManager")
      }
      return pendingEntity
    } else {
      let entitySet = try ReadService.dataService.entitySet(withName: readLinkReadParams.entitySetName)
      let entity = EntityValue.ofType(entitySet.entityType)
      entity.readLink = readLinkReadParams.readLink
      try ReadService.dataService.loadEntity(entity)
      return entity
    }
  }

  // A ReadLink always return one single entity, but in the context of a linking target acquisition, we only work with arrays
  private static func entitiesFromReadLinkReadParams(_ readLinkReadParams: ReadLinkReadParams, changeSetManager: ChangeSetManager) throws -> [EntityValue] {
    return [try entityFromReadLinkReadParams(readLinkReadParams, changeSetManager: changeSetManager)] // TODO: does this actually work?
  }

  private static func entityFromQueryOptions(entitySetName: String, queryOptions: String?) throws -> EntityValue {
    let entities = try entitiesFromQueryOptions(entitySetName: entitySetName, queryOptions: queryOptions)

    guard entities.count == 1 else {
      throw ODataErrors.genericError("The query should have returned only one entity. It returned \(entities.count)")
    }
    return entities[0]
  }

  private static func entitiesFromQueryOptions(entitySetName: String, queryOptions: String?) throws -> [EntityValue] {

    let entityList = try getEntityValueList(entityName: entitySetName, queryOptions: queryOptions)
    return entityList.toArray()
  }

  private static func getEntityValueList(entityName: String, queryOptions: String?) throws -> EntityValueList {

    let query =  try createQuery(entitySetName: entityName, queryOptions: queryOptions)
    return try ReadService.dataService.executeQuery(query).entityList()
  }

  private static func createQuery(entitySetName: String, queryOptions: String?) throws -> DataQuery {

    var query: DataQuery = DataQuery()
    if let queryOptions = queryOptions {
      query.url = "\(entitySetName)?\(queryOptions)"
    } else {
      query.url = "\(entitySetName)"
    }

    let entitySet = try ReadService.dataService.entitySet(withName: entitySetName)
    query = query.from(entitySet)
    return query
  }

  // MARK: Params factory
  public class ReadParamsFactory {
    static let ENTITYSETNAMEKEY = "entitySet"
    static let QUERYOPTIONSKEY = "queryOptions"
    static let READLINKKEY = "readLink"

    public static func createReadParams(_ params: [String: Any]) throws -> ReadParams {

      guard let entitySetName = params[ENTITYSETNAMEKEY] as? String, !entitySetName.isEmpty else {
        throw ODataErrors.genericError("\(CrudParamsHelper.MALFORMEDPARAM) could not find \(ENTITYSETNAMEKEY) value in linking instructions")
      }

      if let queryOptions = params[QUERYOPTIONSKEY] as? String, !queryOptions.isEmpty {
        return QueryOptionsReadParams(entitySetName: entitySetName, queryOptions: queryOptions)
      } else if let readLink = params[READLINKKEY] as? String, !readLink.isEmpty {
        return ReadLinkReadParams(entitySetName: entitySetName, readLink: readLink)
      } else {
        return ReadParams(entitySetName: entitySetName)
      }
    }
  }
}
