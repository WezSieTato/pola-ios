#import "BPLogger.h"


@implementation BPLogger

+ (void)logWithLine:(NSInteger)line fileName:(NSString *)fileName method:(NSString *)method format:(NSString *)format, ... {
    va_list args;
    va_start(args, format);
    NSString *string = [[NSString alloc] initWithFormat:format arguments:args];
    NSLog(@"%@ [%@][%@][%i]", string, fileName, method, line);
    va_end(args);
}


@end