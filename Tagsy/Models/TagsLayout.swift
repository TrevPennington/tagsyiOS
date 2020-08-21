//
//  TagsLayout.swift
//  Tagsy
//
//  Created by Trevor Pennington on 8/18/20.
//  Copyright © 2020 Trevor Pennington. All rights reserved.
//

import UIKit

class TagsLayout: UICollectionViewFlowLayout {
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let attributes = super.layoutAttributesForElements(in: rect)?.map { $0.copy() as! UICollectionViewLayoutAttributes }

        var leftMargin = sectionInset.left
        var maxY: CGFloat = -1.0
        attributes?.forEach { layoutAttribute in
            guard layoutAttribute.representedElementCategory == .cell else {
                return
            }

            if Int(layoutAttribute.frame.origin.y) >= Int(maxY) || layoutAttribute.frame.origin.x == sectionInset.left {
                leftMargin = sectionInset.left
            }

            if layoutAttribute.frame.origin.x == sectionInset.left {
                leftMargin = sectionInset.left
            }
            else {
                layoutAttribute.frame.origin.x = leftMargin
            }

            leftMargin += layoutAttribute.frame.width + minimumInteritemSpacing
            maxY = max(layoutAttribute.frame.maxY , maxY)
        }

        return attributes
    }
}
