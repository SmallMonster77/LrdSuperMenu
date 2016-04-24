//
//  LrdSuperMenu.m
//  LrdSuperMenu
//
//  Created by 键盘上的舞者 on 4/18/16.
//  Copyright © 2016 键盘上的舞者. All rights reserved.
//

#import "LrdSuperMenu.h"

#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height
#define kTableViewCellHeight 44

#define kTextColor [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1]
#define kDetailTextColor [UIColor colorWithRed:136/255.0 green:136/255.0 blue:136/255.0 alpha:1]
#define kSeparatorColor [UIColor colorWithRed:219/255.0 green:219/255.0 blue:219/255.0 alpha:1]
#define kCellBgColor [UIColor colorWithRed:245/255.0 green:245/255.0 blue:245/255.0 alpha:1]
#define kTextSelectColor [UIColor colorWithRed:246/255.0 green:79/255.0 blue:0/255.0 alpha:1]

#define kTableViewHeight 300

typedef void(^complete)();

#pragma mark - LrdIndexPath
@implementation LrdIndexPath

- (instancetype)initWithColumn:(NSInteger)column row:(NSInteger)row {
    if (self = [super init]) {
        _column = column;
        _row = row;
        _item = -1;
    }
    return self;
}

- (instancetype)initWithColumn:(NSInteger)column row:(NSInteger)row item:(NSInteger)item {
    self = [self initWithColumn:column row:row];
    if (self) {
        _item = item;
    }
    return self;
}

+ (instancetype)indexPathWithColumn:(NSInteger)column row:(NSInteger)row {
    LrdIndexPath *path = [[self alloc] initWithColumn:column row:row];
    return path;
}

+ (instancetype)indexPathWithColumn:(NSInteger)column row:(NSInteger)row item:(NSInteger)item {
    return [[self alloc] initWithColumn:column row:row item:item];
}

@end

#pragma mark - LrdSuperMenu
@interface LrdSuperMenu () <UITableViewDataSource, UITableViewDelegate>
{
    struct {
        unsigned int numberOfRowsInColumn :1;
        unsigned int numberOfItemsInRow :1;
        unsigned int titleForRowsAtIndexPath :1;
        unsigned int titleForItemInRowAtIndexPath :1;
        unsigned int imageNameForRowAtIndexPath :1;
        unsigned int imageNameForItemInRowAtIndexPath :1;
        unsigned int detailTextForRowAtIndexPath :1;
        unsigned int detailTextForItemInRowAtIndexPath :1;
    }_dataSourceFlag;
}

@property (nonatomic, assign) CGFloat tableViewHeight;
@property (nonatomic, assign) CGPoint origin;  //原点
@property (nonatomic, assign) CGFloat height;
@property (nonatomic, assign) NSInteger numberOfColumn;  //列数
@property (nonatomic, assign) BOOL isShow;
@property (nonatomic, strong) UIView *backGroundView;
@property (nonatomic, strong) UITableView *leftTableView;  //一级列表
@property (nonatomic, strong) UITableView *rightTableView;  //二级列表
@property (nonatomic, assign) NSInteger currentSelectedColumn;  //当前选中列
@property (nonatomic, strong) UIView *bottomLine;  //底部的线条

//layers array
@property (nonatomic, copy) NSArray *titles;
@property (nonatomic, copy) NSArray *indicators;
@property (nonatomic, copy) NSArray *bgLayers;

@end

@implementation LrdSuperMenu

