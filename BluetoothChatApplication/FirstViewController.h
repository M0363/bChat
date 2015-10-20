//
//  FirstViewController.h
//  BluetoothChatApplication
//
//  Created by Pankaj Verma on 17/08/15.
//  Copyright © 2015 Pankaj Verma. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FirstViewController : UIViewController<UITextFieldDelegate,UITabBarControllerDelegate,UITableViewDataSource>
@property BOOL connected;
@property (weak, nonatomic) IBOutlet UILabel *updateLabel;
@property (weak, nonatomic) IBOutlet UIButton *sendButton;

@property (weak, nonatomic) IBOutlet UITextField *txtMessage;
@property (weak, nonatomic) IBOutlet UITableView *tvChat;
- (IBAction)sendMessage:(id)sender;
- (IBAction)cancelMessage:(id)sender;
@end

