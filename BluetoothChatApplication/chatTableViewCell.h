//
//  chatTableViewCell.h
//  BluetoothChatApplication
//
//  Created by Pankaj Verma on 24/08/15.
//  Copyright © 2015 Pankaj Verma. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface chatTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UILabel *chat;
@property (weak, nonatomic) IBOutlet UIImageView *user;

@property (weak, nonatomic) IBOutlet UIView *devider;

@end
