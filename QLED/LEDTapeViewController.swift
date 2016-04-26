//
//  LEDTapeViewController.swift
//  QLED
//
//  Created by Harry Shamansky on 12/25/15.
//  Copyright © 2015 Harry Shamansky. All rights reserved.
//

import Cocoa

class LEDTapeViewController: NSViewController {

    var didAwakeFromNib = false
    
    var redComponent1: Float = 0.0
    var greenComponent1: Float = 0.0
    var blueComponent1: Float = 0.0
    
    var redComponent2: Float = 0.0
    var greenComponent2: Float = 0.0
    var blueComponent2: Float = 0.0
    
    @IBOutlet weak var colorWellTape1: NSColorWell!
    
    @IBOutlet weak var redSliderTape1: NSSlider!
    @IBOutlet weak var greenSliderTape1: NSSlider!
    @IBOutlet weak var blueSliderTape1: NSSlider!
    
    @IBOutlet weak var redTextTape1: NSTextField!
    @IBOutlet weak var greenTextTape1: NSTextField!
    @IBOutlet weak var blueTextTape1: NSTextField!
    
    
    @IBOutlet weak var colorWellTape2: NSColorWell!
    
    @IBOutlet weak var redSliderTape2: NSSlider!
    @IBOutlet weak var greenSliderTape2: NSSlider!
    @IBOutlet weak var blueSliderTape2: NSSlider!
    
    @IBOutlet weak var redTextTape2: NSTextField!
    @IBOutlet weak var greenTextTape2: NSTextField!
    @IBOutlet weak var blueTextTape2: NSTextField!
    
    
    @IBOutlet weak var dividerView: NSView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        dividerView.wantsLayer = true
        dividerView.layer?.backgroundColor = NSColor.lightGrayColor().CGColor
        didAwakeFromNib = true
    }
    
    @IBAction func colorWellChanged(sender: NSColorWell) {
        
        let color = sender.color.colorUsingColorSpaceName(NSCalibratedRGBColorSpace)!
        
        if sender.tag == 0 {
            redComponent1 = Float(color.redComponent)
            greenComponent1 = Float(color.greenComponent)
            blueComponent1 = Float(color.blueComponent)
        } else if sender.tag == 10 {
            redComponent2 = Float(color.redComponent)
            greenComponent2 = Float(color.greenComponent)
            blueComponent2 = Float(color.blueComponent)
        }
        
        updateUI()
    }
    
    @IBAction func controlChanged(sender: NSControl) {
        
        switch (sender.tag) {
        case 0:
            redComponent1 = sender.floatValue / 100.0
        case 1:
            greenComponent1 = sender.floatValue / 100.0
        case 2:
            blueComponent1 = sender.floatValue / 100.0
        case 10:
            redComponent2 = sender.floatValue / 100.0
        case 11:
            greenComponent2 = sender.floatValue / 100.0
        case 12:
            blueComponent2 = sender.floatValue / 100.0
        default: break
        }
        
        updateUI()
    }
    
    func updateUI() {
        colorWellTape1.color = NSColor(calibratedRed: CGFloat(redComponent1), green: CGFloat(greenComponent1), blue: CGFloat(blueComponent1), alpha: 1.0)
        colorWellTape2.color = NSColor(calibratedRed: CGFloat(redComponent2), green: CGFloat(greenComponent2), blue: CGFloat(blueComponent2), alpha: 1.0)
        
        redSliderTape1.floatValue = redComponent1 * 100.0
        greenSliderTape1.floatValue = greenComponent1 * 100.0
        blueSliderTape1.floatValue = blueComponent1 * 100.0
        
        redSliderTape2.floatValue = redComponent2 * 100.0
        greenSliderTape2.floatValue = greenComponent2 * 100.0
        blueSliderTape2.floatValue = blueComponent2 * 100.0
        
        redTextTape1.intValue = Int32(round(redComponent1 * 100.0))
        greenTextTape1.intValue = Int32(round(greenComponent1 * 100.0))
        blueTextTape1.intValue = Int32(round(blueComponent1 * 100.0))
        
        redTextTape2.intValue = Int32(round(redComponent2 * 100.0))
        greenTextTape2.intValue = Int32(round(greenComponent2 * 100.0))
        blueTextTape2.intValue = Int32(round(blueComponent2 * 100.0))
        
        (NSApplication.sharedApplication().delegate as? AppDelegate)?.updateTape(.Tape1, color: .Red, value: UInt8(round(redComponent1 * 100.0)))
        (NSApplication.sharedApplication().delegate as? AppDelegate)?.updateTape(.Tape1, color: .Green, value: UInt8(round(greenComponent1 * 100.0)))
        (NSApplication.sharedApplication().delegate as? AppDelegate)?.updateTape(.Tape1, color: .Blue, value: UInt8(round(blueComponent1 * 100.0)))
        
        (NSApplication.sharedApplication().delegate as? AppDelegate)?.updateTape(.Tape2, color: .Red, value: UInt8(round(redComponent2 * 100.0)))
        (NSApplication.sharedApplication().delegate as? AppDelegate)?.updateTape(.Tape2, color: .Green, value: UInt8(round(greenComponent2 * 100.0)))
        (NSApplication.sharedApplication().delegate as? AppDelegate)?.updateTape(.Tape2, color: .Blue, value: UInt8(round(blueComponent2 * 100.0)))
    }
}

extension LEDTapeViewController: MIDIDelegate {
    func didUpdateTape(tape: LEDTape, color: LEDColor, value: UInt8) {
        if tape == .Tape1 {
            switch color {
            case .Red: redComponent1 = Float(value) / 100.0
            case .Green: greenComponent1 = Float(value) / 100.0
            case .Blue: blueComponent1 = Float(value) / 100.0
            }
        } else if tape == .Tape2 {
            switch color {
            case .Red: redComponent2 = Float(value) / 100.0
            case .Green: greenComponent2 = Float(value) / 100.0
            case .Blue: blueComponent2 = Float(value) / 100.0
            }
        }
        if didAwakeFromNib {
            NSOperationQueue.mainQueue().addOperationWithBlock { [weak self] in
                self?.updateUI()
            }
        }
    }
}
