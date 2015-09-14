//
//  NoteTests.m
//  BlocNotes
//
//  Created by Weinan Qiu on 2015-09-14.
//  Copyright (c) 2015 Kumiq. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "Note.h"

@interface NoteTests : XCTestCase

@end

@implementation NoteTests

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testInitWithDictionary {
    NSDictionary *json = @{@"title": @"bla", @"content": @"blabla"};
    Note *note = [[Note alloc] initWithDictionary:json];
    XCTAssert(note);
    XCTAssertEqualObjects(note.title, @"bla");
    XCTAssertEqualObjects(note.content, @"blabla");
}
@end
