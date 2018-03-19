//
//  AppProxyProvider.swift
//  ProxyProvider
//
//  Created by Michael on 15/03/2018.
//Copyright © 2018 Michael. All rights reserved.
//

import NetworkExtension

class AppProxyProvider: NEAppProxyProvider {
	var connection: NWTCPConnection? = nil
	var pendingStartCompletion: ((NSError?) -> Void)?

	override func startProxyWithOptions(options: [String : AnyObject]?, completionHandler: (NSError?) -> Void) {
		// Add code here to start the process of connecting the tunnel
		if let serverAddress? = self.`protocol`.serverAddress {
			let newConnection = self.createTCPConnectionToEndpoint(NWHostEndpoint(hostname:serverAddress, port:"9050"), enableTLS:false, TLSParameters:nil, delegate:nil)
			newConnection.addObserver(self, forKeyPath:"state", options:NSKeyValueObservingOptions.Initial, context:nil)
			connection = newConnection
			pendingStartCompletion = completionHandler
		} else {
			completionHandler(NSError(domain:"PacketTunnelProviderDomain", code:-1, userInfo:[NSLocalizedDescriptionKey:"Configuration is missing serverAddress"]))
		}
	}

	override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [NSObject: AnyObject]?, context: UnsafeMutablePointer<Void>) {

		if keyPath == "state" {
			if let conn? = object as? NWTCPConnection {
				if conn.state == NWTCPConnectionState.Connected {
					self.addObserver(self, forKeyPath:"defaultPath", options:NSKeyValueObservingOptions.Initial, context:nil)
					self.pendingStartCompletion?(nil)
					self.pendingStartCompletion = nil
				} else if conn.state == NWTCPConnectionState.Disconnected {
					let error = NSError(domain:"PacketTunnelProviderDomain", code:-1, userInfo:[NSLocalizedDescriptionKey:"Failed to connect"])
					if pendingStartCompletion != nil {
						self.pendingStartCompletion?(error)
						self.pendingStartCompletion = nil
					} else {
						cancelProxyWithError(error)
					}
					conn.cancel()
				} else if conn.state == NWTCPConnectionState.Cancelled {
					conn.removeObserver(self, forKeyPath:"state")
					self.removeObserver(self, forKeyPath:"defaultPath")
					connection = nil
				}
			}
		} else if keyPath == "defaultPath" {
			// Add code here to deal with changes to the network
		} else {
			super.observeValueForKeyPath(keyPath, ofObject: object, change: change, context: context)
		}
	}

	override func stopProxyWithReason(reason: NEProviderStopReason, completionHandler: () -> Void) {
		// Add code here to start the process of stopping the tunnel
		connection?.cancel()
		completionHandler()
	}

	override func handleAppMessage(messageData: NSData, completionHandler: ((NSData?) -> Void)?) {
		// Add code here to handle the message
		if let handler? = completionHandler {
			handler(messageData)
		}
	}

	override func sleepWithCompletionHandler(completionHandler: () -> Void) {
		// Add code here to get ready to sleep
		completionHandler()
	}

	override func wake() {
		// Add code here to wake up
	}

	override func handleNewFlow(flow: NEAppProxyFlow) -> Bool {
		// Add code here to handle the incoming flow
		return false
	}
}
