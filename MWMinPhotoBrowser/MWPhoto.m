//
//  MWPhoto.m
//  MWPhotoBrowser
//
//  Created by Michael Waterfall on 17/10/2010.
//  Copyright 2010 d3i. All rights reserved.
//

#import "MWPhoto.h"
#import "MWPhotoBrowser.h"
#import <SDWebImage/SDWebImageManager.h>
#import <SDWebImage/SDWebImageOperation.h>

@interface MWPhoto () {

    BOOL _loadingInProgress;
    id <SDWebImageOperation> _webImageOperation;
        
}

- (void)imageLoadingComplete;

@end

@implementation MWPhoto

@synthesize underlyingImage = _underlyingImage; // synth property from protocol

#pragma mark - Class Methods

+ (MWPhoto *)photoWithImage:(UIImage *)image {
	return [[MWPhoto alloc] initWithImage:image];
}

// Deprecated
+ (MWPhoto *)photoWithFilePath:(NSString *)path {
    return [MWPhoto photoWithURL:[NSURL fileURLWithPath:path]];
}

+ (MWPhoto *)photoWithURL:(NSURL *)url {
	return [[MWPhoto alloc] initWithURL:url];
}

#pragma mark - Init

- (id)initWithImage:(UIImage *)image {
	if ((self = [super init])) {
		_image = image;
	}
	return self;
}

// Deprecated
- (id)initWithFilePath:(NSString *)path {
	if ((self = [super init])) {
		_photoURL = [NSURL fileURLWithPath:path];
	}
	return self;
}

- (id)initWithURL:(NSURL *)url {
	if ((self = [super init])) {
		_photoURL = [url copy];
	}
	return self;
}

#pragma mark - MWPhoto Protocol Methods

- (UIImage *)underlyingImage {
    return _underlyingImage;
}

- (void)loadUnderlyingImageAndNotify {
    NSAssert([[NSThread currentThread] isMainThread], @"This method must be called on the main thread.");
    if (_loadingInProgress) return;
    _loadingInProgress = YES;
    @try {
        if (self.underlyingImage) {
            [self imageLoadingComplete];
        } else {
            [self performLoadUnderlyingImageAndNotify];
        }
    }
    @catch (NSException *exception) {
        self.underlyingImage = nil;
        _loadingInProgress = NO;
        [self imageLoadingComplete];
    }
    @finally {
    }
}

// Set the underlyingImage
- (void)performLoadUnderlyingImageAndNotify {
    
    // Get underlying image
    if (_image) {
        
        // We have UIImage!
        self.underlyingImage = _image;
        [self imageLoadingComplete];
        
    } else if (_photoURL) {
        
        // Check what type of url it is
        if ([_photoURL isFileReferenceURL]) {
            // Load from local file async
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                @autoreleasepool {
                    @try {
                        self.underlyingImage = [UIImage imageWithContentsOfFile:_photoURL.path];
                        if (!_underlyingImage) {
                            MWLog(@"Error loading photo from path: %@", _photoURL.path);
                        }
                    } @finally {
                        [self performSelectorOnMainThread:@selector(imageLoadingComplete) withObject:nil waitUntilDone:NO];
                    }
                }
            });
            
        } else {
            
            // Load async from web (using SDWebImage)
            @try {
                SDWebImageManager *manager = [SDWebImageManager sharedManager];
                _webImageOperation = [manager.imageDownloader downloadImageWithURL:_photoURL
                                                           options:0
                                                          progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL* url) {
                                                              if (expectedSize > 0) {
                                                                  float progress = receivedSize / (float)expectedSize;
                                                                  NSDictionary* dict = [NSDictionary dictionaryWithObjectsAndKeys:
                                                                                        [NSNumber numberWithFloat:progress], @"progress",
                                                                                        self, @"photo", nil];
                                                                  dispatch_async(dispatch_get_main_queue(),^{
                                                                      [[NSNotificationCenter defaultCenter] postNotificationName:MWPHOTO_PROGRESS_NOTIFICATION object:dict];
                                                                      });
                                                              }
                                                          }
                                                         completed:^(UIImage *image, NSData* data, NSError *error, BOOL finished) {
                                                             if (error) {
                                                                 MWLog(@"SDWebImage failed to download image: %@", error);
                                                             }
                                                             _webImageOperation = nil;
                                                             self.underlyingImage = image;
                                                             [self imageLoadingComplete];
                                                         }];
            } @catch (NSException *e) {
                MWLog(@"Photo from web: %@", e);
                _webImageOperation = nil;
                [self imageLoadingComplete];
            }
            
        }
        
    } else {
        
        // Failed - no source
        @throw [NSException exceptionWithName:NSGenericException reason:nil userInfo:nil];
        
    }
}

// Release if we can get it again from path or url
- (void)unloadUnderlyingImage {
    _loadingInProgress = NO;
	self.underlyingImage = nil;
}

- (void)imageLoadingComplete {
    NSAssert([[NSThread currentThread] isMainThread], @"This method must be called on the main thread.");
    // Complete so notify
    _loadingInProgress = NO;
    // Notify on next run loop
    [self performSelector:@selector(postCompleteNotification) withObject:nil afterDelay:0];
}

- (void)postCompleteNotification {
    [[NSNotificationCenter defaultCenter] postNotificationName:MWPHOTO_LOADING_DID_END_NOTIFICATION
                                                        object:self];
}

- (void)cancelAnyLoading {
    if (_webImageOperation) {
        [_webImageOperation cancel];
        _loadingInProgress = NO;
    }
}

@end
