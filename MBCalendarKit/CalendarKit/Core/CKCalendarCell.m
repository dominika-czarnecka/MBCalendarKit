//
//  CKCalendarCalendarCell.m
//   MBCalendarKit
//
//  Created by Moshe Berman on 4/10/13.
//  Copyright (c) 2013 Moshe Berman. All rights reserved.
//

#import "CKCalendarCell.h"
#import "CKCalendarCellColors.h"
#import <sys/utsname.h>
#import "UIView+Border.h"


#define IS_IPHONE4 ([[UIScreen mainScreen] bounds].size.width == 480 || [[UIScreen mainScreen] bounds].size.height == 480)
#define IS_IPHONE5 ([[UIScreen mainScreen] bounds].size.width == 568 || [[UIScreen mainScreen] bounds].size.height == 568)
#define IS_IPAD    ([[UIScreen mainScreen] bounds].size.width == 768 || [[UIScreen mainScreen] bounds].size.height == 768)
#define IS_IPHONE6 ([[UIScreen mainScreen] bounds].size.width == 667 || [[UIScreen mainScreen] bounds].size.height == 667)
#define IS_IPHONE6PLUS ([[UIScreen mainScreen] bounds].size.width == 736 || [[UIScreen mainScreen] bounds].size.height == 736)


@interface CKCalendarCell (){
    CGSize _size;
}

@property (nonatomic, strong) UILabel *label;
@property (nonatomic, strong) UIView *dot;

@end

@implementation CKCalendarCell

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code
        _state = CKCalendarMonthCellStateNormal;
        
        //  Normal Cell Colors
        _normalBackgroundColor = [UIColor clearColor];
        _selectedBackgroundColor = [UIColor clearColor];
        _inactiveSelectedBackgroundColor = [UIColor clearColor];
        
        //  Today Cell Color Image by device
        if (IS_IPHONE4 || IS_IPHONE5){
                _todayBackgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"dots2"]];
                _todaySelectedBackgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"dots2"]];
        }
        if(IS_IPHONE6){
            _todayBackgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"dots"]];
            _todaySelectedBackgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"dots"]];
        }
        if(IS_IPHONE6PLUS){
            _todayBackgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"dots3"]];
            _todaySelectedBackgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"dots3"]];
        }
        
        _todayTextShadowColor = [UIColor clearColor];
        _todayTextColor = [UIColor whiteColor];
        
        //  Text Colors
        _textColor = [UIColor whiteColor];
        _textShadowColor = [UIColor clearColor];
        _textSelectedColor = [UIColor whiteColor];
        _textSelectedShadowColor = [UIColor clearColor];
        
        _dotColor = [UIColor whiteColor];
        _selectedDotColor = [UIColor whiteColor];
        
        _cellBorderColor = [UIColor clearColor];
        _selectedCellBorderColor = [UIColor clearColor];
        
        // Label
        _label = [UILabel new];
        
        //  Dot
        _dot = [UIView new];
        [_dot setHidden:YES];
        _showDot = NO;
    }
    return self;
}

- (id)initWithSize:(CGSize)size
{
    self = [self init];
    if (self) {
        _size = size;
        [self.layer setCornerRadius:size.width / 2];
    }
    return self;
}

#pragma mark - View Hierarchy

- (void)willMoveToSuperview:(UIView *)newSuperview
{
    CGPoint origin = [self frame].origin;
    [self setFrame:CGRectMake(origin.x, origin.y, _size.width, _size.height)];
    [self layoutSubviews];
    [self applyColors];
}

#pragma mark - Layout

- (void)layoutSubviews
{
    [self configureLabel];
    [self configureDot];
    
    [self addSubview:[self dot]];
    [self addSubview:[self label]];
}

#pragma mark - Setters

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    
    self.label.frame = CGRectMake(0, 0, CGRectGetWidth(frame), CGRectGetHeight(frame));
}


- (void)setState:(CKCalendarMonthCellState)state
{
    if (state > CKCalendarMonthCellStateOutOfRange || state < CKCalendarMonthCellStateTodaySelected) {
        return;
    }
    
    _state = state;
    
    [self applyColorsForState:_state];
}

- (void)setNumber:(NSNumber *)number
{
    _number = number;
    
    //  TODO: Locale support?
    NSString *stringVal = [number stringValue];
    [[self label] setText:stringVal];
}

- (void)setShowDot:(BOOL)showDot
{
    _showDot = showDot;
    [[self dot] setHidden:!showDot];
}

#pragma mark - Recycling Behavior

-(void)prepareForReuse
{
    //  Alpha, by default, is 1.0
    [[self label]setAlpha:1.0];
    
    [self setState:CKCalendarMonthCellStateNormal];
    
    [self applyColors];
}

#pragma mark - Label 

