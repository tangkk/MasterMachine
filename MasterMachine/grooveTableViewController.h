////  grooveTableViewController.h
//  WIJAM-MASTER
//
//  Created by Michelle Wong SU on 4/28/13.
//  Copyright (c) 2013 Michelle Wong SU. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "DirectoryWatcher.h"

@protocol SelectedGrooveDelegate <NSObject>
@required
-(void) selectedgroove:(NSURL*)grooveURL;
@end

@interface grooveTableViewController : UITableViewController <DirectoryWatcherDelegate, UIDocumentInteractionControllerDelegate>
//@property (nonatomic, strong) NSMutableArray *grooveArray;
@property (nonatomic, weak) id <SelectedGrooveDelegate> delegate;

//-(void)passArray:(NSMutableArray *)grooveURLs;

@end
