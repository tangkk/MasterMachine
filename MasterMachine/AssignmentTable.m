//
//  AssignmentTable.m
//  Tuner
//
//  Created by tangkk on 19/4/13.
//  Copyright (c) 2013 tangkk. All rights reserved.
//

#import "AssignmentTable.h"

// Given a scale name and a key, returns an eight-notes assignment
@implementation AssignmentTable

NSArray *Ionian;
NSArray *Dorian;
NSArray *Phrygian;
NSArray *Lydian;
NSArray *Mixolydian;
NSArray *Aeolian;
NSArray *Locrian;
NSArray *Pentatonic;
NSArray *Blues;
NSArray *Harmonic;
NSArray *None;

-(id)init {
    self = [super init];
    
    if (!self) {
        return nil;
    }
    
    // In the form of MIDI SysEx Message
    Ionian = [[NSArray alloc] initWithObjects:@"C4", @"D4", @"E4", @"F4", @"G4", @"A4", @"B4", @"C5", nil];
    Dorian = [[NSArray alloc] initWithObjects:@"C4", @"D4", @"D#4", @"F4", @"G4", @"A4", @"A#4", @"C5", nil];
    Phrygian = [[NSArray alloc] initWithObjects:@"C4", @"C#4", @"D#4", @"F4", @"G4", @"G#4", @"A#4", @"C5", nil];
    Lydian = [[NSArray alloc] initWithObjects:@"C4", @"D4", @"E4", @"F#4", @"G4", @"A4", @"B4", @"C5", nil];
    Mixolydian = [[NSArray alloc] initWithObjects:@"C4", @"D4", @"E4", @"F4", @"G4", @"A4", @"A#4", @"C5", nil];
    Aeolian = [[NSArray alloc] initWithObjects:@"C4", @"D4", @"D#4", @"F4", @"G4", @"G#4", @"A#4", @"C5", nil];
    Locrian = [[NSArray alloc] initWithObjects:@"C4", @"C#4", @"D#4", @"F4", @"F#4", @"G#4", @"A#4", @"C5", nil];
    Pentatonic = [[NSArray alloc] initWithObjects:@"C4", @"D4", @"E4", @"G4", @"A4", @"C5", @"D5", @"E5", nil];
    Blues = [[NSArray alloc] initWithObjects:@"C4", @"D4", @"D#4", @"E4", @"G4", @"G#4", @"A4", @"C5", nil];
    Harmonic = [[NSArray alloc] initWithObjects:@"C4", @"D4", @"D#4", @"F4", @"G4", @"G#4", @"B4", @"C5", nil];
    None = [[NSArray alloc] initWithObjects:@"C0", nil];
    
    _MusicAssignment = @{
                         @"IONIAN": Ionian,
                         @"DORIAN":Dorian,
                         @"PHRYGIAN":Phrygian,
                         @"LYDIAN":Lydian,
                         @"MIXOLYDIAN":Mixolydian,
                         @"AEOLIAN":Aeolian,
                         @"LOCRIAN":Locrian,
                         @"PENTATONIC":Pentatonic,
                         @"BLUES":Blues,
                         @"HARMONIC":Harmonic,
                         @"NONE":None,
              };
    return self;
}

@end
