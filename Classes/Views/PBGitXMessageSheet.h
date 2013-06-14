//
//  PBGitXMessageSheet.h
//  GitX
//
//  Created by BrotherBard on 7/4/10.
//  Copyright 2010 BrotherBard. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "RJModalRepoSheet.h"

@interface PBGitXMessageSheet : RJModalRepoSheet

+ (void)beginMessageSheetForRepo:(PBGitRepository *)repo
				 withMessageText:(NSString *)message
						infoText:(NSString *)info;
+ (void)beginMessageSheetForRepo:(PBGitRepository *)repo
					   withError:(NSError *)error;


- (void)beginMessageSheetWithMessageText:(NSString *)message
								infoText:(NSString *)info;
- (IBAction)closeMessageSheet:(id)sender;


@property (nonatomic, strong) IBOutlet NSImageView *iconView;
@property (nonatomic, strong) IBOutlet NSTextField *messageField;
@property (nonatomic, strong) IBOutlet NSTextView *infoView;
@property (nonatomic, strong) IBOutlet NSScrollView *scrollView;

@end
