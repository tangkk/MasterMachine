//
//  PickViewController.h
//  WIJAM
//
//  Created by Michelle Wong SU on 4/29/13.
//  Copyright (c) 2013 Michelle Wong SU. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PickerDelegate <NSObject>
@required
-(void) selected:(NSString*)selectedName withAccLabel:(NSString *)AccLabel withTag:(UInt8)Tag;
@end

@interface PickViewController : UITableViewController

@property (nonatomic) UInt8 Tag;
@property (nonatomic) NSString *AccLabel;
@property (nonatomic, retain) NSMutableArray *Array;
@property (nonatomic, weak) id <PickerDelegate> delegate;

-(void)passArray:(NSMutableArray *) NamesArray;
-(void)passTag: (UInt8)Tag;
-(void)passAccLabel: (NSString *)AccLabel;


@end
