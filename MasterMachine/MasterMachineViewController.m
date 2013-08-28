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
#import "VirtualInstrument.h"

#import "User.h"

@interface MasterMachineViewController () {
    CGRect RectA;
    CGRect RectB;
    CGRect RectC;
    CGRect RectD;
    CGRect RectE;
    CGRect RectF;
    
    CGFloat VolumeMax, VolumeMin;
}

// View controller elements
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
@property (assign) UInt8 RootNum;
@property (copy) NSString *Root;
@property (copy) NSString *Scale;
@property (assign) BOOL isJamming;

@property (strong, nonatomic) UIPopoverController *LoopPopOver;
@property (strong, nonatomic) UIPopoverController *OverallScorePopOver;
@property (strong, nonatomic) UIPopoverController *InstrumentPopOver;
@property (strong, nonatomic) grooveTableViewController *LoopPicker;
@property (strong, nonatomic) PickViewController *OverallScorePicker;
@property (strong, nonatomic) PickViewController *InstrumentPicker;
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
@property (strong, nonatomic) IBOutlet UIButton *UserFieldA;
@property (strong, nonatomic) IBOutlet UIButton *UserFieldB;
@property (strong, nonatomic) IBOutlet UIButton *UserFieldC;
@property (strong, nonatomic) IBOutlet UIButton *UserFieldD;
@property (strong, nonatomic) IBOutlet UIButton *UserFieldE;
@property (strong, nonatomic) IBOutlet UIButton *UserFieldF;


// Network Service Related Declaraion
@property (strong, nonatomic) NSMutableArray *services;
@property (strong, nonatomic) NSNetServiceBrowser *serviceBrowser;
@property (readwrite) MIDINetworkSession *Session;
@property (nonatomic, retain) NSTimer * rescanTimer;

// Three main button Labels
@property (strong, nonatomic) IBOutlet UILabel *Host;
@property (strong, nonatomic) IBOutlet UILabel *Jam;

// Communication Infrastructure
@property (readwrite) Communicator *CMU;
@property (readwrite) MIDINote *Assignment;
@property (readonly) NoteNumDict *Dict;
@property (readonly) AssignmentTable *AST;

// Virtual Instrument
@property (readonly) VirtualInstrument *VI;

// Backing Manager
@property (readwrite) NSURL *currentTrackURL;
@property (readonly) AVAudioPlayer *audioPlayer;
@property (readwrite) BOOL isLoopPlaying;

// Users
@property (readwrite) NSMutableArray *userArray;
@property (readonly) NSArray *userLabelArray;
@property (readonly) NSArray *userFieldArray;
- (void) blinkPlayerAtID:(NSNumber *)ID;

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

- (void)viewSetup {
    RectA = RectMake(_VolumeSliderA);
    RectB = RectMake(_VolumeSliderB);
    RectC = RectMake(_VolumeSliderC);
    RectD = RectMake(_VolumeSliderD);
    RectE = RectMake(_VolumeSliderE);
    RectF = RectMake(_VolumeSliderF);
    VolumeMin = RectA.origin.y;
    VolumeMax = RectA.origin.y + RectA.size.height;
    _RootNum = Root_C;
    _Root = @"C";
    _Scale = @"IONIAN";
    [self ChangeRootandScale];
    _isJamming = false;
    
    _LoopPicker = [[grooveTableViewController alloc] initWithStyle:UITableViewStylePlain];
    _LoopPicker.delegate = self;
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
    _userFieldArray = [NSArray arrayWithObjects:_UserFieldA, _UserFieldB, _UserFieldC,_UserFieldD, _UserFieldE, _UserFieldF, nil];
    for (UIButton *userField in _userFieldArray) {
        userField.alpha = 0.3;
    }
    
    _InstrumentPicker = [[PickViewController alloc] initWithStyle:UITableViewStylePlain];
    _InstrumentPicker.delegate = self;
    _InstrumentArray = [NSArray arrayWithObjects:@"Trombone", @"SteelGuitar", @"Guitar", @"Ensemble", @"Piano", @"Vibraphone", nil];
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
    if (_VI == nil) {
        _VI = [[VirtualInstrument alloc] init];
        [_VI setInstrument:@"Trombone" withInstrumentID:Trombone]; //This is the groove instrument
        [_VI setInstrument:@"SteelGuitar" withInstrumentID:SteelGuitar];
        [_VI setInstrument:@"Guitar" withInstrumentID:Guitar];
        [_VI setInstrument:@"Ensemble" withInstrumentID:Ensemble];
        [_VI setInstrument:@"Piano" withInstrumentID:Piano];
        [_VI setInstrument:@"Vibraphone" withInstrumentID:Vibraphone];
        
        if (_InstrumentNameToChannelNum == nil) {
            _InstrumentNameToChannelNum = @{
                                            @"Trombone":@1,
                                            @"SteelGuitar":@2,
                                            @"Guitar":@3,
                                            @"Ensemble":@4,
                                            @"Piano":@5,
                                            @"Vibraphone":@6
                                            };
        }
    }
    if (_Dict == nil) {
        _Dict = [[NoteNumDict alloc] init];
    }
    if (_AST == nil) {
        _AST = [[AssignmentTable alloc] init];
    }
    if (_AST) {
        _Assignment = [[MIDINote alloc] initWithNote:0 duration:0 channel:kChannel_0 velocity:0
                                               SysEx:[_AST.MusicAssignment objectForKey:@"Ionian"] Root:Root_C];
    }
    
    // Users Setup
    _userArray = [[NSMutableArray alloc] init];
    
    // Backing Manager Setup
    _isLoopPlaying = false;
}

