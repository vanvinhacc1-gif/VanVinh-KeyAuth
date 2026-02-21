#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#include <dlfcn.h>

#define KH_NAME    @"Free Fire" 
#define KH_OWNERID @"gnIVuUid3U"
#define KH_SECRET  @"d5b933c3de31702c49156093845b42699e19e71935e4e899666f7f631626210b"

NSString* timeRemaining(long long expiry) {
    long long now = (long long)[[NSDate date] timeIntervalSince1970];
    long long diff = expiry - now;
    if (diff <= 0) return @"Hết hạn";
    long days = diff / 86400, hours = (diff % 86400) / 3600, mins = (diff % 3600) / 60;
    return [NSString stringWithFormat:@"%ld ngày, %ld giờ, %ld phút", days, hours, mins];
}

void showLogin() {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"XÁC THỰC HỆ THỐNG" 
                                                                       message:@"CẤM NHẬP DẤU CÁCH" 
                                                                preferredStyle:UIAlertControllerStyleAlert];
        [alert addTextFieldWithConfigurationHandler:^(UITextField *t){ t.placeholder=@"Nhập Key chuẩn..."; }];
        
        [alert addAction:[UIAlertAction actionWithTitle:@"Đăng Nhập" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            NSString *rawKey = alert.textFields.firstObject.text;
            
            // CHẶN NGAY NẾU CÓ DẤU CÁCH HOẶC TRỐNG
            if ([rawKey containsString:@" "] || [rawKey isEqualToString:@""]) {
                showLogin(); // Hiện lại bảng đòi key ngay lập tức
                return;
            }

            NSString *url = [NSString stringWithFormat:@"https://keyauth.win/api/1.2/?type=login&name=%@&ownerid=%@&secret=%@&key=%@&ver=2.0", 
                            [KH_NAME stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]], 
                            KH_OWNERID, KH_SECRET, rawKey];
            
            [[[NSURLSession sharedSession] dataTaskWithURL:[NSURL URLWithString:url] completionHandler:^(NSData *data, NSURLResponse *res, NSError *err) {
                if (data) {
                    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                    // KIỂM TRA BOOLEAN SUCCESS CỰC KỲ CHẶT CHẼ
                    id successObj = [json objectForKey:@"success"];
                    BOOL success = [successObj isKindOfClass:[NSNumber class]] && [successObj boolValue];
                    NSString *msg = [[json objectForKey:@"message"] lowercaseString];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        // CHỈ CHO VÀO KHI SUCCESS LÀ TRUE VÀ KHÔNG CÓ CHỮ "EXPIRED" HOẶC "INVALID"
                        if (success && ![msg containsString:@"expired"] && ![msg containsString:@"invalid"] && ![msg containsString:@"not found"]) {
                            NSDictionary *info = [json objectForKey:@"info"];
                            NSArray *subs = [info objectForKey:@"subscriptions"];
                            long long expiry = [[subs[0] objectForKey:@"expiry"] longLongValue];
                            
                            dlopen([[NSString stringWithFormat:@"%@/aimkill Lol.dylib", [[NSBundle mainBundle] bundlePath]] UTF8String], RTLD_NOW);
                            
                            UIAlertController *ok = [UIAlertController alertControllerWithTitle:@"THÀNH CÔNG" 
                                                                                       message:[NSString stringWithFormat:@"Hạn dùng: %@", timeRemaining(expiry)] 
                                                                                preferredStyle:UIAlertControllerStyleAlert];
                            [ok addAction:[UIAlertAction actionWithTitle:@"Vào Game" style:UIAlertActionStyleDefault handler:nil]];
                            [window.rootViewController presentViewController:ok animated:YES completion:nil];
                        } else {
                            // HIỆN BẢNG TỪ CHỐI VÀ KHÔNG LÀM GÌ TIẾP
                            UIAlertController *no = [UIAlertController alertControllerWithTitle:@"TỪ CHỐI" message:@"Key lỏ hoặc hết hạn!" preferredStyle:UIAlertControllerStyleAlert];
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
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{ showLogin(); });
}
