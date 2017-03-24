#import <UIKit/UIKit.h>
#import "WPMediaCollectionDataSource.h"

@class WPAssetViewController;

@protocol WPAssetViewControllerDelegate <NSObject>

- (void)assetViewController:(WPAssetViewController *)assetPreviewVC selectionChanged:(BOOL)selected;

- (void)assetViewController:(WPAssetViewController *)assetPreviewVC failedWithError:(NSError *)error;

@end

@interface WPAssetViewController : UIViewController

- (instancetype)initWithAsset:(id<WPMediaAsset>)asset;

@property (nonatomic, strong) id<WPMediaAsset> asset;
@property (nonatomic) BOOL selected;
@property (nonatomic) BOOL showsPlaybackControls;

@property (nonatomic, weak) id<WPAssetViewControllerDelegate> delegate;

@end
