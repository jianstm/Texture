//
//  ASNavigationController.m
//  Pods
//
//  Created by Garrett Moon on 4/27/16.
//
//

#import "ASNavigationController.h"

@implementation ASNavigationController
{
  BOOL _parentManagesVisibilityDepth;
  NSInteger _visibilityDepth;
}

- (void)didMoveToParentViewController:(UIViewController *)parent
{
  [super didMoveToParentViewController:parent];
  [self visibilityDepthDidChange];
}

- (void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];

  if (_parentManagesVisibilityDepth == NO) {
    _visibilityDepth = 0;
    [self visibilityDepthDidChange];
  }
}

- (void)viewDidDisappear:(BOOL)animated
{
  [super viewDidDisappear:animated];
  
  if (_parentManagesVisibilityDepth == NO) {
    _visibilityDepth = 1;
    [self visibilityDepthDidChange];
  }
}

- (NSInteger)visibilityDepth
{
  if (self.parentViewController && _parentManagesVisibilityDepth == NO) {
    _parentManagesVisibilityDepth = [self.parentViewController conformsToProtocol:@protocol(ASManagesChildVisibilityDepth)];
  }
  
  if (_parentManagesVisibilityDepth) {
    return [(id <ASManagesChildVisibilityDepth>)self.parentViewController visibilityDepthOfChildViewController:self];
  }
  return _visibilityDepth;
}

- (void)visibilityDepthDidChange
{
  for (UIViewController *viewController in self.viewControllers) {
    if ([viewController conformsToProtocol:@protocol(ASVisibilityDepth)]) {
      [(id <ASVisibilityDepth>)viewController visibilityDepthDidChange];
    }
  }
}

- (NSInteger)visibilityDepthOfChildViewController:(UIViewController *)childViewController
{
  NSUInteger viewControllerIndex = [self.viewControllers indexOfObject:childViewController];
  NSAssert(viewControllerIndex != NSNotFound, @"childViewController is not in the navigation stack.");
  
  if (viewControllerIndex == self.viewControllers.count - 1) {
    //view controller is at the top
    return [self visibilityDepth] + 0;
  } else if (viewControllerIndex == 0) {
    //view controller is the root view controller. Can be accessed by holding the back button.
    return [self visibilityDepth] + 1;
  }
  
  return [self visibilityDepth] + self.viewControllers.count - 1 - viewControllerIndex;
}

#pragma mark - UIKit overrides

- (NSArray *)popToViewController:(UIViewController *)viewController animated:(BOOL)animated
{
  NSArray *viewControllers = [super popToViewController:viewController animated:animated];
  [self visibilityDepthDidChange];
  return viewControllers;
}

- (NSArray *)popToRootViewControllerAnimated:(BOOL)animated
{
  NSArray *viewControllers = [super popToRootViewControllerAnimated:animated];
  [self visibilityDepthDidChange];
  return viewControllers;
}

- (void)setViewControllers:(NSArray *)viewControllers
{
  [super setViewControllers:viewControllers];
  [self visibilityDepthDidChange];
}

- (void)setViewControllers:(NSArray *)viewControllers animated:(BOOL)animated
{
  [super setViewControllers:viewControllers animated:animated];
  [self visibilityDepthDidChange];
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
  [super pushViewController:viewController animated:animated];
  [self visibilityDepthDidChange];
}

- (UIViewController *)popViewControllerAnimated:(BOOL)animated
{
  UIViewController *viewController = [super popViewControllerAnimated:animated];
  [self visibilityDepthDidChange];
  return viewController;
}

@end
