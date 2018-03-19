//
//  VPNManager.swift
//  SwiftVPN
//
//  Created by Michael on 15/03/2018.
//  Copyright © 2018 Michael. All rights reserved.
//

import UIKit
import NetworkExtension

enum VPNStatus: Int {
    case invalid = 0
    case connected = 1
    case disconnected = 2
    case connecting = 3
    case reasserting = 4
    case disconnecting = 5
}

protocol VPNManagerDelegate: NSObjectProtocol {
    func vpnConnectionStatusDidChanged(manager: VPNManager, status: VPNStatus)
}

class VPNManager: NSObject {
    static let shared = VPNManager()
    private var vpnManager = NEVPNManager.shared()
    
    weak var delegate: VPNManagerDelegate?
    
    override init() {
        super.init()
        
        NotificationCenter.default.addObserver(self, selector: #selector(vpnConfigurationDidChanged(notification:)), name: .NEVPNConfigurationChange, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(vpnStatusDidChanged(notification:)), name: .NEVPNStatusDidChange, object: nil)
    }
    
    @objc func vpnConfigurationDidChanged(notification: Notification) {
        print("vpn本地配置信息改变")
        connect()
    }
    
    @objc func vpnStatusDidChanged(notification: Notification) {
        let status = VPNStatus(rawValue: vpnManager.connection.status.rawValue)!
        delegate?.vpnConnectionStatusDidChanged(manager: self, status: status)
    }
    
    fileprivate func connect() {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(1 * NSEC_PER_SEC)) / Double(NSEC_PER_SEC)) {
            self.vpnManager.loadFromPreferences(completionHandler: { (error) in
                if let error = error {
                    print(error.localizedDescription)
                    self.delegate?.vpnConnectionStatusDidChanged(manager: self, status: .invalid)
                    return
                }
                
                do {
                    try self.vpnManager.connection.startVPNTunnel()
                    print("open vpn tunnel success!")
                } catch {
                    print("open vpn tunnel fail!")
                    self.delegate?.vpnConnectionStatusDidChanged(manager: self, status: .disconnected)
                }
            })
        }
    }
    
    var isConnected: Bool {
        get {
            return vpnManager.connection.status == .connected
        }
    }
    
    var isConnecting: Bool {
        get {
            return vpnManager.connection.status == .connecting
        }
    }
    
    func preLoadPreferences() {
        vpnManager.loadFromPreferences { (error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            print("预加载vpn配置信息成功")
        }
    }
    
    func connect(ip: String, username: String, password: String, psk: String) {
        print("开始连接vpn ip=\(ip) username=\(username) passwor=\(password) psk=\(psk)")
        
        vpnManager.loadFromPreferences { (error) in
            if let error = error {
                print(error.localizedDescription)
                self.delegate?.vpnConnectionStatusDidChanged(manager: self, status: .invalid)
                return
            }
            
            let vpnProtocolIKEv2 = NEVPNProtocolIKEv2()
            vpnProtocolIKEv2.serverAddress = ip
            vpnProtocolIKEv2.username = username
            vpnProtocolIKEv2.authenticationMethod = .sharedSecret
            vpnProtocolIKEv2.remoteIdentifier = ip
            vpnProtocolIKEv2.useExtendedAuthentication = true
            vpnProtocolIKEv2.disconnectOnSleep = true
            
            self.vpnManager.protocolConfiguration = vpnProtocolIKEv2
            self.vpnManager.localizedDescription = "SwiftVPN"
            self.vpnManager.isEnabled = true
            self.vpnManager.saveToPreferences(completionHandler: { (error) in
                if let error = error {
                    print(error.localizedDescription)
                    self.delegate?.vpnConnectionStatusDidChanged(manager: self, status: .invalid)
                    return
                }
                
                print("保存配置成功")
                
                if !UserDefaults.standard.bool(forKey: "First_Connect_VPN") {
                    UserDefaults.standard.set(true, forKey: "First_Connect_VPN")
                    self.connect()
                }
                
            })
        }
        
    }
    
    func disconnect() {
        vpnManager.connection.stopVPNTunnel()
    }
    
    func remove() {
        vpnManager.removeFromPreferences { (error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            print("移除配置成功")
        }
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
}
