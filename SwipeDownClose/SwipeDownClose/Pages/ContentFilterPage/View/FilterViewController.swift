//
//  FilterViewController.swift
//  SwipeDownClose
//
//  Created by 이아연 on 2021/07/07.
//

import UIKit
import RxSwift
import RxDataSources
import RxGesture

protocol FilterViewDelegate : AnyObject {
    func selectFilter(mode: FilterCategoryType?, _ filterStr : [String])
    func resetOneCategoryFilter(mode : FilterCategoryType?, _ filterStr : [String])
}

class FilterViewController: UIViewController {
    
    private var disposeBag = DisposeBag()
    private var viewModel : FilterViewModel
    weak var filterDelegate : FilterViewDelegate?
    
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var resetBtn: UIButton!
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.register(UINib(nibName: "FilterTableViewCell", bundle: nil), forCellReuseIdentifier: "FilterTableViewCell")
        }
    }
   
    init(viewModel : FilterViewModel) {
        self.viewModel = viewModel
        super.init(nibName: "FilterViewController", bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupView()
        self.bindView()
       
    }
}

extension FilterViewController {
    
    func setupView() {
        if #available(iOS 11.0, *) {
            headerView.roundCorners(cornerRadius: 15, maskedCorners: [.layerMinXMinYCorner, .layerMaxXMinYCorner])
        } else {
            headerView.roundCorners(cornerRadius: 15, byRoundingCorners: [.topLeft, .topRight])
        }
        
        categoryLabel.text = viewModel.filterMode.rawValue
    }
    
    func bindView() {
        
        viewModel.items
            .bind(to: tableView.rx.items(cellIdentifier : "FilterTableViewCell", cellType: FilterTableViewCell.self)){ indexPath, item, cell in
                
                cell.selectedList = self.viewModel.selectedList
                cell.listText = item
            }.disposed(by: disposeBag)
        
        
        tableView.rx.modelSelected(String.self)
            .subscribe(onNext: { [weak self] model in
                guard let self = self else {return}
        
                var selectedList = self.getSelectedListExceptCurrenCategory()
                selectedList.append(model)
                
                self.filterDelegate?.selectFilter(mode: self.viewModel.filterMode, selectedList)
                self.dismiss(animated: true)
            })
            .disposed(by: disposeBag)
        
        
        resetBtn.rx.tap
            .asDriver()
            .drive(onNext: { [weak self] in
                guard let self = self else {return}
                
                let selectedList = self.getSelectedListExceptCurrenCategory()
                
                self.filterDelegate?.resetOneCategoryFilter(mode: self.viewModel.filterMode, selectedList)
                self.dismiss(animated: true)
            })
            .disposed(by: disposeBag)
        
        
        backView.rx
            .tapGesture()
            .when(.recognized)
            .subscribe(onNext: { [weak self] _ in
                self?.dismiss(animated: true)
            })
            .disposed(by: disposeBag)
    }
    
    
    private func getSelectedListExceptCurrenCategory() -> [String] {
        let list = self.viewModel.filterMode.getFilterList()

        let selectedList = self.viewModel.selectedList.filter{
            !list.contains($0)
        }
        
        return selectedList
    }
}