//初始化方法
- (instancetype)initWithOrigin:(CGPoint)origin andHeight:(CGFloat)height {
    self = [self initWithFrame:CGRectMake(origin.x, origin.y, SCREEN_WIDTH, height)];
    if (self) {
        _origin = origin;
        _height = height;
        _isShow = NO;
        _fontSize = 14;
        _currentSelectedColumn = -1;
        _isClickHaveItemValid = YES;
        _textColor = kTextColor;
        _selectedTextColor = kTextSelectColor;
        _detailTextFont = [UIFont systemFontOfSize:11];
        _separatorColor = kSeparatorColor;
        _detailTextColor = kDetailTextColor;
        _indicatorColor = kTextColor;
        _tableViewHeight = kTableViewHeight;
        
        //初始化两个tableView
        _leftTableView = [[UITableView alloc] initWithFrame:CGRectMake(origin.x, origin.y + self.frame.size.height, SCREEN_WIDTH / 2, 0) style:UITableViewStylePlain];
        _leftTableView.delegate = self;
        _leftTableView.dataSource = self;
        _leftTableView.rowHeight = kTableViewCellHeight;
        _leftTableView.separatorColor = kSeparatorColor;
        
        _rightTableView = [[UITableView alloc] initWithFrame:CGRectMake(origin.x + SCREEN_WIDTH / 2, origin.y + self.frame.size.height, SCREEN_WIDTH / 2, 0) style:UITableViewStylePlain];
        _rightTableView.delegate = self;
        _rightTableView.dataSource = self;
        _rightTableView.rowHeight = kTableViewCellHeight;
        _rightTableView.separatorColor = kSeparatorColor;
        
        self.backgroundColor = [UIColor whiteColor];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(menuTapped:)];
        [self addGestureRecognizer:tap];
        
        _backGroundView = [[UIView alloc] init];
        _backGroundView.frame = CGRectMake(origin.x, origin.y, SCREEN_WIDTH, SCREEN_HEIGHT);
        _backGroundView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.0];
        _backGroundView.opaque = NO;
        UITapGestureRecognizer *backTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backTapped:)];
        [_backGroundView addGestureRecognizer:backTap];
        
        //底部线条
        _bottomLine = [[UIView alloc] initWithFrame:CGRectMake(0, self.height - 0.5, SCREEN_WIDTH, 0.5)];
        _bottomLine.backgroundColor = kSeparatorColor;
        _bottomLine.hidden = YES;
        [self addSubview:_bottomLine];
        
    }
    return self;
}

#pragma mark - 懒加载
- (UIColor *)indicatorColor {
    if (!_indicatorColor) {
        _indicatorColor = [UIColor blackColor];
    }
    return _indicatorColor;
}

- (UIColor *)textColor {
    if (!_textColor) {
        _textColor = [UIColor blackColor];
    }
    return _textColor;
}

- (UIColor *)separatorColor {
    if (!_separatorColor) {
        _separatorColor = [UIColor blackColor];
    }
    return _separatorColor;
}

