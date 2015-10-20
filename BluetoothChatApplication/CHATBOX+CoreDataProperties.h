//
//  CHATBOX+CoreDataProperties.h
//  BluetoothChatApplication
//
//  Created by Pankaj Verma on 19/08/15.
//  Copyright © 2015 Pankaj Verma. All rights reserved.
//
//  Delete this file and regenerate it using "Create NSManagedObject Subclass…"
//  to keep your implementation up to date with your model.
//

#import "CHATBOX.h"

NS_ASSUME_NONNULL_BEGIN

@interface CHATBOX (CoreDataProperties)

@property (nullable, nonatomic, retain) NSDate *time;
@property (nullable, nonatomic, retain) NSString *name;
@property (nullable, nonatomic, retain) NSString *comment;

@end

NS_ASSUME_NONNULL_END
