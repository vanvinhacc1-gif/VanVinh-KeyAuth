#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#include <dlfcn.h>

#define KH_NAME    @"VanVinhiOS" 
#define KH_OWNERID @"gnIVuUid3U"
#define KH_SECRET  @"d5b933c3de31702c49156093845b42699e19e71935e4e899666f7f631626210b"

// Hàm phụ để đổi giây thành định dạng Ngày/Giờ/Phút
NSString* timeRemaining(long long expiry) {
    long long now = (long long)[[NSDate date] timeIntervalSince1970];
    long long diff = expiry - now;
    if (diff <= 0) return @"Đã hết hạn";
    
    long days = diff / 86400;
    long hours = (diff % 86400) / 3600;
    long minutes = (diff % 3600) / 60;
    
    return [NSString stringWithFormat:@"%ld ngày, %ld giờ, %ld phút", days, hours, minutes];
}

void showLogin() {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"VAN VINH - PREMIUM" 
                                                                       message:@"Vui lòng nhập Key để kích hoạt Hack" 
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        [alert addTextFieldWithConfigurationHandler:^(UITextField *t){ t.placeholder=@"Dán Key tại đây..."; }];
        
        [alert addAction:[UIAlertAction actionWithTitle:@"Kích Hoạt" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            // Xử lý xóa dấu cách thừa
            NSString *rawKey = alert.textFields.firstObject.text;
            NSString *userKey = [rawKey stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            
            NSString *url = [NSString stringWithFormat:@"https://keyauth.win/api/1.2/?type=login&name=%@&ownerid=%@&secret=%@&key=%@&ver=2.0", KH_NAME, KH_OWNERID, KH_SECRET, userKey];
            
            [[[NSURLSession sharedSession] dataTaskWithURL:[NSURL URLWithString:url] completionHandler:^(NSData *data, NSURLResponse *res, NSError *err) {
                if (data) {
                    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                    BOOL success = [[json objectForKey:@"success"] boolValue];
                    NSString *msg = [[json objectForKey:@"message"] lowercaseString];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (success && ![msg containsString:@"expired"]) {
                            // Lấy thời gian hết hạn từ Server
                            NSDictionary *info = [json objectForKey:@"info"];
                            NSArray *subs = [info objectForKey:@"subscriptions"];
                            long long expiry = [[subs[0] objectForKey:@"expiry"] longLongValue];
                            
                            // Load Menu Mod
                            dlopen([[NSString stringWithFormat:@"%@/aimkill Lol.dylib", [[NSBundle mainBundle] bundlePath]] UTF8String], RTLD_NOW);
                            
                            // Hiện thông báo thành công kèm thời gian còn lại
                            NSString *successMsg = [NSString stringWithFormat:@"Chào mừng VanVinh!\nHạn dùng: %@", timeRemaining(expiry)];
                            UIAlertController *ok = [UIAlertController alertControllerWithTitle:@"KÍCH HOẠT THÀNH CÔNG" message:successMsg preferredStyle:UIAlertControllerStyleAlert];
                            [ok addAction:[UIAlertAction actionWithTitle:@"Vào Game" style:UIAlertActionStyleDefault handler:nil]];
                            [window.rootViewController presentViewController:ok animated:YES completion:nil];
                        } else {
                            // Báo lỗi nếu key lỏ hoặc hết hạn
                            UIAlertController *no = [UIAlertController alertControllerWithTitle:@"LỖI TRUY CẬP" message:@"Key không đúng hoặc đã hết hạn!" preferredStyle:UIAlertControllerStyleAlert];
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
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{ showLogin(); });
}
