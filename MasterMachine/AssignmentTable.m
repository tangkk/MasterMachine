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

NSArray *Ionian_1;
NSArray *Ionian_2;
NSArray *Ionian_3;

NSArray *Dorian_1;
NSArray *Dorian_2;
NSArray *Dorian_3;

NSArray *Phrygian_1;
NSArray *Phrygian_2;
NSArray *Phrygian_3;

NSArray *Lydian_1;
NSArray *Lydian_2;
NSArray *Lydian_3;

NSArray *Mixolydian_1;
NSArray *Mixolydian_2;
NSArray *Mixolydian_3;

NSArray *Aeolian_1;
NSArray *Aeolian_2;
NSArray *Aeolian_3;

NSArray *Pentatonic_1;
NSArray *Pentatonic_2;
NSArray *Pentatonic_3;

NSArray *Blues_1;
NSArray *Blues_2;
NSArray *Blues_3;

NSArray *Harmonic_1;
NSArray *Harmonic_2;
NSArray *Harmonic_3;

NSArray *None;
NSArray *Ack;

-(id)init {
    self = [super init];
    
    if (!self) {
        return nil;
    }
    
    // In the form of MIDI SysEx Message
    Ionian_1 = [[NSArray alloc] initWithObjects:@"C3", @"D3", @"E3", @"F3", @"G3", @"A3", @"B3", @"C4", nil];
    Ionian_2 = [[NSArray alloc] initWithObjects:@"C4", @"D4", @"E4", @"F4", @"G4", @"A4", @"B4", @"C5", nil];
    Ionian_3 = [[NSArray alloc] initWithObjects:@"C4", @"E4", @"G4", @"C5", @"D5", @"F5", @"A5", @"C6", nil];
    
    Dorian_1 = [[NSArray alloc] initWithObjects:@"C3", @"D3", @"D#3", @"F3", @"G3", @"A3", @"A#3", @"C4", nil];
    Dorian_2 = [[NSArray alloc] initWithObjects:@"C4", @"D4", @"D#4", @"F4", @"G4", @"A4", @"A#4", @"C5", nil];
    Dorian_3 = [[NSArray alloc] initWithObjects:@"C4", @"D#4", @"F4", @"A#4", @"C5", @"D#5", @"G5", @"A5", nil];
    
    Phrygian_1 = [[NSArray alloc] initWithObjects:@"C3", @"C#3", @"D#3", @"F3", @"G3", @"G#3", @"A#3", @"C4", nil];
    Phrygian_2 = [[NSArray alloc] initWithObjects:@"C4", @"C#4", @"D#4", @"F4", @"G4", @"G#4", @"A#4", @"C5", nil];
    Phrygian_3 = [[NSArray alloc] initWithObjects:@"C4", @"C#4", @"F4", @"G4", @"G#4", @"C5", @"C#5", @"F5", nil];
    
    Lydian_1 = [[NSArray alloc] initWithObjects:@"C3", @"D3", @"E3", @"F#3", @"G3", @"A3", @"B3", @"C4", nil];
    Lydian_2 = [[NSArray alloc] initWithObjects:@"C4", @"D4", @"E4", @"F#4", @"G4", @"A4", @"B4", @"C5", nil];
    Lydian_3 = [[NSArray alloc] initWithObjects:@"C4", @"E4", @"F#4", @"G4", @"C5", @"D5", @"E5", @"F#5", nil];
    
    Mixolydian_1 = [[NSArray alloc] initWithObjects:@"C3", @"D3", @"E3", @"F3", @"G3", @"A3", @"A#3", @"C4", nil];
    Mixolydian_2 = [[NSArray alloc] initWithObjects:@"C4", @"D4", @"E4", @"F4", @"G4", @"A4", @"A#4", @"C5", nil];
    Mixolydian_3 = [[NSArray alloc] initWithObjects:@"C4", @"E4", @"G4", @"A#4", @"C5", @"E5", @"G5", @"A#5", nil];
    
    Aeolian_1 = [[NSArray alloc] initWithObjects:@"C3", @"D3", @"D#3", @"F3", @"G3", @"G#3", @"A#3", @"C4", nil];
    Aeolian_2 = [[NSArray alloc] initWithObjects:@"C4", @"D4", @"D#4", @"F4", @"G4", @"G#4", @"A#4", @"C5", nil];
    Aeolian_3 = [[NSArray alloc] initWithObjects:@"C4", @"D4", @"D#4", @"F4", @"G#4", @"A#4", @"C5", @"E5", nil];
    
    Pentatonic_1 = [[NSArray alloc] initWithObjects:@"C3", @"D3", @"E3", @"G3", @"A3", @"C4", @"D4", @"E4", nil];
    Pentatonic_2 = [[NSArray alloc] initWithObjects:@"C4", @"D4", @"E4", @"G4", @"A4", @"C5", @"D5", @"E5", nil];
    Pentatonic_3 = [[NSArray alloc] initWithObjects:@"C5", @"D5", @"E5", @"G5", @"A5", @"C6", @"D6", @"E6", nil];
    
    Blues_1 = [[NSArray alloc] initWithObjects:@"C3", @"D3", @"D#3", @"E3", @"G3", @"G#3", @"A3", @"C4", nil];
    Blues_2 = [[NSArray alloc] initWithObjects:@"C4", @"D4", @"D#4", @"E4", @"G4", @"G#4", @"A4", @"C5", nil];
    Blues_3 = [[NSArray alloc] initWithObjects:@"C4", @"D4", @"D#4", @"E4", @"F4", @"G4", @"G#4", @"A4", nil];
    
    Harmonic_1 = [[NSArray alloc] initWithObjects:@"C3", @"D3", @"D#3", @"F3", @"G3", @"G#3", @"B3", @"C4", nil];
    Harmonic_2 = [[NSArray alloc] initWithObjects:@"C4", @"D4", @"D#4", @"F4", @"G4", @"G#4", @"B4", @"C5", nil];
    Harmonic_3 = [[NSArray alloc] initWithObjects:@"C4", @"D4", @"D#4", @"F4", @"G#4", @"B4", @"C5", @"E5", nil];
    
    None = [[NSArray alloc] initWithObjects:@"C0", nil];
    Ack = [[NSArray alloc] initWithObjects:@"C0", @"C0", nil];
    
    _MusicAssignment = @{
                         @"Ionian_1": Ionian_1,
                         @"Ionian_2": Ionian_2,
                         @"Ionian_3": Ionian_3,
                         
                         @"Dorian_1":Dorian_1,
                         @"Dorian_2":Dorian_2,
                         @"Dorian_3":Dorian_3,
                         
                         @"Phrygian_1":Phrygian_1,
                         @"Phrygian_2":Phrygian_2,
                         @"Phrygian_3":Phrygian_3,
                         
                         @"Lydian_1":Lydian_1,
                         @"Lydian_2":Lydian_2,
                         @"Lydian_3":Lydian_3,
                         
                         @"Mixolydian_1":Mixolydian_1,
                         @"Mixolydian_2":Mixolydian_2,
                         @"Mixolydian_3":Mixolydian_3,
                         
                         @"Aeolian_1":Aeolian_1,
                         @"Aeolian_2":Aeolian_2,
                         @"Aeolian_3":Aeolian_3,
                         
                         @"Pentatonic_1":Pentatonic_1,
                         @"Pentatonic_2":Pentatonic_2,
                         @"Pentatonic_3":Pentatonic_3,
                         
                         @"Blues_1":Blues_1,
                         @"Blues_2":Blues_2,
                         @"Blues_3":Blues_3,
                         
                         @"Harmonic_1":Harmonic_1,
                         @"Harmonic_2":Harmonic_2,
                         @"Harmonic_3":Harmonic_3,
                         
                         @"None":None,
                         @"Ack":Ack
              };
    return self;
}


@end
