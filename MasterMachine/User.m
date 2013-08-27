//
//  User.m
//
//  Created by tangkk and Cayden on 4/29/13.
//  Copyright (c) 2013 tangkk and Cayden. All rights reserved.
//

#import "User.h"

@implementation User

-(id)initWithUserName:(NSString *)userName ID:(UInt8)uid IP:(NSString *)IP Instrument:(NSString *)Instr {
    self = [super init];
    if (self) {
        _userName = userName;
        _userid = uid;
        _IP = IP;
        _instrument = Instr;
    }
    return self;
}
    




@end
