//
//  AppDelegate.swift
//  Transcriber
//
//  Created by Erik Engheim on 24/06/2021.
//

import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet var window: WinController!


    func applicationDidFinishLaunching(_ aNotification: Notification) {
        let window = WinController(windowNibName: "WinController")
        window.showWindow(self)
        self.window = window
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }


}

