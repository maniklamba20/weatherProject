//
//  ViewController.m
//  WeatherApp
//
//  Created by Manik Lamba on 2/28/17.
//  Copyright © 2017 Manik Lamba. All rights reserved.
//

#import "ViewController.h"
#define OWMURL @"http://api.openweathermap.org/data/2.5/weather?q="
#define APPKEY @"8e7c4aed47181d98eaff8e8bbc0b65c4"
#define OWMImageURL @"http://openweathermap.org/img/w/"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UITextField *cityTxtField;
@property (weak, nonatomic) IBOutlet UITextField *stateTxtField;
@property (nonatomic,strong) NSMutableArray *sectionalData;
@property (nonatomic,strong) NSMutableDictionary *infoData;
@property (weak, nonatomic) IBOutlet UILabel *minTempLabel;
@property (weak, nonatomic) IBOutlet UILabel *maxTempLabel;
@property (weak, nonatomic) IBOutlet UILabel *humidityLabel;
@property (weak, nonatomic) IBOutlet UILabel *pressureLabel;
@property (weak, nonatomic) IBOutlet UILabel *windLabel;
@property (weak, nonatomic) IBOutlet UILabel *sunriseLabel;
@property (weak, nonatomic) IBOutlet UILabel *sunsetLabel;
@property (weak, nonatomic) IBOutlet UIImageView *weatherImg;
@property (weak, nonatomic) IBOutlet UILabel *cityLabel;
@property (weak, nonatomic) IBOutlet UILabel *weatherDescLabel;
@property (weak, nonatomic) IBOutlet UIView *backView;
@property (weak, nonatomic) IBOutlet UILabel *errorLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@end

@implementation ViewController

-(NSMutableArray*)sectionalData{
    if (!_sectionalData) {
        _sectionalData = [[NSMutableArray alloc]init];
    }
    return _sectionalData;
}

-(NSMutableDictionary*)infoData{
    if (!_infoData) {
        _infoData = [[NSMutableDictionary alloc]init];
    }
    return _infoData;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.cityTxtField.text = [[NSUserDefaults standardUserDefaults]valueForKey:@"lastCitySearched"];
    self.stateTxtField.text = [[NSUserDefaults standardUserDefaults]valueForKey:@"lastStateSearched"];
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Textfield Delegates

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (self.stateTxtField.text.length >= 2 && range.length == 0)
    {
        return NO; // return NO to not change text
    }
    {return YES;}
}




#pragma mark Lookup Button logic
- (IBAction)weatherLookup:(id)sender {
    if (self.cityTxtField.text.length>0 && self.stateTxtField.text.length>0 ){
        [self rememberTheLastSearchedCityAndState];
        self.activityIndicator.hidden = NO;
        [self.activityIndicator startAnimating];

        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@,%@,us&APPID=%@",OWMURL,self.cityTxtField.text,self.stateTxtField.text,APPKEY]];
            NSLog(@"Warning2- %@",url);
            NSURLSession *urlSession= [NSURLSession sharedSession];
            if (url){
            [[urlSession dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                NSMutableDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:data options: NSJSONReadingMutableContainers error: &error];
                dispatch_async(dispatch_get_main_queue(), ^{
                    if ([[NSThread currentThread] isMainThread]){
                        if ([[jsonDict valueForKey:@"message"] length]>0){
                            self.backView.hidden = YES;
                            self.errorLabel.hidden = NO;
                            self.errorLabel.text= @"Temporary service error. Please check your internet connection and retry after sometime.";
                        }
                        else{
                            [self updateTheViewWithDictValues:jsonDict];
                            self.backView.hidden = NO;
                            self.errorLabel.hidden = YES;
                        }
                         [self.activityIndicator stopAnimating];
                            
                        
                    }
                    else{
                    }
                });
            }] resume];
        }
        });
    }
    else{
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Missing Information" message:@"Please enter both city and state." preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* dismissBtn = [UIAlertAction
                                    actionWithTitle:@"Dismiss"
                                    style:UIAlertActionStyleDefault
                                    handler:^(UIAlertAction * action) {
                                        NSLog(@"Close the alert");
                                    }];
        [alert addAction:dismissBtn];
        [self presentViewController:alert animated:YES completion:nil];
    }
    
}

-(void)updateTheViewWithDictValues:(NSMutableDictionary*)dictInfo{
    NSLog(@"Warning3- %@",dictInfo);

    self.cityLabel.text = [dictInfo valueForKey:@"name"];
    self.weatherDescLabel.text = [[[dictInfo valueForKey:@"weather"]valueForKey:@"description"] objectAtIndex:0];
    
    __block NSData *imagedata;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString * baseUrlString =[OWMImageURL stringByAppendingString:[NSString stringWithFormat:@"%@.png",[[[dictInfo valueForKey:@"weather"]valueForKey:@"icon"] objectAtIndex:0]]];
        NSURL *url = [NSURL URLWithString:baseUrlString];
        NSLog(@"Warning1- %@",url);
        NSURLSession *urlSession= [NSURLSession sharedSession];
        [[urlSession dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            imagedata = data;

        }] resume];
        dispatch_async(dispatch_get_main_queue(), ^{
        self.weatherImg.image = [UIImage imageWithData:imagedata];
        });
    });
    

        self.maxTempLabel.text = [NSString stringWithFormat:@"%0.1f F",[self TempConversionFor:[[[dictInfo valueForKey:@"main"] valueForKey:@"temp_max"] floatValue]]];
        self.minTempLabel.text = [NSString stringWithFormat:@"%0.1f F",[self TempConversionFor:[[[dictInfo valueForKey:@"main"] valueForKey:@"temp_min"] floatValue]]];
        self.humidityLabel.text = [NSString stringWithFormat:@"%@ %%",[[dictInfo valueForKey:@"main"] valueForKey:@"humidity"]];
        self.pressureLabel.text = [NSString stringWithFormat:@"%@ hpa",[[dictInfo valueForKey:@"main"] valueForKey:@"pressure"]];
        self.windLabel.text = [NSString stringWithFormat:@"%@ m/s",[[dictInfo valueForKey:@"wind"] valueForKey:@"speed"]];
        self.sunriseLabel.text = [NSString stringWithFormat:@"%@", [self convertUnixEpocTimeToEst:[[dictInfo valueForKey:@"sys"] valueForKey:@"sunrise"]]];
        self.sunsetLabel.text = [NSString stringWithFormat:@"%@", [self convertUnixEpocTimeToEst:[[dictInfo valueForKey:@"sys"] valueForKey:@"sunset"]]];
    
    
}

// Remember the last searched city and state

-(void)rememberTheLastSearchedCityAndState{
    [[NSUserDefaults standardUserDefaults] setObject:self.cityTxtField.text forKey:@"lastCitySearched"];
    [[NSUserDefaults standardUserDefaults] setObject:self.stateTxtField.text forKey:@"lastStateSearched"];
    [[NSUserDefaults standardUserDefaults]synchronize];
}


// Required Conversions

-(float)TempConversionFor:(float)tempK{
    return (tempK*9/5)-459.67;
}

-(NSString*)convertUnixEpocTimeToEst:(NSString*)unixDate{
    NSTimeInterval seconds = [unixDate doubleValue];
    // Create NSDate object
    NSDate *epochNSDate = [[NSDate alloc] initWithTimeIntervalSince1970:seconds];
    // Use NSDateFormatter to display epochNSDate in local time zone
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH:mm"];
    return [dateFormatter stringFromDate:epochNSDate];
}


@end