#pragma mark - 设置dataSource
- (void)setDataSource:(id<LrdSuperMenuDataSource>)dataSource {
    if (_dataSource == dataSource) {
        return;
    }
    _dataSource = dataSource;
    if ([_dataSource respondsToSelector:@selector(numberOfColumnsInMenu:)]) {
        _numberOfColumn = [_dataSource numberOfColumnsInMenu:self];
    }else {
        _numberOfColumn = 1;
    }
    
    
    _currentSelectedRows = [[NSMutableArray alloc] initWithCapacity:_numberOfColumn];
    for (int i=0; i<_numberOfColumn; i++) {
        [_currentSelectedRows addObject:@(0)];
    }
    
    //判断是否响应了某方法
    _dataSourceFlag.numberOfRowsInColumn = [_dataSource respondsToSelector:@selector(menu:numberOfRowsInColumn:)];
    _dataSourceFlag.numberOfItemsInRow = [_dataSource respondsToSelector:@selector(menu:numberOfItemsInRow:inColumn:)];
    _dataSourceFlag.titleForRowsAtIndexPath = [_dataSource respondsToSelector:@selector(menu:titleForRowAtIndexPath:)];
    _dataSourceFlag.titleForItemInRowAtIndexPath = [_dataSource respondsToSelector:@selector(menu:titleForItemsInRowAtIndexPath:)];
    _dataSourceFlag.imageNameForRowAtIndexPath = [_dataSource respondsToSelector:@selector(menu:imageNameForRowAtIndexPath:)];
    _dataSourceFlag.imageNameForItemInRowAtIndexPath = [_dataSource respondsToSelector:@selector(menu:imageForItemsInRowAtIndexPath:)];
    _dataSourceFlag.detailTextForRowAtIndexPath = [_dataSource respondsToSelector:@selector(menu:detailTextForRowAtIndexPath:)];
    _dataSourceFlag.detailTextForItemInRowAtIndexPath = [_dataSource respondsToSelector:@selector(menu:detailTextForItemsInRowAtIndexPath:)];
    
    CGFloat numberOfLine = SCREEN_WIDTH / self.numberOfColumn;
    CGFloat numberOfBackground = SCREEN_WIDTH / self.numberOfColumn;
    CGFloat numberOfTextLayer = SCREEN_WIDTH / (self.numberOfColumn * 2);
    
    //底部的line显示
    _bottomLine.hidden = NO;
    
    NSMutableArray *tempTitles = [[NSMutableArray alloc] initWithCapacity:_numberOfColumn];
    NSMutableArray *tempIndicators = [[NSMutableArray alloc] initWithCapacity:_numberOfColumn];
    NSMutableArray *tempBgLayers = [[NSMutableArray alloc] initWithCapacity:_numberOfColumn];
    
    
    //画出菜单
    for (int i = 0; i < _numberOfColumn; i++) {
        //backgrounLayer
        CGPoint positionForBackgroundLayer = CGPointMake((i + 0.5) * numberOfBackground, self.height / 2);
        CALayer *bgLayer = [self createBackgroundLayerWithPosition:positionForBackgroundLayer color:[UIColor whiteColor]];
        [self.layer addSublayer:bgLayer];
        [tempBgLayers addObject:bgLayer];
        
        //titleLayer
        NSString *titleString = nil;
        if (!_isClickHaveItemValid && [_dataSource menu:self numberOfItemsInRow:0 inColumn:i] > 0 && _dataSourceFlag.numberOfItemsInRow) {
            titleString = [_dataSource menu:self titleForItemsInRowAtIndexPath:[LrdIndexPath indexPathWithColumn:i row:0 item:0]];
        }else {
            titleString = [_dataSource menu:self titleForRowAtIndexPath:[LrdIndexPath indexPathWithColumn:i row:0]];
        }
        CGPoint positionForTitle = CGPointMake(( i * 2 + 1) * numberOfTextLayer, self.height / 2);
        CATextLayer *textLayer = [self createTitleLayerWithString:titleString position:positionForTitle color:self.textColor];
        [self.layer addSublayer:textLayer];
        [tempTitles addObject:textLayer];
        
        //indicatorLayer
        CGPoint indicatorPosition = CGPointMake((i + 1) * numberOfLine - 10, self.height / 2);
        CAShapeLayer *sharpLayer = [self createIndicatorWithPosition:indicatorPosition color:self.indicatorColor];
        [self.layer addSublayer:sharpLayer];
        [tempIndicators addObject:sharpLayer];
        
        //separatorLayer
        if (i != self.numberOfColumn - 1) {
            CGPoint separatorPosition = CGPointMake(ceilf((i + 1) * numberOfLine - 1), self.height / 2);
            CAShapeLayer *separatorLayer = [self createSeparatorWithPosition:separatorPosition color:self.separatorColor];
            [self.layer addSublayer:separatorLayer];
        }
    }
    _titles = [tempTitles copy];
    _indicators = [tempIndicators copy];
    _bgLayers = [tempBgLayers copy];
}

#pragma mark - 绘图
//背景
- (CALayer *)createBackgroundLayerWithPosition:(CGPoint)position color:(UIColor *)color {
    CALayer *layer = [CALayer layer];
    layer.position = position;
    layer.bounds = CGRectMake(0, 0, SCREEN_WIDTH / self.numberOfColumn, self.height - 1);
    layer.backgroundColor = color.CGColor;
    return layer;
}
//标题
- (CATextLayer *)createTitleLayerWithString:(NSString *)string position:(CGPoint)position color:(UIColor *)color {
    CGSize size = [self calculateTitleSizeWithString:string];
    
    CATextLayer *layer = [CATextLayer new];
    CGFloat sizeWidth = (size.width < (self.frame.size.width / _numberOfColumn) - 25) ? size.width : self.frame.size.width / _numberOfColumn - 25;
    layer.bounds = CGRectMake(0, 0, sizeWidth, size.height);
    layer.string = string;
    layer.fontSize = _fontSize;
    layer.alignmentMode = kCAAlignmentCenter;
    layer.truncationMode = kCATruncationEnd;
    layer.foregroundColor = color.CGColor;
    
    layer.contentsScale = [[UIScreen mainScreen] scale];
    
    layer.position = position;
    
    return layer;
}
//计算String的宽度
- (CGSize)calculateTitleSizeWithString:(NSString *)string
{
    //CGFloat fontSize = 14.0;
    NSDictionary *dic = @{NSFontAttributeName: [UIFont systemFontOfSize:_fontSize]};
    CGSize size = [string boundingRectWithSize:CGSizeMake(280, 0) options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:dic context:nil].size;
    return CGSizeMake(ceilf(size.width)+2, size.height);
}

