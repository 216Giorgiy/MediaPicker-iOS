#import "WPAssetViewController.h"

@import AVFoundation;
@import AVKit;

@interface WPAssetViewController ()

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIView *videoView;
@property (nonatomic, strong) AVPlayerViewController *playerViewController;

@property (nonatomic, strong) UIActivityIndicatorView *activityIndicatorView;

@end

@implementation WPAssetViewController

- (instancetype)initWithAsset:(id<WPMediaAsset>)asset
{
    if (self = [super initWithNibName:nil bundle:nil]) {
        _asset = asset;
    }

    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor blackColor];

    [self.view addSubview:self.imageView];
    self.imageView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.imageView.leftAnchor constraintEqualToAnchor:self.view.leftAnchor].active = YES;
    [self.imageView.widthAnchor constraintEqualToAnchor:self.view.widthAnchor].active = YES;
    [self.imageView.topAnchor constraintEqualToAnchor:self.topLayoutGuide.topAnchor].active = YES;
    [self.imageView.heightAnchor constraintEqualToAnchor:self.view.heightAnchor].active = YES;

    [self addChildViewController:self.playerViewController];
    self.videoView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.videoView];
    [self.playerViewController didMoveToParentViewController:self];
    [self.videoView.leftAnchor constraintEqualToAnchor:self.view.leftAnchor].active = YES;
    [self.videoView.widthAnchor constraintEqualToAnchor:self.view.widthAnchor].active = YES;
    [self.videoView.topAnchor constraintEqualToAnchor:self.topLayoutGuide.bottomAnchor].active = YES;
    [self.videoView.bottomAnchor constraintEqualToAnchor:self.bottomLayoutGuide.topAnchor].active = YES;

    [self.view addSubview:self.activityIndicatorView];
    self.activityIndicatorView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.activityIndicatorView.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor].active = YES;
    [self.activityIndicatorView.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor].active = YES;

    NSString *actionTitle = NSLocalizedString(@"Add", @"Remove asset from media picker list");
    if (self.selected) {
        actionTitle = NSLocalizedString(@"Remove", @"Add asset to media picker list");
    }

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:actionTitle style:UIBarButtonItemStylePlain target:self action:@selector(selectAction:)];

    [self showAsset];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (UIImageView *)imageView
{
    if (_imageView) {
        return _imageView;
    }
    _imageView = [[UIImageView alloc] init];
    _imageView.contentMode = UIViewContentModeScaleAspectFit;
    _imageView.backgroundColor = [UIColor blackColor];
    _imageView.userInteractionEnabled = YES;
    [_imageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapOnAsset:)]];
    return _imageView;
}

- (AVPlayerViewController *)playerViewController
{
    if (!_playerViewController) {
        _playerViewController = [AVPlayerViewController new];
        _videoView = _playerViewController.view;
    }

    return _playerViewController;
}

- (UIActivityIndicatorView *)activityIndicatorView
{
    if (_activityIndicatorView) {
        return _activityIndicatorView;
    }

    _activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];

    return _activityIndicatorView;
}

- (void)showAsset
{
    self.imageView.hidden = YES;
    self.videoView.hidden = YES;

    if (self.asset == nil) {
        self.imageView.image = nil;
        [self.playerViewController.player replaceCurrentItemWithPlayerItem:nil];
        return;
    }
    switch ([self.asset assetType]) {
        case WPMediaTypeImage:
            [self showImageAsset];
        break;
        case WPMediaTypeVideo:
            [self showVideoAsset];
        break;
        default:
            return;
        break;
    }
}

- (void)showImageAsset
{
    self.imageView.hidden = NO;
    [self.activityIndicatorView startAnimating];
    __weak __typeof__(self) weakSelf = self;
    [self.asset imageWithSize:CGSizeZero completionHandler:^(UIImage *result, NSError *error) {
        __typeof__(self) strongSelf = weakSelf;
        if (!strongSelf) {
            return;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [strongSelf.activityIndicatorView stopAnimating];
            if (error) {
                [strongSelf showError:error];
                return;
            }
            strongSelf.imageView.image = result;
        });
    }];
}

- (void)showVideoAsset
{
    self.playerViewController.view.hidden = NO;
    [self.activityIndicatorView startAnimating];
    __weak __typeof__(self) weakSelf = self;
    [self.asset videoAssetWithCompletionHandler:^(AVAsset *asset, NSError *error) {
        __typeof__(self) strongSelf = weakSelf;
        if (!strongSelf) {
            return;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [strongSelf.activityIndicatorView stopAnimating];

            if (error) {
                [strongSelf showError:error];
                return;
            }
            [strongSelf setPlayerAsset:asset];
        });
    }];
}

- (void)setPlayerAsset:(AVAsset *)asset {
    AVPlayerItem *playerItem = [[AVPlayerItem alloc] initWithAsset: asset];
    AVPlayer *player = [AVPlayer playerWithPlayerItem:playerItem];
    self.playerViewController.player = player;
    self.playerViewController.updatesNowPlayingInfoCenter = NO;
    self.playerViewController.showsPlaybackControls = self.showsPlaybackControls;

    [self.playerViewController.player play];
}

- (void)showError:(NSError *)error {
    [self.activityIndicatorView stopAnimating];
    if (self.delegate) {
        [self.delegate assetViewController:self failedWithError:error];
    }
}

- (void)handleTapOnAsset:(UIGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
        [self.navigationController setNavigationBarHidden:!self.navigationController.isNavigationBarHidden animated:YES];
    }
}

- (void)selectAction:(UIBarButtonItem *)button
{
    self.selected = !self.selected;
    if (self.delegate) {
        [self.delegate assetViewController:self selectionChanged:self.selected];    
    }
}

- (void)setShowsPlaybackControls:(BOOL)showsPlaybackControls
{
    if (_showsPlaybackControls != showsPlaybackControls) {
        _showsPlaybackControls = showsPlaybackControls;

        self.playerViewController.showsPlaybackControls = showsPlaybackControls;
    }
}

- (CGSize)preferredContentSize
{
    CGSize size = self.view.bounds.size;

    // Scale the preferred content size to be the same aspect
    // ratio as the asset we're displaying.
    CGSize pixelSize = [self.asset pixelSize];
    CGFloat scaleFactor = pixelSize.height / pixelSize.width;

    return CGSizeMake(size.width, size.width * scaleFactor);
}

@end
