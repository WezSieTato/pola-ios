import Foundation
import RxSwift
import Decodable

final class BasketManager {
    private let apiService: ApiService
    private let emarsysService: EmarsysService
    private let storageManager: StorageManager
    private let userManager: UserManager
    private let disposeBag = DisposeBag()
    
    let state: BasketState
    
    var isUserLogged: Bool {
        return userManager.user != nil
    }
    
    init(with apiService: ApiService, emarsysService: EmarsysService, storageManager: StorageManager, userManager: UserManager) {
        self.apiService = apiService
        self.emarsysService = emarsysService
        self.storageManager = storageManager
        self.userManager = userManager
        
        //if it will be a problem we will need to think about loading it in background
        var basketState: BasketState? = nil
        do {
            basketState = try storageManager.load(Constants.Persistent.basketStateId)
        } catch {
            logError("Error while loading basket state from cache \(error)")
        }
        self.state = basketState ?? BasketState()
    }
    
    func validate() {
        logInfo("Validating basket")
        
        let request = state.createRequest()
        
        state.validationState = BasketValidationState(validating: true, validated: state.validationState.validated)
        apiService.validateBasket(with: request)
            .doOnNext { [weak self] basket in
                self?.emarsysService.sendCartEvent(with: basket)
            }
            .observeOn(MainScheduler.instance)
            .map { [weak self] (basket: Basket) -> BasketState in
                guard let strongSelf = self else { return BasketState() }
                guard basket != strongSelf.state.basket else {
                    logInfo("Basket state is the same")
                    return strongSelf.state
                }
                logInfo("Mapping basket to basket state")
                strongSelf.state.basket = basket
                if strongSelf.state.deliveryCountry == nil || !basket.deliveryInfo.availableCountries.contains({ $0.id == strongSelf.state.deliveryCountry!.id }){
                    strongSelf.state.deliveryCountry = basket.deliveryInfo.defaultCountry
                }
                if strongSelf.state.deliveryCarrier == nil || !basket.deliveryInfo.carriers.contains({ $0.id == strongSelf.state.deliveryCarrier!.id && $0.available }) {
                    strongSelf.state.deliveryCarrier = basket.deliveryInfo.carriers.find { $0.available }
                }
                return strongSelf.state
            }
            .observeOn(ConcurrentDispatchQueueScheduler(globalConcurrentQueueQOS: .Background))
            .save(Constants.Persistent.basketStateId, storageManager: storageManager)
            .observeOn(MainScheduler.instance)
            .subscribe { [weak self](event: Event<BasketState>) in
                guard let strongSelf = self else { return }
                
                switch event {
                case .Next(let state):
                    logInfo("Validated basket: \(state.basket)")
                    strongSelf.state.validationState = BasketValidationState(validating: false, validated: true)
                case .Error(let error):
                    logError("Error during basket validation: \(error)")
                    strongSelf.state.validationState = BasketValidationState(validating: false, validated: false)
                default: break
                }
        }.addDisposableTo(disposeBag)
    }
    
    func addToBasket(product: BasketProduct, of brand: BasketBrand) {
        logInfo("Adding to basket \(product), brandId \(brand.id)")
        guard state.basket?.isPossibleToAddProduct(product, of: brand, maxProductAmount: Constants.basketProductAmountLimit) ?? false else {
            logInfo("It is not possible to add product to basket")
            return
        }
        state.basket?.add(product, of: brand)
        validate()
    }
    
    func removeFromBasket(product: BasketProduct) {
        logInfo("Removing from basket \(product)")
        state.basket?.remove(product)
        validate()
    }
    
    func updateInBasket(product: BasketProduct) {
        logInfo("Updating product in basket \(product)")
        if (product.amount == 0) {
            state.basket?.remove(product)
        } else {
            state.basket?.update(product)
        }
        validate()
    }
    
    func clearBasket() {
        logInfo("Clearing basket")
        state.clear()
        validate()
    }
    
    func isInBasket(brand: BasketBrand) -> Bool {
        return state.basket?.productsByBrands.contains { brand.id == $0.id } ?? false
    }
    
    func isInBasket(product: BasketProduct) -> Bool {
        return state.basket?.productsByBrands.contains { $0.products.contains({ $0.isEqualInBasket(to: product) }) } ?? false
    }
    
    func isInBasket(product: ProductDetails) -> Bool {
        return state.basket?.productsByBrands.contains { $0.products.contains { $0.id == product.id } } ?? false
    }
    
