//
//  AudioView.swift

import AVFoundation

protocol AudioDelegate: class {
    //-------------------------------------------------------------------------------------------------------------------------------------------------
    func didRecordAudio(_ path: String?)
}

class AudioView: UIViewController, AVAudioPlayerDelegate, AVAudioRecorderDelegate {
    private var isPlaying = false
    private var isRecorded = false
    private var isRecording = false
    private var timer: Timer?
    private var dateTimer: Date?
    private var audioPlayer: AVAudioPlayer?
    private var audioRecorder: AVAudioRecorder?
    
    weak var delegate: AudioDelegate!
    
    @IBOutlet private var labelTimer: UILabel!
    @IBOutlet private var buttonRecord: UIButton!
    @IBOutlet private var buttonStop: UIButton!
    @IBOutlet private var buttonDelete: UIButton!
    @IBOutlet private var buttonPlay: UIButton!
    @IBOutlet private var buttonSend: UIButton!
    
    override func viewDidLoad() {

        super.viewDidLoad()

        title = "Audio"
   
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(self.actionCancel))

        isRecording = false
        isRecorded = isRecording
        isPlaying = isRecorded

        updateButtonDetails()
    }
    
    func actionStop() {
        if isPlaying {
            audioPlayerStop()
        }
        if isRecording {
            audioRecorderStop()
        }
    }

    @objc func actionCancel() {

        actionStop()

        dismiss(animated: true)
    }

    @IBAction func actionRecord(_ sender: Any) {
        audioRecorderStart()
    }
    
    @IBAction func actionStop(_ sender: Any) {
        actionStop()
    }

    @IBAction func actionDelete(_ sender: Any) {
        isRecorded = false
        updateButtonDetails()

        timerReset()
    }

    @IBAction func actionPlay(_ sender: Any) {
        audioPlayerStart()
    }
    
    @IBAction func actionSend(_ sender: Any) {
        dismiss(animated: true)
        if delegate != nil {
            delegate.didRecordAudio(audioRecorder!.url.path)
        }
    }
    
    // MARK: - Audio recorder methods
    func audioRecorderStart() {
        isRecording = true
        updateButtonDetails()
        timerStart()
        do {
            let audioSession = AVAudioSession.sharedInstance()
            if #available(iOS 10.0, *) {
                try audioSession.setCategory(AVAudioSessionCategoryPlayback)
            } else {
                AVAudioSession.sharedInstance().perform(NSSelectorFromString("setCategory:error:"), with: AVAudioSessionCategoryPlayback  )
            }
        } catch {
        }
        let settings = [
            AVFormatIDKey: NSNumber(value: kAudioFormatMPEG4AAC),
            AVSampleRateKey: NSNumber(value: 44100),
            AVNumberOfChannelsKey: NSNumber(value: 2)
        ]
        //audioRecorder = [[AVAudioRecorder alloc] initWithURL:[NSURL fileURLWithPath:[File temp:@"m4a"]] settings:settings error:nil];
        audioRecorder!.prepareToRecord()
        audioRecorder!.record()
    }
    
    func audioRecorderStop() {
        isRecording = false
        isRecorded = true
        updateButtonDetails()
        
        timerStop()
        
        audioRecorder!.stop()
    }
    
    // MARK: - Audio player methods
    func audioPlayerStart() {
        isPlaying = true
        updateButtonDetails()
        
        timerStart()
        AVAudioSession.sharedInstance().perform(NSSelectorFromString("setCategory:error:"), with: AVAudioSessionCategoryPlayback)
        audioPlayer = try? AVAudioPlayer(contentsOf: audioRecorder!.url)
        audioPlayer!.delegate = self
        audioPlayer!.prepareToPlay()
        audioPlayer!.play()
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        isPlaying = false
        updateButtonDetails()
        
        timerStop()
    }
    
    func audioPlayerStop() {
        isPlaying = false
        updateButtonDetails()
        timerStop()
        audioPlayer!.stop()
    }
    
    // MARK: - Timer methods
    func timerStart() {
        dateTimer = Date()
        timer = Timer.scheduledTimer(timeInterval: 0.07, target: self, selector: #selector(self.timerUpdate), userInfo: nil, repeats: true)
        RunLoop.main.add(timer!, forMode: RunLoopMode.commonModes)
    }
    
    @objc func timerUpdate() {
        let interval: TimeInterval = Date().timeIntervalSince(dateTimer!)
        let millisec = Int(interval * 100) % 100
        let seconds = Int(interval) % 60
        let minutes = Int(interval) / 60
        labelTimer.text = String(format: "%02d:%02d:%02d", minutes, seconds, millisec)
    }
    
    func timerStop() {
        timer?.invalidate()
        timer = nil
    }
    
    func timerReset() {
        labelTimer.text = "00:00:00"
    }
    
    // MARK: - Helper methods
    func updateButtonDetails() {
        buttonRecord.isHidden = isRecorded
        buttonStop.isHidden = (isPlaying == false) && (isRecording == false)
        buttonDelete.isHidden = (isPlaying == true) || (isRecorded == false)
        buttonPlay.isHidden = (isPlaying == true) || (isRecorded == false)
        buttonSend.isHidden = (isPlaying == true) || (isRecorded == false)
    }
}
