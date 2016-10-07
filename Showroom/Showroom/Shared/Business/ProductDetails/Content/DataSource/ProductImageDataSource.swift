import Foundation
import UIKit

enum ProductImageDataSourceState {
    case Default
    case FullScreen
}

final class ProductImageDataSource: NSObject, UICollectionViewDataSource {
    private weak var collectionView: UICollectionView?
    var lowResImageUrl: String?
    var imageUrls: [String] = [] {
        didSet {
            guard oldValue.count != 0 else {
                collectionView?.reloadData()
                return
            }
            if let cell = collectionView?.cellForItemAtIndexPath(NSIndexPath(forItem: 0, inSection: 0)) as? ProductImageCell where oldValue[0] != imageUrls[0] {
                loadImageForFirstItem(imageUrls[0], forCell: cell)
            }
            
            guard imageUrls.count > 1 else { return }
            
            var reloadIndexPaths: [NSIndexPath] = []
            var deleteIndexPaths: [NSIndexPath] = []
            var insertIndexPaths: [NSIndexPath] = []
            
            let maxCommonCount = min(oldValue.count, imageUrls.count)
            if maxCommonCount > 1 {
                for index in 1...(maxCommonCount - 1) {
                    if oldValue[index] != imageUrls[index] {
                        reloadIndexPaths.append(NSIndexPath(forItem: index, inSection: 0))
                    }
                }
            }
            
            if imageUrls.count > oldValue.count {
                for index in oldValue.count...(imageUrls.count - 1) {
                    insertIndexPaths.append(NSIndexPath(forItem: index, inSection: 0))
                }
            } else if imageUrls.count < oldValue.count {
                for index in imageUrls.count...(oldValue.count - 1) {
                    deleteIndexPaths.append(NSIndexPath(forItem: index, inSection: 0))
                }
            }
            
            if reloadIndexPaths.isEmpty && deleteIndexPaths.isEmpty && insertIndexPaths.isEmpty {
                return
            }
            
            collectionView?.performBatchUpdates({
                self.collectionView?.insertItemsAtIndexPaths(insertIndexPaths)
                self.collectionView?.reloadItemsAtIndexPaths(reloadIndexPaths)
                self.collectionView?.deleteItemsAtIndexPaths(deleteIndexPaths)
                }, completion: nil)
            
        }
    }
    var state: ProductImageDataSourceState = .Default {
        didSet {
            guard let collectionView = collectionView else { return }
            let visibleCells = collectionView.visibleCells() as! [ProductImageCell]
            for cell in visibleCells {
                cell.fullScreenMode = state == .FullScreen
            }
        }
    }
    var highResImageVisible: Bool = true {
        didSet {
            guard let collectionView = collectionView else { return }
            for cell in collectionView.visibleCells() {
                if let cell = cell as? ProductImageCell {
                    cell.imageView.alpha = highResImageVisible ? 1 : 0
                }
            }
        }
    }
    weak var productPageView: ProductPageView?
    
    init(collectionView: UICollectionView) {
        super.init()
        
        self.collectionView = collectionView
        collectionView.registerClass(ProductImageCell.self, forCellWithReuseIdentifier: String(ProductImageCell))
    }
    
    func highResImage(forIndex index: Int) -> UIImage? {
        if let cell = collectionView?.cellForItemAtIndexPath(NSIndexPath(forItem: index, inSection: 0)) as? ProductImageCell {
            return cell.imageView.image
        }
        return nil
    }
    
    func scrollToImage(atIndex index: Int) {
        collectionView?.scrollToItemAtIndexPath(NSIndexPath(forItem: index, inSection: 0), atScrollPosition: .Top, animated: true)
    }
    
    private func loadImageForFirstItem(imageUrl: String, forCell cell: ProductImageCell) {
        let onRetrieveFromCache: (UIImage?) -> () = { image in
            cell.contentViewSwitcher.changeSwitcherState(image == nil ? .Loading : .Success, animated: false)
        }
        
        let onFailure: (NSError?) -> () = { [weak self] error in
            logInfo("Failed to download image \(error)")
            self?.productPageView?.didDownloadFirstImage(withSuccess: false)
        }
        
        let onSuccess: (UIImage) -> () = { [weak self] image in
            self?.productPageView?.didDownloadFirstImage(withSuccess: true)
            cell.contentViewSwitcher.changeSwitcherState(.Success)
        }
        
        cell.imageView.loadImageWithLowResImage(imageUrl, lowResUrl: lowResImageUrl, width: cell.bounds.width, onRetrievedFromCache: onRetrieveFromCache, failure: onFailure, success: onSuccess)
    }
    
    // MARK:- UICollectionViewDataSource
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageUrls.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let imageUrl = imageUrls[indexPath.row]
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(String(ProductImageCell), forIndexPath: indexPath) as! ProductImageCell
        cell.fullScreenMode = state == .FullScreen
        cell.imageView.image = nil
        cell.imageView.alpha = highResImageVisible ? 1 : 0
        if indexPath.row == 0 {
            loadImageForFirstItem(imageUrl, forCell: cell)
        } else {
            cell.imageView.loadImageFromUrl(imageUrl, width: cell.bounds.width, onRetrievedFromCache: { (image: UIImage?) in
                cell.contentViewSwitcher.changeSwitcherState(image == nil ? .Loading : .Success, animated: false)
            }) { (image: UIImage) in
                cell.contentViewSwitcher.changeSwitcherState(.Success)
            }
        }
        
        return cell
    }
}
