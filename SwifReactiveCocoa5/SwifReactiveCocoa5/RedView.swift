//
//  RedView.swift
//  SwifReactiveCocoa5
//
//  Created by MAC on 2017/1/23.
//  Copyright © 2017年 MAC. All rights reserved.
//

import UIKit
import Foundation
import Result // NoError
import ReactiveSwift

class RedView: UIView {
    
    let (signal, obser) = Signal<Any, NoError>.pipe()
    @IBAction func btnClick(btn: UIButton) {
        obser.send(value: "代理测试")
    }

}
