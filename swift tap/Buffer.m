//
//  Buffer.m
//  swift tap
//
//  Created by Henry on 01/06/2017.
//  Copyright © 2017 Gordon Childs. All rights reserved.
//

#import "Buffer.h"

@implementation LOLOL

+ (float)getVolume:(AudioBuffer)buffer samples:(UInt32) cSamples {
    
    float *pData = (float *)buffer.mData;
    
    float rms = 0.0f;
    for (UInt32 j = 0; j < cSamples; j++)
    {
        rms += pData[j] * pData[j];
    }
    if (cSamples > 0)
    {
        rms = sqrtf(rms / cSamples);
    }
    
    return rms;
}


@end
