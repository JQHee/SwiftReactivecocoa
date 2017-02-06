# 什么是RAC？

几乎每一篇介绍RAC的文章开头都是这么一个问题。我这篇文章是写给新手（包括我自己）看的，所以这个问题更是无法忽视。
简单的说，RAC就是一个第三方库，他可以大大简化你的代码过程。
官方的说，ReactiveCocoa（其简称为RAC）是由GitHub开源的一个应用于iOS和OS X开发的新框架。RAC具有函数式编程和响应式编程的特性。
# 为什么我们要学习RAC？
为了提高我们的开发效率。RAC在某些特定情况下开发时可以大大简化代码，并且目前来看安全可靠。

# 学习背景
趁着过年前的激情，准备入坑RAC Swift的版本，在RAC 5.0这个版本，作者做了一个很大的改版，API已经重新命名。对于我个人而言，网上可以学习和参考的资源是很少的，新学一点东西都要花时间去慢慢的研读，然后整理自己的笔记。原来 RAC 中只和 Swift 平台相关的核心代码被单独抽取成了一个新框架：ReactiveSwift 。Swift 正在快速成长并且成长为一个跨平台的语言。把只和 Swift 相关的代码抽取出来后，ReactiveSwift 就可以在其他平台上被使用，而不只是局限在 CocoaTouch 和 Cocoa 中。

# 简介
需使用的头文件
> 
import ReactiveCocoa
import Result
import ReactiveSwift 

- (值得注意的是Signal 依赖于ReactiveSwift  )
- (NoError 依赖于 Result)


# 

主要的类型
- 1.事件（Event）
- 2.监听器（Observer）
- 3.存根（Disposable）
- 4.信号（Signal

# 主要用法
### 1.信号的创建
```
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
```
### 2.文本输入框的监听
```
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
```
### 3.按钮监听
```
// MARK: - 3.按钮监听
    func testBtnClick() {
        testBtn.reactive.trigger(for: .touchUpInside).observeValues {
           print("按钮点击")
        }
    }
```

### 4.信号合并
```
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
```

### 5.Scheduler调度器
```
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
```

### 6.Delegate
```
    let (signal, obser) = Signal<Any, NoError>.pipe()
    @IBAction func btnClick(btn: UIButton) {
        obser.send(value: "代理测试")
    }
    // MARK: - 7.Delegate
    func testDelegate() {
        redView.signal.observeValues { (value) in
            print("按钮点击\(value)")
        }
    }
```

### 7.通知
```
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
```

### 8.KVO
```
    // MARK: - 9.KVO
    func testKVO() {
        let result = self.view.reactive.values(forKeyPath: "bounds")
        result.start { [weak self](rect) in
            print(self?.view ?? "")
            print(rect)
        }
    }
```
```
DynamicProperty(object: self.view, keyPath: "...") gives a MutableProperty like experience on top of values(forKeyPath:).
```
### 9.迭代器
```
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
```

### 10、其他事件绑定
```
// UI绑定到Model  
Signal.combineLatest(uerNameTF1.reactive.continuousTextValues,passwordTF1.reactive.continuousTextValues).observeValues { (name, password) in
//print("name = \(name) + password = \(password)")
}

// 当输入框的两个值长度都大于或者等于6，按钮才可以点击
Signal.combineLatest(uerNameTF1.reactive.continuousTextValues,passwordTF1.reactive.continuousTextValues).map { (name, password) -> Bool in
return ((name?.characters.count)! >= 6 && (password?.characters.count)! >= 6)
}.observeValues { [weak self](value) in
print("合并\(value)")
self?.loginBtn.isEnabled = value
}

// 参数省略        
Signal.combineLatest(uerNameTF1.reactive.continuousTextValues,passwordTF1.reactive.continuousTextValues).map { $0?.characters.count ?? 0 >= 6 && $1?.characters.count ?? 0 >= 6
}.observeValues { [weak self](value) in
print("合并\(value)")
self?.loginBtn.isEnabled = value
}

loginBtn.reactive.isEnabled <~ Signal.combineLatest(uerNameTF1.reactive.continuousTextValues,passwordTF1.reactive.continuousTextValues).map { $0?.characters.count ?? 0 >= 6 && $1?.characters.count ?? 0 >= 6
}
`
class ViewModel {
    var username: MutableProperty<String>
    var password: MutableProperty<String>
    var loginEnabled: Property<Bool>

    // This can be done in a different spot, or init can be made to take initial values as parameters, or whatever...
    init() {
        userName = MutableProperty("")
        password = MutableProperty("")

        // I'm pretty sure the below code is incorrect, but I'm sure you get the idea that we're creating a "calculated, read-only property" out of the above two.
        loginEnabled = .combineLatest(userName.producer, password.producer).map { $0.0.characters.count > 0 && $0.1.characters.count > 0 }
    }
}
`
```
