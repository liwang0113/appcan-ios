/*
 *  Copyright (C) 2014 The AppCan Open Source Project.
 *
 *  This program is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU Lesser General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU Lesser General Public License for more details.
 
 *  You should have received a copy of the GNU Lesser General Public License
 *  along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 */

#import <Foundation/Foundation.h>
#import "WidgetOneDelegate.h"
#import "EBrowserController.h"
#import "EBrowserMainFrame.h"
#import "EBrowserWidgetContainer.h"
#import "EBrowserWindowContainer.h"
#import "EBrowserWindow.h"
#import "EBrowserView.h"
#import "EBrowser.h"
#import "EUExManager.h"
#import "WWidgetMgr.h"
#import "BUtility.h"
#import <sys/utsname.h>
#import "WWidget.h"
#import "FileEncrypt.h"
#import "PluginParser.h"
#import "JSON.h"
#import "EUExBase.h"
#import <objc/runtime.h>
#import <objc/message.h>
#import "EUExBaseDefine.h"
#import "ACEUtils.h"
#import "ACEUINavigationController.h"
#import "ACEDrawerViewController.h"
#import "MMExampleDrawerVisualStateManager.h"
#import "ACEWebViewController.h"
#import "ACEDes.h"


#define kViewTagExit 100
#define kViewTagLocalNotification 200

@implementation WidgetOneDelegate

@synthesize window;
@synthesize meBrwCtrler;
@synthesize mwWgtMgr;
@synthesize userStartReport = _userStartReport;
@synthesize useEmmControl = _useEmmControl;
@synthesize useOpenControl = _useOpenControl;
@synthesize useUpdateControl = _useUpdateControl;
@synthesize useOnlineArgsControl = _useOnlineArgsControl;
@synthesize usePushControl = _usePushControl;
@synthesize useDataStatisticsControl = _useDataStatisticsControl;
@synthesize useAuthorsizeIDControl = _useAuthorsizeIDControl;
@synthesize useAppCanMAMURL = _useAppCanMAMURL;
@synthesize useAppCanMCMURL = _useAppCanMCMURL;
@synthesize useAppCanMDMURL = _useAppCanMDMURL;
@synthesize useStartReportURL = _useStartReportURL;
@synthesize useAnalysisDataURL = _useAnalysisDataURL;
@synthesize useBindUserPushURL = _useBindUserPushURL;
@synthesize useCloseAppWithJaibroken =_useCloseAppWithJaibroken;
@synthesize useRC4EncryptWithLocalstorage =_useRC4EncryptWithLocalstorage;
@synthesize useUpdateWgtHtmlControl =_useUpdateWgtHtmlControl;
@synthesize useCertificatePassWord = _useCertificatePassWord;
@synthesize useEraseAppDataControl =_useEraseAppDataControl;
@synthesize useCertificateControl = _useCertificateControl;
@synthesize useIsHiddenStatusBarControl =_useIsHiddenStatusBarControl;
@synthesize useAppCanUpdateURL = _useAppCanUpdateURL;
@synthesize useAppCanMDMURLControl = _useAppCanMDMURLControl;
@synthesize thirdInfoDict = _thirdInfoDict;
NSString *AppCanJS = nil;


-(void)readAppCanJS {
    
    NSString * baseJS = nil;
    
    if (_useRC4EncryptWithLocalstorage) {
        
        baseJS = [NSString stringWithFormat:@"%@\n%@",[BUtility getBaseJSKey],[BUtility getRC4LocalStoreJSKey]];
        
    } else {
        
        baseJS = [BUtility getBaseJSKey];
        
    }
    
    pluginObj = [[PluginParser alloc] init] ;
    NSString *pluginJS = [pluginObj initPluginJS];
    
	if (pluginJS && [pluginJS length] > 0) {
        
		AppCanJS = [[NSString alloc] initWithFormat:@"%@\n%@",baseJS,pluginJS];
        
	} else {
        
		AppCanJS = [[NSString alloc] initWithFormat:@"%@\n",baseJS];
        
	}
    
}

