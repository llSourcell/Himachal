//
//  Video.m
//  Himachal
//
//  Created by Siraj Ravel on 8/7/15.
//  Copyright (c) 2015 Ellipse. All rights reserved.
//

#import "Video.h"

@interface Video()
@property (nonatomic, strong) AVAsset *video;
@end

@implementation Video

- (instancetype)initWithAsset:(AVAsset *)asset
{
    if (!(self = [super init])) return nil;
    self.video = asset;
    return self;
}

+ (instancetype)videoWithURL:(NSURL *)url
{
    return [[self alloc] initWithAsset:[AVAsset assetWithURL:url]];
}

+ (instancetype)videoWithStringURL:(NSString *)url
{
    return [[self alloc] initWithAsset:[AVAsset assetWithURL:[NSURL URLWithString:url]]];
}

@end
