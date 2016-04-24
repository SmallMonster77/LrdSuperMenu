//
//  LrdSuperMenu.h
//  LrdSuperMenu
//
//  Created by 键盘上的舞者 on 4/18/16.
//  Copyright © 2016 键盘上的舞者. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LrdIndexPath : NSObject

@property (nonatomic, assign) NSInteger row; //行
@property (nonatomic, assign) NSInteger column; //列
@property (nonatomic, assign) NSInteger item; //item

- (instancetype)initWithColumn:(NSInteger)column row:(NSInteger)row;

+ (instancetype)indexPathWithColumn:(NSInteger)column row:(NSInteger)row;
+ (instancetype)indexPathWithColumn:(NSInteger)column row:(NSInteger)row item:(NSInteger)item;

@end

#pragma  mark - datasource
@class LrdSuperMenu;
@protocol LrdSuperMenuDataSource <NSObject>

@required
//每个column有多少行
- (NSInteger)menu:(LrdSuperMenu *)menu numberOfRowsInColumn:(NSInteger)column;
//每个column中每行的title
- (NSString *)menu:(LrdSuperMenu *)menu titleForRowAtIndexPath:(LrdIndexPath *)indexPath;

@optional
//有多少个column，默认为1列
- (NSInteger)numberOfColumnsInMenu:(LrdSuperMenu *)menu;
//第column列，没行的image
- (NSString *)menu:(LrdSuperMenu *)menu imageNameForRowAtIndexPath:(LrdIndexPath *)indexPath;
//detail text
- (NSString *)menu:(LrdSuperMenu *)menu detailTextForRowAtIndexPath:(LrdIndexPath *)indexPath;
//某列的某行item的数量，如果有，则说明有二级菜单，反之亦然
- (NSInteger)menu:(LrdSuperMenu *)menu numberOfItemsInRow:(NSInteger)row inColumn:(NSInteger)column;
//如果有二级菜单，则实现下列协议
//二级菜单的标题
- (NSString *)menu:(LrdSuperMenu *)menu titleForItemsInRowAtIndexPath:(LrdIndexPath *)indexPath;
//二级菜单的image
- (NSString *)menu:(LrdSuperMenu *)menu imageForItemsInRowAtIndexPath:(LrdIndexPath *)indexPath;
//二级菜单的detail text
- (NSString *)menu:(LrdSuperMenu *)menu detailTextForItemsInRowAtIndexPath:(LrdIndexPath *)indexPath;
@end

#pragma mark - delegate
@protocol LrdSuperMenuDelegate <NSObject>

@optional
//点击
- (void)menu:(LrdSuperMenu *)menu didSelectRowAtIndexPath:(LrdIndexPath *)indexPath;

@end

@interface LrdSuperMenu : UIView

@property (nonatomic, weak) id<LrdSuperMenuDelegate> delegate;
@property (nonatomic, weak) id<LrdSuperMenuDataSource> dataSource;
@property (nonatomic, strong) UIColor *textColor;
@property (nonatomic, strong) UIColor *selectedTextColor;
@property (nonatomic, strong) UIColor *detailTextColor;
@property (nonatomic, strong) UIColor *indicatorColor;
@property (nonatomic, strong) UIFont *detailTextFont;
@property (nonatomic, strong) UIColor *separatorColor;
@property (nonatomic, assign) NSInteger fontSize;
//当前选中的列
@property (nonatomic, strong) NSMutableArray *currentSelectedRows;
//当有二级列表的时候，是否调用点击代理方法
@property (nonatomic, assign) BOOL isClickHaveItemValid;

//获取title
- (NSString *)titleForRowAtIndexPath:(LrdIndexPath *)indexPath;
//初始化方法
- (instancetype)initWithOrigin:(CGPoint)origin andHeight:(CGFloat)height;
//菜单切换，选中的indexPath
- (void)selectIndexPath:(LrdIndexPath *)indexPath;
//默认选中
- (void)selectDeafultIndexPath;
//数据重载
- (void)reloadData;

@end
