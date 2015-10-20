//
//  FirstViewController.m
//  BluetoothChatApplication
//
//  Created by Pankaj Verma on 17/08/15.
//  Copyright © 2015 Pankaj Verma. All rights reserved.
//

#import "FirstViewController.h"
#import "AppDelegate.h"
#import "chatTableViewCell.h"

@interface FirstViewController ()
@property (nonatomic, strong) AppDelegate *appDelegate;
-(void)sendMyMessage;
-(void)didReceiveDataWithNotification:(NSNotification *)notification;
-(void)noConnection:(NSNotification *)notification;
@property CGFloat height;
@end

@implementation FirstViewController
NSMutableArray *users ;
NSMutableArray *comments;
NSMutableArray *theData;
NSInteger lastIndex;
- (void)viewDidLoad {
    [super viewDidLoad];
    self.tabBarController.delegate = self;
    self.connected = false;
    _tvChat.separatorStyle = UITableViewCellSeparatorStyleNone;
    _height = self.view.frame.size.height;
    users =  [[NSMutableArray alloc] init];
    comments = [[NSMutableArray alloc] init];
    theData = [[NSMutableArray alloc] init];
    lastIndex = 0;
    // Do any additional setup after loading the view, typically from a nib.
    _appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    _txtMessage.delegate = self;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveDataWithNotification:)
                                                 name:@"MCDidReceiveDataNotification"
                                               object:nil];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(noConnection:)
                                                     name:@"CONNECTIONINFO"
                                                   object:nil];
    });

    
}
-(void)viewWillAppear:(BOOL)animated{
    AppDelegate *delegate = [UIApplication sharedApplication].delegate;
    NSManagedObjectContext *context = delegate.managedObjectContext;
    NSFetchRequest *request = [[NSFetchRequest alloc]initWithEntityName:@"CHATBOX"];
    NSMutableArray * result =  [[context executeFetchRequest:request error:NULL] mutableCopy];
    if (result) {
        theData = result;
        lastIndex = theData.count-1;
        printf("last index = %ld\n",(long)lastIndex);
    }
    else
    printf("couldn't fetch request");
}
- (IBAction)dismissKeyBoard:(UITapGestureRecognizer *)sender {
    
     [self.view setFrame:CGRectMake(0,0,self.view.frame.size.width,_height)];
    [_txtMessage resignFirstResponder];
     _sendButton.titleLabel.textColor = [UIColor grayColor];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
   dispatch_async(dispatch_get_main_queue(), ^{
    if (_txtMessage.hasText) {
        [self sendMyMessage];
        
    }
   });
    return YES;
}
- (IBAction)sendMessage:(id)sender {

    if (_txtMessage.hasText) {
        [self sendMyMessage];

    }
}

- (IBAction)cancelMessage:(id)sender {
  
    _txtMessage.text = @"";
    _sendButton.titleLabel.textColor = [UIColor grayColor];
//    [_txtMessage resignFirstResponder];
}
-(void)noConnection:(NSNotification *)notification{
    if ([[notification.userInfo valueForKey:@"connected"] isEqualToString:@"YES"]) {
         self.connected = true;
    }
    else{
        self.connected = false;
    }
    if (self.connected) {
        printf("connected");
    }
}
-(void)sendMyMessage{
    NSData *dataToSend = [_txtMessage.text dataUsingEncoding:NSUTF8StringEncoding];
    NSArray *allPeers = _appDelegate.mcManager.session.connectedPeers;
    NSError *error;
   
    if (self.connected) {
        [_appDelegate.mcManager.session sendData:dataToSend
                                         toPeers:allPeers
                                        withMode:MCSessionSendDataReliable
                                           error:&error];
        if (error) {
            NSLog(@"%@", [error localizedDescription]);
        }
        
        AppDelegate *delegate = [UIApplication sharedApplication].delegate;
        NSManagedObjectContext *context = delegate.managedObjectContext;
        NSEntityDescription *description = [NSEntityDescription entityForName:@"CHATBOX" inManagedObjectContext:context];
        NSManagedObject *obj = [[NSManagedObject alloc]initWithEntity:description insertIntoManagedObjectContext:context];
        [obj setValue:@"Me" forKey:@"name"];
        [obj setValue:_txtMessage.text forKey:@"comment"];
        [obj setValue:[NSDate date] forKey:@"time"];
        NSError *err = nil;
        if (![context save:&err]) {
            printf("could not save.")   ;
        }
        
        
        [theData addObject:obj];
       

        
           }
 else{
    printf("no connection no send");
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setObject:@"Me" forKey:@"name"];
    [dict setObject:[NSString stringWithFormat:@"%@\U000026A0 (not send)",_txtMessage.text] forKey:@"comment"];
    [dict setObject:@"   " forKey:@"time"];
    [theData addObject:dict];
    }

    //    [users insertObject:@"Me" atIndex:0];
