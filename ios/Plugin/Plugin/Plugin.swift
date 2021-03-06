import Foundation
import Capacitor
import SafariServices
import AuthenticationServices

typealias JSObject = [String:Any]
@objc(SingleSignOn)
public class SingleSignOn: CAPPlugin, ASWebAuthenticationPresentationContextProviding {

    @available(iOS 12.0, *)
    public func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        return DispatchQueue.main.sync {
           return UIApplication.shared.keyWindow!
        }
    }
    
    private var session: Any?

    @objc func authenticate(_ call: CAPPluginCall) {
        let url = call.getString("url") ?? ""
        let scheme = call.getString("customScheme") ?? ""
        
        if #available(iOS 12.0, *) {
            self.session = ASWebAuthenticationSession.init(url: URL(string: url)!, callbackURLScheme: scheme, completionHandler: { url, error in
                if (error != nil) {
                    call.error("Error", error)
                }
                else {
                    var response = JSObject()
                    response["url"] = url?.absoluteString
                    call.resolve(response)
                }
            })
            if #available(iOS 13.0, *) {
                (self.session as! ASWebAuthenticationSession).presentationContextProvider = self
            }
            (self.session as! ASWebAuthenticationSession).start()
        }
        else if #available(iOS 11.0, *) {
            self.session = SFAuthenticationSession.init(url: URL(string: url)!, callbackURLScheme: scheme, completionHandler: { url, error in
                if (error != nil) {
                    call.error("Error", error)
                }
                else {
                    var response = JSObject()
                    response["url"] = url?.absoluteString
                    call.resolve(response)
                }
            })
            (self.session as! SFAuthenticationSession).start()
        }
        else {
            call.error("Not supported")
        }
    }

}
