//
//  RecordSoundsViewController.swift
//  Pitch Perfect
//
//  Created by Steven LeMay on 3/8/15.
//  Copyright (c) 2015 Steven LeMay. All rights reserved.
//

import UIKit
import AVFoundation

class RecordSoundsViewController: UIViewController, AVAudioRecorderDelegate
{
   @IBOutlet weak var recordingInstructions: UILabel!
   @IBOutlet weak var stopButton: UIButton!
   @IBOutlet weak var microphoneButton: UIButton!
   @IBOutlet weak var pauseButton: UIButton!
   
   var audioRecorder: AVAudioRecorder!;
   
   override func viewWillAppear(animated: Bool)
   {
      super.viewWillAppear(animated);
      
      // These are always displayed
      recordingInstructions.hidden = false;
      microphoneButton.hidden = false;
      
      // Update the GUI items that change when the recording state changes
      updateInstructions ();
   }

   override func viewDidDisappear(animated: Bool)
   {
      super.viewDidDisappear(animated);

      // Release the audio recorder
      audioRecorder = nil;
   }
   
   @IBAction func recordAudio(sender: UIButton)
   {
      // When first starting to record, create a temporary file and prepare recorder
      if (audioRecorder == nil)
      {
         // Get the document directory path within the app
         let dirPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String;
      
         // Create a file name using date and time.
         //let currentDateTime = NSDate();
         //let formatter = NSDateFormatter();
         //formatter.dateFormat = "ddMMyyyy-HHmmss";
         //let recordingName = formatter.stringFromDate(currentDateTime) + ".wav";
         
         // Reuse the same file name each time, otherwise the data directory will be a mess.
         let recordingName = "Recording.wav";
         let pathArray = [dirPath, recordingName];
         let filePath = NSURL.fileURLWithPathComponents(pathArray);

         // Error handling
         var error: NSError?;
      
         // Create a recording session
         var session = AVAudioSession.sharedInstance();
         session.setCategory(AVAudioSessionCategoryPlayAndRecord, error: &error);
      
         // TODO Add real error handling
      
         // Record the audio
         let record_settings = [AVEncoderAudioQualityKey: AVAudioQuality.Min.rawValue,AVEncoderBitRateKey: 16, AVNumberOfChannelsKey: 2, AVSampleRateKey: 44100.0];
         audioRecorder = AVAudioRecorder(URL: filePath, settings: record_settings, error: &error);
         audioRecorder.delegate = self;
         audioRecorder.meteringEnabled = true;
      }
      // Start or resume recording
      audioRecorder.record();

      // Update the GUI to reflect recording state
      updateInstructions();
   }
   
   @IBAction func stopRecordingAudio (sender: UIButton)
   {
      // Stop the recording of audio
      audioRecorder.stop();
      var session = AVAudioSession.sharedInstance();
      session.setActive (false, error: nil);

      // Quit showing instruction prior to transition
      recordingInstructions.hidden = true;
      updateInstructions ();
   }
   
   @IBAction func pauseRecordingAudio (sender: UIButton)
   {
      // If recording mode active
      if (audioRecorder != nil)
      {
         // If actively recording pause, otherwise resume recording
         if (audioRecorder.recording)
         {
            audioRecorder.pause ();
         }
         else
         {
            audioRecorder.record ();
         }
      }

      // Update the GUI to reflect recording state
      updateInstructions();
   }

   func audioRecorderDidFinishRecording(recorder: AVAudioRecorder!, successfully flag: Bool)
   {
      if (flag)
      {
         let recorded_audio = RecordedAudio (filePathUrl: recorder.url, title: recorder.url.lastPathComponent);
         performSegueWithIdentifier("stopRecording", sender: recorded_audio);
      }
      else
      {
         // TODO. Enhance error handling and user feedback for failure
         audioRecorder = nil;
         updateInstructions();
      }
   }
   
   func updateInstructions ()
   {
      var active : Bool = audioRecorder != nil;
      var recording : Bool = active ? audioRecorder.recording : false;
      
      // Update the GUI based on the recording state
      stopButton.enabled = active;
      stopButton.hidden = !active;
      pauseButton.enabled = recording;
      pauseButton.hidden = !active;
      microphoneButton.enabled = !recording;
      recordingInstructions.text = (recording) ? "Recording" : (active) ? "Paused" : "Tap Microphone to Record";
   }
   
   override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
   {
      if (segue.identifier == "stopRecording")
      {
         let play_sound_vc:PlaySoundsViewController = segue.destinationViewController as PlaySoundsViewController;
         play_sound_vc.received_audio = sender as RecordedAudio;
      }
   }
}

 