//
//  MasterMachineViewController.m
//  MasterMachine
//
//  Created by tangkk on 19/8/13.
//  Copyright (c) 2013 tangkk. All rights reserved.
//

#import "MasterMachineViewController.h"
#import "Definition.h"

#import "PGMidi/PGMidi.h"
#import "PGMidi/PGArc.h"
#import "PGMidi/iOSVersionDetection.h"

#import "MIDINote.h"
#import "NoteNumDict.h"
#import "AssignmentTable.h"

#import "User.h"

@interface MasterMachineViewController () {
    CGRect RectA;
    CGRect RectB;
    CGRect RectC;
    CGRect RectD;
    CGRect RectE;
    CGRect RectF;
    
    NSString *Root;
    NSString *Scale;
}
@property (strong, nonatomic) IBOutlet UIImageView *VolumeA;
@property (strong, nonatomic) IBOutlet UIImageView *VolumeB;
@property (strong, nonatomic) IBOutlet UIImageView *VolumeC;
@property (strong, nonatomic) IBOutlet UIImageView *VolumeD;
@property (strong, nonatomic) IBOutlet UIImageView *VolumeE;
@property (strong, nonatomic) IBOutlet UIImageView *VolumeF;

@property (strong, nonatomic) IBOutlet UIImageView *VolumeSliderA;
@property (strong, nonatomic) IBOutlet UIImageView *VolumeSliderB;
@property (strong, nonatomic) IBOutlet UIImageView *VolumeSliderC;
@property (strong, nonatomic) IBOutlet UIImageView *VolumeSliderD;
@property (strong, nonatomic) IBOutlet UIImageView *VolumeSliderE;
@property (strong, nonatomic) IBOutlet UIImageView *VolumeSliderF;

@property (strong, nonatomic) IBOutlet UILabel *LoopName;
@property (strong, nonatomic) IBOutlet UILabel *OverallScore;
@property (strong, nonatomic) IBOutlet UILabel *RootScale;

@property (strong, nonatomic) UIPopoverController *LoopPopOver;
@property (strong, nonatomic) UIPopoverController *OverallScorePopOver;
@property (strong, nonatomic) UIPopoverController *InstrumentPopOver;
@property (strong, nonatomic) PickViewController *LoopPicker;
@property (strong, nonatomic) PickViewController *OverallScorePicker;
@property (strong, nonatomic) PickViewController *InstrumentPicker;
@property (strong, nonatomic) NSMutableArray *LoopArray;
@property (strong, nonatomic) NSMutableArray *ScoreArray;
@property (strong, nonatomic) NSMutableArray *InstrumentArray;
@property (strong, nonatomic) NSDictionary *InstrumentNameToChannelNum;

@property (strong, nonatomic) IBOutlet UIButton *ScoreA;
@property (strong, nonatomic) IBOutlet UIButton *ScoreB;
@property (strong, nonatomic) IBOutlet UIButton *ScoreC;
@property (strong, nonatomic) IBOutlet UIButton *ScoreD;
@property (strong, nonatomic) IBOutlet UIButton *ScoreE;
@property (strong, nonatomic) IBOutlet UIButton *ScoreF;
@property (strong, nonatomic) IBOutlet UIButton *InstrumentA;
@property (strong, nonatomic) IBOutlet UIButton *InstrumentB;
@property (strong, nonatomic) IBOutlet UIButton *InstrumentC;
@property (strong, nonatomic) IBOutlet UIButton *InstrumentD;
@property (strong, nonatomic) IBOutlet UIButton *InstrumentE;
@property (strong, nonatomic) IBOutlet UIButton *InstrumentF;
@property (strong, nonatomic) IBOutlet UILabel *UserA;
@property (strong, nonatomic) IBOutlet UILabel *UserB;
@property (strong, nonatomic) IBOutlet UILabel *UserC;
@property (strong, nonatomic) IBOutlet UILabel *UserD;
@property (strong, nonatomic) IBOutlet UILabel *UserE;
@property (strong, nonatomic) IBOutlet UILabel *UserF;


