//
//  ContentMainViewController.swift
//  SwipeDownClose
//
//  Created by 이아연 on 2021/07/07.
//

import UIKit
import RxSwift
import RxCocoa

class ContentMainViewController: UIViewController {
    
    private var flowLayout : UICollectionViewFlowLayout?
    private var sizingCell : FilterCategoryCollectionViewCell?
    private var viewModel : ContentMainViewModel?
    private var disposeBag = DisposeBag()
    private var isPaging = false
    
    
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.register(UINib(nibName: "FilterTagTableViewCell", bundle: nil), forCellReuseIdentifier: "FilterTagTableViewCell")
            tableView.register(UINib(nibName: "ContentListTableViewCell", bundle: nil), forCellReuseIdentifier: "ContentListTableViewCell")
        }
    }
    
    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            flowLayout = UICollectionViewFlowLayout()
            flowLayout?.minimumInteritemSpacing = 10
            flowLayout?.minimumLineSpacing = 10
            flowLayout?.sectionInset = UIEdgeInsets.init(top: 5, left: 16, bottom: 5, right: 16)
            collectionView.collectionViewLayout = flowLayout ?? UICollectionViewFlowLayout()
            
            let cellNib = UINib(nibName: "FilterCategoryCollectionViewCell", bundle: nil)
            
            collectionView.register(cellNib, forCellWithReuseIdentifier: "FilterCategoryCollectionViewCell")
            sizingCell = (cellNib.instantiate(withOwner: nil, options: nil) as NSArray).firstObject as! FilterCategoryCollectionViewCell?
        }
    }
   
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel = ContentMainViewModel(self)
        bindTableView()
        bindCollectionView()
    }
}

extension ContentMainViewController {
   
    func bindTableView(){
        
        tableView.rx.setDelegate(self)
            .disposed(by: disposeBag)
    
        viewModel?.mainSectionSubject
            .debug()
            .bind(to:
                tableView.rx.items(dataSource: viewModel!.dataSource)
            )
            .disposed(by: disposeBag)
        
        viewModel?.mainSectionSubject
            .asDriver(onErrorJustReturn: [])
            .drive(onNext: { [weak self] _ in
                
                guard let self = self else { return }
                
                if self.isPaging {
                    self.isPaging = false
                } else {
                    let indexPath = NSIndexPath(row: NSNotFound, section: 0)
                    self.tableView?.scrollToRow(at: indexPath as IndexPath, at: .top, animated: true)
                }
            })
            .disposed(by: disposeBag)
        
    }
    
    func bindCollectionView() {
        collectionView.rx.setDelegate(self)
            .disposed(by: disposeBag)
    
        viewModel?.filterSubject
            .asObserver()
            .bind(to : collectionView.rx.items(
                    cellIdentifier: "FilterCategoryCollectionViewCell",
                    cellType: FilterCategoryCollectionViewCell.self)
            ){ [weak self] indexPath, data, cell in
                cell.categoryDelegate = self
                cell.filterMode = data
                cell.filterBtn.isSelected = self?.viewModel?.isSelctedFilterMode(data) ?? false
            }
            .disposed(by: disposeBag)
    
    }
}

extension ContentMainViewController : UITableViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        
        let contentHeight = scrollView.contentSize.height
        if offsetY >= contentHeight - (scrollView.frame.height){
            if !isPaging  {
                isPaging = true
                self.viewModel?.callDataAPI()
            }
        }
    }
}

extension ContentMainViewController : UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView,layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        sizingCell?.setMaximumCellWidth(collectionView.frame.width)
        sizingCell?.filterMode = viewModel?.filterCategory[indexPath.item]

        let sizingCellSize = sizingCell?.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize) ?? CGSize.zero
        let width = sizingCellSize.width + 20
        let height = sizingCellSize.height + 10

        return CGSize(width: width, height: height)
    }
}

extension ContentMainViewController : ContentListTableViewCellDelegate {
    func goDetail(imageUrl: String, description: String) {
        let vc = ContentDetailViewController(imageUrl: imageUrl, description: description)
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension ContentMainViewController : FilterCategoryCellDelegate {
    func goFilter(mode: FilterCategoryType) {
        
        let filterVM = FilterViewModel(mode: mode, selectedFilter: viewModel?.selectedFilter ?? [])
        let filterVC = FilterViewController(viewModel:filterVM)
        
        filterVC.modalPresentationStyle = .custom
        filterVC.filterDelegate = self
        filterVC.transitioningDelegate = self
        self.present(filterVC, animated: true)
    }
}

extension ContentMainViewController : FilterTagCellDelegate {
    func deleteTag(_ filterIndex : Int) {
        let deleteStr = viewModel?.selectedFilter[filterIndex] ?? ""
        viewModel?.deleteFilterCategoryByString(deleteStr)
        viewModel?.deleteFilterByString(deleteStr)
    }
}

extension ContentMainViewController : FilterViewDelegate {
    func selectFilter(mode : FilterCategoryType?, _ filterStr: [String]) {

        if let mode = mode {
            viewModel?.deleteFilterCategoryByString(filterStr.last ?? "")
            viewModel?.selectedFilterCategory.append(mode)
            viewModel?.selectedFilter = filterStr
        }
    }
    
    func resetOneCategoryFilter(mode : FilterCategoryType?, _ filterStr : [String]) {
        if let mode = mode {
            viewModel?.deleteFilterCategory(mode)
            viewModel?.selectedFilter = filterStr
        }
    }
}

