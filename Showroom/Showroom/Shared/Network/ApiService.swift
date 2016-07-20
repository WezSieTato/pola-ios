import Foundation
import RxSwift

struct ApiService {
    let networkClient: NetworkClient
    
    var basePath: String {
        return Constants.baseUrl
    }
}

extension ApiService {
    func fetchContentPromo(withGender gender: Gender) -> Observable<ContentPromoResult> {
        let url = NSURL(fileURLWithPath: basePath)
            .URLByAppendingPathComponent("home")
            .URLByAppendingParams(["gender": gender.rawValue])
        
        let urlRequest = NSMutableURLRequest(URL: url)
        urlRequest.HTTPMethod = "GET"
        return networkClient
            .request(withRequest: urlRequest)
            .flatMap { data -> Observable<ContentPromoResult> in
                do {
                    let array = try NSJSONSerialization.JSONObjectWithData(data, options: []) as! [AnyObject]
                    return Observable.just(try ContentPromoResult.decode(array))
                } catch {
                    return Observable.error(error)
                }
        }
    }
    
    func fetchProductDetails(withProductId productId: Int) -> Observable<ProductDetails> {
        let url = NSURL(fileURLWithPath: basePath)
            .URLByAppendingPathComponent("products")
            .URLByAppendingPathComponent(String(productId))
        
        let urlRequest = NSMutableURLRequest(URL: url)
        urlRequest.HTTPMethod = "GET"
        return networkClient
            .request(withRequest: urlRequest)
            .flatMap { data -> Observable<ProductDetails> in
                do {
                    let result = try NSJSONSerialization.JSONObjectWithData(data, options: [])
                    return Observable.just(try ProductDetails.decode(result))
                } catch {
                    return Observable.error(error)
                }
        }
    }
    
    func validateBasket(with basketRequest: BasketRequest) -> Observable<Basket> {
        let url = NSURL(fileURLWithPath: basePath)
            .URLByAppendingPathComponent("cart/validate")
        
        do {
            let jsonData = try NSJSONSerialization.dataWithJSONObject(basketRequest.encode(), options: [])
            
            let urlRequest = NSMutableURLRequest(URL: url)
            urlRequest.HTTPMethod = "POST"
            urlRequest.HTTPBody = jsonData
            return networkClient
                .request(withRequest: urlRequest)
                .flatMap { data -> Observable<Basket> in
                    do {
                        let result = try NSJSONSerialization.JSONObjectWithData(data, options: [])
                        return Observable.just(try Basket.decode(result))
                    } catch {
                        return Observable.error(error)
                    }
            }
        } catch {
            return Observable.error(error)
        }
    }
    
    func fetchProducts(forPage: Int, pageSize: Int = Constants.productListPageSize) -> Observable<ProductListResult> {
        let url = NSURL(fileURLWithPath: basePath)
            .URLByAppendingPathComponent("products")
            .URLByAppendingParams(["page": String(forPage), "pageSize": String(pageSize)])
        
        let urlRequest = NSMutableURLRequest(URL: url)
        urlRequest.HTTPMethod = "GET"
        return networkClient
            .request(withRequest: urlRequest)
            .flatMap { data -> Observable<ProductListResult> in
                do {
                    let result = try NSJSONSerialization.JSONObjectWithData(data, options: [])
                    return Observable.just(try ProductListResult.decode(result))
                } catch {
                    return Observable.error(error)
                }
        }
    }
    
    func fetchTrend(slug: String) -> Observable<ProductListResult> {
        let url = NSURL(fileURLWithPath: basePath)
            .URLByAppendingPathComponent("trend")
            .URLByAppendingPathComponent(slug)
        
        let urlRequest = NSMutableURLRequest(URL: url)
        urlRequest.HTTPMethod = "GET"
        return networkClient
            .request(withRequest: urlRequest)
            .flatMap { data -> Observable<ProductListResult> in
                do {
                    let result = try NSJSONSerialization.JSONObjectWithData(data, options: [])
                    return Observable.just(try ProductListResult.decodeForTrend(result))
                } catch {
                    return Observable.error(error)
                }
        }
    }

    func fetchKiosks(withLatitude latitude: Double, longitude: Double, limit: Int = 10) -> Observable<KioskResult> {
        let url = NSURL(fileURLWithPath: basePath)
            .URLByAppendingPathComponent("delivery/pwr/pops")
            .URLByAppendingParams(["limit": String(limit)])
        
        do {
            let paramsDict = ["lat": latitude, "lng": longitude] as NSDictionary
            let jsonData = try NSJSONSerialization.dataWithJSONObject(paramsDict, options: [])
            
            let urlRequest = NSMutableURLRequest(URL: url)
            urlRequest.HTTPMethod = "POST"
            urlRequest.HTTPBody = jsonData
            return networkClient
                .request(withRequest: urlRequest)
                .flatMap { data -> Observable<KioskResult> in
                    do {
                        let array = try NSJSONSerialization.JSONObjectWithData(data, options: []) as! [AnyObject]
                        return Observable.just(try KioskResult.decode(array))
                    } catch {
                        return Observable.error(error)
                    }
            }
        } catch {
            return Observable.error(error)
        }
    }
    
    func login(withEmail email: String, password: String) -> Observable<SigningResult> {
        let url = NSURL(fileURLWithPath: basePath)
            .URLByAppendingPathComponent("login")
        
        do {
            let login = Login(username: email, password: password)
            let jsonData = try NSJSONSerialization.dataWithJSONObject(login.encode(), options: [])
            let urlRequest = NSMutableURLRequest(URL: url)
            urlRequest.HTTPMethod = "POST"
            urlRequest.HTTPBody = jsonData
            return networkClient.request(withRequest: urlRequest).flatMap { data -> Observable<SigningResult> in
                do {
                    let result = try NSJSONSerialization.JSONObjectWithData(data, options: [])
                    let loginResult = try SigningResult.decode(result)
                    return Observable.just(loginResult)
                } catch {
                    return Observable.error(error)
                }
            }
        } catch {
            return Observable.error(error)
        }
    }
    
    func register(with registration: Registration) -> Observable<SigningResult> {
        let url = NSURL(fileURLWithPath: basePath)
            .URLByAppendingPathComponent("register")
        do {
            let jsonData = try NSJSONSerialization.dataWithJSONObject(registration.encode(), options: [])
            let urlRequest = NSMutableURLRequest(URL: url)
            urlRequest.HTTPMethod = "POST"
            urlRequest.HTTPBody = jsonData
            return networkClient.request(withRequest: urlRequest).flatMap { data -> Observable<SigningResult> in
                do {
                    let result = try NSJSONSerialization.JSONObjectWithData(data, options: [])
                    let registrationResult = try SigningResult.decode(result)
                    return Observable.just(registrationResult)
                } catch {
                    return Observable.error(error)
                }
            }
        } catch {
            return Observable.error(error)
        }
    }
}

extension NSURL {
    func URLByAppendingParams(params: [String: String]) -> NSURL {
        var url = self.absoluteString
        url += url.containsString("?") ? "&" : "?"
        for (key, value) in params {
            url += key + "=" + value + "&"
        }
        url = url.substringToIndex(url.endIndex.predecessor())
        return NSURL(string: url)!
    }
}