//: Playground - noun: a place where people can play

import UIKit

var str = "Hello, playground"





class P {
    var name: String = "a"
    var age: Int = 1
    var title: String = "s"
    private var priv: String = "d"
    private let pril = "s"
    
}

let p = P()

struct G {
    var name: String = "a"
    var age: Int = 1
    var title: String = "s"
    private var priv: String = "d"
    private let pril = "s"
    
    var pro: Int {
        get{
            return 1
        }
        set{
            pro = 2
        }
    }
}

let g = G()

let pm = Mirror(reflecting: p)
for i in pm.children {
    print("\(i.label) | \(i.value)")
    
}
pm.subjectType
print()

let gm = Mirror(reflecting: g)

for i in gm.children {
    print("\(i.label) | \(i.value)")
    let mm = Mirror(reflecting: i.value)
    print(mm.subjectType == String.self)

    print(mm.subjectType)
}
print()

let s = 0..<10
s.count