//    [comments insertObject:_txtMessage.text atIndex:0];
//    [users addObject:@"Me"];
//    [comments addObject:_txtMessage.text];
     lastIndex++;
    dispatch_async(dispatch_get_main_queue(), ^{
         [_tvChat reloadData];
        NSIndexPath* ip = [NSIndexPath indexPathForRow:theData.count-1 inSection:0];
        [self.tvChat scrollToRowAtIndexPath:ip atScrollPosition:UITableViewScrollPositionTop animated:NO];
    });
     [_txtMessage setText:@""];
    //    dispatch_queue_t coreDataThread = dispatch_queue_create("com.tavant.BluetoothChatApplication", DISPATCH_QUEUE_SERIAL);
//    
//    dispatch_async(coreDataThread, ^{
//        
//        [self.tvChat reloadData];
//        
//    });
    
//    dispatch_release(YourThreadName);
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0),
//                   ^{
//                       
//                       dispatch_async(dispatch_get_main_queue(),
//                                      ^{
//                                          [self.tvChat reloadData];
//                                      });
//                   });
    

    //[_tvChat reloadData];
    
   // [_tvChat setText:[_tvChat.text stringByAppendingString:[NSString stringWithFormat:@"I wrote:\n%@\n\n", _txtMessage.text]]];
   
  

  //  [_txtMessage resignFirstResponder];
}