    func createCheckout() -> Checkout? {
        guard let user = userManager.user else {
            logInfo("Cannot create checkout, no user")
            return nil
        }
        return Checkout.from(basketState: state, user: user)
    }
    
    func createBasketProductListContext(initialIndexPath: NSIndexPath, onChangedForIndexPath: NSIndexPath -> ()) -> ProductDetailsContext? {
        guard let basket = state.basket else {
            logError("Cannot create context, basket does not exist")
            return nil
        }
        
        guard let initialProduct = basket.productsByBrands[safe: initialIndexPath.section]?.products[safe: initialIndexPath.row] else {
            logError("Cannot find initial product \(initialIndexPath), productsByBrands \(basket.productsByBrands)")
            return nil
        }
        
        var productTuples: [(product: BasketProduct, brand: BasketBrand)] = [] // basketBrand is needed for parsing to Product
        for basketBrand in basket.productsByBrands {
            for basketProduct in basketBrand.products {
                productTuples.append((basketProduct, basketBrand))
            }
        }
        
        let initialIndex = productTuples.indexOf { $0.product.isEqualInBasket(to: initialProduct) }
        guard let index = initialIndex else {
            logError("Cannot find initial index \(productTuples), \(initialProduct)")
            return nil
        }
        
        let onRetrieveProductInfo: Int -> ProductInfo = { index in
            logInfo("Retreving productTuple for index \(index)")
            let productTuple = productTuples[index]
            return ProductInfo.Object(productTuple.product.toProduct(productTuple.brand))
        }
        
        let onChanged: Int -> () = { index in
            logInfo("Changed product with index \(index)")
            let productTuple = productTuples[index]
            let section = basket.productsByBrands.indexOf(productTuple.brand)
            let row = productTuple.brand.products.indexOf(productTuple.product)
            guard let s = section, let r = row else {
                logError("Cannot create indexPath from \(section) \(row) \(index)")
                return
            }
            onChangedForIndexPath(NSIndexPath(forRow: r, inSection: s))
        }
        
        return OnePageProductDetailsContext(productsCount: productTuples.count, initialProductIndex: index, fromType: .Basket,onChanged: onChanged, onRetrieveProductInfo: onRetrieveProductInfo)
    }
}

struct BasketValidationState {
    let validating: Bool
    let validated: Bool
}

final class BasketState {
    let basketObservable = PublishSubject<Basket?>()
    let deliveryCountryObservable = PublishSubject<DeliveryCountry?>()
    let deliveryCarrierObservable = PublishSubject<DeliveryCarrier?>()
    let validationStateObservable = PublishSubject<BasketValidationState>()
    
    private(set) var basket: Basket? {
        didSet { basketObservable.onNext(basket) }
    }
    var discountCode: String?
    var deliveryCountry: DeliveryCountry? {
        didSet { deliveryCountryObservable.onNext(deliveryCountry) }
    }
    var deliveryCarrier: DeliveryCarrier? {
        didSet { deliveryCarrierObservable.onNext(deliveryCarrier) }
    }
    var validationState = BasketValidationState(validating: false, validated: false) {
        didSet { validationStateObservable.onNext(validationState) }
    }
    
    private func clear() {
        basket = nil
        discountCode = nil
        deliveryCountry = nil
        deliveryCarrier = nil
    }
}

extension BasketState {
    private func createRequest() -> BasketRequest {
        return BasketRequest(from: basket, countryCode: deliveryCountry?.id, deliveryType: deliveryCarrier?.id, discountCode: discountCode, deliveryPop: nil)
    }
}

// MARK:- Encodable, Decodable

extension BasketState: Encodable, Decodable {
    static func decode(json: AnyObject) throws -> BasketState {
        let state = BasketState()
        state.basket = try json => "basket"
        state.discountCode = try json =>? "discount_code"
        state.deliveryCountry = try json =>? "delivery_country"
        state.deliveryCarrier = try json =>? "delivery_carrier"
        return state
    }
    
    func encode() -> AnyObject {
        let dict: NSMutableDictionary = [:]
        if basket != nil { dict.setObject(basket!.encode(), forKey: "basket") }
        if discountCode != nil { dict.setObject(discountCode!, forKey: "discount_code") }
        if deliveryCountry != nil { dict.setObject(deliveryCountry!.encode(), forKey: "delivery_country") }
        if deliveryCarrier != nil { dict.setObject(deliveryCarrier!.encode(), forKey: "delivery_carrier") }
        return dict
    }
}