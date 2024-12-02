//
//  FilterCustomLayout.swift
//  Satender Task
//
//  Created by Satender Dagar on 01/12/24.
//

import UIKit

class FilterCustomLayout: UICollectionViewFlowLayout, UICollectionViewDelegateFlowLayout {
    
    required override init() {super.init(); common()}
    required init?(coder aDecoder: NSCoder) {super.init(coder: aDecoder); common()}
    
    private func common() {
        estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        minimumLineSpacing = 10
        minimumInteritemSpacing = 10
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        
        guard let attributes = super.layoutAttributesForElements(in:rect) else {
            return []
        }
        var leftMargin: CGFloat = sectionInset.left
        var y: CGFloat = -1.0
        
        for attribute in attributes {
            if attribute.representedElementCategory != .cell { continue }
            
            if attribute.frame.origin.y >= y {
                leftMargin = sectionInset.left
            }
            attribute.frame.origin.x = leftMargin
            leftMargin += attribute.frame.width + minimumInteritemSpacing
            y = attribute.frame.maxY
        }
        
        return attributes
    }
}