//指示器
- (CAShapeLayer *)createIndicatorWithPosition:(CGPoint)position color:(UIColor *)color {
    CAShapeLayer *layer = [CAShapeLayer new];
    
    UIBezierPath *path = [UIBezierPath new];
    [path moveToPoint:CGPointMake(0, 0)];
    [path addLineToPoint:CGPointMake(8, 0)];
    [path addLineToPoint:CGPointMake(4, 5)];
    [path closePath];
    
    layer.path = path.CGPath;
    layer.lineWidth = 0.8;
    layer.fillColor = color.CGColor;
    
    CGPathRef bound = CGPathCreateCopyByStrokingPath(layer.path, nil, layer.lineWidth, kCGLineCapButt, kCGLineJoinMiter, layer.miterLimit);
    layer.bounds = CGPathGetBoundingBox(bound);
    CGPathRelease(bound);
    layer.position = position;
    
    return layer;
}
//分隔线
- (CAShapeLayer *)createSeparatorWithPosition:(CGPoint)position color:(UIColor *)color {
    CAShapeLayer *layer = [CAShapeLayer new];
    
    UIBezierPath *path = [UIBezierPath new];
    [path moveToPoint:CGPointMake(160,0)];
    [path addLineToPoint:CGPointMake(160, 20)];
    
    layer.path = path.CGPath;
    layer.lineWidth = 1;
    layer.strokeColor = color.CGColor;
    
    CGPathRef bound = CGPathCreateCopyByStrokingPath(layer.path, nil, layer.lineWidth, kCGLineCapButt, kCGLineJoinMiter, layer.miterLimit);
    layer.bounds = CGPathGetBoundingBox(bound);
    CGPathRelease(bound);
    layer.position = position;
    return layer;
}

#pragma mark - 动画
- (void)animateIndicator:(CAShapeLayer *)indicator reverse:(BOOL)reverse complete:(complete)complete {
    [CATransaction begin];
    [CATransaction setAnimationDuration:0.25];
    [CATransaction setAnimationTimingFunction:[CAMediaTimingFunction functionWithControlPoints:0.4 :0.0 :0.2 :1.0]];
    
    CAKeyframeAnimation *anim = [CAKeyframeAnimation animationWithKeyPath:@"transform.rotation"];
    anim.values = reverse ? @[ @0, @(M_PI) ] : @[ @(M_PI), @0 ];
    
    if (!anim.removedOnCompletion) {
        [indicator addAnimation:anim forKey:anim.keyPath];
    } else {
        [indicator addAnimation:anim forKey:anim.keyPath];
        [indicator setValue:anim.values.lastObject forKeyPath:anim.keyPath];
    }
    
    [CATransaction commit];
    if (reverse) {
        indicator.fillColor = self.selectedTextColor.CGColor;
    }else {
        indicator.fillColor = self.textColor.CGColor;
    }
    complete();
}

- (void)animateBackGroundView:(UIView *)view show:(BOOL)show complete:(complete)complete {
    if (show) {
        [self.superview addSubview:view];
        [view.superview addSubview:self];
        [UIView animateWithDuration:0.2 animations:^{
            view.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.3];
        }];
    }else {
        [UIView animateWithDuration:0.2 animations:^{
            view.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.0];
        } completion:^(BOOL finished) {
            if (finished) {
                [view removeFromSuperview];
            }
        }];
    }
    complete();
}

