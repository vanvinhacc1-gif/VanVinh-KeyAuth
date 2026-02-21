#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#include <dlfcn.h>

// QUAN TRỌNG: Mày phải dán Link RAW từ Gist vào đây
#define LINK_GIST_RAW @"DÁN_LINK_RAW_CỦA_MÀY_VÀO_ĐÂY"

void showLogin() {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"VAN VINH VIP" 
                                                                       message:@"HỆ THỐNG KEY RIÊNG" 
                                                                preferredStyle:UIAlertControllerStyleAlert];
        [alert addTextFieldWithConfigurationHandler:^(UITextField *t){ t.placeholder=@"Nhập Key (VinhiOS)..."; }];
        
        [alert addAction:[UIAlertAction actionWithTitle:@"Kích Hoạt" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            NSString *input = [alert.textFields.firstObject.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            
            [[[NSURLSession sharedSession] dataTaskWithURL:[NSURL URLWithString:LINK_GIST_RAW] completionHandler:^(NSData *data, NSURLResponse *res, NSError *err) {
                if (data) {
                    NSString *serverKey = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                    serverKey = [serverKey stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if ([input isEqualToString:serverKey] && ![input isEqualToString:@""]) {
                            // LOAD MENU MOD (Đúng tên file mày nhúng trong ESign)
                            dlopen([[NSString stringWithFormat:@"%@/aimkill Lol.dylib", [[NSBundle mainBundle] bundlePath]] UTF8String], RTLD_NOW);
                            
                            UIAlertController *ok = [UIAlertController alertControllerWithTitle:@"THÀNH CÔNG" message:@"Chào đại ca Vinh!" preferredStyle:UIAlertControllerStyleAlert];
                            [ok addAction:[UIAlertAction actionWithTitle:@"Vào" style:UIAlertActionStyleDefault handler:nil]];
                            [window.rootViewController presentViewController:ok animated:YES completion:nil];
                        } else {
                            showLogin(); // Sai key hiện lại bảng nhập
                        }
                    });
                }
            }] resume];
        }]];
        [window.rootViewController presentViewController:alert animated:YES completion:nil];
    });
}

__attribute__((constructor)) static void init() {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{ showLogin(); });
}
