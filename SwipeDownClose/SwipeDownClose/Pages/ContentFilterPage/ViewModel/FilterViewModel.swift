//
//  FilterViewModel.swift
//  SwipeDownClose
//
//  Created by 이아연 on 2021/07/07.
//
import Foundation
import RxSwift
import RxDataSources


struct FilterViewModel {
    var filterMode : FilterCategoryType
    var items : Observable<[String]>
    var selectedList : [String]
    
    init(mode : FilterCategoryType, selectedFilter : [String]) {
        filterMode = mode
        items = Observable<[String]>.of(mode.getFilterList())
        selectedList = selectedFilter
    }
}
