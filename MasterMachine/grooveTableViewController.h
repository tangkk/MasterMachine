////  grooveTableViewController.h
//  MasterMachine
//
//  Created by tangkk, Philip Ng, Bony, CX and Cayden on 4/28/13.
//  Copyright (c) 2013 tangkk, Philip Ng, Bony, CX and Cayden. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "DirectoryWatcher.h"

@protocol SelectedGrooveDelegate <NSObject>
@required

-(void) selectedgroove:(NSURL*)grooveURL withName:(NSString *)fileName;

@end

@interface grooveTableViewController : UITableViewController <DirectoryWatcherDelegate, UIDocumentInteractionControllerDelegate>

@property (nonatomic, weak) id <SelectedGrooveDelegate> delegate;

@end
