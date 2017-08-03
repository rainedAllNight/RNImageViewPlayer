# RNImageViewPlayer
一个小巧精致的无限轮播(支持自定义)

## 效果图
* ### 默认效果：
![默认](https://github.com/rainedAllNight/RNImageViewPlayer/blob/master/RNImageViewPlayer.gif)

* ### 自定义效果:
![自定义](https://github.com/rainedAllNight/RNImageViewPlayer/blob/master/RNImageViewPlayerCustom.gif)

## How to use
**代码添加RNImageViewPlayer或者在storyBoard/xib中继承RNImageViewPlayer，并设置代理**

### 可配置项
* **scrollInterval：** 自动滑动的时间间隔，默认为2.5s
* **isHidePageControl：** 是否隐藏pageController，默认不隐藏
* **isAutomaticScroll：** 是否自动滑动，默认为true
* **isEndlessScroll：** 是否无限轮播，默认为true
* **pageControlPosition：** pageController位置，详见**PageControlPosition枚举**
* **currentPgaeIndex：** 显示的位置，默认为0显示第一个

### Delegate

```
// 数据源大小，images count
func imagePlayerNumberOfItems(imagePlayer: RNImageViewPlayer) -> Int
```

```
// 返回自定义的cell，需要提前进行注册
@objc optional func imagePlayer(imagePlayer: RNImageViewPlayer, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
```

```
// 将要展示默认样式(默认cell)的imageView，在这里可以对imageView进行一些操作如设置image
@objc optional func imagePlayer(imagePlayer: RNImageViewPlayer, willLoadDefaultCellImageWith imageView: UIImageView, at index: Int)
```

```
// 已经滑动到某个item
@objc optional func imagePlayer(imagePlayer: RNImageViewPlayer, didScrollAt index: Int)
```

```
// 选中某个Item
@objc optional func imagePlayer(imagePlayer: RNImageViewPlayer, didSelectItemAt index: Int)
```