#pragma mark - PlayBack routine
-(void) MIDIPlayback:(const MIDIPacket *)packet {
    NSLog(@"PlaybackDelegate Called");
    if (packet->length == 3) {
        NSLog(@"Playback Notes");
        UInt8 noteTypeAndChannel;
        UInt8 noteNum;
        UInt8 Velocity;
        UInt8 noteType, noteChannel;
        noteTypeAndChannel = (packet->length > 0) ? packet->data[0] : 0;
        noteNum = (packet->length > 1) ? packet->data[1] : 0;
        Velocity = (packet->length >2) ? packet->data[2] : 0;
        noteType = noteTypeAndChannel & 0xF0;
        noteChannel = noteTypeAndChannel & 0x0F;
        NSLog(@"noteNum: %d, noteType: %x, noteChannel: %x", noteNum, noteType, noteChannel);
        
        MIDINote *Note = [[MIDINote alloc] initWithNote:noteNum duration:1 channel:noteChannel velocity:Velocity SysEx:0 Root:noteType];
        if (noteChannel <= 6 && _VI) {
            [_VI playMIDI:Note];
        }
    } else if (packet->length == 4) {
        NSLog(@"Blink the user field");
        NSNumber *ID = [NSNumber numberWithChar:packet->data[2]];
        [self performSelectorInBackground:@selector(blinkPlayerAtID:) withObject:ID];
    }
}

- (void) blinkPlayerAtID:(NSNumber *)ID {
    UInt8 playerID = [ID unsignedCharValue];
    if (playerID < 6) {
        NSLog(@"Blink player ID %d", playerID);
        UIButton *UserField = [_userFieldArray objectAtIndex:playerID];
        [UIView animateWithDuration:0.1 animations:^{UserField.alpha = 1;}];
        [UIView animateWithDuration:0.1 delay:0.1 options:UIViewAnimationOptionTransitionCurlUp animations:^{UserField.alpha = 0.3;} completion:NO];
    }
}

- (IBAction)loopPlay:(id)sender {
    _isLoopPlaying = !_isLoopPlaying;
    if (_isLoopPlaying && _currentTrackURL != nil) {
        _audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:_currentTrackURL error:nil];
        _audioPlayer.volume = 0.3;
        [_audioPlayer prepareToPlay];
        [_audioPlayer play];
    } else {
        [_audioPlayer stop];
        _audioPlayer = nil;
    }
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
    
    [self volumeChanged];
}

- (void)volumeChanged {
    CGFloat Volume[6];
    CGFloat centerY;
    centerY = _VolumeA.center.y;
    Volume[0] = 1 - (centerY - VolumeMin) / (VolumeMax - VolumeMin);
    centerY = _VolumeB.center.y;
    Volume[1] = 1 - (centerY - VolumeMin) / (VolumeMax - VolumeMin);
    centerY = _VolumeC.center.y;
    Volume[2] = 1 - (centerY - VolumeMin) / (VolumeMax - VolumeMin);
    centerY = _VolumeD.center.y;
    Volume[3] = 1 - (centerY - VolumeMin) / (VolumeMax - VolumeMin);
    centerY = _VolumeE.center.y;
    Volume[4] = 1 - (centerY - VolumeMin) / (VolumeMax - VolumeMin);
    centerY = _VolumeF.center.y;
    Volume[5] = 1 - (centerY - VolumeMin) / (VolumeMax - VolumeMin);
    
    UInt8 userIdx = 0;
    for (User *user in _userArray) {
        if (userIdx > 5)
            break;
        user.volume = Volume[userIdx];
        userIdx++;
    }
}

#pragma mark - Root and Scale Change

- (IBAction)applyRootScaleChange:(id)sender {
    if (_isJamming) {
        [_Assignment setSysEx:[_AST.MusicAssignment objectForKey:_Scale]];
        [_Assignment setRoot:_RootNum];
        [_CMU sendMidiData:_Assignment];
    }
}

