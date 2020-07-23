#import "BPFlashlightManager.h"
@import AVFoundation;

@interface BPFlashlightManager ()
@property (nonatomic, readonly) AVCaptureDevice *flashlight;
@end

@implementation BPFlashlightManager

- (instancetype)init {
    self = [super init];
    if (self) {
        _flashlight = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    }
    return self;
}

- (BOOL)isAvailable {
    return [self.flashlight isTorchAvailable] && [self.flashlight isTorchModeSupported:AVCaptureTorchModeOn];
}

+ (NSSet<NSString *> *)keyPathsForValuesAffectingIsOn {
    NSString *flashlightSel = NSStringFromSelector(@selector(flashlight));
    NSString *torchModeSel = NSStringFromSelector(@selector(torchMode));
    NSString *compoundSel = [NSString stringWithFormat:@"%@.%@", flashlightSel, torchModeSel];
    return [NSSet setWithObject:compoundSel];
}

- (BOOL)isOn {
    return self.flashlight.torchMode == AVCaptureTorchModeOn;
}

- (void)toggleWithCompletionBlock:(void (^)(BOOL))completion {
    BOOL success = [self.flashlight lockForConfiguration:nil];
    if (success) {
        if ([self.flashlight isTorchActive]) {
            [self.flashlight setTorchMode:AVCaptureTorchModeOff];
        } else {
            [self.flashlight setTorchMode:AVCaptureTorchModeOn];
        }

        [self.flashlight unlockForConfiguration];
    }

    completion(success);
}

@end