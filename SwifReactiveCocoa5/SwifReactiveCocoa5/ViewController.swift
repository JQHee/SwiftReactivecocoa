//
//  ViewController.swift
//  SwifReactiveCocoa5
//
//  Created by MAC on 2017/1/23.
//  Copyright © 2017年 MAC. All rights reserved.
//

import UIKit
import Foundation
import ReactiveCocoa
import Result
import ReactiveSwift // Sinal

class ViewController: UIViewController {
    
    @IBOutlet weak var userNameTF: UITextField!
    @IBOutlet weak var redView: RedView!
    @IBOutlet weak var testBtn: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        //testTF()
        //testBtnClick()
        //testCombineLatest()
        //testScheduler()
        //testKVO()
        //testGes()
        testDelegate()
    }
    
    // MARK: - 0.创建信号的方法
    func createSignalMehods() {
        // 1.通过信号发生器创建(冷信号)
        let producer = SignalProducer<String, NoError>.init { (observer, _) in
            print("新的订阅，启动操作")
            observer.send(value: "Hello")
            observer.send(value: "World")
        }
        
        let subscriber1 = Observer<String, NoError>(value: { print("观察者1接收到值 \($0)") })
        let subscriber2 = Observer<String, NoError>(value: { print("观察者2接收到值 \($0)") })
        
        print("观察者1订阅信号发生器")
        producer.start(subscriber1)
        print("观察者2订阅信号发生器")
        producer.start(subscriber2)
        //注意：发生器将再次启动工作
        
        // 2.通过管道创建（热信号）
        let (signalA, observerA) = Signal<String, NoError>.pipe()
        let (signalB, observerB) = Signal<String, NoError>.pipe()
        Signal.combineLatest(signalA, signalB).observeValues { (value) in
            print( "收到的值\(value.0) + \(value.1)")
        }
        observerA.send(value: "1")
        observerA.sendCompleted()
        observerB.send(value: "2")
        observerB.sendCompleted()
    }
    
    // MARK: - 1.监听输入框输入
    func testTF() {
        // 输入时监听
        userNameTF.reactive.continuousTextValues.observeValues { text in
            print(text ?? "")
        }
        
        // 监听粘贴进来的文本
        let result = userNameTF.reactive.values(forKeyPath: "text")
        result.start { (text) in
            print(text)
        }
        
    }
    
    // MARK: - 2.手势监听
    func testGes() {
        // 暂时没有RAC监听手势的API
        let tapGes = UITapGestureRecognizer.init()
        tapGes.addTarget(self, action: #selector(viewClick(tapGes:)))
        redView.isUserInteractionEnabled = true
        redView.addGestureRecognizer(tapGes)
    }
    
    func viewClick(tapGes: UITapGestureRecognizer) {
        print("点击了")
    }
    
    // MARK: - 3.按钮监听
    func testBtnClick() {
        testBtn.reactive.trigger(for: .touchUpInside).observeValues {
           print("按钮点击")
        }
    }
    
    // MARK: - 4.信号联合
    func testCombineLatest() {
        
        // 通过管道创建
        let (signalA, observerA) = Signal<String, NoError>.pipe()
        let (signalB, observerB) = Signal<String, NoError>.pipe()
        Signal.combineLatest(signalA, signalB).observeValues { (value) in
            print( "收到的值\(value.0) + \(value.1)")
        }
        observerA.send(value: "1")
        observerA.sendCompleted()
        observerB.send(value: "2")
        observerB.sendCompleted()
        
        
    }
    // MARK: - 5.信号联合
    func testZip() {
        let (signalA, observerA) = Signal<String, NoError>.pipe()
        let (signalB, observerB) = Signal<String, NoError>.pipe()
        
        Signal.zip(signalA, signalB).observeValues { (value) in
            print( "收到的值\(value.0) + \(value.1)")
        }
        
        signalA.zip(with: signalB).observeValues { (value) in
            
        }
        observerA.send(value: "1")
        observerA.sendCompleted()
        observerB.send(value: "2")
        observerB.sendCompleted()
        
    }
    
    // MARK: - 6.Scheduler(调度器)
    func testScheduler() {
        // 主线程上延时0.3秒调用
        QueueScheduler.main.schedule(after: Date.init(timeIntervalSinceNow: 0.3)) {
            print("主线程调用")
        }
        
        QueueScheduler.init().schedule(after: Date.init(timeIntervalSinceNow: 0.3)){
            print("子线程调用")
        }
        
    }
    
    // MARK: - 7.Delegate
    func testDelegate() {
        redView.signal.observeValues { (value) in
            print("按钮点击\(value)")
        }
    }
    
    // MARK: - 8.通知
    func testNoti() {
     // 普通的通知方法
       NotificationCenter.default.reactive.notifications(forName: Notification.Name(rawValue: "home")).observeValues { (value) in
            print(value.object ?? "")
        }
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "home"), object: nil)
        
        // 键盘的通知
        NotificationCenter.default.reactive.notifications(forName: Notification.Name(rawValue: "UIKeyboardWillShowNotification" ), object: nil).observeValues { (value) in
            print("键盘弹起")
        }
        NotificationCenter.default.reactive.notifications(forName: Notification.Name(rawValue: "UIKeyboardWillHideNotification"), object: nil).observeValues { (value) in
            print("键盘收起")
        }
    }
    
    // MARK: - 9.KVO
    func testKVO() {
        let result = self.view.reactive.values(forKeyPath: "bounds")
        result.start { [weak self](rect) in
            print(self?.view ?? "")
            print(rect)
        }
    }
    
    // MARK: - 10.迭代器
    func testIterator() {
        
        // 数组的迭代器
        let array:[String] = ["name","name2"]
        var arrayIterator =  array.makeIterator()
        while let temp = arrayIterator.next() {
            print(temp)
        }
        
        // swift 系统自带的遍历
        array.forEach { (value) in
            print(value)
        }
        
        // 字典的迭代器
        let dict:[String: String] = ["key":"name", "key1":"name1"]
        var dictIterator =  dict.makeIterator()
        while let temp = dictIterator.next() {
            print(temp)
        }
        
        // swift 系统自带的遍历
        dict.forEach { (key, value) in
            print("\(key) + \(value)")
        }
    
    }
    

}