- (IBAction)RootChange:(id)sender {
    UIButton *button = (UIButton *)sender;
    int tag = button.tag;
    switch (tag) {
        case 0:
            _RootNum = Root_C;
            _Root = @"C";
            break;
        case 1:
            _RootNum = Root_CC;
            _Root = @"C#";
            break;
        case 2:
            _RootNum = Root_D;
            _Root = @"D";
            break;
        case 3:
            _RootNum = Root_DD;
            _Root = @"D#";
            break;
        case 4:
            _RootNum = Root_E;
            _Root = @"E";
            break;
        case 5:
            _RootNum = Root_F;
            _Root = @"F";
            break;
        case 6:
            _RootNum = Root_FF;
            _Root = @"F#";
            break;
        case 7:
            _RootNum = Root_G;
            _Root = @"G";
            break;
        case 8:
            _RootNum = Root_GG;
            _Root = @"G#";
            break;
        case 9:
            _RootNum = Root_A;
            _Root = @"A";
            break;
        case 10:
            _RootNum = Root_AA;
            _Root = @"A#";
            break;
        case 11:
            _RootNum = Root_B;
            _Root = @"B";
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
            _Scale = @"IONIAN";
            break;
        case 1:
            _Scale = @"DORIAN";
            break;
        case 2:
            _Scale = @"PHRYGIAN";
            break;
        case 3:
            _Scale = @"LYDIAN";
            break;
        case 4:
            _Scale = @"MIXOLYDIAN";
            break;
        case 5:
            _Scale = @"AEOLIAN";
            break;
        case 6:
            _Scale = @"LOCRIAN";
            break;
        case 7:
            _Scale = @"BLUES";
            break;
        case 8:
            _Scale = @"PENTATONIC";
            break;
        case 9:
            _Scale = @"HARMONIC";
            break;

        default:
            break;
    }
    [self ChangeRootandScale];
}

- (void) ChangeRootandScale {
    _RootScale.text = [NSString stringWithFormat:@"Root: %@, Scale: %@", _Root, _Scale];
}


- (IBAction)Jam:(id)sender {
    _isJamming = !_isJamming;
    if (_isJamming) {
        _Jam.textColor = [UIColor grayColor];
        [_Assignment setSysEx:[_AST.MusicAssignment objectForKey:_Scale]];
        [_Assignment setRoot:_RootNum];
        [_CMU sendMidiData:_Assignment];
    } else {
        _Jam.textColor = [UIColor whiteColor];
        [_Assignment setSysEx:[_AST.MusicAssignment objectForKey:@"NONE"]];
        [_Assignment setRoot:0];
        [_CMU sendMidiData:_Assignment];
    }
    
}

#pragma mark - Loop, Score, Instrument Selector

- (IBAction)loopSelector:(id)sender {
    UIButton *Selector = (UIButton *)sender;
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

-(void) selectedgroove:(NSURL*)grooveURL withName:(NSString *)fileName{
    NSLog(@"file URL = %@", grooveURL);
    _LoopName.text = fileName;
    _currentTrackURL = grooveURL;
    [_LoopPopOver dismissPopoverAnimated:YES];
}

- (void)selected:(NSString*)selectedName withAccLabel:(NSString *)AccLabel withTag:(UInt8)Tag {
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
        
#pragma mark - player Mapping Broadcast
        // Broadcast the Arr(as SysEx) and the ID(as Root) to let each player know its unique ID and its instrument
        // This is how master can differentiate players
        if (_userArray.count > Tag) {
            User *player = [_userArray objectAtIndex:Tag];
            NSNumber *Channel = [_InstrumentNameToChannelNum objectForKey:selectedName];
            [player setInstrument:selectedName];
            [_Assignment setSysEx:[player.IP componentsSeparatedByString:@"."]];
            [_Assignment setRoot:[Channel unsignedCharValue]];
            [_Assignment setID:Tag];
            [_CMU sendMidiData:_Assignment];
        }
        [_InstrumentPopOver dismissPopoverAnimated:YES];
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
    DSLog(@"scanPlayers...");
    NSInteger userArrayIdx = 0;
    
    if (_Session.enabled) {
        for (MIDINetworkConnection *conn in _Session.connections) {
            // no more than 6 players is allowed for the moment!!
            if (userArrayIdx > 5) {
                break;
            }
            NSString *playerName = conn.host.name;
            NSString *IP = conn.host.address;
            DSLog(@"Player name: %@", playerName);
            DSLog(@"Player IP: %@", IP);
            DSLog(@"Player ID: %d", userArrayIdx);
            if (_userArray.count < (userArrayIdx + 1) && IP != nil) {
                // new users comming
                UILabel *userLabel = [_userLabelArray objectAtIndex:userArrayIdx];
                User *user = [[User alloc] initWithUserName:playerName ID:userArrayIdx IP:IP Instrument:@"unknown"];
                [_userArray addObject:user];
                userLabel.textColor = [UIColor grayColor];
            }
            userArrayIdx++;
        }
    }
}


@end
