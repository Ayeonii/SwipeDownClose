//
//  CallJsonData.swift
//  SwipeDownClose
//
//  Created by 이아연 on 2021/07/07.
//

import Foundation
import RxSwift

enum myError : Error {
    case NO_FILE
}

class CallJsonData {
    
    open class func callContentList() -> Observable<ContentListCodable> {
        
        return Observable.create{ observer in
            do {
                guard let fileUrl = Bundle.main.url(forResource: "myJson", withExtension: "json") else {
                    observer.onError(myError.NO_FILE)
                    return Disposables.create()
                }
                
                let data = try Data(contentsOf: fileUrl)
                
                let decoder = JSONDecoder()
                let shoppingList = try decoder.decode(ContentListCodable.self, from: data)

                observer.onNext(shoppingList)
                observer.onCompleted()
            } catch {
                observer.onError(error)
            }
            
            return Disposables.create()
        }
    }
}

