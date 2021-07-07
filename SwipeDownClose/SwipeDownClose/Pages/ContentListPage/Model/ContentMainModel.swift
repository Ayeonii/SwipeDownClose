//
//  ContentMainModel.swift
//  SwipeDownClose
//
//  Created by 이아연 on 2021/07/07.
//

import RxDataSources

struct ContentsFilterSectionModel {
    var selectedFilterTag : [String]
    
    init(filterName : [String]) {
        self.selectedFilterTag = filterName
    }
}

struct ContentsListSectionModel {
    var dataList : [ContentsListCellModel] = []
    
    init(_ data :ContentListCodable? = nil) {
        if let res = data {
            res.base?.forEach {
                dataList.append(ContentsListCellModel($0))
            }
        }
    }
}

struct ContentsListCellModel{
    var id : Int?
    var imageUrl : String
    var nickName : String
    var profileImageUrl : String
    var description : String
    
    init(_ data : ContentListData?) {
        self.id = data?.id
        self.imageUrl = data?.image_url ?? ""
        self.nickName = data?.nickname ?? ""
        self.profileImageUrl = data?.profile_image_url ?? ""
        self.description = data?.description ?? ""
    }
}



// MARK: - DataSources
struct ContentsMainSectionItem : IdentifiableType, Equatable {
    typealias Identity = String
    
    var identity: Identity {
        return UUID().uuidString
    }
    
    public let filterSectionItem : ContentsFilterSectionModel?
    public let contentsSectionItem : ContentsListCellModel?
    
    init(filterSectionItem : ContentsFilterSectionModel) {
        self.filterSectionItem = filterSectionItem
        self.contentsSectionItem = nil
    }
    
    init(contentsSectionItem : ContentsListCellModel) {
        self.filterSectionItem = nil
        self.contentsSectionItem = contentsSectionItem
    }
    
    static func == (lhs: ContentsMainSectionItem, rhs: ContentsMainSectionItem) -> Bool {
        return lhs.identity == rhs.identity
    }
}

enum ContentsMainSectionModel {
    case FirstSection(content : [ContentsMainSectionItem])
    case SecondSection(content : [ContentsMainSectionItem])
}

extension ContentsMainSectionModel : AnimatableSectionModelType {
    typealias Identity = Int
    
    var identity : Identity {
        return Int.random(in: 0..<20000)
    }
    
    typealias Item = ContentsMainSectionItem
    
    var items : [Item] {
        switch self {
        case let .FirstSection(content) :
            return content
        case let .SecondSection(content) :
            return content
        }
    }
    
    init(original: ContentsMainSectionModel, items: [ContentsMainSectionItem]) {
        self = original
    }
}


struct ContentsMainDataSource {
    typealias DataSource = RxTableViewSectionedAnimatedDataSource
    
    static func dataSource(vc : UIViewController) -> DataSource<ContentsMainSectionModel> {
        return .init(animationConfiguration: AnimationConfiguration(insertAnimation: .none, reloadAnimation: .none, deleteAnimation: .fade),
                     configureCell: { dataSource, tableView, indexPath, sectionItem -> UITableViewCell in
            let sectionItem = dataSource[indexPath]
            
            if let filter = sectionItem.filterSectionItem {
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "FilterTagTableViewCell",for: indexPath) as? FilterTagTableViewCell else  { fatalError("cell not Exists!") }
                
                cell.cellDelgate = vc as? FilterTagCellDelegate
                cell.tagList = filter.selectedFilterTag
                return cell
            }
               
            if let contents = sectionItem.contentsSectionItem {
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "ContentListTableViewCell",for: indexPath) as? ContentListTableViewCell else  { fatalError("cell not Exists!") }
                
                cell.cellDelegate = vc as? ContentListTableViewCellDelegate
                cell.model = contents
                
                return cell
            }
            
            return UITableViewCell()
        })
    }
}