- (void)animateTableView:(UITableView *)tableview show:(BOOL)show complete:(complete)complete {
    BOOL haveItems = NO;
    if (_dataSource) {
        NSInteger num = [self.leftTableView numberOfRowsInSection:0];
        for (int i=0; i<num; i++) {
            if (_dataSourceFlag.numberOfItemsInRow && [_dataSource menu:self numberOfItemsInRow:i inColumn:self.currentSelectedColumn] > 0) {
                haveItems = YES;
                break;
            }
        }
    }
    
    if (show) {
        if (haveItems) {
            _leftTableView.frame = CGRectMake(self.origin.x, self.origin.y + self.height, SCREEN_WIDTH / 2, 0);
            _rightTableView.frame = CGRectMake(self.origin.x + SCREEN_WIDTH / 2, self.origin.y +self.height, SCREEN_WIDTH / 2, 0);
            [self.superview addSubview:_leftTableView];
            [self.superview addSubview:_rightTableView];
        }else {
            _leftTableView.frame = CGRectMake(self.origin.x, self.origin.y + self.height, SCREEN_WIDTH, 0);
            [self.superview addSubview:_leftTableView];
        }
        CGFloat num = [_leftTableView numberOfRowsInSection:0];
        CGFloat tableViewHeight = num * kTableViewCellHeight > kTableViewHeight ? kTableViewHeight : num * kTableViewCellHeight;
        
        [UIView animateWithDuration:0.2 animations:^{
            if (haveItems) {
                _leftTableView.frame = CGRectMake(self.origin.x, self.origin.y + self.height, SCREEN_WIDTH / 2, tableViewHeight);
                _rightTableView.frame = CGRectMake(self.origin.x + SCREEN_WIDTH / 2, self.origin.y +self.height, SCREEN_WIDTH / 2, tableViewHeight);
            }else {
                _leftTableView.frame = CGRectMake(self.origin.x, self.origin.y + self.height, SCREEN_WIDTH, tableViewHeight);
            }
        }];
    }else {
        [UIView animateWithDuration:0.2 animations:^{
            if (haveItems) {
                _leftTableView.frame = CGRectMake(self.origin.x, self.origin.y + self.height, SCREEN_WIDTH / 2, 0);
                _rightTableView.frame = CGRectMake(self.origin.x + SCREEN_WIDTH / 2, self.origin.y +self.height, SCREEN_WIDTH / 2, 0);
            }else {
                _leftTableView.frame = CGRectMake(self.origin.x, self.origin.y + self.height, SCREEN_WIDTH, 0);
            }
        } completion:^(BOOL finished) {
            if (_rightTableView) {
                [_rightTableView removeFromSuperview];
            }
            [_leftTableView removeFromSuperview];
        }];
    }
    complete();
}

- (void)animateTitle:(CATextLayer *)title show:(BOOL)show complete:(complete)complete {
    CGSize size = [self calculateTitleSizeWithString:title.string];
    CGFloat sizeWidth = (size.width < (self.frame.size.width / _numberOfColumn) - 25) ? size.width : self.frame.size.width / _numberOfColumn - 25;
    title.bounds = CGRectMake(0, 0, sizeWidth, size.height);
    if (!show) {
        title.foregroundColor = _textColor.CGColor;
    } else {
        title.foregroundColor = _selectedTextColor.CGColor;
    }
    complete();
}

- (void)animateIndicator:(CAShapeLayer *)indicator background:(UIView *)background tableView:(UITableView *)tableView title:(CATextLayer *)title reverse:(BOOL)reverse complecte:(void(^)())complete {
    [self animateIndicator:indicator reverse:reverse complete:^{
       [self animateTitle:title show:reverse complete:^{
          [self animateBackGroundView:background show:reverse complete:^{
             [self animateTableView:tableView show:reverse complete:^{
                 
             }];
          }];
       }];
    }];
    complete();
}


