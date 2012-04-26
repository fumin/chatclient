//
//  ViewController.h
//  chatclient
//
//  Created by  on 12/4/27.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OnlineSession.h"

@interface ViewController : UIViewController <OnlineSessionDelegate, UITableViewDelegate, UITableViewDataSource>
@property (strong, nonatomic) IBOutlet UIView *joinView;
@property (strong, nonatomic) IBOutlet UITextField *inputNameField;
@property (strong, nonatomic) IBOutlet UITextField *inputRoomField;
- (IBAction)joinChat:(id)sender;
@property (strong, nonatomic) IBOutlet UITextField *inputMessageField;
- (IBAction)sendMessage:(id)sender;
@property (strong, nonatomic) IBOutlet UITableView *tView;
@property (strong, nonatomic) IBOutlet UIView *chatView;

@end
