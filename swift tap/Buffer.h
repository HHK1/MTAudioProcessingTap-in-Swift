//
//  Buffer.h
//  swift tap
//
//  Created by Henry on 01/06/2017.
//  Copyright © 2017 Gordon Childs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface LOLOL: NSObject

+ (float)getVolume:(AudioBuffer)buffer samples:(UInt32) cSamples;

@end

