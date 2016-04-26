//
//  AppDelegate.swift
//  QLED
//
//  Created by Harry Shamansky on 12/25/15.
//  Copyright © 2015 Harry Shamansky. All rights reserved.
//

import Cocoa
import CoreMIDI

enum LEDTape: UInt8 {
    case Tape1 = 176
    case Tape2 = 177
}

enum LEDColor: UInt8 {
    case Red = 0
    case Green = 1
    case Blue = 2
}

protocol MIDIDelegate {
    func didUpdateTape(tape: LEDTape, color: LEDColor, value: UInt8)
}

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    let popover = NSPopover()
    var midiDelegate: MIDIDelegate? = nil
    
    /// two file descriptors to write to the serial ports
    var serialFileDescriptorTape1: CInt?
    var serialFileDescriptorTape2: CInt?
    
    /// a queue of serial write commands
    let serialWriteQueue = NSOperationQueue()
    
    let statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(NSSquareStatusItemLength)
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        
        // MARK: - Menu Bar Item
        if let button = statusItem.button {
            button.image = NSImage(named: "Beaker")
            button.action = #selector(AppDelegate.togglePopover(_:))
        }
        let contentViewController = LEDTapeViewController(nibName: "LEDTapeViewController", bundle: nil)
        midiDelegate = contentViewController
        popover.contentViewController = contentViewController
        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "Quit QLED", action: #selector(AppDelegate.quitApp(_:)), keyEquivalent: "q"))
        
        //statusItem.menu = menu
        
        // MARK: - File Descriptors and Write Queue
        serialFileDescriptorTape1 = open("/dev/cu.usbmodem1411", O_RDWR | O_NOCTTY | O_NONBLOCK)
        serialFileDescriptorTape2 = open("/dev/cu.usbmodem1421", O_RDWR | O_NOCTTY | O_NONBLOCK)
        serialWriteQueue.maxConcurrentOperationCount = 1    // queue must be serial
        
        // MARK: - MIDI Handling
        var client = MIDIClientRef()
        MIDIClientCreateWithBlock("MIDIClient", &client, nil)
        
        var destinationEndpointRef = MIDIEndpointRef()
        MIDIDestinationCreateWithBlock(client, "QLED (LED Tape Control)", &destinationEndpointRef) {
            (packetList: UnsafePointer<MIDIPacketList>, srcConnRefCon: UnsafeMutablePointer<Void>) -> Void in
            
            // handle the packet and write the appropriate data to the Arduino
            let packets = packetList.memory
            let packet: MIDIPacket = packets.packet
            var ap = UnsafeMutablePointer<MIDIPacket>.alloc(1)
            ap.initialize(packet)
            
            for _ in 0 ..< packets.numPackets {
                let p = ap.memory as MIDIPacket
                
                if let tape = LEDTape(rawValue: p.data.0), color = LEDColor(rawValue: p.data.1) {
                    self.updateTape(tape, color: color, value: p.data.2, updateInterface: true)
                }
                
                ap = MIDIPacketNext(ap)
            }
        }
    }
    
    func quitApp(sender: AnyObject) {
        NSApplication.sharedApplication().terminate(sender)
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }
    
    func updateTape(tape: LEDTape, color: LEDColor, value: UInt8, updateInterface: Bool = false) {
        if tape == .Tape1 {
            if let serial = serialFileDescriptorTape1 {
                serialWriteQueue.addOperationWithBlock {
                    write(serial, [color.rawValue, value], 2)
                }
            }
        } else if tape == .Tape2 {
            if let serial = serialFileDescriptorTape2 {
                serialWriteQueue.addOperationWithBlock {
                    write(serial, [color.rawValue, value], 2)
                }
            }
        }
        if updateInterface {
            midiDelegate?.didUpdateTape(tape, color: color, value: value)
        }
    }
    
    // MARK: - UI
    func togglePopover(sender: AnyObject?) {
        if popover.shown {
            closePopover(sender)
        } else {
            showPopover(sender)
        }
    }
    
    func showPopover(sender: AnyObject?) {
        if let button = statusItem.button {
            popover.showRelativeToRect(button.bounds, ofView: button, preferredEdge: NSRectEdge.MinY)
        }
    }
    
    func closePopover(sender: AnyObject?) {
        popover.performClose(sender)
    }
}

