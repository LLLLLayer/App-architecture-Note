//
//  RecordViewController.swift
//  Recordings-MVC
//
//  Created by 杨杰 on 2021/6/8.
//

import UIKit

class RecordViewController: UIViewController {

    @IBOutlet var timeLabel: UILabel! // 计时
    @IBOutlet var stopButton: UIButton! // 暂停
    
    var audioRecorder: Recorder? // 录制器
    var folder: Folder? = nil // 所属文件夹
    var recording = Recording(name: "", uuid: UUID()) // 录音文件
    
    override func viewDidLoad() {
        super.viewDidLoad()
        timeLabel.text = timeString(0)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // 录制时间显示
        audioRecorder = folder?.store?.fileURL(for: recording).flatMap { url in
            Recorder(url: url) { time in
                if let t = time {
                    self.timeLabel.text = timeString(t)
                } else {
                    self.dismiss(animated: true)
                }
            }
        }
        if audioRecorder == nil {
            dismiss(animated: true)
        }
    }
    
    // 录制结束并命名
    @IBAction func stop(_ sender: Any) {
        audioRecorder?.stop()
        modalTextAlert(title: .saveRecording, accept: .save, placeholder: .nameForRecording) { string in
            if let title = string {
                self.recording.setName(title)
                self.folder?.add(self.recording)
            } else {
                self.recording.deleted()
            }
            self.dismiss(animated: true)
        }
    }
}

fileprivate extension String {
    static let saveRecording = NSLocalizedString("Save recording", comment: "Heading for audio recording save dialog")
    static let save = NSLocalizedString("Save", comment: "Confirm button text for audio recoding save dialog")
    static let nameForRecording = NSLocalizedString("Name for recording", comment: "Placeholder for audio recording name text field")
}
