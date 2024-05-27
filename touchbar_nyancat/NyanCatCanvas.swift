//
//  NyanCatCanvas.swift
//  touchbar_nyancat
//
//  Created by Aslan Vatsaev on 05/11/2016.
//  Copyright © 2016 AVatsaev. All rights reserved.
//

import Cocoa

class NyanCatCanvas: NSView {
    var timer: Timer?
    var imageLoaded: Bool = false
    var xPosition: CGFloat = -680 {
        didSet {
            setFrame()
        }
    }
    var direction: CGFloat = 1
    let imageUrl = "https://i.imgur.com/7pgdK28.gif"

    var backgroundImageView: NSImageView = {
        let imageView = NSImageView(frame: .zero)
        imageView.animates = true
        imageView.canDrawSubviewsIntoLayer = true
        return imageView
    }()

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setupSize()
    }

    func setupView() {
        self.wantsLayer = true // Enable layer-backing
        self.addSubview(backgroundImageView)
        self.downloadImage()
        timer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(moveNyancat), userInfo: nil, repeats: true)
    }

    func setupSize() {
        xPosition = -680
        setFrame()
    }

    func setFrame() {
        DispatchQueue.main.async {
            self.backgroundImageView.frame = CGRect(x: self.xPosition, y: 0, width: 680, height: 30)
        }
    }

    override func touchesBegan(with event: NSEvent) {
        timer?.invalidate()
    }
    
    override func touchesMoved(with event: NSEvent) {
        if #available(macOS 10.12.2, *) {
            if let touch = event.allTouches().first {
                let current = touch.location(in: self).x
                let previous = touch.previousLocation(in: self).x
                let dX = current - previous
                xPosition += dX
            }
        }
    }
    
    override func touchesEnded(with event: NSEvent) {
        timer?.invalidate()
        timer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(moveNyancat), userInfo: nil, repeats: true)
    }
    
    @objc func moveNyancat() {
        xPosition += direction
        if xPosition > 0 { direction = -1 }
        else if xPosition < -680 { direction = 1 }
    }

    func downloadImage() {
        guard let url = URL(string: imageUrl) else { return }
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else { return }
            DispatchQueue.main.async {
                self.backgroundImageView.image = NSImage(data: data)
                self.imageLoaded = true
            }
        }.resume()
    }
}
