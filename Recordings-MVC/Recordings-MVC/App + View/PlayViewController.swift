//
//  PlayViewController.swift
//  Recordings-MVC
//
//  Created by 杨杰 on 2021/6/7.
//

import UIKit
import AVFoundation

class PlayViewController: UIViewController, UITextFieldDelegate, AVAudioPlayerDelegate {

    @IBOutlet var noRecordingLabel: UILabel!
    @IBOutlet var activeItemElements: UIStackView!
    @IBOutlet var nameTextField: UITextField!
    @IBOutlet var playButton: UIButton!
    @IBOutlet var progressSlider: UISlider!
    @IBOutlet var progressLabel: UILabel!
    @IBOutlet var durationLabel: UILabel!
    
    var audioPlayer: Player? // 播放器
    var recording: Recording? { // 当前所选录音
        didSet {
            updateForChangedRecording()
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
        navigationItem.leftItemsSupplementBackButton = true
        updateForChangedRecording()
        
        // 通知
        NotificationCenter.default.addObserver(self, selector: #selector(storeChanged(notification:)), name: Store.changedNotification, object: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        recording = nil
    }
    
    @objc func storeChanged(notification: Notification) {
        guard let item = notification.object as? Item, item === recording else { return }
        updateForChangedRecording()
    }
    
    // 播放的显示与否更新
    func updateForChangedRecording() {
        if let r = recording, let url = r.fileURL {
            audioPlayer = Player(url: url) { [weak self] time in
                if let t = time {
                    self?.updateProgressDisplays(progress: t, duration: self?.audioPlayer?.duration ?? 0)
                } else {
                    self?.recording = nil
                }
            }
            
            if let ap = audioPlayer {
                updateProgressDisplays(progress: 0, duration: ap.duration)
                title = r.name
                nameTextField?.text = r.name
                activeItemElements?.isHidden = false
                noRecordingLabel?.isHidden = true
            } else {
                recording = nil
            }
        } else {
            updateProgressDisplays(progress: 0, duration: 0)
            audioPlayer = nil
            title = ""
            activeItemElements?.isHidden = true
            noRecordingLabel?.isHidden = false
        }
    }
    
    // 进度条更新
    func updateProgressDisplays(progress: TimeInterval, duration: TimeInterval) {
        progressLabel?.text = timeString(progress)
        durationLabel?.text = timeString(duration)
        progressSlider?.maximumValue = Float(duration)
        progressSlider?.value = Float(progress)
        updatePlayButton()
    }
    
    // 播放按钮更新
    func updatePlayButton() {
        if audioPlayer?.isPlaying == true {
            playButton?.setTitle(.pause, for: .normal)
        } else if audioPlayer?.isPaused == true {
            playButton?.setTitle(.resume, for: .normal)
        } else {
            playButton?.setTitle(.play, for: .normal)
        }
    }
    
    // MARK: - TextFiled
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let r = recording, let text = textField.text {
            r.setName(text)
            title = r.name
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func setProgress(_ sender: Any) {
        guard let s = progressSlider else { return }
        audioPlayer?.setProgress(TimeInterval(s.value))
    }
    
    @IBAction func play(_ sender: Any) {
        audioPlayer?.togglePlay()
        updatePlayButton()
    }
    
    // MARK: UIStateRestoring
    
    override func encodeRestorableState(with coder: NSCoder) {
        super.encodeRestorableState(with: coder)
        coder.encode(recording?.uuidPath, forKey: .uuidPathKey)
    }
    
    override func decodeRestorableState(with coder: NSCoder) {
        super.decodeRestorableState(with: coder)
        if let uuidPath = coder.decodeObject(forKey: .uuidPathKey) as? [UUID], let recording = Store.shared.item(atUUIDPath: uuidPath) as? Recording {
            self.recording = recording
        }
    }
}

fileprivate extension String {
    static let uuidPathKey = "uuidPath"
    static let pause = NSLocalizedString("Pause", comment: "")
    static let resume = NSLocalizedString("Resume playing", comment: "")
    static let play = NSLocalizedString("Play", comment: "")
}
