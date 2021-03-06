@import UIKit;
#import "WPMediaCollectionDataSource.h"

@interface WPMediaCollectionViewCell : UICollectionViewCell

@property (nonatomic, strong) id<WPMediaAsset> asset;
@property (nonatomic, assign) NSInteger position;

@property (nonatomic, strong) UIColor *placeholderTintColor UI_APPEARANCE_SELECTOR;

@end
