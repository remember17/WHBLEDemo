//
//  ViewController.swift
//  蓝牙中心设备Swift
//
//  Created by 吴浩 on 2018/1/12.
//  Copyright © 2018年 wuhao. All rights reserved.
//

import UIKit
import CoreBluetooth

class ViewController: UIViewController {

    private let Service_UUID: String = "CDD1"
    private let Characteristic_UUID: String = "CDD2"
    
    @IBOutlet weak var textField: UITextField!
    private var centralManager: CBCentralManager?
    private var peripheral: CBPeripheral?
    private var characteristic: CBCharacteristic?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "蓝牙中心设备"
        centralManager = CBCentralManager.init(delegate: self, queue: .main)
    }


    @IBAction func didClickGet(_ sender: Any) {
        self.peripheral?.readValue(for: self.characteristic!)
    }
    
    @IBAction func didClickPost(_ sender: Any) {
        let data = (self.textField.text ?? "empty input")!.data(using: String.Encoding.utf8)
        self.peripheral?.writeValue(data!, for: self.characteristic!, type: CBCharacteristicWriteType.withResponse)
    }
    
}

extension ViewController: CBCentralManagerDelegate, CBPeripheralDelegate {
    
    // 判断手机蓝牙状态
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .unknown:
            print("未知的")
        case .resetting:
            print("重置中")
        case .unsupported:
            print("不支持")
        case .unauthorized:
            print("未验证")
        case .poweredOff:
            print("未启动")
        case .poweredOn:
            print("可用")
            central.scanForPeripherals(withServices: [CBUUID.init(string: Service_UUID)], options: nil)
        }
    }
    
    /** 发现符合要求的外设 */
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        self.peripheral = peripheral
        // 根据外设名称来过滤
//        if (peripheral.name?.hasPrefix("WH"))! {
//            central.connect(peripheral, options: nil)
//        }
        central.connect(peripheral, options: nil)
    }
    
    /** 连接成功 */
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        self.centralManager?.stopScan()
        peripheral.delegate = self
        peripheral.discoverServices([CBUUID.init(string: Service_UUID)])
        print("连接成功")
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
         print("连接失败")
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("断开连接")
        // 重新连接
        central.connect(peripheral, options: nil)
    }
    
    /** 发现服务 */
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        for service: CBService in peripheral.services! {
            print("外设中的服务有：\(service)")
        }
        //本例的外设中只有一个服务
        let service = peripheral.services?.last
        // 根据UUID寻找服务中的特征
        peripheral.discoverCharacteristics([CBUUID.init(string: Characteristic_UUID)], for: service!)
    }
    
    /** 发现特征 */
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        for characteristic: CBCharacteristic in service.characteristics! {
            print("外设中的特征有：\(characteristic)")
        }
        
        self.characteristic = service.characteristics?.last
        // 读取特征里的数据
        peripheral.readValue(for: self.characteristic!)
        // 订阅
        peripheral.setNotifyValue(true, for: self.characteristic!)
    }
    
    /** 订阅状态 */
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error {
            print("订阅失败: \(error)")
            return
        }
        if characteristic.isNotifying {
            print("订阅成功")
        } else {
            print("取消订阅")
        }
    }
    
    /** 接收到数据 */
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        let data = characteristic.value
        self.textField.text = String.init(data: data!, encoding: String.Encoding.utf8)
    }
    
    /** 写入数据 */
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        print("写入数据")
    }
}
