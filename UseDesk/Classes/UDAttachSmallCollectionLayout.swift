//
//  UDAttachSmallCollectionLayout.swift
//  UseDesk_SDK_Swift
//

import UIKit

protocol UDAttachSmallCollectionLayoutDelegate: AnyObject {
    func sizeCell() -> CGSize
}

class UDAttachSmallCollectionLayout: UICollectionViewFlowLayout {

    private var attributes: [UICollectionViewLayoutAttributes] = []
    private let cellPadding: CGFloat = 8
    
    weak var delegate: UDAttachSmallCollectionLayoutDelegate?

    override var collectionViewContentSize: CGSize {
        let sizeCell = delegate?.sizeCell()
        let contentHeight: CGFloat = sizeCell?.height ?? 85
        var contentWidthSumm: CGFloat = cellPadding
        for attribut in attributes {
            contentWidthSumm += attribut.frame.width + cellPadding
        }
        if contentWidthSumm == 0 {
            return CGSize(width: 0, height: contentHeight)
        } else {
            return CGSize(width: contentWidthSumm, height: contentHeight)
        }
    }

    override func prepare() {
        let sizeCell = delegate?.sizeCell()
        let contentHeight: CGFloat = sizeCell?.height ?? 85
        let contentWidth: CGFloat = sizeCell?.width ?? 85
        guard let collectionView = collectionView else { return }
        var xOffset: CGFloat = 8
        let yOffset: CGFloat = 0
        attributes = []
        for item in 0..<collectionView.numberOfItems(inSection: 0) {
            let indexPath = IndexPath(item: item, section: 0)

            let frame = CGRect(x: xOffset,
                             y: yOffset,
                             width: contentWidth,
                             height: contentHeight)

            let attributesItem = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            attributesItem.frame = frame
            attributes.append(attributesItem)

            xOffset += contentWidth + 8
        }
    }

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var visibleLayoutAttributes: [UICollectionViewLayoutAttributes] = []
        for attribut in attributes {
          if attribut.frame.intersects(rect) {
            visibleLayoutAttributes.append(attribut)
          }
        }
        return visibleLayoutAttributes
    }

    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return attributes[indexPath.item]
    }
}

