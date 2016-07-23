//
//  SideMenuController.m
//  Seik
//
//  Created by Gavin on 10/26/14.
//  Copyright (c) 2014 Seik, Inc. All rights reserved.
//s

#import "SideMenuController.h"
static const CGFloat kAnimationDuration = 0.3f;
static const CGFloat kSideMenuWidth = 260.0f;

@interface SideMenuController ()

@property (assign, nonatomic) AnimationTransitionStyle selectedTransitionStyle;
@property (assign, nonatomic) Side selectedSide;
@property (strong, nonatomic) UIViewController *selectedSidemenuViewController;
@property (strong, nonatomic) NSArray *sidemenuAnimations;
@property (strong, nonatomic) UIViewController *centerContainerViewController;
@property (strong, nonatomic) UIViewController *leftContainerViewController;
@property (strong, nonatomic) UIViewController *rightContainerViewController;
@property (assign, nonatomic) CATransform3D contentTransform;

- (void)showSidemenuViewControllerFromSide:(Side)side withTransitionStyle:(AnimationTransitionStyle)transitionStyle;
- (void)hideSidemenuViewController;
- (void)setAnchorPoint:(CGPoint)anchorPoint forView:(UIView *)view;

@end

@implementation SideMenuController

#pragma mark - Designated Initializer
- (id)init
{
    return [self initWithCenterViewController:nil leftViewController:nil rightViewController:nil];
}

- (id)initWithCenterViewController:(UIViewController *)contentViewController leftViewController:(UIViewController *)leftViewController
{
    return [self initWithCenterViewController:contentViewController leftViewController:leftViewController rightViewController:nil];
}

- (id)initWithCenterViewController:(UIViewController *)contentViewController rightViewController:(UIViewController *)rightViewController
{
    return [self initWithCenterViewController:contentViewController leftViewController:nil rightViewController:rightViewController];
}

- (id)initWithCenterViewController:(UIViewController *)contentViewController leftViewController:(UIViewController *)leftViewController rightViewController:(UIViewController *)rightViewController
{
    self = [super init];
    
    if(self)
    {
        _centerContainerViewController = [[UIViewController alloc] init];
        _leftContainerViewController = [[UIViewController alloc] init];
        _rightContainerViewController = [[UIViewController alloc] init];
        
        _centerViewController = contentViewController;
        _leftViewController = (DashboardViewController *)leftViewController;
        _rightViewController = rightViewController;
        
        _animationDuration = kAnimationDuration;
        _sideMenuWidth = kSideMenuWidth;
        _sidemenuAnimations = @[Animaions];
        _isSideMenuPresent = NO;
    }
    
    return self;
}

- (id)initWithCenterViewController:(UIViewController *)contentViewController
          leftViewController:(UIViewController *)leftViewController
           storyboardsUseAutoLayout:(BOOL)storyboardsUseAutoLayout
{
    self.isUseAutoLayout = storyboardsUseAutoLayout;
    return [self initWithCenterViewController:contentViewController leftViewController:leftViewController];
}

- (id)initWithCenterViewController:(UIViewController *)contentViewController
         rightViewController:(UIViewController *)rightViewController
           storyboardsUseAutoLayout:(BOOL)storyboardsUseAutoLayout
{
    self.isUseAutoLayout = storyboardsUseAutoLayout;
    return [self initWithCenterViewController:contentViewController rightViewController:rightViewController];
}

- (id)initWithCenterViewController:(UIViewController *)contentViewController
          leftViewController:(UIViewController *)leftViewController
         rightViewController:(UIViewController *)rightViewController
           storyboardsUseAutoLayout:(BOOL)storyboardsUseAutoLayout
{
    self.isUseAutoLayout = storyboardsUseAutoLayout;
    return [self initWithCenterViewController:contentViewController leftViewController:leftViewController rightViewController:rightViewController];
}