- (void)configureLabel
{
    UILabel *label = [self label];
    
    [label setFont:[UIFont boldSystemFontOfSize:13]];
    [label setTextAlignment:NSTextAlignmentCenter];
    
    [label setBackgroundColor:[UIColor clearColor]];
    [label setFrame:CGRectMake(0, 0, [self frame].size.width, [self frame].size.height)];
}

#pragma mark - Dot

- (void)configureDot
{
    UIView *dot = [self dot];
    
    CGFloat selfWidth = [self frame].size.width -10;
    
    [[dot layer] setCornerRadius:selfWidth /2];
    CGRect dotFrame = CGRectMake(5, 5, selfWidth, selfWidth);
    [[self dot] setFrame:dotFrame];
    [[self dot] setBackgroundColor:[UIColor whiteColor]];
    
}

#pragma mark - UI Coloring

- (void)applyColors
{    
    [self applyColorsForState:[self state]];
    [self showBorder];
}

//  TODO: Make the cell states bitwise, so we can use masks and clean this up a bit
- (void)applyColorsForState:(CKCalendarMonthCellState)state
{
    //  Default colors and shadows
    [[self label] setTextColor:[[self dot] isHidden] ? [self textColor] : [UIColor blackColor]];
    [[self label] setShadowColor:[self textShadowColor]];
    [[self label] setShadowOffset:CGSizeMake(0, 0.5)];
    
    [self setBorderColor:[self cellBorderColor]];
    [self setBorderWidth:0.5];
    [self setBackgroundColor:[self normalBackgroundColor]];
    
    //  Today cell
    if(state == CKCalendarMonthCellStateTodaySelected)
    {
        [self setBackgroundColor:[self todaySelectedBackgroundColor]];
        [[self label] setShadowColor:[self todayTextShadowColor]];
        [[self label] setTextColor:[[self dot] isHidden] ? [self todayTextColor] : [UIColor blackColor]];
        [self setBorderColor:[self backgroundColor]];
    }
    
    //  Today cell, selected
    else if(state == CKCalendarMonthCellStateTodayDeselected)
    {
        [self setBackgroundColor:[self todayBackgroundColor]];
        [[self label] setShadowColor:[self todayTextShadowColor]];
        [[self label] setTextColor:[[self dot] isHidden] ? [self todayTextColor] : [UIColor blackColor]];
        [self setBorderColor:[self backgroundColor]];
        [self showBorder];
    }
    
    //  Selected cells in the active month have a special background color
    else if(state == CKCalendarMonthCellStateSelected)
    {
        [self setBackgroundColor:[self selectedBackgroundColor]];
        [self setBorderColor:[self selectedCellBorderColor]];
        [[self label] setTextColor:[[self dot] isHidden] ? [self textSelectedColor] : [UIColor blackColor]];
        [[self label] setShadowColor:[self textSelectedShadowColor]];
        [[self label] setShadowOffset:CGSizeMake(0, -0.5)];
    }
    
    if (state == CKCalendarMonthCellStateInactive) {
        [[self label] setAlpha:0.5];    //  Label alpha needs to be lowered
        [[self label] setShadowOffset:CGSizeZero];
    }
    else if (state == CKCalendarMonthCellStateInactiveSelected)
    {
        [[self label] setAlpha:0.5];    //  Label alpha needs to be lowered
        [[self label] setShadowOffset:CGSizeZero];
        [self setBackgroundColor:[self inactiveSelectedBackgroundColor]];
    }
    else if(state == CKCalendarMonthCellStateOutOfRange)
    {
        [[self label] setAlpha:0.01];    //  Label alpha needs to be lowered
        [[self label] setShadowOffset:CGSizeZero];
    }
    
    //  Make the dot follow the label's style
    [[self dot] setBackgroundColor:[UIColor whiteColor]];
    [[self dot] setAlpha:[[self label] alpha]];
}

#pragma mark - Selection State

- (void)setSelected
{
    
    CKCalendarMonthCellState state = [self state];
    if (state == CKCalendarMonthCellStateInactive) {
        [self setState:CKCalendarMonthCellStateInactiveSelected];
    }
    else if(state == CKCalendarMonthCellStateNormal)
    {
        [self setState:CKCalendarMonthCellStateSelected];
    }
    else if(state == CKCalendarMonthCellStateTodayDeselected)
    {
        [self setState:CKCalendarMonthCellStateTodaySelected];
    }
}

- (void)setDeselected
{
    CKCalendarMonthCellState state = [self state];
    
    if (state == CKCalendarMonthCellStateInactiveSelected) {
        [self setState:CKCalendarMonthCellStateInactive];
    }
    else if(state == CKCalendarMonthCellStateSelected)
    {
        [self setState:CKCalendarMonthCellStateNormal];
    }
    else if(state == CKCalendarMonthCellStateTodaySelected)
    {
        [self setState:CKCalendarMonthCellStateTodayDeselected];
    }
}

- (void)setOutOfRange
{
    [self setState:CKCalendarMonthCellStateOutOfRange];
}
@end
