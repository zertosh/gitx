//
//  PBGitRepositoryWatcherEventPath.h
//  GitX
//
//  Created by Pieter de Bie on 9/6/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface PBGitRepositoryWatcherEventPath : NSObject

@property (nonatomic, assign) FSEventStreamEventFlags flag;
@property (nonatomic, strong) NSString * path;

@end
