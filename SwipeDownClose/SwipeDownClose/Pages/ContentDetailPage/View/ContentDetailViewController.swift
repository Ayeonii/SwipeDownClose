//
//  ContentDetailViewController.swift
//  SwipeDownClose
//
//  Created by 이아연 on 2021/07/07.
//

import UIKit
import Kingfisher
import RxSwift
import RxGesture

class ContentDetailViewController: UIViewController {
    
    private let disposeBag = DisposeBag()
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var descLabel: UILabel!
    
    let imageUrl : String
    let desc : String
    
    let overImageView = UIImageView()
    let overDescLabel = UILabel()
    let dimmView = UIView()
    let naviView = UIView()
    let tabView = UIView()
    
    var startPoint : CGPoint?
    var isPinching : Bool = false
    
    init(imageUrl : String, description : String) {
        self.desc = description
        self.imageUrl = imageUrl
        super.init(nibName: "ContentDetailViewController", bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindUI()
    }
}

extension ContentDetailViewController {
    
    func setupUI() {
        self.descLabel.text = desc
        
        self.imageView.kf.setImage(with: URL(string :imageUrl), placeholder: UIImage(named:"noImgWidth")!, options: [.transition(.fade(0.4))])
        self.imageView.contentMode = .scaleAspectFill
        self.imageView.layer.masksToBounds = true
        self.imageView.isUserInteractionEnabled = true
    }
    
    func bindUI() {
        self.imageView.rx
            .tapGesture()
            .when(.recognized)
            .subscribe(onNext: { [weak self] _ in
                self?.showImageDetailView()
            })
            .disposed(by: disposeBag)
        
        self.overImageView.rx
            .panGesture()
            .when(.began, .changed, .ended)
            .subscribe(onNext: { [weak self] pan in

                switch pan.state {
                case .began :
                    self?.beginPanGesture(pan)
                case .changed :
                    self?.changingPanGesture(pan)
                case .ended :
                    if self?.isPinching == false {
                        self?.closeImageDetailView(pan)
                    }
                default :
                    break
                }
            })
            .disposed(by: disposeBag)

        self.overImageView.rx
            .pinchGesture()
            .when(.began, .changed, .ended)
            .subscribe(onNext: { [weak self] pinch in
                switch pinch.state {
                case .began :
                    self?.beginPinchGesture(pinch)
                case .changed :
                    self?.changingPinchGesture(pinch)
                case .ended :
                    self?.endPinchGesture(pinch)
                default :
                    break
                }
                
            })
            .disposed(by: disposeBag)
    }
}

extension ContentDetailViewController {
    
    func showImageDetailView(){

        imageView.alpha = 0
        
        dimmView.frame = self.view.frame
        dimmView.backgroundColor = UIColor.black
        dimmView.alpha = 0
        view.addSubview(dimmView)
        
        overImageView.backgroundColor = UIColor.red
        overImageView.frame = self.imageView.frame
        overImageView.image = self.imageView.image
        overImageView.contentMode = .scaleAspectFill
        overImageView.clipsToBounds = true
        overImageView.isUserInteractionEnabled = true
        view.addSubview(overImageView)
        
        var window : UIWindow?
        var topArea : CGFloat = 0
        var bottomArea : CGFloat = 0
        
        if #available(iOS 13.0, *) {
            window = UIApplication.shared.windows[0]
            topArea = window!.safeAreaInsets.top
            bottomArea = window!.safeAreaInsets.bottom
        } else if #available(iOS 11.0, *) {
            window = UIApplication.shared.keyWindow
            topArea = window!.safeAreaInsets.top
            bottomArea = window!.safeAreaInsets.bottom
        }
        
        if let window = window {
            naviView.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.navigationController!.navigationBar.frame.height + topArea)
            naviView.backgroundColor = UIColor.black
            naviView.alpha = 0
            window.addSubview(naviView)
            
