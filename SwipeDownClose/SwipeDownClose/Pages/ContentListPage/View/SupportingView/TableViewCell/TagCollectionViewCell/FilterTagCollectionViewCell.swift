//
//  FilterTagCollectionViewCell.swift
//  SwipeDownClose
//
//  Created by 이아연 on 2021/07/07.
//
import UIKit
import RxSwift
import RxCocoa

class FilterTagCollectionViewCell: UICollectionViewCell {
    private var disposebag = DisposeBag()
    private var horizontalPadding: CGFloat = 32
   
    @IBOutlet weak var labelMaxWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var btnDel: UIButton!
    
    var deleteCompletion : ((_ str : String)->Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.cornerRadius = 15
        self.bindUI()
    }
}

extension FilterTagCollectionViewCell {
    
    func bindUI() {
        btnDel.rx.tap
            .asDriver()
            .drive(onNext: { [weak self] in
                let tagStr = self?.label.text ?? ""
                self?.deleteCompletion?(tagStr)
            })
            .disposed(by: disposebag)
    }
    
    
    func setMaximumCellWidth(_ width: CGFloat) {
        self.labelMaxWidthConstraint.constant = width - horizontalPadding
    }
    
}
