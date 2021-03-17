#import "Trouter.h"
#import "TrouterSkypetokenProvider.h"


@interface RegistrarResponse : NSObject
@property(nonatomic, readonly, strong) NSString* message;
@property(nonatomic, readonly) int code;
+ (id)createWithData:(NSData*)data
            response:(NSURLResponse*)response;
@end

/*
 * Holds parameters of client Registration record
 * that can be POSTed automatically by Trouter client on behalf of the application
 */
@interface TrouterUrlRegistrationData : NSObject
@property(nonatomic, readonly, strong) NSString* applicationId;     // mandatory, should match appIds value set in PNH templates
@property(nonatomic, readonly, strong) NSString* registrationId;    // optional, GUID is generated if null or empty
@property(nonatomic, readonly, strong) NSString* platform;          // optional
@property(nonatomic, readonly, strong) NSString* platformUiVersion; // mandatory, take the value from "clientVersion" set to TrouterClientHost
@property(nonatomic, readonly, strong) NSString* templateKey;       // mandatory, should match templateKeys value set in PNH templates
@property(nonatomic, readonly, strong) NSString* productContext;    // optional, currently only used by TFL
@property(nonatomic, readonly, strong) NSString* context;           // optional

+ (id)createWithApplicationId:(NSString*)applicationId
               registrationId:(NSString*)registrationId
                     platform:(NSString*)platform
            platformUiVersion:(NSString*)platformUiVersion
                  templateKey:(NSString*)templateKey
               productContext:(NSString*)productContext
                      context:(NSString*)context;
@end


/*
 * Provides functionality of automatically tracking Trouter URL updates
 * and registering them in EDF Registrar on behalf of the application
 */
@interface TrouterUrlRegistrar : NSObject
+ (id)createWithSkypetokenProvider:(id<TrouterSkypetokenProvider>)skypetokenProvider // mandatory, auth header provider
                  registrationData:(TrouterUrlRegistrationData*)registrationData     // mandatory
      registrarHostnameAndBasePath:(NSString*)registrarHostnameAndBasePath           // optional, defaults to edge.skype.com/registrar/prod
               maxRegistrationTtlS:(int)maxRegistrationTtlS;                         // optional, in seconds, limits registration TTL, min value is 3600
- (void)onTrouterConnected:(id<TrouterConnectionInfo>)connectionInfo;
@end
