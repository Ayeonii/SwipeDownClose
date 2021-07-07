//
//  FilterCategoryCollectionViewCell.swift
//  SwipeDownClose
//
//  Created by 이아연 on 2021/07/07.
//

import UIKit
import RxSwift
import RxCocoa


protocol FilterCategoryCellDelegate : AnyObject {
    func goFilter(mode: FilterCategoryType)
}

class FilterCategoryCollectionViewCell: UICollectionViewCell {
    private var disposebag = DisposeBag()
    weak var categoryDelegate : FilterCategoryCellDelegate?
    
    @IBOutlet weak var buttonMaxWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var filterBtn: UIButton!
    
    var filterMode : FilterCategoryType? {
        didSet {
            if let mode = filterMode {
                let filterName = mode.rawValue
                filterBtn.setTitle(filterName, for: .normal)
                filterBtn.setTitle(filterName, for: .selected)
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
        bindBtn()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        filterBtn.setTitle("", for: .normal)
        filterBtn.setTitle("", for: .selected)
    }
}

extension FilterCategoryCollectionViewCell {
    
    func setupUI() {
        self.layer.cornerRadius = 5
        self.filterBtn.setBackgroundColor(.lightGray, forState: .normal)
        self.filterBtn.setBackgroundColor(.systemTeal, forState: .selected)
        self.filterBtn.setBackgroundColor(.systemTeal.withAlphaComponent(0.7), forState: .highlighted)
    }
    
    func bindBtn(){
        filterBtn.rx.tap
            .bind(onNext: { [weak self] in
                if let mode = self?.filterMode {
                    self?.categoryDelegate?.goFilter(mode: mode)
                }
            })
            .disposed(by: disposebag)
    }
    
    func setMaximumCellWidth(_ width: CGFloat) {
        self.buttonMaxWidthConstraint.constant = width
    }
    
}
