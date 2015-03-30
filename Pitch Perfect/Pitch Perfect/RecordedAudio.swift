//
//  RecordedAudio.swift
//  Pitch Perfect
//
//  Created by Steven LeMay on 3/15/15.
//  Copyright (c) 2015 Steven LeMay. All rights reserved.
//

import Foundation

class RecordedAudio : NSObject
{
   var filePathUrl: NSURL!;
   var title: String!;

   init (filePathUrl url: NSURL, title file_title:String?)
   {
      filePathUrl = url;
      title = file_title;
   }
}