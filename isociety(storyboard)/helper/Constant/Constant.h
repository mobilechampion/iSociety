//
//  Constant.h
//  Seik
//
//  Created by Gavin on 10/26/14.
//  Copyright (c) 2014 Seik, Inc. All rights reserved.
//


//-------------------------------------------------------------------------------------------------------------------------------------------------
#define HEXCOLOR(c) [UIColor colorWithRed:((c>>24)&0xFF)/255.0 green:((c>>16)&0xFF)/255.0 blue:((c>>8)&0xFF)/255.0 alpha:((c)&0xFF)/255.0]

//-------------------------------------------------------------------------------------------------------------------------------------------------
#define		COLOR_NAVBAR_TITLE					HEXCOLOR(0xFFFFFFFF)
#define		COLOR_NAVBAR_BUTTON					HEXCOLOR(0xFFFFFFFF)
#define		COLOR_NAVBAR_BACKGROUND				HEXCOLOR(0x19C5F0D4)

#define		COLOR_TABBAR_LABEL					HEXCOLOR(0xFFFFFFFF)
#define		COLOR_TABBAR_BACKGROUND				HEXCOLOR(0x19C5FF00)

//-------------------------------------------------------------------------------------------------------------------------------------------------
#define		PF_USER_CLASS_NAME					@"_User"
#define		PF_USER_OBJECTID					@"objectId"
#define		PF_USER_USERNAME					@"username"
#define		PF_USER_PASSWORD					@"password"
#define		PF_USER_EMAIL						@"email"
#define		PF_USER_EMAILCOPY					@"emailCopy"
#define		PF_USER_FULLNAME					@"fullname"
#define		PF_USER_FULLNAME_LOWER				@"fullname_lower"
#define		PF_USER_FACEBOOKID					@"facebookId"
#define		PF_USER_PICTURE						@"picture"
#define		PF_USER_THUMBNAIL					@"thumbnail"
#define		PF_USER_AVIALABLITY					@"availability"
#define		PF_USER_STATUS					    @"status"
#define		PF_USER_COLOR_HUE				    @"ColorHue"
#define		PF_USER_COLOR_SAT				    @"ColorSat"
#define		PF_USER_COLOR_BRG				    @"ColorBrg"

#define     PF_FROM_USER                        @"fromuser"
#define     PF_FROM_USER_ID                     @"fromuserid"
#define     PF_TO_USER                          @"touser"
#define     PF_TO_USER_ID                       @"touserid"
#define     PF_STATUS                           @"status"

#define		PF_USER_ID                          @"currentUserID"
#define		PF_USER_FRIEND_ID                   @"friendsUserID"

#define		PF_CHAT_CLASS_NAME					@"Chat"
#define		PF_CHAT_ROOM						@"room"
#define		PF_CHAT_USER						@"user"
#define		PF_CHAT_TEXT						@"text"
#define		PF_CHAT_CREATEDAT					@"createdAt"

#define		PF_CHATROOMS_CLASS_NAME				@"ChatRooms"
#define		PF_CHATROOMS_ROOM					@"room"


#define		PF_CALENDAR_CLASS_NAME              @"Calendar"
#define		PF_CALENDAR_USER					@"user"
#define		PF_CALENDAR_DATE					@"date"
#define		PF_CALENDAR_DATE_TMSTMP             @"timestamp"

//-------------------------------------------------------------------------------------------------------------------------------------------------
#define		NOTIFICATION_APP_STARTED			@"NCAppStarted"
#define		NOTIFICATION_USER_LOGGED_IN			@"NCUserLoggedIn"
#define		NOTIFICATION_USER_LOGGED_OUT		@"NCUserLoggedOut"
#define		NOTIFICATION_LOAD_COMMENTS          @"NCLoadComments"


#define     PF_REMINDER_FROMID                  @"fromUserId"
#define     PF_REMINDER_TOID                    @"toUserId"
#define     PF_REMINDER_ROOM                    @"room"
#define     PF_REMINDER_REMINDERSTATUS          @"reminderStatus"
#define     PF_REMINDER_ACTIONTIME              @"actionTime"

#define     PF_FRIENDS                          @"Friends"


//------------------------------------------------------------------------------------------------------------------------------------------------- Important Custom Values

#define     V_MIN_POST_DOWN_VOTE_LIMIT           -2


//-------------------------------------------------------------------------------------------------------------------------------------------------


//------------------------------------------------------------------------------------------------------------------------------------------------- User alert messages

#define     M_POST_ALREADY_FLAGGED              @"Looking for some good karma? Vote down and flag any offensive content and help us keep the community appropriate for everyone!"


//-------------------------------------------------------------------------------------------------------------------------------------------------

#define AppFontSavoyeLETWithSize(fontSize) [UIFont fontWithName:@"Savoye LET" size:fontSize]

#ifdef DEBUG
#   define DLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#else
#   define DLog(...)
#endif