- (void)parseURL:(NSURL *)url application:(UIApplication *)application {
    //调用支付对象解析url，传递值给js
    //    EUExManager *manager = [[meBrwCtrler.meBrwMainFrm.meBrwWgtContainer aboveWindowContainer] aboveWindow].meBrwView.meUExManager;
    
    //取window的最上层ebrview
    //    EUExManager *manager = [[[meBrwCtrler.meBrwMainFrm.meBrwWgtContainer aboveWindowContainer] aboveWindow] theFrontView].meUExManager;
    EBrowserWindow * ebv = [[meBrwCtrler.meBrwMainFrm.meBrwWgtContainer aboveWindowContainer] aboveWindow];
    EBrowserView * ebview = [ebv theFrontView];
    EUExManager * manager = ebview.meUExManager;
    NSMutableDictionary *objDict = manager.uexObjDict;
    //get the plist file from bundle
    NSString * plistPath = [[NSBundle mainBundle] pathForResource:@"CBSchemesList" ofType:@"plist"];
    
    if (plistPath) {
        
        NSDictionary *pDataDict = [NSDictionary dictionaryWithContentsOfFile:plistPath];
        NSMutableArray *anArray = [NSMutableArray arrayWithArray:[pDataDict objectForKey:@"UexObjName"]];
        
        for (NSString * uexNameStr in anArray) {
            
            EUExBase * payObj = [objDict objectForKey:uexNameStr];
            if (payObj) {
                
                [payObj performSelector:@selector(parseURL:application:) withObject:url withObject:application];
                
            }
            
        }
        
    }
    
}
- (BOOL)isSingleTask {
    
	struct utsname name;
	uname(&name);
    
	float version = [[UIDevice currentDevice].systemVersion floatValue];//判定系统版本。
    
	if (version < 4.0 || strstr(name.machine, "iPod1,1") != 0 || strstr(name.machine, "iPod2,1") != 0) {
        
		return YES;
        
	} else {
        
		return NO;
        
	}
    
}



- (id)init{
    
    self = [super init];
    
    if (self != nil) {
        
		// set cookie storage:
		NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
		//[cookieStorage setCookieAcceptPolicy:NSHTTPCookieAcceptPolicyOnlyFromMainDocumentDomain];
		//[cookieStorage setCookieAcceptPolicy:NSHTTPCookieAcceptPolicyNever];
		[cookieStorage setCookieAcceptPolicy:NSHTTPCookieAcceptPolicyAlways];
		//NSLog(@"cookie accept policy is %d", [cookieStorage cookieAcceptPolicy]);
		//[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedCookiesChange:) name:NSHTTPCookieManagerCookiesChangedNotification object:nil];
        //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedCookiesPolicyChange:) name:NSHTTPCookieManagerAcceptPolicyChangedNotification object:nil];
		// set cache storage:
		/*NSURLCache *cacheStorage = [[NSURLCache alloc] initWithMemoryCapacity:512000
         diskCapacity:100000000
         diskPath:@"zd111"];*/
		//[NSURLCache setSharedURLCache:cacheStorage];
        //		NSURLCache *cacheStorage = [NSURLCache sharedURLCache];
        //		NSLog(@"cache disk size: %d", [cacheStorage diskCapacity]);
        //		NSLog(@"cache disk used size: %d", [cacheStorage currentDiskUsage]);
        //		NSLog(@"cache memory size: %d", [cacheStorage memoryCapacity]);
        //		NSLog(@"cache memory used size: %d", [cacheStorage currentMemoryUsage]);
		//[cacheStorage release];
		self.userStartReport = YES;
		self.useOpenControl = YES;
		self.usePushControl = YES;
		self.useUpdateControl = YES;
		self.useOnlineArgsControl = YES;
		self.useDataStatisticsControl = YES;
        self.useAuthorsizeIDControl = YES;
        //startreport
        self.useStartReportURL = @"http://115.29.138.150/appIn/";
        //数据统计
        self.useAnalysisDataURL = @"http://115.29.138.150/appIn/";
        //bind push
        self.useBindUserPushURL = @"https://push.appcan.cn/push/";
        //mam
        self.useAppCanMAMURL = @"";
        self.useAppCanUpdateURL = @"";
        //jaibroken
        self.useCloseAppWithJaibroken = NO;
        //rc4 加密 js
        self.useRC4EncryptWithLocalstorage = YES;
        //网页增量升级
        self.useUpdateWgtHtmlControl = YES;
        //https密钥
        self.useCertificatePassWord = @"pwd";
        //擦除信息
        _useEraseAppDataControl = YES;
        //https 密钥控制
        self.useCertificateControl = YES;
        //应用内是否显示状态条
        self.useIsHiddenStatusBarControl = NO;
        //MDM
        self.useAppCanMDMURL=@"";
        self.useAppCanMDMURLControl=NO;
        self.isFirstPageDidLoad = NO;
        
        [self setAppCanUserAgent];
        
	}
    
    return self;
    
}
-(void)setAppCanUserAgent {
    
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSString *_userAgent=nil;
    _userAgent =[ud objectForKey:ACE_USERAGENT];
    
    if(_userAgent == nil) {
        
        UIWebView * sampleWebView = [[UIWebView alloc] initWithFrame:CGRectZero];
        NSString * originalUserAgent = [sampleWebView stringByEvaluatingJavaScriptFromString:@"navigator.userAgent"];
        NSString * subS1 = @"AppleWebKit/";
        NSRange range1 = [originalUserAgent rangeOfString:subS1];
        
        int location1 = range1.location;
        int lenght1 = range1.length;
        NSString * s1 = [originalUserAgent substringToIndex:location1+lenght1];
        NSString * s2 = [originalUserAgent substringFromIndex:location1+lenght1];
        
        NSString * subS2 = @" ";
        NSRange  rang2 = [s2 rangeOfString:subS2];
        int location2 = rang2.location;
        int length2 = rang2.length;
        NSString * s21 = [s2 substringToIndex:location2 + length2];
        NSString * s22 = [s2 substringFromIndex:location2 + length2];
        
        NSString * subS3 = @"Mobile/";
        NSRange  rang3 = [s22 rangeOfString:subS3];
        int location3 = rang3.location;
        NSMutableString *s32 = [[NSMutableString alloc]initWithString:s22];
        [s32 insertString:@"Version/8.0 "atIndex:location3];
        NSString * safari= [NSString stringWithFormat:@"Safari/%@Appcan/3.0",s21];
        
        _userAgent = [NSString stringWithFormat:@"%@%@%@ %@",s1,s21,s32,safari];
        [ud setObject:_userAgent forKey:ACE_USERAGENT];
    }
    NSDictionary * dictionnary = [[NSDictionary alloc] initWithObjectsAndKeys:_userAgent, @"UserAgent", nil];
    [[NSUserDefaults standardUserDefaults] registerDefaults:dictionnary];
    [dictionnary release];
}

