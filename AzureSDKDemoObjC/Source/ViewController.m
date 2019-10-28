// --------------------------------------------------------------------------
//
// Copyright (c) Microsoft Corporation. All rights reserved.
//
// The MIT License (MIT)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the ""Software""), to
// deal in the Software without restriction, including without limitation the
// rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
// sell copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED *AS IS*, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
// FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
// IN THE SOFTWARE.
//
// --------------------------------------------------------------------------

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
    AZCCollection *settings = [client listConfigurationSettingsForKey:nil forLabel:nil withResponse:raw error:&error];
    if (settings != nil) {
        [_textLabel setTextColor:UIColor.blackColor];
        NSString *text = [[NSString alloc] initWithFormat:@"%@", [[raw statusCode] description]];
        for (id object in [settings items]) {
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