#pragma mark - UITableView的dataSource和delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == _leftTableView) {
        if (_dataSourceFlag.numberOfRowsInColumn) {
            return [_dataSource menu:self numberOfRowsInColumn:_currentSelectedColumn];
        }else {
            return 0;
        }
    }else {
        if (_dataSourceFlag.numberOfItemsInRow) {
            NSInteger row = [_currentSelectedRows[_currentSelectedColumn] integerValue];
            return [_dataSource menu:self numberOfItemsInRow:row inColumn:_currentSelectedColumn];
        }else {
            return 0;
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *ID = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:ID];
        cell.textLabel.textColor = _textColor;
        cell.textLabel.highlightedTextColor = _selectedTextColor;
        cell.textLabel.font = [UIFont systemFontOfSize:_fontSize];
        if (_dataSourceFlag.detailTextForRowAtIndexPath && _dataSourceFlag.detailTextForItemInRowAtIndexPath) {
            cell.detailTextLabel.textColor = _detailTextColor;
            cell.detailTextLabel.font = _detailTextFont;
        }
    }
    if (tableView == _leftTableView) {
        if (_dataSourceFlag.titleForRowsAtIndexPath) {
            cell.textLabel.text = [_dataSource menu:self titleForRowAtIndexPath:[LrdIndexPath indexPathWithColumn:_currentSelectedColumn row:indexPath.row]];
            if (_dataSourceFlag.imageNameForRowAtIndexPath) {
                NSString *imgName = [_dataSource menu:self imageNameForRowAtIndexPath:[LrdIndexPath indexPathWithColumn:_currentSelectedColumn row:indexPath.row]];
                if (imgName && imgName.length > 0) {
                    cell.imageView.image = [UIImage imageNamed:imgName];
                }else {
                    cell.imageView.image = nil;
                }
            }else {
                cell.imageView.image = nil;
            }
            
            //detailText
            if (_dataSourceFlag.detailTextForRowAtIndexPath) {
                cell.detailTextLabel.text = [_dataSource menu:self detailTextForRowAtIndexPath:[LrdIndexPath indexPathWithColumn:_currentSelectedColumn row:indexPath.row]];
            }else {
                cell.detailTextLabel.text = nil;
            }
        }
        //设置accessory
        NSInteger currentSelectRow = [_currentSelectedRows[_currentSelectedColumn] integerValue];
        
        //NSLog(@"当前%ld栏中%ld列", _currentSelectedColumn, currentSelectRow);
        
        if (indexPath.row == currentSelectRow) {
            [tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
        }
        
        if (_dataSourceFlag.numberOfItemsInRow && [_dataSource menu:self numberOfItemsInRow:indexPath.row inColumn:_currentSelectedColumn] > 0) {
            cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"accessory_normal"] highlightedImage:[UIImage imageNamed:@"accessory_highlight"]];
        }else {
            cell.accessoryView = nil;
        }
    }else {
        //右边
        if (_dataSourceFlag.titleForItemInRowAtIndexPath) {
            NSInteger currentSelectedRow = [_currentSelectedRows[_currentSelectedColumn] integerValue];
            cell.textLabel.text = [_dataSource menu:self titleForItemsInRowAtIndexPath:[LrdIndexPath indexPathWithColumn:_currentSelectedColumn row:currentSelectedRow item:indexPath.row]];
            if (_dataSourceFlag.imageNameForItemInRowAtIndexPath) {
                NSString *imgName = [_dataSource menu:self imageForItemsInRowAtIndexPath:[LrdIndexPath indexPathWithColumn:_currentSelectedColumn row:currentSelectedRow item:indexPath.row]];
                if (imgName && imgName.length > 0) {
                    cell.imageView.image = [UIImage imageNamed:imgName];
                }else {
                    cell.imageView.image = nil;
                }
            }else {
                cell.imageView.image = nil;
            }
            
            if (_dataSourceFlag.detailTextForItemInRowAtIndexPath) {
                cell.detailTextLabel.text = [_dataSource menu:self detailTextForItemsInRowAtIndexPath:[LrdIndexPath indexPathWithColumn:_currentSelectedColumn row:currentSelectedRow item:indexPath.row]];
            }else {
                cell.textLabel.text = nil;
            }
        }
        if ([cell.textLabel.text isEqualToString:[(CATextLayer *)_titles[_currentSelectedColumn] string]]) {
            NSInteger currentSelectedRow = [_currentSelectedRows[_currentSelectedColumn] integerValue];
            [_leftTableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:currentSelectedRow inSection:0] animated:YES scrollPosition:UITableViewScrollPositionMiddle];
            [_rightTableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionMiddle];
        }
        
        cell.accessoryView = nil;
        
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == _leftTableView) {
        BOOL haveItem = [self setMenuWithSelectedRow:indexPath.row];
        BOOL isClickHaveItemValid = self.isClickHaveItemValid ? YES :haveItem;
        if (isClickHaveItemValid && _delegate &&[_delegate respondsToSelector:@selector(menu:didSelectRowAtIndexPath:)]) {
            [_delegate menu:self didSelectRowAtIndexPath:[LrdIndexPath indexPathWithColumn:_currentSelectedColumn row:indexPath.row]];
        }
    }else {
        [self setMenuWithSelectedItem:indexPath.item];
        if (_delegate && [_delegate respondsToSelector:@selector(menu:didSelectRowAtIndexPath:)]) {
            [_delegate menu:self didSelectRowAtIndexPath:[LrdIndexPath indexPathWithColumn:_currentSelectedColumn row:[_currentSelectedRows[_currentSelectedColumn] integerValue] item:indexPath.item]];
        }
    }
}

