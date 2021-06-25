# Transcriber

A prototype of an application for experimenting with Cocoa APIs used for transcribing audio. The app explores the following Apple frameworks:

- Speech
- AVFoundation

With the following classes:

- SFSpeechRecognizer
- AVAudioRecorder
- AVAudioPlayer

Don't use this app as an example of good software engineering. It is hacked together to try out stuff. There is no proper error handling and methods are not neatly factored into separate files for
better overview.

## What Works and Doesn't

I have been able to get audio playback and speech reckognition to work. However I have not been able to use AVAudioRecorder properly. I don't know why this is. I can get similar looking code in playground working.

    import Speech

    let paths = FileManager.default.urls(
        for: .documentDirectory, 
        in: .userDomainMask)
    let docsDir = paths[0]
    let filename = docsDir.appendingPathComponent("voiceRec.m4a")


    let settings = [
        AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
        AVSampleRateKey: 12000,
        AVNumberOfChannelsKey: 1,
        AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
    ]

    let rec = try AVAudioRecorder(
        url: filename, 
        settings: settings)
    var ok = rec.prepareToRecord()

    ok = rec.record()

    // Evaluate this in playground when you are done recording
    rec.stop()
    
However in the project this does not seem to work.