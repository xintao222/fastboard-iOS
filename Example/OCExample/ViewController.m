//
//  ViewController.m
//  OCExample
//
//  Created by xuyunshi on 2021/12/28.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

#import "ViewController.h"
#import "RoomInfo.h"
#import <Fastboard/Fastboard-Swift.h>
#import <Masonry/Masonry.h>
#import "Utility.h"

@interface ViewController() <FastboardDelegate>
@property (nonatomic, strong) UIStackView* stackView;
@property (nonatomic, copy) Theme theme;
@end

@implementation ViewController {
    Fastboard* _fastboard;
    Theme _theme;
}

// MARK: - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupFastboard];
    [self setupTools];
    if (@available(iOS 13.0, *)) {
        _theme = ThemeAuto;
        [self applyTheme:ThemeAuto];
    } else {
        _theme = ThemeLight;
        [self applyTheme:ThemeLight];
    }
}

// MARK: - Action
- (void)onTheme {
    _theme = [self nextThemeFor:_theme];
    [self applyTheme:_theme];
}

- (void)onDirection {
    if (FastboardView.appearance.operationBarDirection == OperationBarDirectionLeft) {
        FastboardView.appearance.operationBarDirection = OperationBarDirectionRight;
        [self.stackView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.view).inset(10);
            make.right.equalTo(self.view).inset(88);
            make.width.equalTo(@120);
        }];
    } else {
        FastboardView.appearance.operationBarDirection = OperationBarDirectionLeft;
        [self.stackView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.view).inset(10);
            make.left.equalTo(self.view).inset(88);
            make.width.equalTo(@120);
        }];
    }
    [AppearanceManager.shared commitUpdate];
}

// MARK: - Private
- (void)setupFastboard {
    FastBoardSDK.globalFastboardRatio = 16.0 / 9.0;
    _fastboard = [FastBoardSDK createFastboardWithAppId:[RoomInfo getValueFrom:RoomInfoAPPID]
                                               roomUUID:[RoomInfo getValueFrom:RoomInfoRoomID]
                                              roomToken:[RoomInfo getValueFrom:RoomInfoRoomToken]
                                                userUID:@"some-unique"
                                    customFastBoardView:nil];
    FastboardView *fastView = _fastboard.view;
    _fastboard.delegate = self;
    [_fastboard joinRoom];
    [self.view addSubview:fastView];
    self.view.autoresizesSubviews = TRUE;
    fastView.autoresizingMask = TRUE;
    fastView.frame = self.view.bounds;
    fastView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
}

- (void)setupTools {
    [self.view addSubview:self.stackView];
    self.stackView.axis = UILayoutConstraintAxisVertical;
    self.stackView.distribution = UIStackViewDistributionFillEqually;
    [self.stackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).inset(10);
        make.right.equalTo(self.view).inset(88);
        make.width.equalTo(@120);
    }];
}

- (Theme)nextThemeFor: (Theme)theme {
    if (@available(iOS 13.0, *)) {
        if ([theme isEqualToString:ThemeAuto]) {
            return ThemeLight;
        } else if ([theme isEqualToString:ThemeLight]) {
            return ThemeDark;
        } else {
            return ThemeAuto;
        }
    } else {
        if ([theme isEqualToString:ThemeAuto]) {
            return ThemeLight;
        } else if ([theme isEqualToString:ThemeLight]) {
            return ThemeDark;
        } else {
            return ThemeLight;
        }
    }
}

- (void)applyTheme: (Theme)theme {
    UIButton* themeBtn = [self.stackView arrangedSubviews][0];
    [themeBtn setTitle:theme forState:UIControlStateNormal];
    if ([theme isEqualToString:ThemeAuto]) {
        [FastboardThemeManager.shared apply:DefaultTheme.defaultAutoTheme];
    } else if ([theme isEqualToString:ThemeLight]) {
        [FastboardThemeManager.shared apply:DefaultTheme.defaultDarkTheme];
    } else if ([theme isEqualToString:ThemeDark]) {
        [FastboardThemeManager.shared apply:DefaultTheme.defaultAutoTheme];
    }
}

- (NSArray<UIButton *> *)setupButtons {
    NSArray* titles = @[@"onTheme",
                        @"onDirection"];
    NSMutableArray* btns = [NSMutableArray new];
    [titles enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString* title = obj;
        int index = (int)idx;
        UIButton* btn = [Utility buttonWith:title index:index];
        [btn addTarget:self action:NSSelectorFromString(title) forControlEvents:UIControlEventTouchUpInside];
        [btns addObject:btn];
    }];
    return btns;
}

// MARK: - Lazy
- (UIStackView *)stackView {
    if (!_stackView) {
        _stackView = [[UIStackView alloc] initWithArrangedSubviews:[self setupButtons]];
    }
    return _stackView;
}


// MARK: - Fastboard Delegate
- (void)fastboard:(Fastboard * _Nonnull)fastboard error:(FastError * _Nonnull)error {
    NSLog(@"error %@", error);
}

- (void)fastboardPhaseDidUpdate:(Fastboard * _Nonnull)fastboard phase:(enum FastPhase)phase {
    NSLog(@"phase, %d", (int)phase);
}

- (void)fastboardUserKickedOut:(Fastboard * _Nonnull)fastboard reason:(NSString * _Nonnull)reason {
    NSLog(@"kicked out");
}

@end
