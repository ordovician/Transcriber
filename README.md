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
Either click _record_ or select an audio file with the `...` button. When recording you need to click `stop` to end. You will then get the path to an audio file you just recorded.

Whatever way you got a path to an audio file, you then click `transcribe` to turn audio into text. Note, this can take some time and program does not currently give any visual feedback on progress.




