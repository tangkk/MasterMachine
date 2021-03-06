//
//  MasterMachineViewController.h
//  MasterMachine
//
//  Created by tangkk on 19/8/13.
//  Copyright (c) 2013 tangkk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PickViewController.h"
#import "grooveTableViewController.h"
#import "Communicator.h"

@interface MasterMachineViewController : UIViewController <PickerDelegate, NSNetServiceBrowserDelegate, MIDIPlaybackHandle, SelectedGrooveDelegate>

@end