-(void)didReceiveDataWithNotification:(NSNotification *)notification{
   
    MCPeerID *peerID = [[notification userInfo] objectForKey:@"peerID"];
    NSString *peerDisplayName = peerID.displayName;
//    if ([[[notification userInfo] objectForKey:@"data"] isEqualToString:@"START"]) {
//        NSLog(@"%@ is typing",peerDisplayName);
//        return;
//    }
    NSData *receivedData = [[notification userInfo] objectForKey:@"data"];
    NSString *receivedText = [[NSString alloc] initWithData:receivedData encoding:NSUTF8StringEncoding];
    
    if ([receivedText isEqualToString:@"START"]) {
        NSLog(@"%@ is typing",peerDisplayName);
        
        //[self.view reloadInputViews];
        dispatch_async(dispatch_get_main_queue(), ^{
            _updateLabel.text = [NSString stringWithFormat:@"%@ is typing ...",peerDisplayName];
        });

       
        return;
    }
    static int unreadChat = 0;
     dispatch_async(dispatch_get_main_queue(), ^{
    if (self.tabBarController.selectedIndex != 0) {
        
        unreadChat++;
        UITabBar *tabBar = self.tabBarController.tabBar;
        UITabBarItem *tabBarItem0 = [tabBar.items objectAtIndex:0];
        [tabBarItem0 setTitle:[NSString  stringWithFormat:@"Chat(%d)",unreadChat]];
       // [tabBarItem0 setImage:[UIImage imageNamed:@"img1"]];
      
    }
    else {
        unreadChat = 0 ;
        UITabBar *tabBar = self.tabBarController.tabBar;
          UITabBarItem *tabBarItem0 = [tabBar.items objectAtIndex:0];
          [tabBarItem0 setTitle:@"Chat"];
     }
           });
    
    
    //    if ([receivedText isEqualToString:@"END"]) {
//        NSLog(@"Last seen :%@ ",[NSDate date]);
//        dispatch_async(dispatch_get_main_queue(), ^{
//        _updateLabel.text = [NSString stringWithFormat:@"Last seen :%@ ",[NSDate date]];
//       [self.view reloadInputViews];
//             });
//       
//        return;
//    }

//    [users insertObject:peerDisplayName atIndex:0];
//    [comments insertObject:receivedText atIndex:0];
//    [users addObject:peerDisplayName];
//    [comments addObject:receivedText];
    dispatch_async(dispatch_get_main_queue(), ^{
        _updateLabel.text = [NSString stringWithFormat:@"Last seen %@ ",[NSDate date]];
       // [self.view reloadInputViews];
    });

    
    AppDelegate *delegate = [UIApplication sharedApplication].delegate;
    NSManagedObjectContext *context = delegate.managedObjectContext;
    NSEntityDescription *description = [NSEntityDescription entityForName:@"CHATBOX" inManagedObjectContext:context];
    NSManagedObject *obj = [[NSManagedObject alloc]initWithEntity:description insertIntoManagedObjectContext:context];
    [obj setValue:peerDisplayName forKey:@"name"];
    [obj setValue:receivedText forKey:@"comment"];
    [obj setValue:[NSDate date] forKey:@"time"];
    NSError *err = nil;
    if (![context save:&err]) {
        printf("could not save.")   ;
    }
    
    [theData addObject:obj];
    lastIndex++;
    printf("last index2 = %ld\n",(long)lastIndex);
    dispatch_async(dispatch_get_main_queue(), ^{
        [_tvChat reloadData];
        NSIndexPath* ip = [NSIndexPath indexPathForRow:theData.count-1 inSection:0];
        [self.tvChat scrollToRowAtIndexPath:ip atScrollPosition:UITableViewScrollPositionTop animated:NO];
        
    });
//    dispatch_queue_t coreDataThread = dispatch_queue_create("com.tavant.BluetoothChatApplication", DISPATCH_QUEUE_SERIAL);
//    
//    dispatch_async(coreDataThread, ^{
//        
//        [self.tvChat reloadData];
//        
//    });
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0),
//                   ^{
//                       
//                       dispatch_async(dispatch_get_main_queue(),
//                                      ^{
//                                          [self.tvChat reloadData];
//                                      });
//                   });
    

    //[_tvChat reloadData];

  //  [_tvChat performSelectorOnMainThread:@selector(setText:) withObject:[_tvChat.text stringByAppendingString:[NSString stringWithFormat:@"%@ wrote:\n%@\n\n", peerDisplayName, receivedText]] waitUntilDone:NO];
}

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
   //  _sendButton.titleLabel.textColor = [UIColor greenColor];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    return YES;
}


- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardDidHideNotification object:nil];
    
    [self.view endEditing:YES];
    return YES;
}


- (void)keyboardDidShow:(NSNotification *)notification
{
    NSDictionary* keyboardInfo = [notification userInfo];
    NSValue* keyboardFrameBegin = [keyboardInfo valueForKey:UIKeyboardFrameBeginUserInfoKey];
    CGRect keyboardFrameBeginRect = [keyboardFrameBegin CGRectValue];
    [UIView animateWithDuration:1.0 animations:^{
        
        [self.view setFrame:CGRectMake(0,0,self.view.frame.size.width,_height- keyboardFrameBeginRect.size.height)];
    
    } ];
    
}