- (void)stopAllNetService {
    
	if (!meBrwCtrler) {
        
		return;
        
	}
	if (!meBrwCtrler.meBrw) {
        
		[meBrwCtrler.meBrw stopAllNetService];
        
	}
    
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    BOOL success;
    NSFileManager * fileManager = [NSFileManager defaultManager];
    NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString * documentsDirectory = [paths objectAtIndex:0];
    NSString * writableDBPath = [documentsDirectory stringByAppendingPathComponent:@"dyFiles"];
    success = [fileManager fileExistsAtPath:writableDBPath];
    
    if (success)  {
        //
    } else {
        
        NSString  *defaultDBPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"dyFiles"];
        
        success = [BUtility copyMissingFile:defaultDBPath toPath:documentsDirectory];
        if (!success) {
            //
        }
        
    }
    
    [ACEDes enable];
    _globalPluginDict = [[NSMutableDictionary alloc] init];
    
    if (_useCloseAppWithJaibroken) {
        
        BOOL isjab = [BUtility isJailbroken];
        
        if (isjab) {
            
            UIAlertView *alertView =[[UIAlertView alloc] initWithTitle:@"提示" message:@"本应用仅适用未越狱机，即将关闭。" delegate:self cancelButtonTitle:@"确认" otherButtonTitles:nil];
            alertView.tag = kViewTagExit;
			[alertView show];
            [alertView release];
            return NO;
            
        }
        
    }
    //应用从未启动到启动，获取推送信息
    if (launchOptions && [launchOptions objectForKey:@"UIApplicationLaunchOptionsRemoteNotificationKey"] ) {
        
        NSDictionary *dict = [launchOptions objectForKey:@"UIApplicationLaunchOptionsRemoteNotificationKey"];
        NSString *userData = [dict objectForKey:@"userInfo"];
        
        if (userData != nil) {
            
            [[NSUserDefaults standardUserDefaults] setObject:userData forKey:@"pushData"];
            
        }
        
        [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
        
    }
	//应用从未启动到启动，获取本地通知信息
    if (launchOptions && [launchOptions objectForKey:@"UIApplicationLaunchOptionsLocalNotificationKey"] ) {
        //        NSDictionary *dict =[launchOptions objectForKey:@"UIApplicationLaunchOptionsLocalNotificationKey"];
        //        NSDictionary *userData = [dict objectForKey:@"userInfo"];
        //        if (userData!=nil) {
        //            NSMutableDictionary *localNotifDict = [[NSUserDefaults standardUserDefaults] objectForKey:@"localData"];
        //			if (!localNotifDict) {
        //				localNotifDict = [[NSMutableDictionary alloc] initWithCapacity:2];
        //			}
        //			if ([userData objectForKey:@"notificationId"] && [userData objectForKey:@"msg"]) {
        //				[localNotifDict setObject:[userData objectForKey:@"msg"] forKey:[userData objectForKey:@"notificationId"]];
        //			}
        //			[[NSUserDefaults standardUserDefaults] setObject:localNotifDict forKey:@"localData"];
        //	        [[NSUserDefaults standardUserDefaults] synchronize];
        //        }
        [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
        
    }
    
    [BUtility setAppCanDocument];
    //        [[AppCanAnalysis ACInstance] setErrorReport:YES];
    Class analysisClass = NSClassFromString(@"AppCanAnalysis");
    
    if (analysisClass) {//类不存在直接返回
        
        id analysisObject = class_createInstance(analysisClass,0);
        
        ((void(*)(id, SEL,BOOL))objc_msgSend)(analysisObject, @selector(setErrorReport:), YES);
        //objc_msgSend(analysisObject, @selector(setErrorReport:),YES);
        
    }
    
    ACEUINavigationController *meNav = nil;
	meBrwCtrler = [[EBrowserController alloc]init];
    
    NSString *hardware = [BUtility getDeviceVer];
    
    if (![hardware hasPrefix:@"iPad"]) {
        
        //如果设置的屏幕方向包括右横屏，则启动时候先禁止有横屏，启动后再解禁
        NSString * orientation = [BUtility getMainWidgetConfigInterface];
        int or = [orientation intValue];
        
        if (or== 10 || or ==11 ||or ==12 ||or ==9 ||or ==14 ||or ==13 ||or ==8) {
            
            meBrwCtrler.wgtOrientation=2;
            
        }
        
    }
    
//    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 6.0) {
//		//
//    } else {
    
    meNav = [[ACEUINavigationController alloc] initWithRootViewController:meBrwCtrler];
    [meNav setNavigationBarHidden:YES];
    [ACEUtils setNavigationBarColor:meNav color:[UIColor purpleColor]];
    
//    if (isSysVersionAbove7_0) {
//        meNav.navigationBar.barTintColor = [UIColor yellowColor];
//    } else {
//        meNav.navigationBar.tintColor = [UIColor yellowColor];
//    }
    
//    meNav.navigationBar.hidden = YES;
    
//    [[UINavigationBar appearance] setBarTintColor:[UIColor yellowColor]];
    
    
    
//	}
    
	mwWgtMgr = [[WWidgetMgr alloc]init];
	meBrwCtrler.mwWgtMgr = mwWgtMgr;
	[self readAppCanJS];
    
	window = [[UIWindow alloc]initWithFrame:[UIScreen mainScreen].bounds];
	window.autoresizesSubviews = YES;
    
//    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 6.0) {
//        
//		window.rootViewController = meBrwCtrler;
//        
//    } else {
    
    
    
    
    
    
    
    _drawerController = [[ACEDrawerViewController alloc]
                                             initWithCenterViewController:meNav
                                             leftDrawerViewController:nil
                                             rightDrawerViewController:nil];
    
    [_drawerController setMaximumRightDrawerWidth:200.0];
    [_drawerController setMaximumLeftDrawerWidth:200.0];
    [_drawerController setOpenDrawerGestureModeMask:MMOpenDrawerGestureModeAll];
    [_drawerController setCloseDrawerGestureModeMask:MMCloseDrawerGestureModeAll];
    
    [_drawerController
     setDrawerVisualStateBlock:^(MMDrawerController *drawerController, MMDrawerSide drawerSide, CGFloat percentVisible) {
         MMDrawerControllerDrawerVisualStateBlock block;
         block = [[MMExampleDrawerVisualStateManager sharedManager]
                  drawerVisualStateBlockForDrawerSide:drawerSide];
         if(block){
             block(drawerController, drawerSide, percentVisible);
         }
     }];
    
    window.rootViewController = _drawerController;
    
    
    [meNav release];
        
//	}
    
    [window makeKeyAndVisible];
    
    if (isSysVersionAbove8_0) {
        
#ifdef __IPHONE_8_0
        
        UIUserNotificationSettings *uns = [UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeAlert|UIUserNotificationTypeBadge|UIUserNotificationTypeSound) categories:nil];
        //注册推送
        [[UIApplication sharedApplication] registerUserNotificationSettings:uns];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
        
#endif
        
    } else {
        
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeAlert|UIRemoteNotificationTypeBadge|UIRemoteNotificationTypeSound)];
        
    }
    
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
	//支付宝支付－－》4.0以前为单任务
	if ([self isSingleTask]) {
        
		NSURL * url = [launchOptions objectForKey:@"UIApplicationLaunchOptionsURLKey"];
		
		if (nil != url) {
            
			[self parseURL:url application:application];
            
		}
        
	}
    
	return YES;
    
}

