import Foundation

extension NSBundle {
    static var appScheme: String {
        let urlTypes = NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleURLTypes") as! Array<[NSObject: NSObject]>
        let urlType = urlTypes[0] as! [NSString: NSObject]
        let urlSchemes = urlType["CFBundleURLSchemes" as NSString] as! Array<NSObject>
        return urlSchemes[0] as! String
    }
}