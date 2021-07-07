//
//  ContentMainViewModel.swift
//  SwipeDownClose
//
//  Created by 이아연 on 2021/07/07.
//

import Foundation
import RxSwift
import RxDataSources

enum FilterCategoryType : String {
    case order = "정렬"
    case space = "주거형태"
    case residence = "공간"
    
    func getFilterList() -> [String] {
        switch self {
        case .order :
            return ["최신순", "베스트", "인기순"]
        case .space :
            return ["거실", "침실", "주방", "욕실"]
        case .residence :
            return ["아파트", "빌라&연립", "단독주택", "사무공간"]
        }
    }
    
}

class ContentMainViewModel {
    private var disposeBag = DisposeBag()

    let dataSource : RxTableViewSectionedAnimatedDataSource<ContentsMainSectionModel>
    let mainSectionSubject = PublishSubject<[ContentsMainSectionModel]>()
   
    
    let filterCategory : [FilterCategoryType] = [.order, .space, .residence]
    let filterSubject = BehaviorSubject<[FilterCategoryType]>(value: [.order, .space, .residence])
    
    var selectedFilterCategory : [FilterCategoryType] = []
    var selectedFilter : [String] = [] {
        didSet {
            callDataAPI()
            filterSubject.onNext(filterCategory)
        }
    }
    
    init(_ vc : UIViewController) {
        dataSource = ContentsMainDataSource.dataSource(vc: vc)
        callDataAPI()
    }
    
    func isSelctedFilterMode(_ filterItem : FilterCategoryType) -> Bool {
        if selectedFilterCategory.contains(filterItem) {
            return true
        }
        return false
    }
    
    func deleteFilterCategoryByString(_ str : String) {
        selectedFilterCategory = selectedFilterCategory.filter{
            !$0.getFilterList().contains(str)
        }
    
    }
    
    func deleteFilterByString(_ str : String) {
        selectedFilter = selectedFilter.filter{
            $0 != str
        }
    
    }
    
    func deleteFilterCategory(_ category : FilterCategoryType) {
        selectedFilterCategory = selectedFilterCategory.filter{
            $0 != category
        }
    }

}

extension ContentMainViewModel {
    
    func callDataAPI() {
        //추후 필터 선택에 따른 request 추가하기
        
        CallJsonData.callContentList()
            .retry(2)
            .subscribe(onNext: { [weak self] data in
                guard let self = self else { return }
                self.emitEvent(res : data.base)
            },
            onError: { error in
                print(error)
            },
            onCompleted: {
                debugPrint("completed")
            })
            .disposed(by: disposeBag)
    }
    
    private func emitEvent(res : [ContentListData]?) {
        guard let data = res else {return}
        var cellModels : [ContentsMainSectionModel] = []
        if !self.selectedFilter.isEmpty {
            cellModels.append(
                ContentsMainSectionModel.FirstSection(content: [
                    ContentsMainSectionItem(filterSectionItem : ContentsFilterSectionModel(filterName: self.selectedFilter))
                ])
            )
        }
        
        let contentsCell = data.map {
            ContentsMainSectionItem(contentsSectionItem: ContentsListCellModel($0))
        }
        
        cellModels.append(
            ContentsMainSectionModel.SecondSection(content: contentsCell)
        )
        self.mainSectionSubject.onNext(cellModels)
        
    }
}
 
