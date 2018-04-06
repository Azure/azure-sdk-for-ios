# AzureData

![Current State: Development](https://img.shields.io/badge/Current_State-Development-blue.svg)

[AzureData API Reference](https://github.com/Azure/Azure.iOS/wiki/AzureData) and [samples](https://github.com/Azure/Azure.iOS/wiki/AzureData) can be found on our [wiki](https://github.com/Azure/Azure.iOS/wiki).

AzureData is an SDK for interfacing with [Azure Cosmos DB](https://docs.microsoft.com/en-us/azure/cosmos-db/sql-api-introduction) - A schema-less JSON database engine with rich SQL querying capabilities. It currently supports the full SQL (DocumentDB) API and development to add offline persistence will start very soon.

More information on the features to be included in AzureData can be found the [Requirements](https://github.com/Azure/Azure.iOS/wiki/Requirements-AzureData) wiki document.


# Configure

Before making calls to AzureData, you'll need to call `AzureData.configure`.  We recommend doing this in `application(_:didFinishLaunchingWithOptions:)`.

```swift
func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
    
    AzureData.configure(forAccountNamed: "<Database Name>", withMasterKey: "<Database Master Key>", withPermissionMode: "<Master Key Permission Mode>")

    return true
}
```


# Usage

| Resource                                              | Create                                                | List                                                  | Get                                                   | Delete                                                | Replace                                               | Query                                                 | Execute                                               |
| ----------------------------------------------------- | ----------------------------------------------------- | ----------------------------------------------------- | ----------------------------------------------------- | ----------------------------------------------------- | ----------------------------------------------------- | ----------------------------------------------------- | ----------------------------------------------------- |
| **[Databases](#databases)**                           | [Create](#create)                                     | [List](#list)                                         | [Get](#get)                                           | [Delete](#delete)                                     | *                                                     | *                                                     | *                                                     |
| **[Collections](#collections)**                       | [Create](#create-1)                                   | [List](#list-1)                                       | [Get](#get-1)                                         | [Delete](#delete-1)                                   | [Replace](#replace)                                   | *                                                     | *                                                     |
| **[Documents](#documents)**                           | [Create](#create-2)                                   | [List](#list-2)                                       | [Get](#get-2)                                         | [Delete](#delete-2)                                   | [Replace](#replace-1)                                 | [Query](#query)                                       | *                                                     |
| **[Attachments](#attachments)**                       | [Create](#create-3)                                   | [List](#list-3)                                       | *                                                     | [Delete](#delete-3)                                   | [Replace](#replace-2)                                 | *                                                     | *                                                     |
| **[Stored Procedures](#stored-procedures)**           | [Create](#create-4)                                   | [List](#list-4)                                       | *                                                     | [Delete](#delete-4)                                   | [Replace](#replace-3)                                 | *                                                     | [Execute](#execute)                                   |
| **[User Defined Functions](#user-defined-functions)** | [Create](#create-5)                                   | [List](#list-5)                                       | *                                                     | [Delete](#delete-5)                                   | [Replace](#replace-4)                                 | *                                                     | *                                                     |
| **[Triggers](#triggers)**                             | [Create](#create-6)                                   | [List](#list-6)                                       | *                                                     | [Delete](#delete-6)                                   | [Replace](#replace-5)                                 | *                                                     | *                                                     |
| **[Users](#users)**                                   | [Create](#create-7)                                   | [List](#list-7)                                       | [Get](#get-3)                                         | [Delete](#delete-7)                                   | [Replace](#replace-6)                                 | *                                                     | *                                                     |
| **[Permissions](#permissions)**                       | [Create](#create-8)                                   | [List](#list-8)                                       | [Get](#get-4)                                         | [Delete](#delete-8)                                   | [Replace](#replace-7)                                 | *                                                     | *                                                     |
| **[Offers](#offers)**                                 | *                                                     | [List](#list-9)                                       | [Get](#get-5)                                         | *                                                     | [Replace](#replace-8)                                 | [Query](#query-1)                                     | *                                                     |


_* not applicable to resource type_


## Databases

#### Create
```swift
AzureData.create (databaseWithId: id) { r in
    // database = r.resource
}
```

#### List
```swift
AzureData.databases () { r in
    // databases = r.resource?.items
}
```

#### Get
```swift
AzureData.get (databaseWithId: id) { r in
    // database = r.resource
}
```

#### Delete
```swift
AzureData.delete (database) { r in
    // successfully deleted == r.isSuccess
}

AzureData.delete (databaseWithId: id) { r in
    // successfully deleted == r.isSuccess
}

database.delete { r in
    // successfully deleted == r.isSuccess
}
```



## Collections

#### Create
```swift
AzureData.create (collectionWithId: id, inDatabase: databaseId) { r in
    // collection = r.resource
}

database.create (collectionWithId: id) { r in
    // collection = r.resource
}
```

#### List
```swift
AzureData.get (collectionsIn: databaseId) { r in
    // collections = r.resource?.items
}

database.getCollections () { r in
    // collections = r.resource?.items
}
```

#### Get
```swift
AzureData.get (collectionWithId: id, inDatabase: databaseId) { r in
    // collection = r.resource
}

database.get (collectionWithId: id) { r in
    // collection = r.resource
}
```

#### Delete
```swift
AzureData.delete (collection) { r in
    // successfully deleted == r.isSuccess
}

AzureData.delete (collectionWithId: collectionId, fromDatabase: databaseId) { r in
    // successfully deleted == r.isSuccess
}

database.delete (collection) { r in
    // successfully deleted == r.isSuccess
}

database.delete (collectionWithId: collectionId) { r in
    // successfully deleted == r.isSuccess
}

collection.delete { r in
    // successfully deleted == r.isSuccess
}
```

#### Replace

A `Replace` operation on a `DocumentCollection` allows you to replace the `IndexingPolicy` for the collection.

Given a created `IndexingPolicy`:

```swift
let policy = DocumentCollection.IndexingPolicy(
    automatic: true,
    excludedPaths: [
        .init(path: "/test/*")
    ],
    includedPaths: [
        .init(
            path: "/*",
            indexes: [
                .range(withDataType: .number, andPrecision: -1),
                .hash(withDataType: .string, andPrecision: 3),
                .spatial(withDataType: .point)
            ]
        )
    ],
    indexingMode: .lazy
)
```

Use the following function to replace the `IndexingPolicy` of a collection.

```swift
AzureData.replace(collectionWithId: collectionId, inDatabase: databaseId, usingPolicy: policy) { r in
    // replaced collection = r.resource
}
```



## Documents

There are two different classes you can use to interact with documents:

### Document

The `Document` type is intended to be inherited by your custom model types. Subclasses must conform to the `Codable` protocal and require minimal boilerplate code for successful serialization/deserialization.

Here is an example of a class `CustomDocument` that inherits from `Document`:

```swift
class CustomDocument: Document {
    
    var testDate:   Date?
    var testNumber: Double?
    
    public override init () { super.init() }
    public override init (_ id: String) { super.init(id) }
    
    public required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        testDate    = try container.decode(Date.self,   forKey: .testDate)
        testNumber  = try container.decode(Double.self, forKey: .testNumber)
    }
    
    public override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)

        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(testDate,      forKey: .testDate)
        try container.encode(testNumber,    forKey: .testNumber)
    }

    private enum CodingKeys: String, CodingKey {
        case testDate
        case testNumber
    }
}
```

### DictionaryDocument

The `DictionaryDocument` type behaves very much like a `[String:Any]` dictionary while handling all properties required by the database.  This allows you to interact with the document directly using subscript syntax.  `DictionaryDocument` cannot be subclassed.

Here is an example of using `DictionaryDocument` to create a document with the same properties as the `CustomDocument` above:

```swift
let document = DictionaryDocument()

document["testDate"]   = Date(timeIntervalSince1970: 1510865595)         
document["testNumber"] = 1_000_000
```


#### Create
```swift
let document = CustomDocument()

document.testDate   = Date(timeIntervalSince1970: 1510865595)
document.testNumber = 1_000_000

// or

let document = DictionaryDocument()

document["testDate"]   = Date(timeIntervalSince1970: 1510865595)         
document["testNumber"] = 1_000_000


AzureData.create (document, inCollection: collectionId, inDatabase: databaseId) { r in
    // document = r.resource
}

AzureData.create (document, in: collection) { r in
    // document = r.resource
}

collection.create (document) { r in
    // document = r.resource
}
```

#### List
```swift
AzureData.get (documentsAs: CustomDocument.self, inCollection: collectionId, inDatabase: databaseId) { r in
    // documents = r.resource?.items
}

AzureData.get (documentsAs: CustomDocument.self, in: collection) { r in
    // documents = r.resource?.items
}

collection.get (documentsAs: CustomDocument.self) { r in
    // documents in r.resource?.list
}
```

#### Get
```swift
AzureData.get (documentWithId: id, as: CustomDocument.self, inCollection: collectionId, inDatabase: databaseId) { r in
    // document = r.resource
}

AzureData.get (documentWithId: id, as: CustomDocument.self, in: collection) { r in
    // document = r.resource
}

collection.get (documentWithResourceId: id: as: CustomDocument.self) { r in
    // document = r.resource
}
```

#### Delete
```swift
AzureData.delete (documentWithId: documentId, fromCollection: collectionId, inDatabase: databaseId) { r in
    // r.isSuccess == successfully deleted
}

AzureData.delete (document) { r in
    // r.isSuccess == successfully deleted
}

collection.delete (document) { r in
    // r.isSuccess == successfully deleted
}

collection.delete (documentWithId: documentId) { r in
    // r.isSuccess == successfully deleted
}

document.delete { r in
    // r.isSuccess == successfully deleted
}
```

#### Replace
```swift
AzureData.replace (document, inCollection: collectionId, inDatabase: databaseId) { r in
    // document = r.resource
}

AzureData.replace (document, in: collection) { r in
    // document = r.resource
}

collection.replace (document) { r in
    // document = r.resource
}
```

#### Query
```swift
let query = ADQuery.select("firstName", "lastName", ...)
                   .from("People")
                   .where("firstName", is: "Colby")
                   .and("lastName", is: "Williams")
                   .and("age", isGreaterThanOrEqualTo: 20)
                   .orderBy("_etag", descending: true)

AzureData.query(documentsIn: collectionId, inDatabase: databaseId, with: query) { r in
    // documents = r.resource?.items
}

AzureData.query(documentsIn: collection, with: query) { r in
    // documents = r.resource?.items
}

collection.query (documentsWith: query) { r in
    // documents in r.resource?.list
}
```



## Attachments

#### Create
```swift
// link to existing media asset:
AzureData.create (attachmentWithId: id, contentType: "image/png", andMediaUrl: url, onDocument: documentId, inCollection: collectionId, inDatabase: databaseId) { r in
    // attachment = r.resource
}

document.create (attachmentWithId: id, contentType: "image/png", andMediaUrl: url) { r in
    // attachment = r.resource
}

//or upload the media directly:
AzureData.create (attachmentWithId: id, contentType: "image/png", name: "file.png", with: media, onDocument: documentId, inCollection: collectionId, inDatabase: databaseId) { r in
    // attachment = r.resource
}

document.create (attachmentWithId: id, contentType: "image/png", name: "file.png", with: media) { r in
    // attachment = r.resource
}
```

#### List
```swift
AzureData.get (attachmentsOn: documentId, inCollection: collectionId, inDatabase: databaseId) { r in
    // attachments = r.resource?.items
}

document.getAttachments { r in
    // attachments = r.resource?.items
}
```

#### Delete
```swift
AzureData.delete (attachmentWithId: attachmentId, onDocument: documentId, inCollection: collectionId, inDatabase: databaseId) { r in
    // r.isSuccess == successfully deleted
}

document.delete (attachment) { r in
    // r.isSuccess == successfully deleted
}

document.delete (attachmentWithId: attachmentId) { r in
    // r.isSuccess == successfully deleted
}
```

#### Replace
```swift
// link to existing media asset:
AzureData.replace(attachmentWithId: id, contentType: "image/png", andMediaUrl: url, onDocument: documentId, inCollection: collectionId, inDatabase: databaseId) { r in
    // attachment = r.resource
}

document.replace(attachmentWithId: id, contentType: "image/png", andMediaUrl: url) { r in
    // attachment = r.resource
}

//or upload the media directly:
AzureData.replace(attachmentWithId: id, contentType: "image/png", name: "file.png", with: media, onDocument: documentId, inCollection: collectionId, inDatabase: databaseId) { r in
    // attachment = r.resource
}

document.replace(attachmentWithId: id, contentType: "image/png", name: "file.png", with: media) { r in
    // attachment = r.resource
}
```



## Stored Procedures

#### Create
```swift
AzureData.create (storedProcedureWithId: id, andBody: body, inCollection: collectionId, inDatabase: databaseId) { r in
    // storedProcedure = r.resource
}

AzureData.create (storedProcedureWithId: id, andBody: body, in: collection) { r in
    // storedProcedure = r.resource
}

collection.create (storedProcedureWithId: storedProcedureId, andBody: body) { r in
    // storedProcedure = r.resource
}
```

#### List
```swift
AzureData.get (storedProceduresIn: collectionId, inDatabase: databaseId) { r in
    // storedProcedures = r.resource?.items
}

AzureData.get (storedProceduresIn: collection) { r in
    // storedProcedures = r.resource?.items
}

collection.getStoredProcedures () { r in
    // storedProcedures in r.resource?.list
}
```

#### Delete
```swift
AzureData.delete (storedProcedureWithId: id, fromCollection: collectionId, inDatabase: databaseId) { r in
    // r.isSuccess == successfully deleted
}

collection.delete (storedProcedure) { r in
    // r.isSuccess == successfully deleted
}

collection.delete (storedProcedureWithId: id) { r in
    // r.isSuccess == successfully deleted
}

storedProcedure.delete { r in
    // r.isSuccess == successfully deleted
}
```

#### Replace
```swift
AzureData.replace (storedProcedureWithId: id, andBody: body, inCollection: collectionId, inDatabase: databaseId) { r in
    // storedProcedure = r.resource
}

AzureData.replace (storedProcedureWithId: id, andBody: body, in: collection) { r in
    // storedProcedure = r.resource
}

collection.replace (storedProcedureWithId: storedProcedureId, andBody: body) { r in
    // storedProcedure = r.resource
}
```

#### Execute
```swift
AzureData.execute (storedProcedureWithId: id, usingParameters: [], inCollection: collectionId, inDatabase: databaseId) { r in
    // r = raw response data
}

AzureData.execute (storedProcedureWithId: id, usingParameters: [], in: collection) { r in
    // r = raw response data
}

collection.execute (storedProcedureWithId: storedProcedureId, usingParameters: parameters) { data in
    // data = response from stored procedure
}
```



## User Defined Functions

#### Create
```swift
AzureData.create (userDefinedFunctionWithId: id, andBody: body, inCollection: collectionId, inDatabase: databaseId) { r in
    // userDefinedFunction = r.resource
}

AzureData.create (userDefinedFunctionWithId: id, andBody: body, in: collection) { r in
    // userDefinedFunction = r.resource
}

collection.create (userDefinedFunctionWithId: userDefinedFunctionId, andBody: body) { r in
    // userDefinedFunction = r.resource
}
```

#### List
```swift
AzureData.get (userDefinedFunctionsIn: collectionId, inDatabase: databaseId) { r in
    // userDefinedFunction = r.resource?.items
}

AzureData.get (userDefinedFunctionsIn: collection) { r in
    // userDefinedFunction = r.resource?.items
}

collection.getUserDefinedFunctions () { r in
    // userDefinedFunctions in r.resource?.list
}
```

#### Delete
```swift
AzureData.delete (userDefinedFunctionWithId: functionId, fromCollection: collectionId, inDatabase: databaseId) { r in
    // r.isSuccess == successfully deleted
}

collection.delete (userDefinedFunction) { r in
    // r.isSuccess == successfully deleted
}

collection.delete (userDefinedFunctionWithId: functionId) { r in
    // r.isSuccess == successfully deleted
}

userDefinedFunction.delete { r in
    // r.isSuccess == successfully deleted
}
```

#### Replace
```swift
AzureData.replace (userDefinedFunctionWithId: id, andBody: body, inCollection: collectionId, inDatabase: databaseId) { r in
    // userDefinedFunction = r.resource
}

AzureData.replace (userDefinedFunctionWithId: id, andBody: body, from: collection) { r in
    // userDefinedFunction = r.resource
}

collection.replace (userDefinedFunctionWithId: userDefinedFunctionId, andBody: body) { r in
    // userDefinedFunction = r.resource
}
```



## Triggers

#### Create
```swift
AzureData.create (triggerWithId: id, operation: .all, type: .pre, andBody: body, inCollection: collectionId, inDatabase: databaseId) { r in
    // trigger = r.resource
}

AzureData.create (triggerWithId: id, operation: .all, type: .pre, andBody: bosy, in: collection) { r in
    // trigger = r.resource
}

collection.create (triggerWithId: triggerId, andBody: body, operation: operation, type: type) { r in
    // trigger = r.resource
}
```

#### List
```swift
AzureData.get (triggersIn: collectionId, inDatabase: databaseId) { r in
    // triggers = r.resource?.items
}

AzureData.get (triggersIn: collection) { r in
    // triggers = r.resource?.items
}

collection.getTriggers { r in
    // triggers in r.resource?.list
}
```

#### Delete
```swift
AzureData.delete (triggerWithId: triggerId, fromCollection: collectionId, inDatabase: databaseId) { r in
    // r.isSuccess == successfully deleted
}

collection.delete (trigger) { r in
    // r.isSuccess == successfully deleted
}

collection.delete (triggerWithId: triggerId) { r in
    // r.isSuccess == successfully deleted
}

trigger.delete { r in
    // r.isSuccess == successfully deleted
}
```

#### Replace
```swift
AzureData.replace (triggerWithId: id, operation: .all, type: .pre, andBody: body, inCollection: collectionId, inDatabase: databaseId) { r in
    // trigger = r.resource
}

AzureData.replace (triggerWithId: id, operation: .all, type: .pre, andBody: body, in: collection) { r in
    // trigger = r.resource
}

collection.replace (triggerWithId: triggerId, andBody: body, operation: operation, type: type) { r in
    // trigger = r.resource
}
```



## Users    

#### Create
```swift
AzureData.create (userWithId: id, inDatabase: databaseId) { r in
    // user = r.resource
}

database.create (userWithId: userId) { r in
    // user = r.resource
}
```

#### List
```swift
AzureData.get (usersIn: databaseId) { r in
    // users = r.resource?.items
}

database.getUsers () { r in
    // users = r.resource?.items
}
```

#### Get
```swift
AzureData.get (userWithId: id, inDatabase: databaseId) { r in
    // user = r.resource
}

database.get (userWithId: userId) { r in
    // user = r.resource
}
```

#### Delete
```swift
AzureData.delete (userWithId: userId, fromDatabase: databaseId) { r in
    // r.isSuccess == successfully deleted
}

database.delete (user) { r in
    // r.isSuccess == successfully deleted
}

database.delete (userWithId: userId) { r in
    // r.isSuccess == successfully deleted
}
```

#### Replace
```swift
AzureData.replace (userWithId: userId, with: newUserId, inDatabase: database) { r in
    // user = r.resource
}

AzureData.replace (userWithId: userId, with: newUserId, inDatabase: databaseId) { r in
    // user = r.resource
}

database.replace (userWithId: userId, with: newUserId) { r in
    // user = r.resource
}
```



## Permissions  

#### Create
```swift
AzureData.create (permissionWithId: id, mode: .read, in: resource, forUser: userId, inDatabase: databaseId) { r in
    // permission = r.resource
}

AzureData.create (permissionWithId: id, mode: .read, in: resource, forUser: user) { r in
    // permission = r.resource
}

<resource>.create (permissionWithId: id, mode: .read, forUser: user) { r in
    // permission = r.resource
}

user.create (permissionWithId: id, mode: .read, in: resource) { r in
    // permission = r.resource
}
```

#### List
```swift
AzureData.get (permissionsFor: userId, inDatabase: databaseId) { r in
    // permissions = r.resource
}

AzureData.get (permissionsFor: user) { r in
    // permissions = r.resource
}

user.getPermissions { r in
    // permissions = r.resource
}
```

#### Get
```swift
AzureData.get (permissionWithId: id, forUser: userId, inDatabase: databaseId) { r in
    // permission = r.resource
}

AzureData.get (permissionWithId: id, forUser: user) { r in
    // permission = r.resource
}

user.get(permissionWithId: id) { r in
    // permission = r.resource
}
```

#### Delete
```swift
AzureData.delete (permissionWithId: id, forUser: userId, inDatabase: databaseId) { r in
    // r.isSuccess == successfully deleted
}

AzureData.delete (permissionWithId: id, forUser: user) { r in
    // r.isSuccess == successfully deleted
}

AzureData.delete (permission) { r in
    // r.isSuccess == successfully deleted
}

user.delete (permissionWithId: id) { r in
    // r.isSuccess == successfully deleted
}

user.delete (permission) { r in
    // r.isSuccess == successfully deleted
}

permission.delete { r in
    // r.isSuccess == successfully deleted
}
```

#### Replace
```swift
AzureData.replace (permissionWithId: id, mode: .read, in: resource, forUser: userId, inDatabase: databaseId) { r in
    // permission = r.resource
}

AzureData.replace (permissionWithId: id, mode: .read, in: resource, forUser: user) { r in
    // permission = r.resource
}

user.replace (permissionWithId: id, mode: .read, in: resource) { r in
    // permission = r.resource
}
```



## Offers

#### List
```swift
AzureData.offers() { r in
// offers = r.resource?.items
}
```

#### Get
```swift
AzureData.get (offerWithId: id) { r in
    // offer = r.resource
}
```

#### Replace
```swift
// TODO...
```

#### Query
```swift
// TODO...
```