// Network Service Related Declaraion
@property (strong, nonatomic) NSMutableArray *services;
@property (strong, nonatomic) NSNetServiceBrowser *serviceBrowser;
@property (readwrite) MIDINetworkSession *Session;
@property (nonatomic, retain) NSTimer * rescanTimer;

// Three main buttons
@property (strong, nonatomic) IBOutlet UILabel *Host;

// Communication Infrastructure
@property (readwrite) Communicator *CMU;
@property (readwrite) MIDINote *Assignment;
@property (readonly) NoteNumDict *Dict;
@property (readonly) AssignmentTable *AST;

// Users
@property (readwrite) NSMutableArray *userArray;
@property (readonly) NSArray *userLabelArray;

@end

@implementation MasterMachineViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    [self configureNetworkSessionAndServiceBrowser];
    [self infrastructureSetup];
    self.rescanTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(scanPlayers) userInfo:nil repeats:YES];
}

- (void)viewDidAppear:(BOOL)animated {
    [self viewSetup];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - setup routines
- (void)infrastructureSetup {
    if (_CMU == nil) {
        _CMU = [[Communicator alloc] init];
        [_CMU setPlaybackDelegate:self];
    }
    IF_IOS_HAS_COREMIDI(
        if (_CMU.midi == nil) {
            _CMU.midi = [[PGMidi alloc] init];
        }
    )
    if (_Dict == nil) {
        _Dict = [[NoteNumDict alloc] init];
    }
    if (_AST == nil) {
        _AST = [[AssignmentTable alloc] init];
    }
    if (_AST) {
        _Assignment = [[MIDINote alloc] initWithNote:0 duration:0 channel:kChannel_0 velocity:0
                                               SysEx:[_AST.MusicAssignment objectForKey:@"Ionian_1"] Root:Root_C];
    }
    
    // Users Setup
    _userArray = [[NSMutableArray alloc] init];
}

- (void)viewSetup {
    RectA = RectMake(_VolumeSliderA);
    RectB = RectMake(_VolumeSliderB);
    RectC = RectMake(_VolumeSliderC);
    RectD = RectMake(_VolumeSliderD);
    RectE = RectMake(_VolumeSliderE);
    RectF = RectMake(_VolumeSliderF);
    Root = @"C";
    Scale = @"IONIAN";
    [self ChangeRootandScale];
    
    _LoopPicker = [[PickViewController alloc] initWithStyle:UITableViewStylePlain];
    _LoopPicker.delegate = self;
    _LoopArray = [NSArray arrayWithObjects:@"Jazz 1", @"Blues ABC", @"How much left", @"Baby Baby", nil];
    [_LoopPicker passArray:_LoopArray];
    _LoopPopOver = [[UIPopoverController alloc] initWithContentViewController:_LoopPicker];
    _LoopPopOver.popoverContentSize = CGSizeMake(300, 200);
    
    _OverallScorePicker = [[PickViewController alloc] initWithStyle:UITableViewStylePlain];
    _OverallScorePicker.delegate = self;
    _ScoreArray = [NSArray arrayWithObjects:@"100", @"95", @"90", @"85", @"80", nil];
    [_OverallScorePicker passArray:_ScoreArray];
    _OverallScorePopOver = [[UIPopoverController alloc] initWithContentViewController:_OverallScorePicker];
    _OverallScorePopOver.popoverContentSize = CGSizeMake(100, 200);
    _ScoreA.titleLabel.textAlignment = NSTextAlignmentCenter;
    _ScoreB.titleLabel.textAlignment = NSTextAlignmentCenter;
    _ScoreC.titleLabel.textAlignment = NSTextAlignmentCenter;
    _ScoreD.titleLabel.textAlignment = NSTextAlignmentCenter;
    _ScoreE.titleLabel.textAlignment = NSTextAlignmentCenter;
    _ScoreF.titleLabel.textAlignment = NSTextAlignmentCenter;
    _userLabelArray = [NSArray arrayWithObjects:_UserA, _UserB, _UserC, _UserD, _UserE, _UserF, nil];
    
    _InstrumentPicker = [[PickViewController alloc] initWithStyle:UITableViewStylePlain];
    _InstrumentPicker.delegate = self;
    _InstrumentArray = [NSArray arrayWithObjects:@"Trombone", @"SteelGuitar", @"Guitar", @"Ensemble", @"Piano", @"Vibraphone", nil];
    _InstrumentNameToChannelNum = @{
                                    @"Trombone":@1,
                                    @"SteelGuitar":@2,
                                    @"Guitar":@3,
                                    @"Ensemble":@4,
                                    @"Piano":@5,
                                    @"Vibraphone":@6
                                    };
    [_InstrumentPicker passArray:_InstrumentArray];
    _InstrumentPopOver = [[UIPopoverController alloc] initWithContentViewController:_InstrumentPicker];
    _InstrumentPopOver.popoverContentSize = CGSizeMake(200, 200);
    _InstrumentA.titleLabel.textAlignment = NSTextAlignmentCenter;
    _InstrumentB.titleLabel.textAlignment = NSTextAlignmentCenter;
    _InstrumentC.titleLabel.textAlignment = NSTextAlignmentCenter;
    _InstrumentD.titleLabel.textAlignment = NSTextAlignmentCenter;
    _InstrumentE.titleLabel.textAlignment = NSTextAlignmentCenter;
    _InstrumentF.titleLabel.textAlignment = NSTextAlignmentCenter;
}

#pragma mark - PlayBack routine
-(void) MIDIPlayback:(const MIDIPacket *)packet {
    NSLog(@"PlaybackDelegate Called");
}

#pragma mark - Volume Slider
static CGRect RectMake (UIImageView *ImageView) {
    return CGRectMake(ImageView.frame.origin.x - 20, ImageView.frame.origin.y + 30, ImageView.frame.size.width + 40, ImageView.frame.size.height - 50);
}

static void Slide (CGRect Rect, CGPoint currentPoint, UIImageView *ImageView) {
    if (CGRectContainsPoint(Rect, currentPoint)) {
        DSLog(@"pointInside");
        [ImageView setCenter:CGPointMake(ImageView.center.x, currentPoint.y)];
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint currentPoint = [touch locationInView:self.view];
    
    Slide(RectA, currentPoint, _VolumeA);
    Slide(RectB, currentPoint, _VolumeB);
    Slide(RectC, currentPoint, _VolumeC);
    Slide(RectD, currentPoint, _VolumeD);
    Slide(RectE, currentPoint, _VolumeE);
    Slide(RectF, currentPoint, _VolumeF);
}

#pragma mark - Root and Scale Change

- (IBAction)applyRootScaleChange:(id)sender {
    //CHECK: CMU
    [_CMU sendMidiData:_Assignment];
}

- (IBAction)RootChange:(id)sender {
    UIButton *button = (UIButton *)sender;
    int tag = button.tag;
    switch (tag) {
        case 0:
            Root = @"C";
            break;
        case 1:
            Root = @"C#";
            break;
        case 2:
            Root = @"D";
            break;
        case 3:
            Root = @"D#";
            break;
        case 4:
            Root = @"E";
            break;
        case 5:
            Root = @"F";
            break;
        case 6:
            Root = @"F#";
            break;
        case 7:
            Root = @"G";
            break;
        case 8:
            Root = @"G#";
            break;
        case 9:
            Root = @"A";
            break;
        case 10:
            Root = @"A#";
            break;
        case 11:
            Root = @"B";
            break;
        default:
            break;
    }
    [self ChangeRootandScale];
}

- (IBAction)ScaleChange:(id)sender {
    UIButton *button = (UIButton *)sender;
    int tag = button.tag;
    switch (tag) {
        case 0:
            Scale = @"IONIAN";
            break;
        case 1:
            Scale = @"DORIAN";
            break;
        case 2:
            Scale = @"PHRYGIAN";
            break;
        case 3:
            Scale = @"LYDIAN";
            break;
        case 4:
            Scale = @"MIXOLYDIAN";
            break;
        case 5:
            Scale = @"AEOLIAN";
            break;
        case 6:
            Scale = @"LOCRIAN";
            break;
        case 7:
            Scale = @"BLUES";
            break;
        case 8:
            Scale = @"PENTATONIC";
            break;

        default:
            break;
    }
    [self ChangeRootandScale];
}

- (void) ChangeRootandScale {
    _RootScale.text = [NSString stringWithFormat:@"Root: %@, Scale: %@", Root, Scale];
}


#pragma mark - Loop, Score, Instrument Selector

- (IBAction)loopSelector:(id)sender {
    UIButton *Selector = (UIButton *)sender;
    [_LoopPicker passAccLabel:Selector.accessibilityLabel];
    [_LoopPicker passTag:Selector.tag];
    CGPoint origin = Selector.frame.origin;
    CGSize size = Selector.frame.size;
    CGRect rect = CGRectMake(origin.x + size.width/2, origin.y + size.height/2, 1, 1);
    
    [_LoopPopOver presentPopoverFromRect:rect inView:self.view permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
}

- (IBAction)PlayerScoreSelector:(id)sender {
    UIButton *Selector = (UIButton *)sender;
    [_OverallScorePicker passAccLabel:Selector.accessibilityLabel];
    [_OverallScorePicker passTag:Selector.tag];
    CGPoint origin = Selector.frame.origin;
    CGSize size = Selector.frame.size;
    CGRect rect = CGRectMake(origin.x + size.width/2, origin.y + size.height/2, 1, 1);
    [_OverallScorePopOver presentPopoverFromRect:rect inView:self.view permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
}

- (IBAction)instrumentSelector:(id)sender {
    UIButton *Selector = (UIButton *)sender;
    [_InstrumentPicker passAccLabel:Selector.accessibilityLabel];
    [_InstrumentPicker passTag:Selector.tag];
    CGPoint origin = Selector.frame.origin;
    CGSize size = Selector.frame.size;
    CGRect rect = CGRectMake(origin.x + size.width/2, origin.y + size.height/2, 1, 1);
    [_InstrumentPopOver presentPopoverFromRect:rect inView:self.view permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
}

- (void)selected:(NSString*)selectedName withAccLabel:(NSString *)AccLabel withTag:(int)Tag {
    if ([AccLabel isEqual: @"Loop"]) {
        _LoopName.text = selectedName;
        [_LoopPopOver dismissPopoverAnimated:YES];
    }
    if ([AccLabel isEqual: @"Score"]) {
        switch (Tag) {
            // Player Score
            case 0:
                
                _ScoreA.titleLabel.text = selectedName;
                break;
            case 1:
                _ScoreB.titleLabel.text = selectedName;
                break;
            case 2:
                _ScoreC.titleLabel.text = selectedName;
                break;
            case 3:
                _ScoreD.titleLabel.text = selectedName;
                break;
            case 4:
                _ScoreE.titleLabel.text = selectedName;
                break;
            case 5:
                _ScoreF.titleLabel.text = selectedName;
                break;
            
            // Overall Score
            case 6:
                _OverallScore.text = selectedName;
                break;
                
            default:
                break;
        }
        [_OverallScorePopOver dismissPopoverAnimated:YES];
    }
    if ([AccLabel isEqual:@"Instrument"]) {
        switch (Tag) {
            case 0:
                _InstrumentA.titleLabel.text = selectedName;
                break;
            case 1:
                _InstrumentB.titleLabel.text = selectedName;
                break;
            case 2:
                _InstrumentC.titleLabel.text = selectedName;
                break;
            case 3:
                _InstrumentD.titleLabel.text = selectedName;
                break;
            case 4:
                _InstrumentE.titleLabel.text = selectedName;
                break;
            case 5:
                _InstrumentF.titleLabel.text = selectedName;
                break;
                
            default:
                break;
        }
        
        // Broadcast the Arr(as SysEx) and the ID(as Root) to let each player know its unique ID and its instrument
        // This is how master can differentiate players
        if (_userArray.count > Tag) {
            User *player = [_userArray objectAtIndex:Tag];
            NSNumber *Channel = [_InstrumentNameToChannelNum objectForKey:selectedName];
            [player setInstrument:selectedName];
            [_Assignment setSysEx:[player.IP componentsSeparatedByString:@"."]];
            [_Assignment setRoot:[Channel unsignedCharValue]];
            [_CMU sendMidiData:_Assignment];
            [_InstrumentPopOver dismissPopoverAnimated:YES];
        }
    }
}

#pragma mark - network configuration
- (void) configureNetworkSessionAndServiceBrowser {
    // configure network session
    _Session = [MIDINetworkSession defaultSession];
    _Session.enabled = false;
    _Session.connectionPolicy = MIDINetworkConnectionPolicy_Anyone;
    
    // configure service browser
    self.services = [[NSMutableArray alloc] init];
    self.serviceBrowser = [[NSNetServiceBrowser alloc] init];
    [self.serviceBrowser setDelegate:self];
    // starting scanning for services (won't stop until stop() is called)
    [self.serviceBrowser searchForServicesOfType:MIDINetworkBonjourServiceType inDomain:@"local."];
}

- (void) netServiceBrowser:(NSNetServiceBrowser*)serviceBrowser didFindService:(NSNetService *)service moreComing:(BOOL)moreComing {
    DSLog(@"service name: %@", service.name);
    DSLog(@"service hostName: %@", service.hostName);
    DSLog(@"service accessLabel: %@", service.accessibilityLabel);
    [self.services addObject:service];
}

- (void) netServiceBrowser:(NSNetServiceBrowser*)serviceBrowser didRemoveService:(NSNetService *)service moreComing:(BOOL)moreComing {
    MIDINetworkHost *host = [MIDINetworkHost hostWithName:[service name] netService:service];
    MIDINetworkConnection *connection = [MIDINetworkConnection connectionWithHost:host];
    if (connection) {
        [_Session removeConnection:connection]; // remove connection automatically no matter what
    }
    [self.services removeObject:service];
}

- (IBAction)Host:(id)sender {
    _Session.enabled = !_Session.enabled;
    if (_Session.enabled) {
        _Host.textColor = [UIColor grayColor];
    } else {
        _Host.textColor = [UIColor whiteColor];
        // Clear the user arrays and labels
        [_userArray removeAllObjects];
        for (UILabel *Label in _userLabelArray) {
            Label.textColor = [UIColor whiteColor];
        }
        _InstrumentA.titleLabel.text = @"Instrument";
        _InstrumentB.titleLabel.text = @"Instrument";
        _InstrumentC.titleLabel.text = @"Instrument";
        _InstrumentD.titleLabel.text = @"Instrument";
        _InstrumentE.titleLabel.text = @"Instrument";
        _InstrumentF.titleLabel.text = @"Instrument";
    }
}

// Keep scanning incomming players all the time, let them join whenever possible
- (void)scanPlayers {
    NSLog(@"scanPlayers...");
    NSInteger userArrayIdx = 0;
    
    if (_Session.enabled) {
        for (MIDINetworkConnection *conn in _Session.connections) {
            // no more than 6 players is allowed for the moment!!
            if (userArrayIdx > 5) {
                break;
            }
            NSString *playerName = conn.host.name;
            NSString *IP = conn.host.address;
            NSLog(@"Player name: %@", playerName);
            NSLog(@"Player IP: %@", IP);
            NSLog(@"Player ID: %d", userArrayIdx);
            if (_userArray.count < (userArrayIdx + 1) && IP != nil) {
                // new users comming
                UILabel *userLabel = [_userLabelArray objectAtIndex:userArrayIdx];
                User *user = [[User alloc] initWithUserName:playerName ID:userArrayIdx IP:IP Instrument:@"unknown"];
                [_userArray addObject:user];
                userLabel.textColor = [UIColor grayColor];
            }
            userArrayIdx++;
        }
        NSLog(@"\n");
    }
}


@end