            tabView.frame = CGRect(x: 0, y: window.frame.height - self.tabBarController!.tabBar.frame.height, width: self.view.frame.width, height: self.tabBarController!.tabBar.frame.height + bottomArea)
            tabView.backgroundColor = UIColor.black
            tabView.alpha = 0
            window.addSubview(tabView)
        }
        

        UIView.animate(withDuration: 0.8, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0.5, options: .curveEaseOut, animations: { [self] () -> Void in
            
            self.overImageView.center = CGPoint(x: self.view.frame.width / 2, y: self.view.frame.height / 2)
            self.dimmView.alpha = 1
            self.naviView.alpha = 1
            self.tabView.alpha = 1
            
            self.overDescLabel.text = self.descLabel.text
            self.overDescLabel.textColor = .white
            self.overDescLabel.numberOfLines = 0
            self.view.addSubview(self.overDescLabel)
            
            self.overDescLabel.translatesAutoresizingMaskIntoConstraints = false
            
            var constraints: [NSLayoutConstraint] = []
            constraints.append(contentsOf: [
                self.overDescLabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 16),
                self.overDescLabel.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -16),
                self.overDescLabel.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -(self.tabBarController!.tabBar.frame.height)),
            ])
            
            NSLayoutConstraint.activate(constraints)
        })
    
    }

}

extension ContentDetailViewController {

    func beginPanGesture(_ sender : UIPanGestureRecognizer) {
        startPoint = sender.view!.frame.origin
    }
    
    func changingPanGesture(_ sender : UIPanGestureRecognizer) {
        let newPosition = sender.translation(in: self.dimmView)
        
        sender.view!.center = CGPoint(x: sender.view!.center.x + newPosition.x, y: sender.view!.center.y + newPosition.y)
        sender.setTranslation(.zero, in: self.view)
        
        if !isPinching {
            let dy = abs(sender.view!.frame.origin.y - startPoint!.y) / 10
            let alpha = 1 - (floor(dy) / 100)
            
            self.dimmView.alpha = alpha
            self.naviView.alpha = alpha
            self.tabView.alpha = alpha
        }
    }
    
    func closeImageDetailView(_ sender : UIPanGestureRecognizer) {

        let endPoint = sender.translation(in: self.dimmView)
        
        let dx = endPoint.x - startPoint!.x
        let dy = endPoint.y - startPoint!.y
        let distance = sqrt((dx * dx) + (dy * dy))
        
        if distance < 5.0 {
            UIView.animate(withDuration: 0.2, animations: { () -> Void in
                sender.view!.center = CGPoint(x: self.view.frame.width / 2, y: self.view.frame.height / 2)
                self.dimmView.alpha = 1.0
                self.naviView.alpha = 1.0
                self.tabView.alpha = 1.0
            }, completion: { (didComplete) -> Void in
                sender.setTranslation(.zero, in: self.view)
            })
        } else {
            UIView.animate(withDuration: 0.3, animations: { () -> Void in
                self.overImageView.frame = self.imageView.frame
                self.overDescLabel.frame = self.descLabel.frame
                
                self.dimmView.alpha = 0
                self.naviView.alpha = 0
                self.tabView.alpha = 0

            }, completion: { (didComplete) -> Void in
                self.overImageView.removeFromSuperview()
                self.overDescLabel.removeFromSuperview()
                self.dimmView.removeFromSuperview()
                self.naviView.removeFromSuperview()
                self.tabView.removeFromSuperview()
                self.imageView.alpha = 1
            })
        }
    }
    
    func beginPinchGesture(_ sender : UIPinchGestureRecognizer) {
        self.isPinching = true
    }
    
    func changingPinchGesture(_ sender : UIPinchGestureRecognizer){
        let currentScale = scale(for: sender.view!.transform)

        let minScale: CGFloat = 0.2
        let maxScale: CGFloat = 3
        
        var newScale = sender.scale
        newScale = min(newScale, maxScale / currentScale)
        newScale = max(newScale, minScale / currentScale)

        sender.view!.transform = sender.view!.transform.scaledBy(x: newScale, y: newScale)
        sender.scale = 1
    }
    
    func endPinchGesture(_ sender : UIPinchGestureRecognizer) {
        let currentScale = scale(for: sender.view!.transform)
        
        if currentScale < 1.0 {
            UIView.animate(withDuration: 0.2, animations: { () -> Void in
                sender.view!.center = CGPoint(x: self.view.frame.width / 2, y: self.view.frame.height / 2)
                sender.view!.transform = CGAffineTransform.identity
                
            }, completion: { (didComplete) -> Void in
                sender.scale = 1
                self.isPinching = false
            })
        }
    }
    
    private func scale(for transform: CGAffineTransform) -> CGFloat {
        return sqrt(CGFloat(transform.a * transform.a + transform.c * transform.c))
    }
}

