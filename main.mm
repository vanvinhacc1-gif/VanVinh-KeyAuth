#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#include <dlfcn.h>

//https://raw.githubusercontent.com/vanvinhacc1-gif/VanVinh-KeyAuth/refs/heads/main/danh_sach_key.txt
#define LINK_SERVER @"https://raw.githubusercontent.com/vanvinhacc1-gif/VanVinh-KeyAuth/main/danh_sach_key.txt"

void showLogin() {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"VAN VINH PRIVATE" 
                                                                       message:@"HỆ THỐNG KEY RIÊNG" 
                                                                preferredStyle:UIAlertControllerStyleAlert];
        [alert addTextFieldWithConfigurationHandler:^(UITextField *t){ t.placeholder=@"Nhập Key của đại ca..."; }];
        
        [alert addAction:[UIAlertAction actionWithTitle:@"Kích Hoạt" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            NSString *input = [alert.textFields.firstObject.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            
            [[[NSURLSession sharedSession] dataTaskWithURL:[NSURL URLWithString:LINK_SERVER] completionHandler:^(NSData *data, NSURLResponse *res, NSError *err) {
                if (data) {
                    NSString *allKeys = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                    NSArray *keyArray = [allKeys componentsSeparatedByString:@"\n"];
                    __block BOOL check = NO;
                    for (NSString *key in keyArray) {
                        NSString *cleanKey = [key stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                        if ([input isEqualToString:cleanKey] && ![input isEqualToString:@""]) {
                            check = YES; break;
                        }
                    }
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (check) {
                            // LOAD MENU MOD (Phải trùng tên file mày nhúng trong ESign)
                            dlopen([[NSString stringWithFormat:@"%@/aimkill Lol.dylib", [[NSBundle mainBundle] bundlePath]] UTF8String], RTLD_NOW);
                            
                            UIAlertController *ok = [UIAlertController alertControllerWithTitle:@"OK" message:@"Chào đại ca Vinh!" preferredStyle:UIAlertControllerStyleAlert];
                            [ok addAction:[UIAlertAction actionWithTitle:@"Vào" style:UIAlertActionStyleDefault handler:nil]];
                            [window.rootViewController presentViewController:ok animated:YES completion:nil];
                        } else {
                            showLogin(); // Sai key hiện lại bảng login
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
