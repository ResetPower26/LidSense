//
//  LidAngleReader.swift
//  LidSense
//

import Combine
import Foundation
import IOKit.hid

final class LidAngleReader: ObservableObject {
    @Published var angle: Int?
    @Published var status = Status.looking

    private enum HID {
        static let vendorID = 0x05AC
        static let productID = 0x8104
        static let primaryUsagePage = 0x0020
        static let primaryUsage = 0x008A
        static let featureReportID = CFIndex(1)
        static let reportLength = 3
    }

    private enum Status {
        static let looking = "Looking for lid angle sensor..."
        static let reading = "Reading lid angle..."
        static let unavailable = "Lid angle sensor is unavailable on this Mac."
        static let readFailed = "Could not read lid angle."
    }

    private var manager: IOHIDManager?
    private var device: IOHIDDevice?
    private var timer: Timer?

    init() {
        connect()
    }

    deinit {
        timer?.invalidate()

        if let device {
            IOHIDDeviceClose(device, IOOptionBits(kIOHIDOptionsTypeNone))
        }

        if let manager {
            IOHIDManagerClose(manager, IOOptionBits(kIOHIDOptionsTypeNone))
        }
    }

    private func connect() {
        let manager = IOHIDManagerCreate(kCFAllocatorDefault, IOOptionBits(kIOHIDOptionsTypeNone))
        self.manager = manager

        // This sensor/report pairing is undocumented macOS HID behavior. It is
        // useful for personal experiments, but may disappear or behave
        // differently across MacBook models and macOS releases.
        let matching = [
            kIOHIDVendorIDKey as String: NSNumber(value: HID.vendorID),
            kIOHIDProductIDKey as String: NSNumber(value: HID.productID),
            kIOHIDPrimaryUsagePageKey as String: NSNumber(value: HID.primaryUsagePage),
            kIOHIDPrimaryUsageKey as String: NSNumber(value: HID.primaryUsage),
        ] as NSDictionary

        IOHIDManagerSetDeviceMatching(manager, matching)

        let managerResult = IOHIDManagerOpen(manager, IOOptionBits(kIOHIDOptionsTypeNone))
        guard managerResult == kIOReturnSuccess else {
            setUnavailable(Status.unavailable)
            return
        }

        guard let devices = IOHIDManagerCopyDevices(manager) as? Set<IOHIDDevice>,
              let device = devices.first else {
            setUnavailable(Status.unavailable)
            return
        }

        let openResult = IOHIDDeviceOpen(device, IOOptionBits(kIOHIDOptionsTypeNone))
        guard openResult == kIOReturnSuccess else {
            setUnavailable(Status.unavailable)
            return
        }

        self.device = device
        status = Status.reading
        readAngle()
        startPolling()
    }

    private func startPolling() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            self?.readAngle()
        }
    }

    private func readAngle() {
        guard let device else {
            setUnavailable(Status.unavailable)
            return
        }

        var report = [UInt8](repeating: 0, count: HID.reportLength)
        var reportLength = CFIndex(report.count)

        let result = report.withUnsafeMutableBufferPointer { buffer -> IOReturn in
            guard let baseAddress = buffer.baseAddress else {
                return kIOReturnError
            }

            return IOHIDDeviceGetReport(
                device,
                kIOHIDReportTypeFeature,
                HID.featureReportID,
                baseAddress,
                &reportLength
            )
        }

        guard result == kIOReturnSuccess else {
            setUnavailable(Status.readFailed)
            return
        }

        guard reportLength >= HID.reportLength else {
            setUnavailable(Status.readFailed)
            return
        }

        angle = Int(report[1]) | (Int(report[2]) << 8)
        status = Status.reading
    }

    private func setUnavailable(_ message: String) {
        angle = nil
        status = message
    }

}
