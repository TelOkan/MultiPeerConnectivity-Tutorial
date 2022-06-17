//
//  ViewController.swift
//  MultiPeer
//
//  Created by lvs on 16/06/2022.
//

import UIKit
import MultipeerConnectivity

class ViewController: UIViewController {

    @IBOutlet weak var numberLabel: UILabel!
    var number: Int = 0
    var peerID: MCPeerID!
    var mcSession: MCSession!
    var mcNearbyServiceAdvertiser: MCNearbyServiceAdvertiser!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.peerID = MCPeerID(displayName: UIDevice.current.name)
        self.mcSession = MCSession(peer: self.peerID, securityIdentity: .none, encryptionPreference: .required)
        self.mcSession.delegate = self
    }
    // MARK: - Button Actions
        
        @IBAction func didTapHostButton(_ sender: Any) {
            startHosting()
        }
        
        @IBAction func didTapGuestButton(_ sender: Any) {
            joinSession()
        }
        
        
        @IBAction func didTapSendButton(_ sender: Any) {
            self.number += 1
            sendData(data: "\(self.number)")
        }
    
    
    
    func sendData(data: String) {
        if mcSession.connectedPeers.count > 0 {
            if let textData = data.data(using: .utf8) {
                do {
                    try mcSession.send(textData, toPeers: mcSession.connectedPeers, with: .reliable)
                } catch let error as NSError {
                    print("Sending Error: \(error.localizedDescription)")
                }
            }
        }
    }
    
    
    func startHosting() {
        self.mcNearbyServiceAdvertiser = MCNearbyServiceAdvertiser(peer: self.peerID, discoveryInfo: nil, serviceType: "mytype")
        self.mcNearbyServiceAdvertiser.delegate = self
        self.mcNearbyServiceAdvertiser.startAdvertisingPeer()
    }
    
    func joinSession() {
        let mcBrowser = MCBrowserViewController(serviceType: "mytype", session: self.mcSession)
        mcBrowser.delegate = self
        present(mcBrowser, animated: true)
    }

}

extension ViewController: MCSessionDelegate, MCNearbyServiceAdvertiserDelegate, MCBrowserViewControllerDelegate {

    
    
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        switch state {
        case .notConnected:
            print("notConnected: \(peerID.displayName)")
        case .connecting:
            print("connecting: \(peerID.displayName)")
        case .connected:
            print("connected: \(peerID.displayName)")
        @unknown default:
            print("@unknown default")
        }
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        if let text = String(data: data, encoding: .utf8) {
            DispatchQueue.main.async {
                self.numberLabel.text = text
            }
        }
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        print("didReceive: \(stream)","withName: \(streamName)")
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        print("didStartReceivingResourceWithName: \(resourceName)")
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        print("didFinishReceivingResourceWithName: \(resourceName)")
    }
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        print("\(peerID.displayName) Adlı cihaz Size Bağlanmak İstiyor.")
        invitationHandler(true,self.mcSession)
    }
    
    func browserViewControllerDidFinish(_ browserViewController: MCBrowserViewController) {
        dismiss(animated: true)
    }
    
    func browserViewControllerWasCancelled(_ browserViewController: MCBrowserViewController) {
        dismiss(animated: true)
    }
    
}
