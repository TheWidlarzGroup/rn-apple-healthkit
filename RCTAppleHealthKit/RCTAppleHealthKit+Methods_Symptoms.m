//
//  RCTAppleHealthKit+Methods_Symptoms.m
//  RCTAppleHealthKit
//
//  Created by Bartek Widlarz on 18/09/2020.
//

#import "RCTAppleHealthKit+Methods_Symptoms.h"
#import "RCTAppleHealthKit+Queries.h"
#import "RCTAppleHealthKit+Utils.h"

#import <React/RCTBridgeModule.h>
#import <React/RCTEventDispatcher.h>

@implementation RCTAppleHealthKit (Methods_Symptoms)

- (void)symptoms_getBloating:(NSDictionary *)input callback:(RCTResponseSenderBlock)callback
{
    NSDate *startDate = [RCTAppleHealthKit dateFromOptions:input key:@"startDate" withDefault:nil];
    NSDate *endDate = [RCTAppleHealthKit dateFromOptions:input key:@"endDate" withDefault:[NSDate date]];
    double limit = [RCTAppleHealthKit doubleFromOptions:input key:@"limit" withDefault:HKObjectQueryNoLimit];
    NSLog(@"startDate: %@", startDate);

    NSSortDescriptor *timeSortDescriptor = [[NSSortDescriptor alloc]
        initWithKey:HKSampleSortIdentifierEndDate
        ascending:NO
    ];

    HKCategoryType *type = [HKCategoryType categoryTypeForIdentifier: HKCategoryTypeIdentifierBloating];
    
    NSPredicate *predicate = [RCTAppleHealthKit predicateForSamplesBetweenDates:startDate endDate:endDate];

    HKSampleQuery *query = [[HKSampleQuery alloc]
        initWithSampleType:type
        predicate:predicate
        limit: limit
        sortDescriptors:@[timeSortDescriptor]
        resultsHandler:^(HKSampleQuery *query, NSArray *results, NSError *error) {

            if (error != nil) {
                NSLog(@"error with fetchCumulativeSumStatisticsCollection: %@", error);
                callback(@[RCTMakeError(@"error with fetchCumulativeSumStatisticsCollection", error, nil)]);
                return;
                }
        
                NSMutableArray *data = [NSMutableArray arrayWithCapacity:(10)];

                for (HKCategorySample *sample in results) {
                    NSLog(@"sample for bloating %@", sample);
                    NSString *startDateString = [RCTAppleHealthKit buildISO8601StringFromDate:sample.startDate];
                    NSString *endDateString = [RCTAppleHealthKit buildISO8601StringFromDate:sample.endDate];
                    NSInteger val = sample.value;
                        
                    NSString *valueString;
                    
                    switch (val) {
                            case HKCategoryValueSeverityUnspecified:
                                valueString = @"UNSPECIFIED";
                                break;
                            case HKCategoryValueSeverityNotPresent:
                                valueString = @"NOTPRESENT";
                                break;
                            case HKCategoryValueSeverityMild:
                                valueString = @"MILD";
                                break;
                            case HKCategoryValueSeverityModerate:
                                valueString = @"MODERATE";
                                break;
                            case HKCategoryValueSeveritySevere:
                                valueString = @"SEVERE";
                                break;
                            default:
                                valueString = @"UNKNOWN";
                                break;
                    }
                    NSDictionary *elem = @{
                            @"startDate" : startDateString,
                            @"endDate" : endDateString,
                            @"value" : valueString,
                    };

                    [data addObject:elem];
        }
        callback(@[[NSNull null], data]);
     }
    ];
    [self.healthStore executeQuery:query];
}
@end

