//
//  QSZoom.m
//  zoom.us Plugin
//
//  Created by Rob McBroom on 2019/3/8.
//  Copyright © 2019 Quicksilver. All rights reserved.
//

#import "QSMeetingResolver.h"

#pragma mark Helpers

QSObject *objectFromEvent(EKEvent *event, NSDictionary *eventData) {
	
	NSString *url = eventData[@"url"];
	NSString *serviceName = eventData[@"service"];
	NSString *title = [event title];
	
	QSObject *meeting = [QSObject URLObjectWithURL:url title:title];

	
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateStyle:NSDateFormatterNoStyle];
	[dateFormatter setTimeStyle:NSDateFormatterShortStyle];
	NSString *start = [dateFormatter stringFromDate:[event startDate]];
	NSString *end = [dateFormatter stringFromDate:[event endDate]];
	[meeting setObject:[NSString stringWithFormat:@"%@ (%@, %@ – %@)", title, serviceName, start, end] forMeta:@"meetingDescription"];

	// Set icon based on meeting service
	NSImage *icon = iconForMeetingURL(url);
	if (icon) {
		[meeting setIcon:icon];
		[meeting setIconLoaded:YES];
	}
	
	return meeting;
}

NSDictionary *meetingDataFromEvent(EKEvent *event) {
	NSMutableArray *searchFields = [NSMutableArray arrayWithCapacity:3];
	if ([event URL]) {
		[searchFields addObject:[[event URL] absoluteString]];
	}
	if ([event location]) {
		[searchFields addObject:[event location]];
	}
	if ([event notes]) {
		[searchFields addObject:[event notes]];
	}
	for (NSString *field in searchFields) {
		NSDictionary *info = meetingDataFromString(field);
		if (info) {
			NSString *urlString = info[@"url"];
			if (urlString.length > 0) {
				return info;
			}
		}
	}
	return nil;
}
