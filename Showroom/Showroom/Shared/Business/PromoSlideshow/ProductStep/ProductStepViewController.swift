import Foundation
import UIKit

final class ProductStepViewController: ProductPageViewController, ProductPageViewControllerDelegate, ProductPagePreviewOverlayViewDelegate, PromoPageInterface {
    weak var pageDelegate: PromoPageDelegate?
    
    private weak var previewOverlay: ProductPagePreviewOverlayView?
    private let timer: Timer
    
    init(with resolver: DiResolver, product: PromoSlideshowProduct, duration: Int) {
        self.timer = Timer(duration: duration, stepInterval: Constants.promoSlideshowTimerStepInterval)
        super.init(resolver: resolver, productId: product.id, product: Product(product: product), previewMode: true)
        
        delegate = self
        timer.delegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        castView.previewOverlayView = createAndConfigureOverlayView()
        castView.previewMode = true
        
        model.state.productDetailsObservable.subscribeNext { [weak self] _ in
            self?.tryToInformAboutAllDataDownloaded(triggeredByImageDownloaded: false)
        }.addDisposableTo(disposeBag)
    }
    
    override func pageView(pageView: ProductPageView, didDownloadFirstImageWithSuccess success: Bool) {
        super.pageView(pageView, didDownloadFirstImageWithSuccess: success)
        tryToInformAboutAllDataDownloaded(triggeredByImageDownloaded: true)
    }
    
    private func createAndConfigureOverlayView() -> UIView {
        let bottomBarHeight = self.castView.descriptionViewInterface?.headerButtonSectionHeight ?? 0
        logInfo("Creating preview overlay view with bottom bar height \(bottomBarHeight)")
        let view = ProductPagePreviewOverlayView(bottomBarHeight: bottomBarHeight)
        view.update(withWishlistButtonSelected: self.model.isOnWishlist)
        view.delegate = self
        previewOverlay = view
        return view
    }
    
    private func update(withPreviewModeEnabled enabled: Bool) {
        let animationDuration = Constants.promoSlideshowStateChangedAnimationDuration
        
        castView.update(withPreviewModeEnabled: enabled, animationDuration: animationDuration)
        previewOverlay?.update(withEnabled: enabled, animationDuration: animationDuration)
        pageDelegate?.promoPage(self, willChangePromoPageViewState: enabled ? .Close : .Paused, animationDuration: animationDuration)
        if enabled {
            timer.play()
        } else {
            timer.pause()
        }
    }
    
    private func tryToInformAboutAllDataDownloaded(triggeredByImageDownloaded triggeredByImageDownloaded: Bool) {
        var shouldInform = false
        if triggeredByImageDownloaded {
            shouldInform = model.state.productDetails != nil
        } else {
            shouldInform = castView.firstImageDownloaded && model.state.productDetails != nil
        }
        if shouldInform {
            pageDelegate?.promoPageDidDownloadAllData(self)
        }
    }
    
    // MARK:- PromoPageInterface
    
    func didTapPlay() {
        logInfo("Did tap play, previewOverlay \(previewOverlay)")
        update(withPreviewModeEnabled: true)
    }
    
    func didTapDismiss() {
        logInfo("Did tap dismiss")
        dismissContentView()
    }
    
    func pageLostFocus(with reason: PromoFocusChangeReason) {
        logInfo("ProductStep lost focus")
        if reason == .AppForegroundChanged {
            pageDelegate?.promoPage(self, willChangePromoPageViewState: .Paused, animationDuration: Constants.promoSlideshowStateChangedAnimationDuration)
        }
        timer.pause()
    }
    
    func pageGainedFocus(with reason: PromoFocusChangeReason) {
        logInfo("ProductStep gained focus \(reason)")
        if reason == .AppForegroundChanged {
            pageDelegate?.promoPage(self, willChangePromoPageViewState: .Close, animationDuration: Constants.promoSlideshowStateChangedAnimationDuration)
        }
        timer.play()
    }
    
    // MARK:- ProductPagePreviewOverlayViewDelegate
    
    func previewOverlayDidTapOverlay(previewOverlay: ProductPagePreviewOverlayView) {
        logInfo("Did tap overlay")
        update(withPreviewModeEnabled: false)
    }
    
    func previewOverlayDidTapInfoButton(previewOverlay: ProductPagePreviewOverlayView) {
        logInfo("Did tap info button")
        update(withPreviewModeEnabled: false)
    }
    
    func previewOverlayDidTapWishlistButton(previewOverlay: ProductPagePreviewOverlayView) {
        let state = self.model.switchOnWishlist()
        logInfo("Did tap wishlist, switching to state \(state)")
        previewOverlay.update(withWishlistButtonSelected: state)
    }
    
    // MARK:- ProductPageViewControllerDelegate
    
    func productPage(page: ProductPageViewController, willChangeProductPageViewState newViewState: ProductPageViewState, animationDuration: Double?) {
        let promoViewState = PromoPageViewState(with: newViewState, overlayEnabled: previewOverlay?.enabled ?? true)
        pageDelegate?.promoPage(self, willChangePromoPageViewState: promoViewState, animationDuration: animationDuration)
    }
}

extension ProductStepViewController: TimerDelegate {
    func timerDidEnd(timer: Timer) {
        pageDelegate?.promoPageDidFinished(self)
    }
    
    func timer(timer: Timer, didChangeProgress progress: Double) {
        pageDelegate?.promoPage(self, didChangeCurrentProgress: progress)
    }
}

extension PromoPageViewState {
    init(with state: ProductPageViewState, overlayEnabled: Bool) {
        switch state {
        case .Default, .ContentHidden:
            self = overlayEnabled ? .Close : .Paused
        case .ContentExpanded:
            self = .Dismiss
        case .ImageGallery:
            self = .FullScreen
        }
    }
}

extension Product {
    init(product: PromoSlideshowProduct) {
        self.id = product.id
        self.basePrice = product.basePrice
        self.brand = product.brand.name
        self.imageUrl = product.imageUrl
        self.name = product.name
        self.price = product.price
        self.lowResImageUrl = nil
    }
}