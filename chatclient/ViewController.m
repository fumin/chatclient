//
//  ViewController.m
//  chatclient
//
//  Created by  on 12/4/27.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property (copy, nonatomic) NSString* _username;
@property (copy, nonatomic) NSString* _room;
@property (strong, nonatomic) OnlineSession* _onlineSession;
@property (strong, nonatomic) NSMutableArray* _messages;
-(NSString*)protocol_len:(NSString*)instr;
-(void)showErrorAlertWithTitle:(NSString*)alertTitle message:(NSString*)message;

@end

@implementation ViewController
@synthesize tView;
@synthesize chatView;
@synthesize inputMessageField;
@synthesize joinView;
@synthesize inputNameField;
@synthesize inputRoomField;

@synthesize _onlineSession;
@synthesize _username;
@synthesize _room;
@synthesize _messages;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self._username = [[NSString alloc] init];
    self._room = [[NSString alloc] init];
    self._messages = [[NSMutableArray alloc] init];
}

- (void)viewDidUnload
{
    [self setJoinView:nil];
    [self setInputNameField:nil];
    [self setInputRoomField:nil];
    [self setInputMessageField:nil];
    [self setTView:nil];
    [self setChatView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (IBAction)joinChat:(id)sender {
    if (self._onlineSession == nil || self._username != inputNameField.text || self._room != inputRoomField.text) {
        self._username = inputNameField.text;
        self._room = inputRoomField.text;
        self._onlineSession = [[OnlineSession alloc] initWithHost:@"nandalu.idv.tw" port:7777];
        self._onlineSession.delegate = self;
        [self._onlineSession sendData:[[NSString stringWithFormat:@"\x01%@%@%@%@", [self protocol_len:self._room], self._room, [self protocol_len:_username], _username] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    [self.view bringSubviewToFront:chatView];
}

- (NSString*) protocol_len:(NSString*)instr {
    NSString* ls = [NSString stringWithFormat:@"%d", [instr lengthOfBytesUsingEncoding:NSUTF8StringEncoding]];
    switch ([ls length]) {
        case 4:
            return ls;
        case 3:
            return [NSString stringWithFormat:@"%@%@", @"0", ls];
        case 2:
            return [NSString stringWithFormat:@"%@%@", @"00", ls];
        case 1:
            return [NSString stringWithFormat:@"%@%@", @"000", ls];
        default:
            NSLog(@"Error in protocol_len...");
            return ls;
    }
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString* MyIdentifier = @"ChatCellIdentifier";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MyIdentifier];
    }
    cell.textLabel.text = [self._messages objectAtIndex:indexPath.row];
    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self._messages.count;
}

-(void)onlineSession:(OnlineSession *)session receivedData:(NSData *)data{
    [self._messages addObject:[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]];
    [tView beginUpdates];
    [tView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:[self._messages count]-1 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
    [tView endUpdates];
    [tView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[self._messages count]-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}

-(void)showErrorAlertWithTitle:(NSString*)alertTitle message:(NSString*)message{
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:alertTitle message:message delegate:self cancelButtonTitle:NSLocalizedString(@"Bummer", @"Bummer") otherButtonTitles:nil];
    [alert show];
}

-(void)onlineSession:(OnlineSession *)session encounteredReadError:(NSError *)error{
    [self.view bringSubviewToFront:joinView];
    [self showErrorAlertWithTitle:NSLocalizedString(@"Error Reading", @"Error Reading") message:NSLocalizedString(@"Could not read sent packet", @"Could not read sent packet")];
    self._onlineSession = nil;
    [self._messages removeAllObjects];
}

-(void)onlineSession:(OnlineSession *)session encounteredWriteError:(NSError *)error{
    [self.view bringSubviewToFront:joinView];
    [self showErrorAlertWithTitle:NSLocalizedString(@"Error Writing", @"Error Writing") message:NSLocalizedString(@"Could not send packet", @"Could not send packet")];
    self._onlineSession = nil;
    [self._messages removeAllObjects];
}

-(void)onlineSessionDisconnected:(OnlineSession *)session{
    [self.view bringSubviewToFront:joinView];
    [self showErrorAlertWithTitle:NSLocalizedString(@"Server Disconnected", @"Server Disconnected") message:NSLocalizedString(@"Server disconnected or otherwise could not be reached", @"Server disconnected or otherwise could not be reached")];
    self._onlineSession = nil;
    [self._messages removeAllObjects];
}

- (IBAction)sendMessage:(id)sender {
    [self._onlineSession sendData:[[NSString stringWithFormat:@"\x03%@%@%@%@", [self protocol_len:@""], [self protocol_len:self._room], self._room, inputMessageField.text] dataUsingEncoding:NSUTF8StringEncoding]];
    inputMessageField.text = @"";
    [self.inputMessageField resignFirstResponder];
}

@end