#pragma mark - UIViewController Lifecycle
- (void)viewDidLoad
{
    NSAssert(self.centerViewController != nil, @"centerViewController was not set");
    
    [super viewDidLoad];
    self.view.translatesAutoresizingMaskIntoConstraints = self.isUseAutoLayout;
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    if(self.leftViewController)
    {
        // Parent View Controller
        [self addChildViewController:self.leftContainerViewController];
        [self.view addSubview:self.leftContainerViewController.view];
        [self.leftContainerViewController didMoveToParentViewController:self];
        self.leftContainerViewController.view.translatesAutoresizingMaskIntoConstraints = self.isUseAutoLayout;
        self.leftContainerViewController.view.hidden = YES;
        
        // Child View Controller
        [self.leftContainerViewController addChildViewController:self.leftViewController];
        [self.leftContainerViewController.view addSubview:self.leftViewController.view];
        [self.leftViewController didMoveToParentViewController:self.leftContainerViewController];
    }
    
    if(self.rightViewController)
    {
        // Parent View Controller
        [self addChildViewController:self.rightContainerViewController];
        [self.view addSubview:self.rightContainerViewController.view];
        [self.rightContainerViewController didMoveToParentViewController:self];
        self.rightContainerViewController.view.translatesAutoresizingMaskIntoConstraints = self.isUseAutoLayout;
        self.rightContainerViewController.view.hidden = YES;
        
        // Child View Controller
        [self.rightContainerViewController addChildViewController:self.rightViewController];
        [self.rightContainerViewController.view addSubview:self.rightViewController.view];
        [self.rightViewController didMoveToParentViewController:self.rightContainerViewController];
    }
    
    
    // Parent View Controller
    [self addChildViewController:self.centerContainerViewController];
    [self.view addSubview:self.centerContainerViewController.view];
    [self.centerContainerViewController didMoveToParentViewController:self];
    
    // Child View Controller
    [self.centerContainerViewController addChildViewController:self.centerViewController];
    [self.centerContainerViewController.view addSubview:self.centerViewController.view];
    [self.centerViewController didMoveToParentViewController:self.centerContainerViewController];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


#pragma mark - SideMenuController Presentation Methods
- (void)dismissSideMenuViewController
{
    [self hideSidemenuViewController];
}

- (void)presentLeftViewController
{
    [self presentLeftViewControllerWithStyle:AnimationTransitionStyleFacebook];
}

- (void)presentLeftViewControllerWithStyle:(AnimationTransitionStyle)transitionStyle
{
    NSAssert(self.leftViewController != nil, @"leftViewController was not set");
    [self showSidemenuViewControllerFromSide:Left withTransitionStyle:transitionStyle];
}

- (void)presentRightViewController
{
    [self presentRightViewControllerWithStyle:AnimationTransitionStyleFacebook];
}

- (void)presentRightViewControllerWithStyle:(AnimationTransitionStyle)transitionStyle
{
    NSAssert(self.rightViewController != nil, @"rightViewController was not set");
    [self showSidemenuViewControllerFromSide:Right withTransitionStyle:transitionStyle];
}


#pragma mark - TheSidebarController Private Methods


-(void)snap{
    
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    
    CGRect contentFrame = self.centerContainerViewController.view.frame;
    CGRect sidebarFrame = self.selectedSidemenuViewController.parentViewController.view.frame;
    
    if(contentFrame.origin.x>self.sideMenuWidth/2){
        contentFrame.origin.x=self.sideMenuWidth;
        self.isSideMenuPresent = YES;
        sidebarFrame.origin.x=0;
        
        
        NSString *animationClassName = self.sidemenuAnimations[AnimationTransitionStyleFacebook];
        Class animationClass = NSClassFromString(animationClassName);
        
        
        [animationClass resetSidebarPosition:self.selectedSidemenuViewController.parentViewController.view];
        [animationClass resetContentPosition:self.centerContainerViewController.view];
        
        
        if([self.delegate conformsToProtocol:@protocol(SideMenuControllerDelegate)] && [self.delegate respondsToSelector:@selector(sidemenuController:didShowViewController:)])
        {
            [self.delegate sidemenuController:self didShowViewController:self.selectedSidemenuViewController];
        }
        
        
    }
    else{
        contentFrame.origin.x=0;
        sidebarFrame.origin.x=-50;
        self.isSideMenuPresent = NO;
        
        if([self.delegate conformsToProtocol:@protocol(SideMenuControllerDelegate)] && [self.delegate respondsToSelector:@selector(sidemenuController:didHideViewController:)])
        {
            [self.delegate sidemenuController:self didHideViewController:self.selectedSidemenuViewController];
        }
    }
    
    
    [UIView animateWithDuration:self.animationDuration
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.centerContainerViewController.view.frame = contentFrame;
                         self.selectedSidemenuViewController.parentViewController.view.frame = sidebarFrame;
                         
                     }
                     completion:^(BOOL finished) {
                         [[UIApplication sharedApplication] endIgnoringInteractionEvents];
                     }];
    
    
}


