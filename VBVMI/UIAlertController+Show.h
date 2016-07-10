//
//  UIAlertController+Show.h
//  VBVMI
//
//  http://stackoverflow.com/a/30941356
//  Created by Thomas Carey on 26/03/16.
//  Copyright © 2016 Tom Carey. All rights reserved.


#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface UIAlertController (Show)

- (void)show;
- (void)show:(BOOL)animated;

@end
