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
    var number: Int = 0 //messageCount
    var peerID: MCPeerID!
    var mcSession: MCSession!
    var mcNearbyServiceAdvertiser: MCNearbyServiceAdvertiser! //this is providing searchable us.
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // here, we are forming our profile.
        self.peerID = MCPeerID(displayName: UIDevice.current.name) //searching nearby device they see my name to connect to me.
        self.mcSession = MCSession(peer: self.peerID, securityIdentity: .none, encryptionPreference: .required) //We are creating a session to communication.
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
        if mcSession.connectedPeers.count > 0 { //if you want to send a data, you have to connected least one peer.
            if let textData = data.data(using: .utf8) {
                do {
                    try mcSession.send(textData, toPeers: mcSession.connectedPeers, with: .reliable) //we are sending data to all connected peers as reliable.
                } catch let error as NSError {
                    print("Sending Error: \(error.localizedDescription)")
                }
            }
        }
    }
    
    
    func startHosting() {
        self.mcNearbyServiceAdvertiser = MCNearbyServiceAdvertiser(peer: self.peerID, discoveryInfo: nil, serviceType: "mytype") // MCNearbyServiceAdvertiser provides searchable you with servistype. Host and Guest service type must be same. Addition Bonjour item related with your service type name.
        self.mcNearbyServiceAdvertiser.delegate = self
        self.mcNearbyServiceAdvertiser.startAdvertisingPeer()
    }
    
    func joinSession() {
        let mcBrowser = MCBrowserViewController(serviceType: "mytype", session: self.mcSession) //MCBrowserViewController searches peers with serviceType name.
        mcBrowser.delegate = self
        present(mcBrowser, animated: true) // to open MCBrowserViewController screen.
    }

}

extension ViewController: MCSessionDelegate, MCNearbyServiceAdvertiserDelegate, MCBrowserViewControllerDelegate {

    
    
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) { //here we can see stages of peer connection.
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
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) { //after completed connection with a peer, when peer send a data i will be came here.
        if let text = String(data: data, encoding: .utf8) {
            DispatchQueue.main.async {
                self.numberLabel.text = text
            }
        }
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
       
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        
    }
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        print("\(peerID.displayName) wants to connect to you.") //if any peer sent to us connection request, it will be came here.
        invitationHandler(true,self.mcSession)
    }
    
    //below two functions to close the MCBrowserViewController Screen.
    func browserViewControllerDidFinish(_ browserViewController: MCBrowserViewController) {
        dismiss(animated: true)
    }
    
    func browserViewControllerWasCancelled(_ browserViewController: MCBrowserViewController) {
        dismiss(animated: true)
    }
    
}
