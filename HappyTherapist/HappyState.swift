//
//  HappState.swift
//  HappyTherapist
//
//  Created by REO HARADA on 2021/03/20.
//

enum HappyState: CaseIterable {
    case highTension, die, emergency
    
    func string() -> String {
        switch self {
        case .highTension:
            return "集中力が高まったとき"
        case .die:
            return "ハッピーフィナーレのとき"
        case .emergency:
            return "緊急 (過呼吸)のとき"
        }
    }
    
    func message() -> String {
        switch self {
        case .highTension:
            return "集中力が高まっております"
        case .die:
            return "命が危険な状態です"
        case .emergency:
            return "緊急 (過呼吸)の状態です"
        }
    }
    
    func key() -> String {
        switch self {
        case .highTension:
            return "highTension"
        case .die:
            return "die"
        case .emergency:
            return "emergency"
        }
    }
    
    static func value(key: String) -> HappyState {
        switch key {
        case "highTension":
            return HappyState.highTension
        case "die":
            return HappyState.die
        case "emergency":
            return HappyState.emergency
        default:
            return HappyState.highTension
        }
    }
}
