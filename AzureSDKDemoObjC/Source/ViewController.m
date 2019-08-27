//
//  ViewController.m
//  AzureSDKDemoObjC
//
//  Created by Travis Prescott on 8/27/19.
//  Copyright © 2019 Azure SDK Team. All rights reserved.
//

#import "ViewController.h"
#import <AzureCore/AzureCore.h>

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UILabel *textLabel;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    NSURL *url = [[NSURL alloc] initWithString:@"www.microsoft.com"];
    HttpRequest *request = [[HttpRequest alloc] initWithHttpMethod:HttpMethodGET url:url];
    [_textLabel setText:request.description];
}

@end