#pragma mark 解决cell分割线左侧留空的问题
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    // 下面这几行代码是用来设置cell的上下行线的位置
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
    
    //按照作者最后的意思还要加上下面这一段，才能做到底部线控制位置，所以这里按stackflow上的做法添加上吧。
    if([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]){
        [cell setPreservesSuperviewLayoutMargins:NO];
    }
}

#pragma mark - 方法实现
//默认选中的index
- (void)selectDeafultIndexPath {
    [self selectIndexPath:[LrdIndexPath indexPathWithColumn:0 row:0]];
}
//获取IndexPath所对应的字符串
- (NSString *)titleForRowAtIndexPath:(LrdIndexPath *)indexPath {
    return [self.dataSource menu:self titleForRowAtIndexPath:indexPath];
}
//菜单切换
- (void)selectIndexPath:(LrdIndexPath *)indexPath {
    if (!_delegate || !_dataSource || ![_delegate respondsToSelector:@selector(menu:didSelectRowAtIndexPath:)]) {
        return;
    }
    
    if ([_dataSource numberOfColumnsInMenu:self] <= indexPath.column || [_dataSource menu:self numberOfRowsInColumn:indexPath.column] <= indexPath.row) {
        return;
    }
    
    CATextLayer *title = (CATextLayer *)_titles[indexPath.column];
    
    if (indexPath.item < 0 ) {
        
        if (!_isClickHaveItemValid && [_dataSource menu:self numberOfItemsInRow:indexPath.row inColumn:indexPath.column] > 0){
            title.string = [_dataSource menu:self titleForItemsInRowAtIndexPath:[LrdIndexPath indexPathWithColumn:indexPath.column row:indexPath.row]];
                [_delegate menu:self didSelectRowAtIndexPath:[LrdIndexPath indexPathWithColumn:indexPath.column row:indexPath.row item:0]];
        }else {
            title.string = [_dataSource menu:self titleForRowAtIndexPath:[LrdIndexPath indexPathWithColumn:indexPath.column row:indexPath.row]];
            [_delegate menu:self didSelectRowAtIndexPath:indexPath];
        }
        if (_currentSelectedRows.count > indexPath.column) {
            _currentSelectedRows[indexPath.column] = @(indexPath.row);
        }
        CGSize size = [self calculateTitleSizeWithString:title.string];
        CGFloat sizeWidth = (size.width < (self.frame.size.width / _numberOfColumn) - 25) ? size.width : self.frame.size.width / _numberOfColumn - 25;
        title.bounds = CGRectMake(0, 0, sizeWidth, size.height);
    }else if ([_dataSource menu:self numberOfItemsInRow:indexPath.row inColumn:indexPath.column] > indexPath.column) {
        title.string = [_dataSource menu:self titleForItemsInRowAtIndexPath:indexPath];
        [_delegate menu:self didSelectRowAtIndexPath:indexPath];
        if (_currentSelectedRows.count > indexPath.column) {
            _currentSelectedRows[indexPath.column] = @(indexPath.row);
        }
        CGSize size = [self calculateTitleSizeWithString:title.string];
        CGFloat sizeWidth = (size.width < (self.frame.size.width / _numberOfColumn) - 25) ? size.width : self.frame.size.width / _numberOfColumn - 25;
        title.bounds = CGRectMake(0, 0, sizeWidth, size.height);
    }
    
}
//数据重载
- (void)reloadData {
    [self animateBackGroundView:_backGroundView show:NO complete:^{
       [self animateTableView:nil show:NO complete:^{
           _isShow = NO;
           id vc = self.dataSource;
           self.dataSource = nil;
           self.dataSource = vc;
       }];
    }];
}

