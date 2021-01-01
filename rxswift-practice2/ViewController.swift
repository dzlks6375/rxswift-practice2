//
//  ViewController.swift
//  rxswift-practice2
//
//  Created by SIU on 2021/01/01.
//

import UIKit
import RxSwift


class ViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var countLabel: UILabel!
    
    var disposeBag = DisposeBag()
    var counter = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            self.counter += 1
            self.countLabel.text = "\(self.counter)"
        }
        
        exJust1() //그대로 나옴
//        exJust2() //그대로 나옴
//        exFrom() //forEach 처럼 작동
//        exMap1()
//        exMap2()
//        exFilter()

    }


    func exJust1() {
        
        Observable.from(["hello", "world", 123.456, 123])
            .single()
            .subscribe { (event) in
                switch event {
                case .next(let str):
                    print("next \(str)")
                    break
                case .error(let err):
                    print("error \(err.localizedDescription)")
                    break
                    // 종료됨 , disposed가 불림
                case .completed:
                    print("completed")
                    break
                    // 종료됨 , disposed가 불림
                }
            }
            .disposed(by: disposeBag)
        
        // next hello
        // next world
        // next 123.456
        // next 123
        // completed
        
        // .single
        // next hello
        // error The operation couldn’t be completed.
        
    }
    
    func exJust2() {
        
        Observable.from(["hello", "world", 123.456, 123])
            .subscribe { (str) in
//                print(str)
            } onError: { (err) in
                print(err)
            } onCompleted: {
                print("completed")
            } onDisposed: {
                print("disposed")
            }
            .disposed(by: disposeBag)
    }
    
    
    // onNext
    
    func output(_ str: Any) -> Void {
        print(str)
    }
    
    func exFrom() {
        
        // from 으로 하나씩 받기 때문에 next next next
        
        Observable.from(["hello", "world", 123.456, 123])
            .subscribe (onNext: {(str) in
                print(str)
            })
            .disposed(by: disposeBag)
    }
    
    func exMap1() {
        
        Observable.from(["hello", "world", 123.456, 123])
            .map{ str in "\(str) rxswift"}
            .subscribe { (str) in
                print(str)
            }
            .disposed(by: disposeBag)
    }
    
    func exMap2() {
        
        Observable.from(["hello", "world", "123"])
            .map{ $0.count == 5 }
            .subscribe { (str) in
                print(str)
            } onError: { (err) in
                print(err)
            } onCompleted: {
                print("completed")
            } onDisposed: {
                print("disposed")
            }
            .disposed(by: disposeBag)
    }
    
    func exFilter() {

        Observable.from(["hello", "world", "abc", "defghi"])
            .filter({ $0.count % 3 == 0
            })
            .subscribe { (str) in
                print(str)
            } onError: { (err) in
                print(err)
            } onCompleted: {
                print("completed")
            } onDisposed: {
                print("disposed")
            }
            .disposed(by: disposeBag)
    }
    
    @IBAction func buttonClick(_ sender: Any) {
        
        Observable.just("800*600")
            .map { $0.replacingOccurrences(of:"*", with:"/")}
            .map { "https://picsum.photos/\($0)/?random"}
            .map { URL(string: $0) }
            .filter({ $0 != nil })
            .map { $0! }
//            .observeOn(ConcurrentDispatchQueueScheduler(qos: .default)) // Concurrency Scheduler 비동기
            .map { try Data(contentsOf: $0) }
            .map { UIImage(data: $0) }
            .observeOn(MainScheduler.instance) // Main Thread
            .subscribeOn(ConcurrentDispatchQueueScheduler(qos: .default)) // 첫줄부터하고 싶을때 아무대나 해도 상관 없음, subscribe를 쓰는 순간 처음부터 적용
            
            // .do 외부에 사이드 이펙트를 적용한다
            .do(onNext: { (image) in
                print(image?.size)
            })
            
            // .subscribe는 사이트 이펙트 허용
            .subscribe { (image) in
                self.imageView.image = image // 사이드이펙트
            }
            .disposed(by: disposeBag)
    }
    
}

