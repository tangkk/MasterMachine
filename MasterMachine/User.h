//
//  User.h
//
//  Created by tangkk and Cayden on 4/29/13.
//  Copyright (c) 2013 tangkk, Cayden. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface User : NSObject

@property (readonly) UInt8 userid;
@property (copy, readonly) NSString *userName;
@property (copy,nonatomic) NSString *instrument;
@property (copy, readonly) NSString *IP;
@property (nonatomic) float volume;
@property (readonly) UIButton *userButton;

-(id)initWithUserName:(NSString *)userName ID:(UInt8)uid IP:(NSString *)IP Instrument:(NSString *)Instr;

@end
