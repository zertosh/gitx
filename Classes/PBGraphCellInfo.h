//
//  PBGraphCellInfo.h
//  GitX
//
//  Created by Pieter de Bie on 27-08-08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PBGitGraphLine.h"

@interface PBGraphCellInfo : NSObject

@property (nonatomic, assign) struct PBGitGraphLine *lines;
@property (nonatomic, assign) int nLines;
@property (nonatomic, assign) int position, numColumns;
@property (nonatomic, assign) char sign;


- (id)initWithPosition:(int) p andLines:(struct PBGitGraphLine *) l;

@end