-(void)keyboardDidHide:(NSNotification *)notification
{    [UIView animateWithDuration:0.0 animations:^{

    [self.view setFrame:CGRectMake(0,0,self.view.frame.size.width,_height)];
 
}];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
         _sendButton.titleLabel.textColor = [UIColor greenColor];
    NSData *dataToSendS = [@"START" dataUsingEncoding:NSUTF8StringEncoding];
   //  NSData *dataToSendE = [@"END" dataUsingEncoding:NSUTF8StringEncoding];
    NSArray *allPeers = _appDelegate.mcManager.session.connectedPeers;
    __block NSError *error;
    dispatch_async(dispatch_get_main_queue(), ^{
        [_appDelegate.mcManager.session sendData:dataToSendS
                                         toPeers:allPeers
                                        withMode:MCSessionSendDataReliable
                                           error:&error];
        if (error) {
            NSLog(@"%@", [error localizedDescription]);
        }
        
    });
//    if (range.length <= 1) {
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [_appDelegate.mcManager.session sendData:dataToSendE
//    toPeers:allPeers
//    withMode:MCSessionSendDataReliable
//    error:&error];
//        if (error) {
//            NSLog(@"%@", [error localizedDescription]);
//        }
//        
//    });
//
//    }

//    if (range.length == 1) {
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [_appDelegate.mcManager.session sendData:dataToSendS
//                                             toPeers:allPeers
//                                            withMode:MCSessionSendDataReliable
//                                               error:&error];
//            if (error) {
//                NSLog(@"%@", [error localizedDescription]);
//            }
//            
//            });
//        }
//    else if(range.length == 0){
//                      dispatch_async(dispatch_get_main_queue(), ^{
//                    [_appDelegate.mcManager.session sendData:dataToSendE
//                                                     toPeers:allPeers
//                                                    withMode:MCSessionSendDataReliable
//                                                       error:&error];
//
//                    if (error) {
//                        NSLog(@"%@", [error localizedDescription]);
//                    }
//                    
//                    });
//
//        }
//
    
    return YES;
}
-(UITableViewCell*)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath{
NSString *tableIdentifier = @"theCell";
//   UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:tableIdentifier];
//    cell.textLabel.text = [theData[indexPath.row] valueForKey:@"name"];
//    cell.detailTextLabel.text = [theData[indexPath.row] valueForKey:@"comment"];

//    if([[theData[indexPath.row] valueForKey:@"name"]  isEqualToString:@"Me"])
//                cell.textLabel.textColor = [UIColor lightGrayColor];
//        else cell.textLabel.textColor = [UIColor purpleColor];
//    
//        
//    if (indexPath.row == lastIndex)        cell.detailTextLabel.font = [UIFont systemFontOfSize:20];
//        else  cell.detailTextLabel.font = [UIFont systemFontOfSize:13];
//
    
    chatTableViewCell*  cell1 = [tableView dequeueReusableCellWithIdentifier:tableIdentifier];
    cell1.name.text = [theData[indexPath.row] valueForKey:@"name"];
    cell1.chat.text = [theData[indexPath.row] valueForKey:@"comment"];
    if([[theData[indexPath.row] valueForKey:@"name"]  isEqualToString:@"Me"]){
        cell1.name.textColor = [UIColor lightGrayColor];
        //cell1.user.alpha = 0.5;
         cell1.devider.backgroundColor = [UIColor grayColor];
    }
    else {
       // cell1.name.textColor = [UIColor purpleColor];
        cell1.name.textColor = [UIColor lightGrayColor];
       //cell1.user.alpha = 1.0;
         cell1.devider.backgroundColor = [UIColor greenColor];
  
        }
    
    
    if (indexPath.row == lastIndex)        cell1.chat.font = [UIFont systemFontOfSize:20];
    else  cell1.chat.font = [UIFont systemFontOfSize:13];

    return cell1;
}
-(NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
   return  theData.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
  
    NSString *str = [theData[indexPath.row] valueForKey:@"comment"];
    CGSize constraint = CGSizeMake(self.view.frame.size.width-50, MAXFLOAT);
    NSDictionary *attributes = [NSDictionary dictionaryWithObject:[UIFont systemFontOfSize:17.0] forKey:NSFontAttributeName];
    CGRect textsize = [str boundingRectWithSize:constraint options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil];
    float textHeight = textsize.size.height +20;
    textHeight = (textHeight < 50.0) ? 50.0 : textHeight;
    NSLog(@"%f",textHeight);
    if (indexPath.row == lastIndex) {
        return textHeight+50;
    }
    return textHeight + 10;

}
- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController{
    dispatch_async(dispatch_get_main_queue(), ^{
    if (tabBarController.selectedIndex == 0) {
        UITabBar *tabBar = self.tabBarController.tabBar;
        UITabBarItem *tabBarItem0 = [tabBar.items objectAtIndex:0];
        [tabBarItem0 setTitle:@"Chat"];
       
    }
        });
    return YES;
}
@end
