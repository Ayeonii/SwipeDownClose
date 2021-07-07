//
//  FilterTagTableViewCell.swift
//  SwipeDownClose
//
//  Created by 이아연 on 2021/07/07.
//

import UIKit
import RxSwift
import RxDataSources
import RxCocoa

protocol FilterTagCellDelegate : AnyObject {
    func deleteTag(_ filterIndex : Int)
}

class FilterTagTableViewCell: UITableViewCell {
    
    private var disposeBag = DisposeBag()
    private var flowLayout : UICollectionViewFlowLayout?
    private var sizingTagCell: FilterTagCollectionViewCell?
    private let tagSubject = PublishSubject<[String]>()
    
    weak var cellDelgate : FilterTagCellDelegate?
    
    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            flowLayout = UICollectionViewFlowLayout()
            flowLayout?.scrollDirection = .horizontal
            flowLayout?.minimumInteritemSpacing = 10
            flowLayout?.minimumLineSpacing = 10
            flowLayout?.sectionInset = UIEdgeInsets.init(top: 0, left: 16, bottom: 0, right: 16)
            collectionView.collectionViewLayout = flowLayout ?? UICollectionViewFlowLayout()
            
            let cellNib = UINib(nibName: "FilterTagCollectionViewCell", bundle: nil)
            
            collectionView.register(cellNib, forCellWithReuseIdentifier: "FilterTagCollectionViewCell")
            sizingTagCell = (cellNib.instantiate(withOwner: nil, options: nil) as NSArray).firstObject as! FilterTagCollectionViewCell?
        }
    }
    
    var tagList : [String]? {
        didSet {
            tagSubject.onNext(tagList ?? [])
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        setupCollectionView()
    }
}

extension FilterTagTableViewCell {
    func setupCollectionView() {
        collectionView.rx.setDelegate(self)
            .disposed(by: disposeBag)
        
        tagSubject
            .bind(to : collectionView.rx.items(
                    cellIdentifier: "FilterTagCollectionViewCell",
                    cellType: FilterTagCollectionViewCell.self)
            ){ indexPath, data, cell in
                cell.label.text = data
                
                cell.deleteCompletion = { [weak self] str in
                    self?.cellDelgate?.deleteTag(indexPath)
                }
            }.disposed(by: disposeBag)
    }
}

extension FilterTagTableViewCell : UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        sizingTagCell?.setMaximumCellWidth(collectionView.frame.width)
        sizingTagCell?.label.text = tagList?[indexPath.item]
        
        return sizingTagCell!.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
    }
}
