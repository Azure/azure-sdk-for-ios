/**
 * Represents a callback for trouter registrar client to acquire authentication token for its requests
 */
@protocol TrouterSkypetokenProvider <NSObject>
/**
 * Called back whenever Registrar client needs X-Skypetoken auth header value for its next request
 * It is recommended that auth tokens are cached in the upper layer and returned immediately
 *
 * forceRefresh parameter is set to true when Registrar client hits 401 Unauthorized error
 * which may indicate an expired or revoked token so the hint is to ask for new token
 * to be issued instead of returning cached one
 */
-(NSString*)getSkypetoken:(BOOL)forceRefresh;
@end

/**
 * Represents a setter of authentication headers for trouter client requests.
 * Created for convenience of each call back to ITrouterAuthHeadersProvider
 */
@protocol TrouterAuthHeadersSetter <NSObject>
/**
* Sets the authentication headers for trouter client request
* Can be safely called from within  ITrouterAuthHeadersProvider.getAuthHeaders()
*
* Example of the authHeaders value to set is:
*   "X-Skypetoken: eyJhbGc..."
*/
-(void)set:(NSString*)authHeaders;
@end

/**
 * Represents a callback for trouter client to acquire authentication headers for its requests
 */
@protocol TrouterAuthHeadersProvider <NSObject>
/**
 * Called back whenever Trouter client needs authentication headers for its next request
 * It is recommended that auth tokens are cached in the upper layer and returned immediately
 *
 * @param forceRefresh the parameter is set to true when Trouter client hits 401 Unauthorized error
 * which may indicate an expired or revoked token so the hint is to ask for new token
 * to be issued instead of returning cached one
 */
-(void)getAuthHeaders:(BOOL)forceRefresh :(id<TrouterAuthHeadersSetter>)authHeaders;
@end

/**
 * Adapter of TrouterSkypetokenProvider to TrouterAuthHeadersProvider
 * For the convenience of using TrouterSkypetokenProvider for both Trouter client and Registration authentication
 */
@interface TrouterSkypetokenAuthHeaderProvider : NSObject<TrouterAuthHeadersProvider>
{
    id<TrouterSkypetokenProvider> skypetokenProvider;
}
-(id)initWithSkypetokenProvider:(id<TrouterSkypetokenProvider>)skypetokenProvider;
-(void)getAuthHeaders:(BOOL)forceRefresh :(id<TrouterAuthHeadersSetter>)authHeaders;
@end
