//
//  ViewController.m
//  AzureSDKDemoObjC
//
//  Created by Travis Prescott on 8/27/19.
//  Copyright © 2019 Azure SDK Team. All rights reserved.
//

#import "ViewController.h"
#import <AzureCore/AzureCore.h>
#import <AzureAppConfiguration/AzureAppConfiguration.h>
#import <os/log.h>

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UILabel *textLabel;

@end

@implementation ViewController

// read-only connection string
NSString *connectionString = @"";

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSError *error;
    AppConfigurationClient *client = [[AppConfigurationClient alloc] initWithConnectionString:connectionString error:&error];
    HttpResponse *raw = [[HttpResponse alloc] init];
    AZCCollection *settings = [client getConfigurationSettingsForKey:nil forLabel:nil withResponse:raw error:&error];
    if (settings != nil) {
        [_textLabel setTextColor:UIColor.blackColor];
        NSString *text = [[NSString alloc] initWithFormat:@"%@", [[raw statusCode] description]];
        for (id object in settings) {
            ConfigurationSetting *setting = (ConfigurationSetting *)object;
            text = [NSString stringWithFormat:@"%@\n{%@: %@}", text, [setting key], [setting value]];
        }
        [_textLabel setText: text];
    } else if (error != nil) {
        [_textLabel setTextColor:UIColor.redColor];
        [_textLabel setText: [error localizedDescription]];
    }
}

@end
