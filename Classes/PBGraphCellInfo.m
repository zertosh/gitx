//
//  PBGraphCellInfo.m
//  GitX
//
//  Created by Pieter de Bie on 27-08-08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "PBGraphCellInfo.h"


@implementation PBGraphCellInfo

- (id)initWithPosition:(int)p andLines:(struct PBGitGraphLine *)l
{
	self = [super init];
	if (!self) {
		return nil;
	}
	self.position = p;
	self.lines = l;
	
	return self;
}

- (void)setLines:(struct PBGitGraphLine *)l
{
	free(self->_lines);
	self->_lines = l;
}

-(void) dealloc
{
	free(self->_lines);
}

@end
