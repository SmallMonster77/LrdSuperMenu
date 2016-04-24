//
//  ViewController.m
//  LrdSuperMenu
//
//  Created by 键盘上的舞者 on 4/18/16.
//  Copyright © 2016 键盘上的舞者. All rights reserved.
//

#import "ViewController.h"
#import "LrdSuperMenu.h"

@interface ViewController () <LrdSuperMenuDataSource, LrdSuperMenuDelegate>

@property (nonatomic, strong) LrdSuperMenu *menu;

@property (nonatomic, strong) NSArray *sort;
@property (nonatomic, strong) NSArray *choose;
@property (nonatomic, strong) NSArray *classify;
@property (nonatomic, strong) NSArray *jiachang;
@property (nonatomic, strong) NSArray *difang;
@property (nonatomic, strong) NSArray *tese;
@property (nonatomic, strong) NSArray *rihan;
@property (nonatomic, strong) NSArray *xishi;
@property (nonatomic, strong) NSArray *shaokao;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    // 数据
    self.classify = @[@"全部", @"新店特惠", @"连锁餐厅", @"家常快餐", @"地方菜", @"特色小吃", @"日韩料理", @"西式快餐", @"烧烤海鲜"];
    self.sort = @[@"排序", @"智能排序", @"销量最高", @"距离最近", @"评分最高", @"起送价最低", @"送餐速度最快"];
    self.choose = @[@"筛选", @"立减优惠", @"预定优惠", @"特价优惠", @"折扣商品", @"进店领券", @"下单返券"];
    self.jiachang = @[@"家常炒菜", @"黄焖J8饭", @"麻辣烫", @"盖饭"];
    self.difang = @[@"湘菜", @"湘菜", @"湘菜", @"湘菜", @"湘菜", @"湘菜"];
    self.tese = @[@"湘菜", @"湘菜", @"湘菜", @"湘菜", @"湘菜", @"湘菜", @"湘菜"];
    self.rihan = @[@"湘菜", @"湘菜", @"湘菜", @"湘菜", @"湘菜", @"湘菜", @"湘菜"];
    self.xishi = @[@"湘菜", @"湘菜", @"湘菜", @"湘菜", @"湘菜", @"湘菜", @"湘菜"];
    self.shaokao = @[@"湘菜", @"湘菜", @"湘菜", @"湘菜", @"湘菜", @"湘菜", @"湘菜", @"湘菜"];
    
    
    _menu = [[LrdSuperMenu alloc] initWithOrigin:CGPointMake(0, 64) andHeight:44];
    _menu.delegate = self;
    _menu.dataSource = self;
    [self.view addSubview:_menu];
    
    [_menu selectDeafultIndexPath];
}

- (NSInteger)numberOfColumnsInMenu:(LrdSuperMenu *)menu {
    return 3;
}

- (NSInteger)menu:(LrdSuperMenu *)menu numberOfRowsInColumn:(NSInteger)column {
    if (column == 0) {
        return self.classify.count;
    }else if(column == 1) {
        return self.sort.count;
    }else {
        return self.choose.count;
    }
}

- (NSString *)menu:(LrdSuperMenu *)menu titleForRowAtIndexPath:(LrdIndexPath *)indexPath {
    if (indexPath.column == 0) {
        return self.classify[indexPath.row];
    }else if(indexPath.column == 1) {
        return self.sort[indexPath.row];
    }else {
        return self.choose[indexPath.row];
    }
}

- (NSString *)menu:(LrdSuperMenu *)menu imageNameForRowAtIndexPath:(LrdIndexPath *)indexPath {
    if (indexPath.column == 0 || indexPath.column == 1) {
        return @"baidu";
    }
    return nil;
}

- (NSString *)menu:(LrdSuperMenu *)menu imageForItemsInRowAtIndexPath:(LrdIndexPath *)indexPath {
    if (indexPath.column == 0 && indexPath.item >= 0) {
        return @"baidu";
    }
    return nil;
}

- (NSString *)menu:(LrdSuperMenu *)menu detailTextForRowAtIndexPath:(LrdIndexPath *)indexPath {
    if (indexPath.column < 2) {
        return [@(arc4random()%1000) stringValue];
    }
    return nil;
}

- (NSString *)menu:(LrdSuperMenu *)menu detailTextForItemsInRowAtIndexPath:(LrdIndexPath *)indexPath {
    return [@(arc4random()%1000) stringValue];
}

- (NSInteger)menu:(LrdSuperMenu *)menu numberOfItemsInRow:(NSInteger)row inColumn:(NSInteger)column {
    if (column == 0) {
        if (row == 3) {
            return self.jiachang.count;
        }else if (row == 4) {
            return self.difang.count;
        }else if (row == 5) {
            return self.tese.count;
        }else if (row == 6) {
            return self.rihan.count;
        }else if (row == 7) {
            return self.xishi.count;
        }else if (row == 8) {
            return self.shaokao.count;
        }
    }
    return 0;
}

- (NSString *)menu:(LrdSuperMenu *)menu titleForItemsInRowAtIndexPath:(LrdIndexPath *)indexPath {
    NSInteger row = indexPath.row;
    if (indexPath.column == 0) {
        if (row == 3) {
            return self.jiachang[indexPath.item];
        }else if (row == 4) {
            return self.tese[indexPath.item];
        }else if (row == 5) {
            return self.rihan[indexPath.item];
        }else if (row == 6) {
            return self.xishi[indexPath.item];
        }else if (row == 7) {
            return self.shaokao[indexPath.item];
        }
    }
    return nil;
}

- (void)menu:(LrdSuperMenu *)menu didSelectRowAtIndexPath:(LrdIndexPath *)indexPath {
    if (indexPath.item >= 0) {
        NSLog(@"点击了 %ld - %ld - %ld 项目",indexPath.column,indexPath.row,indexPath.item);
    }else {
        NSLog(@"点击了 %ld - %ld 项目",indexPath.column,indexPath.row);
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
