//
//  FastPanel.swift
//  Fastboard
//
//  Created by xuyunshi on 2021/12/31.
//

import Foundation
import Whiteboard

public class FastPanel {
    public init(items: [FastOperationItem]) {
        self.items = items
    }
    var flatItems: [FastOperationItem] {
        return items
            .map {
                (($0 as? SubOpsItem)?.subOps) ?? []
            }
            .flatMap { $0 }
    }
    var items: [FastOperationItem]
    weak var delegate: FastPanelDelegate?
    weak var view: UIView?
    
    func itemWillBeExecution(_ item: FastOperationItem) {
        if let _ = item as? ApplianceItem {
            deselectAll()
        }
        if let _ = item as? SubOpsItem {
            deselectAll()
        }
        delegate?.itemWillBeExecution(fastPanel: self, item: item)
    }
    
    func deselectAll() {
        items.compactMap { $0.associatedView as? UIButton }.forEach { $0.isSelected = false }
    }
    
    func updateStrokeWidth(_ width: Float) {
        let sliderOps = items
            .compactMap { $0 as? SubOpsItem }
            .flatMap { $0.subOps }
            .compactMap { $0 as? SliderOperationItem }
        sliderOps.forEach {
            $0.syncValueToSlider(width)
        }
    }
    
    func updateSelectedColor(_ color: UIColor) {
        let oldTarget = items
            .compactMap { $0 as? SubOpsItem }
            .flatMap { $0.subOps }
            .compactMap { $0 as? ColorItem }
            .first(where: { $0.color == color })

        let colorSubOps = items
            .compactMap { $0 as? SubOpsItem }
            .first(where: { $0.subOps.contains(where: { $0 is ColorItem })})
        
        if let target = oldTarget {
            (target.associatedView as? UIButton)?.isSelected = true
        } else {
            if let colorSubOps = colorSubOps {
                let newItem = ColorItem(color: color)
                colorSubOps.insertItem(newItem)
            }
        }
        
        if let colorSubOps = colorSubOps {
            let targetItem = colorSubOps.subOps
                .compactMap { $0 as? ColorItem }
                .first(where: { $0.color == color })
            if let targetItem = targetItem {
                colorSubOps.selectedColorItem = targetItem
            }
        }
    }
    
    func updateWithApplianceOutside(_ appliance: WhiteApplianceNameKey) {
        deselectAll()
        for item in items {
            if let i = item as? ApplianceItem, i.identifier == appliance.rawValue {
                (i.associatedView as? UIButton)?.isSelected = true
            }
            if let i = item as? SubOpsItem,
               let ids = i.identifier,
               let id = item.identifier,
               ids.contains(id) {
                if let target = i.subOps.first(where: { $0.identifier == appliance.rawValue}) as? ApplianceItem {
                    i.selectedApplianceItem = target
                }
            }
        }
    }
    
    func setup(room: WhiteRoom) -> UIView {
        let views = items.map { item -> UIView in
            item.room = room
            return item.buildView { [weak self] i in
                guard let self = self else { return }
                self.itemWillBeExecution(i)
            }
        }
        let view = ControlBar(direction: .vertical,
                          borderMask: [.layerMaxXMinYCorner, .layerMaxXMaxYCorner],
                          views: views)
        self.view = view
        return view
    }
}
