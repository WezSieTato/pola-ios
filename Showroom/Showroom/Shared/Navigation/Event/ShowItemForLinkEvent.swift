import Foundation

struct ShowItemForLinkEvent: NavigationEvent {
    let link: String
    let title: String?
    let productDetailsFromType: ProductDetailsFromType?
}