- (void)menuTapped:(UITapGestureRecognizer *)gesture {
    if (_dataSource == nil) {
        return;
    }
    //触摸的地方的index
    CGPoint touchPoint = [gesture locationInView:self];
    NSInteger touchIndex = touchPoint.x / (SCREEN_WIDTH / self.numberOfColumn);
    
    //将当前点击的column之外的column给收回
    for (int i=0; i<_numberOfColumn; i++) {
        if (i != touchIndex) {
            [self animateIndicator:_indicators[i] reverse:NO complete:^{
               [self animateTitle:_titles[i] show:NO complete:^{
                   
               }];
            }];
        }
    }
    
    if (touchIndex == _currentSelectedColumn && _isShow) {
        //收回menu
        [self animateIndicator:_indicators[touchIndex] background:_backGroundView tableView:_leftTableView title:_titles[touchIndex] reverse:NO complecte:^{
            _currentSelectedColumn = touchIndex;
            _isShow = NO;
        }];
    }else {
        //弹出menu
        _currentSelectedColumn = touchIndex;
        [_leftTableView reloadData];
        if (_dataSource && _dataSourceFlag.numberOfItemsInRow) {
            [_rightTableView reloadData];
        }
        [self animateIndicator:_indicators[touchIndex] background:_backGroundView tableView:_leftTableView title:_titles[touchIndex] reverse:YES complecte:^{
            _isShow = YES;
        }];
    }
    
}

- (void)backTapped:(UITapGestureRecognizer *)gesture {
    [self animateIndicator:_indicators[_currentSelectedColumn] background:_backGroundView tableView:_leftTableView title:_titles[_currentSelectedColumn] reverse:NO complecte:^{
        _isShow = NO;
    }];
    
}

- (BOOL)setMenuWithSelectedRow:(NSInteger)row {
    _currentSelectedRows[_currentSelectedColumn] = @(row);

    CATextLayer *title = (CATextLayer *)_titles[_currentSelectedColumn];
    if (_dataSourceFlag.numberOfItemsInRow && [_dataSource menu:self numberOfItemsInRow:row inColumn:_currentSelectedColumn] > 0) {
        if (_isClickHaveItemValid) {
            title.string = [_dataSource menu:self titleForRowAtIndexPath:[LrdIndexPath indexPathWithColumn:_currentSelectedColumn row:row]];
            [self animateTitle:title show:YES complete:^{
                [_rightTableView reloadData];
            }];
        }else {
            [_rightTableView reloadData];
        }
        return NO;
    }else {
        title.string = [_dataSource menu:self titleForRowAtIndexPath:[LrdIndexPath indexPathWithColumn:_currentSelectedColumn row:row]];
        [self animateIndicator:_indicators[_currentSelectedColumn] background:_backGroundView tableView:_leftTableView title:title reverse:NO complecte:^{
            _isShow = NO;
        }];
        return YES;
    }
}

- (void)setMenuWithSelectedItem:(NSInteger)item {
    CATextLayer *title = (CATextLayer *)_titles[_currentSelectedColumn];
    NSInteger currentSelectedMenudRow = [_currentSelectedRows[_currentSelectedColumn] integerValue];
    title.string = [_dataSource menu:self titleForItemsInRowAtIndexPath:[LrdIndexPath indexPathWithColumn:_currentSelectedColumn row:currentSelectedMenudRow item:item]];
    [self animateIndicator:_indicators[_currentSelectedColumn] background:_backGroundView tableView:_leftTableView title:title reverse:NO complecte:^{
        _isShow = NO;
    }];
}

@end
