//
//  WeatherAppUITests.m
//  WeatherAppUITests
//
//  Created by Manik Lamba on 2/28/17.
//  Copyright © 2017 Manik Lamba. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "ViewController.h"

@interface WeatherAppUITests : XCTestCase
@property (nonatomic) ViewController*vc;
@end

@implementation WeatherAppUITests

-(ViewController*) vc{
    if (!_vc) {
        _vc = [[ViewController alloc]init];
    }
    return _vc;
}

- (void)setUp {
    [super setUp];
    
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    // In UI tests it is usually best to stop immediately when a failure occurs.
    self.continueAfterFailure = NO;
    // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
    [[[XCUIApplication alloc] init] launch];
    
    // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    XCTAssertTrue(_vc.viewLoaded);
    [[[XCUIApplication alloc] init].buttons[@"Weather Lookup"] tap];
    [self testDateFormatterPerformance];
    // Use recording to get started writing UI tests.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
}

- (void)testDateFormatterPerformance {
    [self measureBlock:^{
        NSString *string = [_vc convertUnixEpocTimeToEst:@"1369821049"];
        NSLog(@"%@",string);
    }];
}

@end
