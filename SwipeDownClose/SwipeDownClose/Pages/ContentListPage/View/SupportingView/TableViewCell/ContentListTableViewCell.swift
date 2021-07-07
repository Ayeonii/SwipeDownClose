//
//  ContentListTableViewCell.swift
//  SwipeDownClose
//
//  Created by 이아연 on 2021/07/07.
//

import UIKit
import Kingfisher
import RxSwift
import RxGesture

protocol ContentListTableViewCellDelegate : AnyObject {
    func goDetail(imageUrl : String, description : String)
}

class ContentListTableViewCell: UITableViewCell {
    
    private var disposeBag = DisposeBag()
    weak var cellDelegate : ContentListTableViewCellDelegate?
    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var nickName: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var contentImage: UIImageView!
    
    var model : ContentsListCellModel? {
        didSet {
            if let data = model {
                self.profileImage.kf.setImage(with: URL(string :data.profileImageUrl)!, options: [.transition(.fade(0.4))])
                self.contentImage.kf.setImage(with: URL(string :data.imageUrl)!, options: [.transition(.fade(0.4))])
                self.nickName.text = data.nickName
                self.descLabel.text = data.description
              
                DispatchQueue.main.async {
                    if self.descLabel.isTruncated {
                        let desc = data.description
                        self.descLabel.setMoreText(description: desc, moreText: "...더보기", moreTextColor: .gray)
                    }
                }
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        makeAspectFill(profileImage)
        makeAspectFill(contentImage)
        
        bindEvent()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.descLabel.isUserInteractionEnabled = false
        self.profileImage.image = UIImage(named : "")
        self.contentImage.image = UIImage(named : "")
    }
}

extension ContentListTableViewCell {
    
    func makeAspectFill(_ image : UIImageView) {
        image.contentMode = .scaleAspectFill
        image.clipsToBounds = true
    }
    
    func bindEvent() {
        contentImage.rx
            .tapGesture()
            .when(.recognized)
            .subscribe(onNext: { [weak self] _ in
                self?.goDetail()
            })
            .disposed(by: disposeBag)
        
        descLabel.rx
            .tapGesture()
            .when(.recognized)
            .subscribe(onNext: { [weak self] _ in
                self?.goDetail()
            })
            .disposed(by: disposeBag)
        
        self.descLabel.isUserInteractionEnabled = false
       
    }
    
    func goDetail(){
        guard let data = model else {return}
        cellDelegate?.goDetail(imageUrl: data.imageUrl, description: data.description)
    }
}