-(void)menuDragFrom:(float)from To:(float)to Direction:(int)direction{
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    self.view.autoresizingMask = UIViewAutoresizingNone;
    
    self.selectedTransitionStyle=5;
    
    if(direction==1){//left
        self.leftContainerViewController.view.hidden = NO;
        self.rightContainerViewController.view.hidden = YES;
        self.selectedSidemenuViewController = self.leftViewController;
        self.view.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleHeight;
        self.selectedSide = Left;
    }
    else{
        self.rightContainerViewController.view.hidden = NO;
        self.leftContainerViewController.view.hidden = YES;
        self.selectedSidemenuViewController = self.rightViewController;
        self.view.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleHeight;
        self.selectedSide = Right;
    }
    
    
    CGRect contentFrame = self.centerContainerViewController.view.frame;
    CGRect sidebarFrame = self.selectedSidemenuViewController.parentViewController.view.frame;
    
    
    contentFrame.origin.x += to-from;
    
    if(contentFrame.origin.x<0){
        contentFrame.origin.x=0;
    }
    if(contentFrame.origin.x>self.sideMenuWidth){
        contentFrame.origin.x=self.sideMenuWidth;
    }
    
    
    sidebarFrame.origin.x=50*(contentFrame.origin.x /self.sideMenuWidth)-50;
    
    
    self.centerContainerViewController.view.frame = contentFrame;
    self.selectedSidemenuViewController.parentViewController.view.frame = sidebarFrame;
    
    [[UIApplication sharedApplication] endIgnoringInteractionEvents];
    
}


- (void)showSidemenuViewControllerFromSide:(Side)side withTransitionStyle:(AnimationTransitionStyle)transitionStyle
{
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    self.view.autoresizingMask = UIViewAutoresizingNone;
    
    if(side == Left)
    {
        self.leftContainerViewController.view.hidden = NO;
        self.rightContainerViewController.view.hidden = YES;
        self.selectedSidemenuViewController = self.leftViewController;
        self.view.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleHeight;
    }
    else if(side == Left)
    {
        self.rightContainerViewController.view.hidden = NO;
        self.leftContainerViewController.view.hidden = YES;
        self.selectedSidemenuViewController = self.rightViewController;
        self.view.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleHeight;
    }
    
    self.selectedSide = side;
    self.selectedTransitionStyle = transitionStyle;
    
    
    if([self.delegate conformsToProtocol:@protocol(SideMenuControllerDelegate)] && [self.delegate respondsToSelector:@selector(sidemenuController:willShowViewController:)])
    {
        [self.delegate sidemenuController:self willShowViewController:self.selectedSidemenuViewController];
    }
    
    NSString *animationClassName = self.sidemenuAnimations[transitionStyle];
    Class animationClass = NSClassFromString(animationClassName);
    [animationClass animateContentView:self.centerContainerViewController.view
                           sidebarView:self.selectedSidemenuViewController.parentViewController.view
                              fromSide:self.selectedSide
                          visibleWidth:self.sideMenuWidth
                              duration:self.animationDuration
                            completion:^(BOOL finished) {
                                [[UIApplication sharedApplication] endIgnoringInteractionEvents];
                                self.isSideMenuPresent = YES;
                                
                                if([self.delegate conformsToProtocol:@protocol(SideMenuControllerDelegate)] && [self.delegate respondsToSelector:@selector(sidemenuController:didShowViewController:)])
                                {
                                    [self.delegate sidemenuController:self didShowViewController:self.selectedSidemenuViewController];
                                }
                            }
     ];
}

- (void)hideSidemenuViewController
{
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    
    if([self.delegate conformsToProtocol:@protocol(SideMenuControllerDelegate)] && [self.delegate respondsToSelector:@selector(sidemenuController:willHideViewController:)])
    {
        [self.delegate sidemenuController:self willHideViewController:self.selectedSidemenuViewController];
    }
    
    NSString *animationClassName = self.sidemenuAnimations[self.selectedTransitionStyle];
    Class animationClass = NSClassFromString(animationClassName);
    [animationClass reverseAnimateContentView:self.centerContainerViewController.view
                                  sidebarView:self.selectedSidemenuViewController.parentViewController.view
                                     fromSide:self.selectedSide
                                 visibleWidth:self.sideMenuWidth
                                     duration:self.animationDuration
                                   completion:^(BOOL finished) {
                                       [[UIApplication sharedApplication] endIgnoringInteractionEvents];
                                       self.isSideMenuPresent = NO;
                                       
                                       if([self.delegate conformsToProtocol:@protocol(SideMenuControllerDelegate)] && [self.delegate respondsToSelector:@selector(sidemenuController:didHideViewController:)])
                                       {
                                           [self.delegate sidemenuController:self didHideViewController:self.selectedSidemenuViewController];
                                       }
                                   }
     ];
}


