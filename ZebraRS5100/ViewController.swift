//
//  ViewController.swift
//  ZebraRS5100
//
//  Created by Juan Diego Ocampo on 6/1/22.
//

import UIKit

class ViewController: UIViewController {
    
    let apiInstance = SbtSdkFactory.createSbtSdkApiInstance()
    
    let pairingBarcodeImage = UIImageView()
    let pairingBarcodeLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupView()
        self.configurePairingBarcodeImage()
        self.configurePairingBarcodeLabel()
        self.setupZebraScannerSDK()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    private func setupView() {
        self.view.backgroundColor = .systemBackground
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.title = "RS5100 Setup"
    }
    
    private func configurePairingBarcodeImage() {
        self.view.addSubview(pairingBarcodeImage)
        self.pairingBarcodeImage.translatesAutoresizingMaskIntoConstraints = false
        self.pairingBarcodeImage.image = UIImage(named: "code")!
        NSLayoutConstraint.activate([
            self.pairingBarcodeImage.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            self.pairingBarcodeImage.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
            self.pairingBarcodeImage.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            self.pairingBarcodeImage.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            self.pairingBarcodeImage.heightAnchor.constraint(equalToConstant: 200),
        ])
    }
    
    private func configurePairingBarcodeLabel() {
        self.view.addSubview(pairingBarcodeLabel)
        self.pairingBarcodeLabel.translatesAutoresizingMaskIntoConstraints = false
        self.pairingBarcodeLabel.text = "Scan this barcode to pair the RS5100 Scanner with this device."
        self.pairingBarcodeLabel.numberOfLines = 0
        self.pairingBarcodeLabel.sizeToFit()
        self.pairingBarcodeLabel.textAlignment = .center
        NSLayoutConstraint.activate([
            self.pairingBarcodeLabel.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            self.pairingBarcodeLabel.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            self.pairingBarcodeLabel.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
        ])
    }
    
    func generateImage() {
        
    }

}

extension ViewController: ISbtSdkApiDelegate {
    
    fileprivate func setupZebraScannerSDK() {
        var availableScanners: NSMutableArray?
        var activeScanners: NSMutableArray?
        guard let sdkVersion = self.apiInstance?.sbtGetVersion() else { return }
        print("Zebra SDK Version: \(sdkVersion)")
        self.apiInstance?.sbtSetDelegate(self)
        self.apiInstance?.sbtSubsribe(forEvents: Int32(SBT_EVENT_SCANNER_APPEARANCE) | Int32(SBT_EVENT_SCANNER_DISAPPEARANCE) | Int32(SBT_EVENT_SESSION_ESTABLISHMENT) | Int32(SBT_EVENT_SESSION_TERMINATION) | Int32(SBT_EVENT_BARCODE) | Int32(SBT_EVENT_IMAGE) | Int32(SBT_EVENT_VIDEO))
        self.apiInstance?.sbtSetOperationalMode(Int32(SBT_OPMODE_ALL))
        self.apiInstance?.sbtEnableAvailableScannersDetection(true)
        self.apiInstance?.sbtGetAvailableScannersList(&availableScanners)
        self.apiInstance?.sbtGetActiveScannersList(&activeScanners)
        
        if let availableScanners = availableScanners {
            for scanner in availableScanners { print(scanner) }
        } else {
            print("Available Scanners is nil.")
        }
        
        if let activeScanners = activeScanners {
            for scanner in activeScanners { print(scanner) }
        } else {
            print("Active Scanners is nil.")
        }
        
        if let result = self.apiInstance?.sbtEstablishCommunicationSession(Int32(3)) {
            if result == SBT_RESULT_SUCCESS {
                print("Connection to scanner successfull")
            } else {
                print("Connection to scanner failed")
            }
        } else {
            print("Result is nil")
        }
        
        if let autoConnect = self.apiInstance?.sbtEnableAutomaticSessionReestablishment(true, forScanner: Int32(3)) {
            if autoConnect == SBT_RESULT_SUCCESS {
                print("autoConnect Connection to scanner successfull")
            } else {
                print("autoConnect Connection to scanner failed")
            }
        } else {
            print("autoConnect Result is nil")
        }
        
    }
    
    /// This event occurs when the presence of a scanner appears.
    func sbtEventScannerAppeared(_ availableScanner: SbtScannerInfo!) {}
    
    /// This event occurs when a scanner is no longer present.
    func sbtEventScannerDisappeared(_ scannerID: Int32) {}
    
    /// This event occurs when communication is established with a scanner.
    func sbtEventCommunicationSessionEstablished(_ activeScanner: SbtScannerInfo!) {}
    
    /// This event occurs when communication with a scanner is terminated.
    func sbtEventCommunicationSessionTerminated(_ scannerID: Int32) {}
    
    /// This event occurs when bar code event is triggered.
    func sbtEventBarcode(_ barcodeData: String!, barcodeType: Int32, fromScanner scannerID: Int32) {}
    
    /// This event occurs when bar code data is read and received.
    func sbtEventBarcodeData(_ barcodeData: Data!, barcodeType: Int32, fromScanner scannerID: Int32) {}
    
    /// This event occurs when firmware update is in progress.
    ///  You don't need to specifically subscribe to this event. You just have to implement this delegate method.
    func sbtEventFirmwareUpdate(_ fwUpdateEventObj: FirmwareUpdateEvent!) {}
    
    /// This event occurs when image data is received.
    func sbtEventImage(_ imageData: Data!, fromScanner scannerID: Int32) {}
    
    /// This event occurs when video data is received.
    func sbtEventVideo(_ videoFrame: Data!, fromScanner scannerID: Int32) {}
    
}


extension ViewController {
    
//    - (BOOL)scannerHasConnected:(int)scannerID
//    {
//
//        SbtScannerInfo *scanner_info = [[zt_ScannerAppEngine sharedAppEngine] getScannerByID:scannerID];
//
//        if ([scanner_info getConnectionType] == SBT_CONNTYPE_MFI)
//        {
//            return  NO;
//        }
//        ///Scanner auto reconnect to check virutal tether alarm
//        if ([[ConnectionManager sharedConnectionManager] getConnectedScannerId] == scannerID)
//        {
//            [[ConnectionManager sharedConnectionManager] scannerReconnectedOnVirtualTetherAlarm];
//        }
//        [self showActiveScannerVC:[NSNumber numberWithInt:scannerID] aBarcodeView:NO aAnimated:YES];
//
//        return YES; /* we have processed the notification */
//    }
    
    func scannerHasConnected(withID scannerID: Int) -> Bool {
        
//        let scannerInfo = zt_ScannerAppEngine.shared()
        
//        guard let scannerInfo = zt_ScannerAppEngine.shared().getScannerByID(Int32(scannerID)) else { return false }
//
//        if scannerInfo.getConnectionType() == SBT_CONNTYPE_MFI {
//            return false
//        }
        
        /// Does not matter since we have not processed the notification.
        return false
    }
    
    /// Does not matter since we have not processed the notification.
    func scannerHasAppeared(withID scannerID: Int) -> Bool { return false }
    
    /// Does not matter since we have not processed the notification.
    func scannerHasDissapeared(withID scannerID: Int) -> Bool { return false }
    
    /// Does not matter since we have not processed the notification.
    func scannerHasDisconnected(withID scannerID: Int) -> Bool { return false }
    
}
