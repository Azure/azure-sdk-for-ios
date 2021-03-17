#import "Trouter.h"
#import "TrouterUrlRegistrar.h"
#import "TrouterSkypetokenProvider.h"

/**
 * Represents a callback for trouter client to store and load connection data.
 * Storing that data allows Trouter Client to reconnect to the service quicker
 * and preserves Trouter URL.
 *
 * It can even be a simple in-memory storage for applications that start/stop
 * Trouter client often during its lifetime
 *
 * !!! It is important to carefully separate data for applications with
 *  multiple Trouter connections (e.g. multi user login)
 */
@protocol TrouterConnectionDataCache <NSObject>
/**
 * Called when trouter establishes new connection or is forced to reconnect to a new DC
 */
-(void)store:(NSString*)data;
/**
 * Called when trouter starts up and checks if it can reconnect instead of
 * establishing brand new connection
 */
-(NSString*)load;
@end

/**
 * This object represents self hosted Trouter Client
 * i.e. client which lifecycle can be directly managed
 * unlike trouter client hosted by SlimCore
 */
@interface SelfHostedTrouterClient : NSObject<TrouterClient>
/**
 * Creates new instance of self hosted trouter client
 * It has to be started in order to establish connection to server
 * Two phase startup is designed to let application register listeners prior to connecting
 * @param authHeadersProvider is a must have dependency
 * @param dataCache is an optional dependency which is recommended for maximum efficiency
 * @param trouterHostname is an optional parameter pointing to one of the trouter service clouds (deployments)
 *                   used to separate Consumer vs Enterprise traffic
 *                   sample values are 'go.trouter.skype.com', 'go.trouter.teams.microsoft.com', 'go-us.trouter.teams.microsoft.com'
 */
+ (SelfHostedTrouterClient*)createWithClientVersion:(NSString*)clientVersion
                                authHeadersProvider:(id<TrouterAuthHeadersProvider>)authHeadersProvider
                                          dataCache:(id<TrouterConnectionDataCache>)dataCache
                                    trouterHostname:(NSString*)trouterHostname;
/**
 * Starts client connection to the Trouter service
 */
- (BOOL)start;
/**
  * Gracefully disconnects client from the service
  * It does not reset listener registrations, those stay active
  */
- (BOOL)stop;
/**
 * Attaches registrar component that will track Trouter connection
 * and automatically register it.
 * Must be done before starting the client
 */
- (void)withRegistrar:(TrouterUrlRegistrar*)registrar;

@end
