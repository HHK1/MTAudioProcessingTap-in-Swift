//
//  ViewController.swift
//  swift tap
//
//  Created by Gordon Childs on 11/11/2015.
//  Copyright © 2015 Gordon Childs. All rights reserved.
//

import UIKit
import MediaToolbox
import AVFoundation

class ViewController: UIViewController {

    @IBOutlet weak var soundView: SoundWaveView!
    var player = AVPlayer()
    weak var moviePlayerEndNotification: AnyObject?
    var videoLayer = AVPlayerLayer()
    
    var playerItem: AVPlayerItem! {
        didSet {
            registerForPlayToEndTimeNotification()

        }
    }
    
	override func viewDidLoad() {
		super.viewDidLoad()
        videoLayer.player = player
        videoLayer.frame = view.bounds
        videoLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
        player.actionAtItemEnd = .none
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        doit()
        videoLayer.frame = view.bounds
    }
    
    let tapInit: MTAudioProcessingTapInitCallback = {
        (tap, clientInfo, tapStorageOut) in
        tapStorageOut.pointee = clientInfo
    }
    
    let tapFinalize: MTAudioProcessingTapFinalizeCallback = {
        (tap) in
        print("finalize \(tap)\n")
    }
    
    let tapPrepare: MTAudioProcessingTapPrepareCallback = {
        (tap, b, c) in
        print("prepare: \(tap, b, c)\n")
    }
    
    let tapUnprepare: MTAudioProcessingTapUnprepareCallback = {
        (tap) in
        print("unprepare \(tap)\n")
    }
    
    let tapProcess: MTAudioProcessingTapProcessCallback = {
        (tap, numberFrames, flags, bufferListInOut, numberFramesOut, flagsOut) in
       
        let vc = Unmanaged<ViewController>.fromOpaque(MTAudioProcessingTapGetStorage(tap)).takeUnretainedValue()
        let status = MTAudioProcessingTapGetSourceAudio(tap, numberFrames, bufferListInOut, flagsOut, nil, numberFramesOut)
        let bufferList = UnsafeMutableAudioBufferListPointer(bufferListInOut)
        let numberFrames = numberFramesOut.pointee

        var volume: Float = 0.0
        for buffer in bufferList {
            let cSamples = UInt32(numberFrames) * buffer.mNumberChannels
            volume += LOLOL.getVolume(buffer, samples: cSamples)
        }
        
        DispatchQueue.main.async {
            vc.soundView.animateSoundLevel(rms: CGFloat(volume))
        }
    }
 
    func doit() {
 
        guard let path = Bundle.main.path(forResource: "sample", ofType: "mp4") else {
            return
        }
        
        let url = URL(fileURLWithPath: path)

        playerItem = AVPlayerItem(url: url)
        
        var callbacks = MTAudioProcessingTapCallbacks(
            version: kMTAudioProcessingTapCallbacksVersion_0,
            clientInfo: UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque()),
            init: tapInit,
            finalize: tapFinalize,
            prepare: tapPrepare,
            unprepare: tapUnprepare,
            process: tapProcess)
        
        var tap: Unmanaged<MTAudioProcessingTap>?
        let err = MTAudioProcessingTapCreate(kCFAllocatorDefault, &callbacks, kMTAudioProcessingTapCreationFlag_PostEffects, &tap)
        
        if err != noErr || tap == nil {
            print("err: \(err)\n")
        }
        
        print("tracks? \(playerItem.asset.tracks)\n")
        let audioTrack = playerItem.asset.tracks(withMediaType: AVMediaTypeAudio).first!
        let inputParams = AVMutableAudioMixInputParameters(track: audioTrack)
        inputParams.audioTapProcessor = tap?.takeRetainedValue()
        
        let audioMix = AVMutableAudioMix()
        audioMix.inputParameters = [inputParams]
        
        playerItem.audioMix = audioMix
        playerItem.automaticallyLoadedAssetKeys.forEach({print($0)})

        player.replaceCurrentItem(with: playerItem)
        player.play()
        player.volume = 1.0
        player.isMuted = false
    }
    
    @IBAction func play(_ sender: Any) {
        player.play()
    }
    
    private func registerForPlayToEndTimeNotification() {
        moviePlayerEndNotification = NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object:
            playerItem, queue: .main, using: { [weak self] (notification) in
                self?.player.seek(to: kCMTimeZero)
                self?.player.play()
        })
    }
}
