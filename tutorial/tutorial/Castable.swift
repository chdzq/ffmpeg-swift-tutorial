//
//  Castable.swift
//  Castable
//
//  Created by jayios on 2016. 6. 23..
//  Copyright © 2016년 ngenii. All rights reserved.
//

import Foundation
import CoreGraphics

public protocol PointerCastable {}

public protocol UnsafePointerable {
    init(_ other: UnsafePointer<Pointee>)
    init?(_ other: UnsafePointer<Pointee>?)
    init(_ other: UnsafeMutablePointer<Pointee>)
    init?(_ other: UnsafeMutablePointer<Pointee>?)
    associatedtype Pointee
    var pointee: Pointee { get }
    func withMemoryRebound<T, Result>(to: T.Type, capacity count: Int, _ body: (UnsafeMutablePointer<T>) throws -> Result) rethrows -> Result
}

public protocol MutablePointerShortener {
    associatedtype Pointee
    /// meaning for o(bject)
    var o: Pointee { get set }
    var pointee: Pointee { get set }
}
public protocol PointerShortener {
    associatedtype Pointee
    /// meaning for o(bject)
    var o: Pointee { get }
    var pointee: Pointee { get }
}

extension MutablePointerShortener where Self: UnsafePointerable {
    public var o: Pointee {
        set {
            self.pointee = newValue
        }
        get {
            return self.pointee
        }
    }
}

extension PointerShortener where Self: UnsafePointerable {
    public var o: Pointee {
        return self.pointee
    }
}

extension UnsafePointer: PointerCastable, UnsafePointerable, PointerShortener {}
extension UnsafeMutablePointer: PointerCastable, UnsafePointerable, MutablePointerShortener {}

public protocol UnsafeRawPointerable{
    init<T>(_ other: UnsafePointer<T>)
    init?<T>(_ other: UnsafePointer<T>?)
    init<T>(_ other: UnsafeMutablePointer<T>)
    init?<T>(_ other: UnsafeMutablePointer<T>?)
}

extension UnsafeRawPointer: UnsafeRawPointerable, PointerCastable {}
extension UnsafeMutableRawPointer: UnsafeRawPointerable, PointerCastable {}

extension PointerCastable where Self: UnsafePointerable {
    public func cast<P: UnsafePointerable, M>() -> P? where P.Pointee == M {
        if self is P {
            return self as? P
        }
        let ptr = self.withMemoryRebound(to: M.self, capacity: MemoryLayout<M>.stride){$0}
        return P(ptr)
    }
    public func cast<P: UnsafePointerable, M>() -> P where P.Pointee == M {
        if self is P {
            return self as! P
        }
        let ptr = self.withMemoryRebound(to: M.self, capacity: MemoryLayout<M>.stride){$0}
        return P(ptr)
    }
    public func castRaw<R: UnsafeRawPointerable, T>(from: T.Type) -> R? {
        if R.self == UnsafeRawPointer.self {
            let ptr: UnsafePointer<T> = self.cast()
            return R(ptr)
        }
        let ptr: UnsafeMutablePointer<T> = self.cast()
        return R(ptr)
    }
    public func castRaw<R: UnsafeRawPointerable, T>(from: T.Type) -> R {
        if R.self == UnsafeRawPointer.self {
            let ptr: UnsafePointer<T> = self.cast()
            return R(ptr)
        }
        let ptr: UnsafeMutablePointer<T> = self.cast()
        return R(ptr)
    }
}

extension PointerCastable where Self: UnsafeRawPointerable {
    public func cast<P: UnsafePointerable, M>(to: M.Type) -> P where P.Pointee == M {
        if self is UnsafeRawPointer {
            let raw = self as! UnsafeRawPointer
            let ptr = raw.assumingMemoryBound(to: M.self)
            return P(ptr)
        } else {
            let raw: UnsafeMutableRawPointer = self as! UnsafeMutableRawPointer
            let ptr = raw.assumingMemoryBound(to: M.self)
            return P(ptr)
        }
    }
    public func cast<P: UnsafePointerable, M>(to: M.Type) -> P? where P.Pointee == M {
        if self is UnsafeRawPointer {
            let raw = self as! UnsafeRawPointer
            let ptr = raw.assumingMemoryBound(to: M.self)
            return P(ptr)
        } else {
            let raw: UnsafeMutableRawPointer = self as! UnsafeMutableRawPointer
            let ptr = raw.assumingMemoryBound(to: M.self)
            return P(ptr)
        }
    }
}


public protocol Pointerable {
    associatedtype Element
    var pointer: UnsafePointer<Element>? {get}
}

extension Array : Pointerable {}
extension ArraySlice : Pointerable {
    func array() -> Array<Element> {
        return Array<Element>(self)
    }
}

extension Pointerable where Self: Sequence {
    public var pointer: UnsafePointer<Element>? {
        switch self {
        case let a as Array<Element>:
            return UnsafePointer<Element>(a)
        case let s as ArraySlice<Element>:
            return UnsafePointer<Element>(s.array())
        default:
            return nil
        }
    }
}

public protocol ArithmeticCastable: Comparable, Equatable, Hashable {
    init(_ value: Int)
    init(_ value: Int8)
    init(_ value: Int16)
    init(_ value: Int32)
    init(_ value: Int64)
    init(_ value: UInt)
    init(_ value: UInt8)
    init(_ value: UInt16)
    init(_ value: UInt32)
    init(_ value: UInt64)
    init(_ value: Float)
    init(_ value: Double)
    init(_ value: CGFloat)
}

extension Int: ArithmeticCastable{}
extension Int8: ArithmeticCastable{}
extension Int16: ArithmeticCastable{}
extension Int32: ArithmeticCastable{}
extension Int64: ArithmeticCastable{}
extension UInt: ArithmeticCastable{}
extension UInt8: ArithmeticCastable{}
extension UInt16: ArithmeticCastable{}
extension UInt32: ArithmeticCastable{}
extension UInt64: ArithmeticCastable{}
extension Float: ArithmeticCastable{}
extension Double: ArithmeticCastable{}
extension CGFloat: ArithmeticCastable{}

extension ArithmeticCastable {
    func cast<R: ArithmeticCastable>() -> R {
        switch self {
        case let n as Int:
            return R(n)
        case let n as Int8:
            return R(n)
        case let n as Int16:
            return R(n)
        case let n as Int32:
            return R(n)
        case let n as Int64:
            return R(n)
        case let n as UInt:
            return R(n)
        case let n as UInt8:
            return R(n)
        case let n as UInt16:
            return R(n)
        case let n as UInt32:
            return R(n)
        case let n as UInt64:
            return R(n)
        case let n as Float:
            return R(n)
        case let n as Double:
            return R(n)
        case let n as CGFloat:
            return R(n)
        default:
            assertionFailure("Couldn't cast to \(String(describing: R.self)) from \(String(describing: self))")
            return R(0)
        }
    }
}
