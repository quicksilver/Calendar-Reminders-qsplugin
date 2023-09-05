//
//  CalendarPrefPane.h
//  CalendarPlugin
//
//  Created by Patrick Robertson 2023/09/05
//  Copyright Patrick Robertson. All rights reserved.
//

#import <QSInterface/QSPreferencePane.h>


@interface CalendarPrefPane : QSPreferencePane {
    IBOutlet NSPopUpButton *calendarPopup;
    IBOutlet NSPopUpButton *remindersPopup;
}
- (IBAction)popupChanged:(id)sender;

@end
