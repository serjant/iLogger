//
//  AppDelegate.m
//  iLogger
//
//  Created by Dmitry Beym on 1/14/13.
//  Copyright (c) 2013 SAMity. All rights reserved.
//

#import "AppDelegate.h"
#import "ProcessesViewController.h"
#import "LogsViewController.h"
#import "ActivityViewController.h"
#import "SystemViewController.h"
#import "Appirater.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    UIViewController *viewController1, *viewController2, *viewController3, *viewController4;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        viewController1 = [[ProcessesViewController alloc] initWithNibName:@"ProcessesViewController_iPhone" bundle:nil];
        viewController2 = [[LogsViewController alloc] initWithNibName:@"LogsViewController_iPhone" bundle:nil];
        viewController3 = [[ActivityViewController alloc] initWithNibName:@"ActivityViewController_iPhone" bundle:nil];
        viewController4 = [[SystemViewController alloc] initWithNibName:@"SystemViewController_iPhone" bundle:nil];
    } else {
        viewController1 = [[ProcessesViewController alloc] initWithNibName:@"ProcessesViewController_iPad" bundle:nil];
        viewController2 = [[LogsViewController alloc] initWithNibName:@"LogsViewController_iPad" bundle:nil];
        viewController3 = [[ActivityViewController alloc] initWithNibName:@"ActivityViewController_iPad" bundle:nil];
        viewController4 = [[SystemViewController alloc] initWithNibName:@"SystemViewController_iPad" bundle:nil];
    }
    
    self.tabBarController = [[UITabBarController alloc] init];
    self.tabBarController.viewControllers = @[viewController1, viewController2, viewController3, viewController4];
    self.window.rootViewController = self.tabBarController;
    self.tabBarController.tabBar.tintColor = [UIColor colorWithRed:15.0f/255.0f green:9.0f/255.0f blue:29.0f/255.0f alpha:1.0f];
    [self.window makeKeyAndVisible];
    
    [Appirater appLaunched:YES];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

/*
// Optional UITabBarControllerDelegate method.
- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
}
*/

/*
// Optional UITabBarControllerDelegate method.
- (void)tabBarController:(UITabBarController *)tabBarController didEndCustomizingViewControllers:(NSArray *)viewControllers changed:(BOOL)changed
{
}
*/

@end
