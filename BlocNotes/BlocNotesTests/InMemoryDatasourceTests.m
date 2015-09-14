//
//  InMemoryDatasourceTests.m
//  BlocNotes
//
//  Created by Weinan Qiu on 2015-09-14.
//  Copyright (c) 2015 Kumiq. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "InMemoryDatasource.h"

@interface InMemoryDatasourceTests : XCTestCase

@end

@implementation InMemoryDatasourceTests

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testLoadsBundleJson {
    InMemoryDatasource *datasource = [InMemoryDatasource sharedInstnace];
    if (!datasource) {
        XCTFail(@"InMemoryDatasource did not initialize properly");
    }
    XCTAssert(datasource.notes.count > 0);
}

@end
