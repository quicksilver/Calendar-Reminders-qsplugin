//
//  CalendarPrefPane.m
//  CalendarPlugin
//
//  Created by Patrick Robertson 2023/09/05
//  Copyright Patrick Robertson. All rights reserved.
//

#import "CalendarPrefPane.h"
#import "QSiCalModule.h"

@implementation CalendarPrefPane

- (void)mainViewDidLoad {

    // set the values on the calendar popup
    QSiCalModule *sharedInstance = [QSiCalModule sharedInstance];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [calendarPopup removeAllItems];
    [calendarPopup addItemsWithTitles:[[sharedInstance eventsCalendars] arrayByEnumeratingArrayUsingBlock:^id(EKCalendar *cal) {
        return [NSString stringWithFormat:@"%@ (%@)", cal.title, cal.source.title];
    }]];
    NSString *uuid = [defaults objectForKey:@"QSiCalDefaultCalendar"];
    NSUInteger i = [[sharedInstance eventsCalendars] indexOfObjectPassingTest:^BOOL(EKCalendar *cal, NSUInteger idx, BOOL *stop) {
        return [cal.calendarIdentifier isEqualToString:uuid];
    }];
    if (i != NSNotFound) {
        [calendarPopup selectItemAtIndex:i];
    }
    // set the values for the reminders popup
    [remindersPopup removeAllItems];
    [remindersPopup addItemsWithTitles:[[sharedInstance remindersCalendars] arrayByEnumeratingArrayUsingBlock:^id(EKCalendar *cal) {
        return [NSString stringWithFormat:@"%@ (%@)", cal.title, cal.source.title];
    }]];
    i = [[sharedInstance remindersCalendars] indexOfObjectPassingTest:^BOOL(EKCalendar *cal, NSUInteger idx, BOOL *stop) {
        return [cal.calendarIdentifier isEqualToString:[defaults objectForKey:@"QSiCalDefaultReminderCalendar"]];
    }];
    if (i != NSNotFound) {
        [remindersPopup selectItemAtIndex:i];
    }
}

-(IBAction)popupChanged:(id)sender {
    NSString *defaultsKey = sender == remindersPopup ? @"QSiCalDefaultReminderCalendar" : @"QSiCalDefaultCalendar";
    NSArray *calendars = sender == remindersPopup ? [[QSiCalModule sharedInstance] remindersCalendars] : [[QSiCalModule sharedInstance] eventsCalendars];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    // get the index from the right claendar, and set the UUID
    NSUInteger i = [sender indexOfSelectedItem];
    if (i != NSNotFound) {
        [defaults setObject:[[calendars objectAtIndex:i] calendarIdentifier] forKey:defaultsKey];
    }
}

@end