- (void)application:(UIApplication *)app didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    
    NSString * devStr = [deviceToken description];
	NSString * firstStr = [devStr stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    
	if (firstStr) {
        
		NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
		[userDefault setValue:firstStr forKey:@"deviceToken"];
        [userDefault setValue:deviceToken forKey:@"device_Token"];
        
	}
    
}
// 注册APNs错误

- (void)application:(UIApplication *)app didFailToRegisterForRemoteNotificationsWithError:(NSError *)err {
    
	
}
// 接收推送通知

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    
    {
        
    NSString *userinfoJson=[userInfo JSONFragment];
    NSString *Json=[NSString stringWithFormat:@"uexWidget.onRemoteNotification(\'%@\');",userinfoJson];
   [[[meBrwCtrler.meBrwMainFrm.meBrwWgtContainer aboveWindowContainer] aboveWindow].meBrwView stringByEvaluatingJavaScriptFromString:Json];
        
    }
    
	NSString *userData = [userInfo objectForKey:@"userInfo"];
	if (userData != nil) {
        
		[[NSUserDefaults standardUserDefaults] setObject:userData forKey:@"pushData"];
        EBrowserWindowContainer * aboveWindowContainer = [meBrwCtrler.meBrwMainFrm.meBrwWgtContainer aboveWindowContainer];
        
        if (aboveWindowContainer) {
            
            [aboveWindowContainer pushNotify];
            
        }
        
//		if (meBrwCtrler) {
//			if (meBrwCtrler.meBrwMainFrm) {
//				if (meBrwCtrler.meBrwMainFrm.meBrwWgtContainer) {
//					if ([meBrwCtrler.meBrwMainFrm.meBrwWgtContainer aboveWindowContainer]) {
//						[[meBrwCtrler.meBrwMainFrm.meBrwWgtContainer aboveWindowContainer] pushNotify];
//					}
//				}
//			}
//		}
        
	}
    
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    
	UIApplicationState state = [application applicationState];
    
	if (state == UIApplicationStateActive) {
        
        //		NSString *notID = [notification.userInfo objectForKey:@"notificationId"];
		NSString * msg = [notification.userInfo objectForKey:@"msg"];
        //		NSString * jsStr = [NSString stringWithFormat:@"uexLocalNotification.onActive(\'%@\', \'%@\')", notID, msg];
        //		EBrowserView *brwView = [meBrwCtrler.meBrwMainFrm.meBrwWgtContainer aboveWindowContainer].meRootBrwWnd.meBrwView;
        //		if (brwView) {
        //			[brwView  stringByEvaluatingJavaScriptFromString:jsStr];
        //		}
		application.applicationIconBadgeNumber = 0;
		UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:msg delegate:self cancelButtonTitle:@"确认" otherButtonTitles:nil];
		alertView.tag = kViewTagLocalNotification;
		[alertView show];
		[alertView release];
        
	} else {
        
		NSString * notID = [notification.userInfo objectForKey:@"notificationId"];
		NSString * jsStr = [NSString stringWithFormat:@"uexLocalNotification.onActive(\'%@\')", notID];
		EBrowserView *brwView = [meBrwCtrler.meBrwMainFrm.meBrwWgtContainer aboveWindowContainer].meRootBrwWnd.meBrwView;
		if (brwView) {
            
			[brwView  stringByEvaluatingJavaScriptFromString:jsStr];
            
		}
		application.applicationIconBadgeNumber = 0;
        
	}
    
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    
	//支付完成后返回当前应用shi调用
	[self parseURL:url application:application];
	return YES;
    
}

