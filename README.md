# Transcriber

A prototype of an application for experimenting with Cocoa APIs used for transcribing audio. The app explores the following Apple frameworks:

- Speech
- AVFoundation

With the following classes:

- SFSpeechRecognizer
- AVAudioRecorder
- AVAudioPlayer

Don't use this app as an example of good software engineering.  There is no proper error handling and methods are not neatly factored into separate files for
better overview.

## Rational Behind Design
The GUI is mainly designed for experimentation and hacking. That is why it is fairly complex. It is to be able to see a lot of info and be able to do various operations in small steps to see what happens.

## Howto Use
This software supports a variety of actions. You can record audio to file and later transcribe. Or you could use an audio file previously recorded with other software and transcribe it.


Either click _record_ or select an audio file with the `...` button. When recording you need to click `stop` to end. You will then get the path to an audio file you just recorded.

Whatever way you got a path to an audio file, you then click `transcribe` to turn audio into text. Note, this can take some time and program does not currently give any visual feedback on progress.

# Intro to Code
At this point this is pretty much a big grayball of mud design. Almost everything is done inside the `WinController.swift` file. The entrypoint for a Cocoa app is `AppDelegate`. This is where we initilize the `WindController` class which manages the main UI. A Window in Cocoa is managed by a subclass of a `NSWindowController` which handles loading a `.xib` file describing the UI.

The most important function is `startTranscribe` which is where we create a `SFSpeechURLRecognitionRequest`. This follows a fairly standard Cocoa pattern where a request object is created and then it is later passed to a method `recognitionTask` which carries our the reckognition task. A task if typically a long running task, which you want a callback for when it is done. This callback will get call repeatedly as transcribed text becomes available and you have to check yourself if it is done or not with `result.isFinal`.

## Word, SpokenWord, SpokenDoc
The `SFSpeechURLRecognitionRequest` will return a `SFTranscription` object representing our transcription. However this isn't very practical to work with as you cannot mutate objects. Thus we have made the `SpokenDoc` type to represent transcriptions, where every individual segment in the transcription with a timestamp and duration is represented by `SpokenWord`.

## Table With Transcribed Words - TranscriptionDataSource
`SpokenDoc` is shown both in a text view `transcribedTextView` and in a table `wordTableView`. The table UI is provided data to show through a data source `transcriptionDataSource`. This data source is the `TranscriptionDataSource` which wraps our `SpokenDoc`. In a Model-View-Controller design we can think of `NSTableView` (`transcribedTextView`) as the View. The controller is `TranscriptionDataSource` and `SpokenDoc` is our Model. The view asks the controller for rows and columns and we implement methods in the controller to pick the requested row and column data out of the `SpokenDoc`.


