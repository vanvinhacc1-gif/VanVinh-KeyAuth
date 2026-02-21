#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#include <dlfcn.h>

// THÔNG TIN KHỚP 100% VỚI DASHBOARD FF CỦA MÀY
#define KH_NAME    @"Free Fire" 
#define KH_OWNERID @"gnIVuUid3U"
#define KH_SECRET  @"d5b933c3de31702c49156093845b42699e19e71935e4e899666f7f631626210b"

// Hàm đổi thời gian sang Ngày/Giờ/Phút
NSString* timeRemaining(long long expiry) {
    long long now = (long long)[[NSDate date] timeIntervalSince1970];
    long long diff = expiry - now;
    if (diff <= 0) return @"Đã hết hạn";
    long days = diff / 86400;
    long hours = (diff % 86400) / 3600;
    long mins = (diff % 3600) / 60;
    return [NSString stringWithFormat:@"%ld ngày, %ld giờ, %ld phút", days, hours, mins];
}

void showLogin() {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"VAN VINH - FF MOD" 
                                                                       message:@"VUI LÒNG NHẬP KEY" 
                                                                preferredStyle:UIAlertControllerStyleAlert];
        [alert addTextFieldWithConfigurationHandler:^(UITextField *t){ t.placeholder=@"Dán Key FF tại đây..."; }];
        
        [alert addAction:[UIAlertAction actionWithTitle:@"Kích Hoạt" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            NSString *rawKey = alert.textFields.firstObject.text;
            
            // CHẶN DẤU CÁCH VÀ TRỐNG (FIX THÔNG CHỐT)
            if ([rawKey containsString:@" "] || [rawKey isEqualToString:@""]) {
                showLogin();
                return;
            }

            // Gửi API chuẩn Ver 2.0
            NSString *url = [NSString stringWithFormat:@"https://keyauth.win/api/1.2/?type=login&name=%@&ownerid=%@&secret=%@&key=%@&ver=2.0", 
                            [KH_NAME stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]], 
                            KH_OWNERID, KH_SECRET, rawKey];
            
            [[[NSURLSession sharedSession] dataTaskWithURL:[NSURL URLWithString:url] completionHandler:^(NSData *data, NSURLResponse *res, NSError *err) {
                if (data) {
                    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                    id successObj = [json objectForKey:@"success"];
                    BOOL success = [successObj isKindOfClass:[NSNumber class]] && [successObj boolValue];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (success) {
                            // LẤY HẠN DÙNG
                            NSDictionary *info = [json objectForKey:@"info"];
                            NSArray *subs = [info objectForKey:@"subscriptions"];
                            long long expiry = [[subs[0] objectForKey:@"expiry"] longLongValue];
                            
                            // LOAD MENU MOD (FILE DYLIB TRONG ẢNH 11:21)
                            dlopen([[NSString stringWithFormat:@"%@/aimkill Lol.dylib", [[NSBundle mainBundle] bundlePath]] UTF8String], RTLD_NOW);
                            
                            NSString *msg = [NSString stringWithFormat:@"Đăng nhập thành công!\nHạn dùng: %@", timeRemaining(expiry)];
                            UIAlertController *ok = [UIAlertController alertControllerWithTitle:@"THÀNH CÔNG" message:msg preferredStyle:UIAlertControllerStyleAlert];
                            [ok addAction:[UIAlertAction actionWithTitle:@"Vào Game" style:UIAlertActionStyleDefault handler:nil]];
                            [window.rootViewController presentViewController:ok animated:YES completion:nil];
                        } else {
                            // BÁO LỖI VÀ BẮT NHẬP LẠI
                            UIAlertController *no = [UIAlertController alertControllerWithTitle:@"TỪ CHỐI" message:@"Key FF không đúng hoặc hết hạn!" preferredStyle:UIAlertControllerStyleAlert];
                            [no addAction:[UIAlertAction actionWithTitle:@"Thử lại" style:UIAlertActionStyleDestructive handler:^(id a){ showLogin(); }]];
                            [window.rootViewController presentViewController:no animated:YES completion:nil];
                        }
                    });
                }
            }] resume];
        }]];
        [window.rootViewController presentViewController:alert animated:YES completion:nil];
    });
}

__attribute__((constructor)) static void init() {
    // Đợi 2 giây cho game load
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{ showLogin(); });
}