-(BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation{
    
    if (url != NULL) {
        
        NSString * strUrl = [url resourceSpecifier];
        NSArray * paramUrlArray = [strUrl componentsSeparatedByString:@"?"];
        
        if (paramUrlArray != NULL && paramUrlArray.count > 1) {
            
            NSString * paramUrl = [paramUrlArray objectAtIndex:1];
            
            if (paramUrl != NULL) {
                
                NSArray * paramUrlArray1 = [paramUrl componentsSeparatedByString:@"&"];
                
                if (paramUrlArray1 != NULL && paramUrlArray1.count > 0) {
                    
                    for (NSInteger i = 0; i < paramUrlArray1.count; i++) {
                        
                        NSString * parmStr = [paramUrlArray1 objectAtIndex:i];
                        NSArray * parmStrArray = [parmStr componentsSeparatedByString:@"="];
                        
                        if (paramUrlArray1 != NULL && parmStrArray.count == 2) {
                            
                            NSString *paramKey = [parmStrArray objectAtIndex:0];
                            NSString *paramValue = [parmStrArray objectAtIndex:1];
                            
                            if (paramValue && paramKey) {
                                
                                if (_thirdInfoDict == nil) {
                                    
                                    _thirdInfoDict = [[NSMutableDictionary dictionary] retain];
                                    
                                }
                                
                                [_thirdInfoDict setValue:paramValue forKey:paramKey];
                                
                            }
                            
                        }
                        
                    }
                    
                    if (_thirdInfoDict.count != 0) {
                        
                        [self performSelector:@selector(delayLoadByOtherApp) withObject:self afterDelay:1.0];
                        
                    }
                    
                }
                
            }
            
            
        }
        
    }
    //支付完成后返回当前应用shi调用
	[self parseURL:url application:application];
	return YES;
}

- (void)delayLoadByOtherApp {
    
    NSString * josnStr = [_thirdInfoDict JSONFragment];
    NSString * jsSuccessCB = [NSString stringWithFormat:@"uexWidget.onLoadByOtherApp(\'%@\');",josnStr];
    
    [meBrwCtrler.meBrwMainFrm.meBrwWgtContainer.meRootBrwWndContainer.meRootBrwWnd.meBrwView stringByEvaluatingJavaScriptFromString:jsSuccessCB];
    
    self.thirdInfoDict = nil;
    
}



- (void)applicationWillResignActive:(UIApplication *)application {
    
	[UIApplication sharedApplication].applicationIconBadgeNumber = -1;
    //	[[[meBrwCtrler.meBrwMainFrm.meBrwWgtContainer aboveWindowContainer] aboveWindow].meBrwView stringByEvaluatingJavaScriptFromString:@"uexWidget.onSuspend();"];
	[meBrwCtrler.meBrwMainFrm.meBrwWgtContainer.meRootBrwWndContainer.meRootBrwWnd.meBrwView stringByEvaluatingJavaScriptFromString:@"uexWidget.onSuspend();"];
    
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    
    //data analysis
    Class  analysisClass = NSClassFromString(@"AppCanAnalysis");
    if (analysisClass) {//类不存在直接返回
        id analysisObject = class_createInstance(analysisClass,0);
        ((void(*)(id, SEL))objc_msgSend)(analysisObject, @selector(setAppBecomeActive));
        //objc_msgSend(analysisObject, @selector(setAppBecomeActive),nil);
    }
    
    [self performSelector:@selector(onResume) withObject:self afterDelay:1.0];
    
}

-(void)onResume{
    
    [meBrwCtrler.meBrwMainFrm.meBrwWgtContainer.meRootBrwWndContainer.meRootBrwWnd.meBrwView stringByEvaluatingJavaScriptFromString:@"uexWidget.onResume();"];
    
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    
    id number = [[NSUserDefaults standardUserDefaults] objectForKey:F_UD_BadgeNumber];
    if (number) {
        
        [UIApplication sharedApplication].applicationIconBadgeNumber = [number intValue];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:F_UD_BadgeNumber];
        
    }
    
	[self stopAllNetService];
    //data analysis
    int type = [[meBrwCtrler.meBrwMainFrm.meBrwWgtContainer aboveWindowContainer] aboveWindow].meBrwView.mwWgt.wgtType;
    NSString * viewName =[[[meBrwCtrler.meBrwMainFrm.meBrwWgtContainer aboveWindowContainer] aboveWindow].meBrwView.curUrl absoluteString];
    [BUtility setAppCanViewBackground:type name:viewName closeReason:2];
    
    if ([[meBrwCtrler.meBrwMainFrm.meBrwWgtContainer aboveWindowContainer] aboveWindow].mPopoverBrwViewDict) {
        
        NSArray * popViewArray = [[[meBrwCtrler.meBrwMainFrm.meBrwWgtContainer aboveWindowContainer] aboveWindow].mPopoverBrwViewDict allValues];
        for (EBrowserView * ePopView in popViewArray) {
            
            int type =ePopView.mwWgt.wgtType;
            NSString *viewName =[ePopView.curUrl absoluteString];
            [BUtility setAppCanViewBackground:type name:viewName closeReason:0];
            //[BUtility setAppCanViewActive:type opener:goViewName name:viewName openReason:0 mainWin:1];
            
        }
        
    }
    
    Class  analysisClass = NSClassFromString(@"AppCanAnalysis");
    if (analysisClass) {//类不存在直接返回
        
        id analysisObject = class_createInstance(analysisClass,0);
        ((void(*)(id, SEL))objc_msgSend)(analysisObject, @selector(setAppBecomeBackground));
        //objc_msgSend(analysisObject, @selector(setAppBecomeBackground),nil);
        
    }
    
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
	//[self startAllNetService];
    int type = [[meBrwCtrler.meBrwMainFrm.meBrwWgtContainer aboveWindowContainer] aboveWindow].meBrwView.mwWgt.wgtType;
    NSString * goViewName =[[[meBrwCtrler.meBrwMainFrm.meBrwWgtContainer aboveWindowContainer] aboveWindow].meBrwView.curUrl absoluteString];
    //[BUtility setAppCanViewBackground:type name:viewName closeReason:2];
    if (!goViewName || [goViewName isKindOfClass:[NSNull class]]) {
        
        [BUtility writeLog:@"appcan crash ....."];
        return;
        
    }
    
    [BUtility setAppCanViewActive:type opener:@"application://" name:goViewName openReason:0 mainWin:0];
    if ([[meBrwCtrler.meBrwMainFrm.meBrwWgtContainer aboveWindowContainer] aboveWindow].mPopoverBrwViewDict) {
        
        NSArray * popViewArray = [[[meBrwCtrler.meBrwMainFrm.meBrwWgtContainer aboveWindowContainer] aboveWindow].mPopoverBrwViewDict allValues];
        
        for (EBrowserView * ePopView in popViewArray) {
            
            int type =ePopView.mwWgt.wgtType;
            NSString * viewName =[ePopView.curUrl absoluteString];
            [BUtility setAppCanViewActive:type opener:goViewName name:viewName openReason:0 mainWin:1];
            
        }
        
    }
    
}