#pragma mark - UIViewController Setters
- (void)setContentViewController:(UIViewController *)centerViewController
{
    // Old View Controller
    UIViewController *oldViewController = self.centerViewController;
    [oldViewController willMoveToParentViewController:nil];
    [oldViewController.view removeFromSuperview];
    [oldViewController removeFromParentViewController];
    
    // New View Controller
    UIViewController *newViewController = centerViewController;
    [self.centerContainerViewController addChildViewController:newViewController];
    [self.centerContainerViewController.view addSubview:newViewController.view];
    [newViewController didMoveToParentViewController:self.centerContainerViewController];
    
    _centerViewController = newViewController;
}


- (void)setLeftSidebarViewController:(UIViewController *)leftViewController
{
    // Old View Controller
    UIViewController *oldViewController = self.leftViewController;
    [oldViewController willMoveToParentViewController:nil];
    [oldViewController.view removeFromSuperview];
    [oldViewController removeFromParentViewController];
    
    // New View Controller
    UIViewController *newViewController = leftViewController;
    [self.leftContainerViewController addChildViewController:newViewController];
    [self.leftContainerViewController.view addSubview:newViewController.view];
    [newViewController didMoveToParentViewController:self.leftContainerViewController];
    
    _leftViewController = (DashboardViewController *)newViewController;
}

- (void)setRightSidebarViewController:(UIViewController *)rightViewController
{
    // Old View Controller
    UIViewController *oldViewController = self.leftViewController;
    [oldViewController willMoveToParentViewController:nil];
    [oldViewController.view removeFromSuperview];
    [oldViewController removeFromParentViewController];
    
    // New View Controller
    UIViewController *newViewController = rightViewController;
    [self.rightContainerViewController addChildViewController:newViewController];
    [self.rightContainerViewController.view addSubview:newViewController.view];
    [newViewController didMoveToParentViewController:self.rightContainerViewController];
    
    _rightViewController = newViewController;
}


#pragma mark - Autorotation Delegates
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
    if((toInterfaceOrientation == UIInterfaceOrientationPortrait) ||
       (toInterfaceOrientation == UIInterfaceOrientationPortraitUpsideDown))
    {
        NSLog(@"Portrait");
    }
    else if((toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft) ||
            (toInterfaceOrientation == UIInterfaceOrientationLandscapeRight))
    {
        NSLog(@"Landscape");
    }
}


#pragma mark - Helpers
- (void)setAnchorPoint:(CGPoint)anchorPoint forView:(UIView *)view
{
    CGPoint newPoint = CGPointMake(view.bounds.size.width * anchorPoint.x, view.bounds.size.height * anchorPoint.y);
    CGPoint oldPoint = CGPointMake(view.bounds.size.width * view.layer.anchorPoint.x, view.bounds.size.height * view.layer.anchorPoint.y);
    
    newPoint = CGPointApplyAffineTransform(newPoint, view.transform);
    oldPoint = CGPointApplyAffineTransform(oldPoint, view.transform);
    
    CGPoint position = view.layer.position;
    
    position.x -= oldPoint.x;
    position.x += newPoint.x;
    
    position.y -= oldPoint.y;
    position.y += newPoint.y;
    
    view.layer.position = position;
    view.layer.anchorPoint = anchorPoint;
}

@end


#pragma mark - SideMenuController Category
@implementation UIViewController(SideMenuController)

- (SideMenuController *)sidemenuController
{
    if([self.parentViewController.parentViewController isKindOfClass:[SideMenuController class]])
    {
        return (SideMenuController *)self.parentViewController.parentViewController;
    }
    else if([self.parentViewController isKindOfClass:[UINavigationController class]] &&
            [self.parentViewController.parentViewController.parentViewController isKindOfClass:[SideMenuController class]])
    {
        return (SideMenuController *)self.parentViewController.parentViewController.parentViewController;
    }
    
    return nil;
}

@end
