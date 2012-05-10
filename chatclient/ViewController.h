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
@property (weak, nonatomic) IBOutlet UIView *joinView;
@property (weak, nonatomic) IBOutlet UITextField *inputNameField;
@property (weak, nonatomic) IBOutlet UITextField *inputRoomField;
- (IBAction)joinChat:(id)sender;
@property (weak, nonatomic) IBOutlet UITextField *inputMessageField;
- (IBAction)sendMessage:(id)sender;
@property (weak, nonatomic) IBOutlet UITableView *tView;
@property (weak, nonatomic) IBOutlet UIView *chatView;
- (IBAction)leaveRoom:(id)sender;

@end