- (void)applicationWillTerminate:(UIApplication *)application {
    
    //data analysis
    Class  analysisClass = NSClassFromString(@"AppCanAnalysis");
    
    if (analysisClass) {//类不存在直接返回
        
        id analysisObject = class_createInstance(analysisClass,0);
        ((void(*)(id, SEL))objc_msgSend)(analysisObject, @selector(setAppBecomeBackground));
        //objc_msgSend(analysisObject, @selector(setAppBecomeBackground),nil);
        
    }
    
    int type = [[meBrwCtrler.meBrwMainFrm.meBrwWgtContainer aboveWindowContainer] aboveWindow].meBrwView.mwWgt.wgtType;
    NSString * viewName =[[[meBrwCtrler.meBrwMainFrm.meBrwWgtContainer aboveWindowContainer] aboveWindow].meBrwView.curUrl absoluteString];
    [BUtility setAppCanViewBackground:type name:viewName closeReason:2];
    
    if ([[meBrwCtrler.meBrwMainFrm.meBrwWgtContainer aboveWindowContainer] aboveWindow].mPopoverBrwViewDict) {
        
        NSArray * popViewArray = [[[meBrwCtrler.meBrwMainFrm.meBrwWgtContainer aboveWindowContainer] aboveWindow].mPopoverBrwViewDict allValues];
        
        for (EBrowserView *ePopView in popViewArray) {
            
            int type =ePopView.mwWgt.wgtType;
            NSString *viewName =[ePopView.curUrl absoluteString];
            [BUtility setAppCanViewBackground:type name:viewName closeReason:0];
            
        }
        
    }
    
	[UIApplication sharedApplication].applicationIconBadgeNumber = -1;
	[[[meBrwCtrler.meBrwMainFrm.meBrwWgtContainer aboveWindowContainer] aboveWindow].meBrwView stringByEvaluatingJavaScriptFromString:@"uexWidget.onTerminate();"];
    // empty the tmp directory
    //    NSFileManager* fileMgr = [[NSFileManager alloc] init];
    //    NSError* err = nil;
    //
    //    // clear contents of NSTemporaryDirectory
    //    NSString* tempDirectoryPath = NSTemporaryDirectory();
    //    NSDirectoryEnumerator* directoryEnumerator = [fileMgr enumeratorAtPath:tempDirectoryPath];
    //    NSString* fileName = nil;
    //    BOOL result;
    //
    //    while ((fileName = [directoryEnumerator nextObject])) {
    //        NSString* filePath = [tempDirectoryPath stringByAppendingPathComponent:fileName];
    //        result = [fileMgr removeItemAtPath:filePath error:&err];
    //        if (!result && err) {
    //            ACENSLog(@"Failed to delete: %@ (error: %@)", filePath, err);
    //        }
    //    }
    //    [fileMgr release];
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    
	[BUtility writeLog:@"wigetone application receive memory warning"];
    
    // Remove and disable all URL Cache, but doesn't seem to affect the memory
	[[NSURLCache sharedURLCache] removeAllCachedResponses];
	[[NSURLCache sharedURLCache] setDiskCapacity:0];
	[[NSURLCache sharedURLCache] setMemoryCapacity:0];
	[[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"WebKitCacheModelPreferenceKey"];
	// Remove all credential on release, but memory used doesn't move!
	NSURLCredentialStorage * credentialsStorage = [NSURLCredentialStorage sharedCredentialStorage];
	NSDictionary * allCredentials = [credentialsStorage allCredentials];
    
	for (NSURLProtectionSpace * protectionSpace in allCredentials) {
        
		NSDictionary * credentials = [credentialsStorage credentialsForProtectionSpace:protectionSpace];
        
		for (NSString * credentialKey in credentials) {
            
			[credentialsStorage removeCredential:[credentials objectForKey:credentialKey] forProtectionSpace:protectionSpace];
            
		}
        
	}
    
}

#pragma mark - UIAlertViewDelgate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    [alertView dismissWithClickedButtonIndex:buttonIndex animated:YES];
    
	if (alertView.tag == kViewTagExit) {
        
		[BUtility exitWithClearData];
        
	}
    
}
- (void)dealloc {
	if(pluginObj){
		[pluginObj release];
		pluginObj = nil;
	}
	
	if (AppCanJS) {
		[AppCanJS release];
		AppCanJS = nil;
	}
	if (window) {
		[window release];
		window = nil;
	}
	if (meBrwCtrler) {
		[meBrwCtrler release];
		meBrwCtrler = nil;
	}
	if (mwWgtMgr) {
		[mwWgtMgr release];
		mwWgtMgr = nil;
	}
    self.useAppCanMAMURL = nil;
    self.useAppCanMCMURL=nil;
    self.useAppCanMDMURL=nil;
    self.useAnalysisDataURL = nil;
    self.useBindUserPushURL = nil;
    self.useStartReportURL = nil;
    self.useAppCanMAMURL = nil;
    self.useCertificatePassWord = nil;
    self.useAppCanUpdateURL = nil;
    [_leftWebController release];
    [_rightWebController release];
    [_drawerController release];
    [_globalPluginDict release];
	[super dealloc];
}
@end
