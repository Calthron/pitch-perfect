//
//  PlaySoundsViewController.swift
//  Pitch Perfect
//
//  Created by Steven LeMay on 3/14/15.
//  Copyright (c) 2015 Steven LeMay. All rights reserved.
//

import UIKit
import AVFoundation 

class PlaySoundsViewController: UIViewController
{
   var audioPlayer:AVAudioPlayer!;
   var audioEngine:AVAudioEngine!;
   var audioFile:AVAudioFile!;
   
   // Model
   var received_audio : RecordedAudio!;
   
   override func viewDidLoad()
   {
      super.viewDidLoad()

      audioPlayer = AVAudioPlayer(contentsOfURL: received_audio.filePathUrl, error: nil);
      audioPlayer.enableRate = true;
      audioEngine = AVAudioEngine ();
      audioFile = AVAudioFile (forReading: received_audio.filePathUrl, error: nil);
   }

   @IBAction func slowPlayback(sender: UIButton)
   {
      playAudio (current_time: 0.0, rate: 0.5);
   }
   
   @IBAction func fastPlayback(sender: AnyObject)
   {
      playAudio (current_time: 0.0, rate: 2.0);
   }
   
   @IBAction func playChipmunkAudio(sender: UIButton)
   {
      playAudioWithVariablePitch (1000);
   }
   
   @IBAction func playVaderAudio(sender: UIButton)
   {
      playAudioWithVariablePitch (-1000);
   }
 
   @IBAction func echoPlayback(sender: UIButton)
   {
      stopPlayback();
      
      // Setup an effect playback, and adjust the distortion for echo
      var change_echo_effect = AVAudioUnitDistortion ();
      change_echo_effect.loadFactoryPreset(AVAudioUnitDistortionPreset.MultiEcho1);
      playWithEffect(effect: change_echo_effect);
   }
 
   @IBAction func reverbPlayback(sender: UIButton)
   {
      stopPlayback();
      
      // Setup an effect playback, and adjust the preset the reverb for a small room
      var change_reverb_effect = AVAudioUnitReverb ();
      change_reverb_effect.loadFactoryPreset(AVAudioUnitReverbPreset.SmallRoom);
      playWithEffect (effect: change_reverb_effect);
   }

   func playAudio (#current_time: NSTimeInterval, rate: Float)
   {
      // Stop any currently playing sounds
      stopPlayback ();
      
      // Play the recording back
      audioPlayer.rate = rate;
      audioPlayer.currentTime = current_time;
      audioPlayer.play();
   }
   
   @IBAction func stopPlayback(sender: UIButton)
   {
      stopPlayback();
   }
   
   func playAudioWithVariablePitch (pitch: Float)
   {
      // Stop any current playback
      stopPlayback();
      
      // Setup an effect playback, and adjust the pitch
      var change_pitch_effect = AVAudioUnitTimePitch ();
      change_pitch_effect.pitch = pitch;
      
      playWithEffect(effect: change_pitch_effect);
   }
   
   func playWithEffect (#effect : AVAudioUnit!)
   {
      // Attach and effect and start the playback
      var audioPlayer_node = AVAudioPlayerNode ();
      audioEngine.attachNode (audioPlayer_node);
      audioEngine.attachNode (effect);
      audioEngine.connect (audioPlayer_node, to:effect, format:nil);
      audioEngine.connect (effect, to:audioEngine.outputNode, format:nil);
      
      audioPlayer_node.scheduleFile (audioFile, atTime: nil, completionHandler:nil);
      audioEngine.startAndReturnError(nil);
      audioPlayer_node.play ();
   }
   
   func stopPlayback ()
   {
      // Stop any possibly playing sound
      audioPlayer.stop ();
      audioEngine.stop();
      audioEngine.reset();
   }
}
