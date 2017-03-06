#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "ACPDownloadConstants.h"
#import "ACPDownloadView.h"
#import "ACPIndeterminateGoogleLayer.h"
#import "ACPIndeterminateLayer.h"
#import "ACPLayerProtocol.h"
#import "ACPProgressLayer.h"
#import "ACPStaticImages.h"
#import "ACPStaticImagesAlternative.h"
#import "ACPStaticImagesProtocol.h"

FOUNDATION_EXPORT double ACPDownloadVersionNumber;
FOUNDATION_EXPORT const unsigned char ACPDownloadVersionString[];

