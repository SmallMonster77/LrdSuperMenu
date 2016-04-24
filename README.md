# LrdSuperMenu
仿美团外卖，百度外卖的选择菜单栏

之前看到过DOPDropMenu这个第三方库，挺不错的，花了些时间阅读了一下，参考了一下，修改了一些地方。

效果如图:<br>
![](http://lrdup888.qiniudn.com/%E4%BB%BF%E7%99%BE%E5%BA%A6%E5%A4%96%E5%8D%96%E8%8F%9C%E5%8D%95.gif)

##使用方法
将LrdSuperMenu文件夹拖入到工程里面，在需要用到的地方，导入头文件。

类似UITableView，需要实现代理和数据源方法，然后根据项目的实际需要，分别对数据源和代理进行设置。

```Objective-C
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
```

更具体的请下载demo查看。

喜欢就给颗星呗~ 

我的博客地址:[我的博客](http://www.lrdup.net "键盘上的舞者")
