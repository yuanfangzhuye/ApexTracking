//
//  ApexExceptionHandler.m
//  ApexTracker
//
//  Created by 李超 on 2018/10/17.
//  Copyright © 2018年 LiChao. All rights reserved.
//

#import "ApexExceptionHandler.h"
#import "ApexTracksQueue.h"
#include <libkern/OSAtomic.h>
#include <stdatomic.h>

static NSString * const UncaughtExceptionHandlerSignalExceptionName = @"UncaughtExceptionHandlerSignalExceptionName";
static NSString * const UncaughtExceptionHandlerSignalKey = @"UncaughtExceptionHandlerSignalKey";

static volatile atomic_int_fast32_t UncaughtExceptionCount = 0;
static const atomic_int_fast32_t UncaughtExceptionMaximum = 10;

@interface ApexExceptionHandler ()

@property (nonatomic) NSUncaughtExceptionHandler *defaultExceptionHandler;
@property (nonatomic, unsafe_unretained) struct sigaction *prev_signal_handlers;
//@property (nonatomic, strong) NSHashTable *apexInstances;

@end

@implementation ApexExceptionHandler

+ (instancetype)sharedHandler {
    static ApexExceptionHandler *gSharedHandler = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        gSharedHandler = [[ApexExceptionHandler alloc] init];
    });
    return gSharedHandler;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        // Create a hash table of weak pointers to apex instances
//        _apexInstances = [NSHashTable weakObjectsHashTable];
        _prev_signal_handlers = calloc(NSIG, sizeof(struct sigaction));
        
        // Install our handler
//        [self setupHandlers];
    }
    return self;
}

- (void)dealloc {
    free(_prev_signal_handlers);
}

- (void)setupHandlers {
    _defaultExceptionHandler = NSGetUncaughtExceptionHandler();
    NSSetUncaughtExceptionHandler(&APEXHandleException);
    
    struct sigaction action;
    sigemptyset(&action.sa_mask);
    action.sa_flags = SA_SIGINFO;
    action.sa_sigaction = &APEXSignalHandler;
    int signals[] = {SIGABRT, SIGILL, SIGSEGV, SIGFPE, SIGBUS};
    for (int i = 0; i < sizeof(signals) / sizeof(int); i++) {
        struct sigaction prev_action;
        int err = sigaction(signals[i], &action, &prev_action);
        if (err == 0) {
            memcpy(_prev_signal_handlers + signals[i], &prev_action, sizeof(prev_action));
        } else {
            [[PEXLogger sharedInstance] debug:[NSString stringWithFormat:@"Errored while trying to set up sigaction for signal %d", signals[i]]];
        }
    }
}

//- (void)addApexInstance:(ApexTracksManager *)instance {
//    NSParameterAssert(instance != nil);
//    
//    [self.apexInstances addObject:instance];
//}

void APEXSignalHandler(int signalNumber, struct __siginfo *info, void *context) {
    ApexExceptionHandler *handler = [ApexExceptionHandler sharedHandler];
    
    atomic_int_fast32_t exceptionCount = atomic_fetch_add_explicit(&UncaughtExceptionCount, 1, memory_order_relaxed);
    
    if (exceptionCount <= UncaughtExceptionMaximum) {
        NSDictionary *userInfo = @{UncaughtExceptionHandlerSignalKey: @(signalNumber)};
        NSException *exception = [NSException exceptionWithName:UncaughtExceptionHandlerSignalExceptionName
                                                         reason:[NSString stringWithFormat:@"Signal %d was raised.", signalNumber]
                                                       userInfo:userInfo];
        
        [handler apex_handleUncaughtException:exception];
    }
    
    struct sigaction prev_action = handler.prev_signal_handlers[signalNumber];
    // Since there is no way to pass through to the default handler, re-raise the signal as our best efforts
    if (prev_action.sa_handler == SIG_DFL) {
        signal(signalNumber, SIG_DFL);
        raise(signalNumber);
        return;
    }
    if (prev_action.sa_flags & SA_SIGINFO) {
        if (prev_action.sa_sigaction) {
            prev_action.sa_sigaction(signalNumber, info, context);
        }
    } else if (prev_action.sa_handler) {
        prev_action.sa_handler(signalNumber);
    }
}

void APEXHandleException(NSException *exception) {
    ApexExceptionHandler *handler = [ApexExceptionHandler sharedHandler];
    
    atomic_int_fast32_t exceptionCount = atomic_fetch_add_explicit(&UncaughtExceptionCount, 1, memory_order_relaxed);
    if (exceptionCount <= UncaughtExceptionMaximum) {
        [handler apex_handleUncaughtException:exception];
    }
    
    if (handler.defaultExceptionHandler) {
        handler.defaultExceptionHandler(exception);
    }
}

- (void)apex_handleUncaughtException:(NSException *)exception {
    
    [[ApexTracksQueue sharedTracksQueueInstance] saveQueueToDatabaseCompleteHandler:nil];
    
    NSMutableDictionary *properties = [[NSMutableDictionary alloc] init];
    [properties setValue:[exception reason] forKey:@"crashed_reason"];
    
    [[PEXLogger sharedInstance] debug:[NSString stringWithFormat:@"Encountered an uncaught exception. All Apex instances were archived.\nreason:%@", [exception reason]]];
}

@end
