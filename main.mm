#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#include <dlfcn.h>

#define KH_NAME    @"VanVinhiOS" 
#define KH_OWNERID @"gnIVuUid3U"
#define KH_SECRET  @"d5b933c3de31702c49156093845b42699e19e71935e4e899666f7f631626210b"

void showLogin() {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        // Tạo bảng nhập Key
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"XÁC THỰC VAN VINH" 
                                                                       message:@"Vui lòng nhập Key để tiếp tục" 
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        [alert addTextFieldWithConfigurationHandler:^(UITextField *t){ 
            t.placeholder=@"Nhập Key tại đây..."; 
            t.secureTextEntry = YES;
        }];
        
        [alert addAction:[UIAlertAction actionWithTitle:@"Kích Hoạt" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            NSString *key = alert.textFields.firstObject.text;
            // Ép Version 2.0 để chặn mọi Session cũ
            NSString *url = [NSString stringWithFormat:@"https://keyauth.win/api/1.2/?type=login&name=%@&ownerid=%@&secret=%@&key=%@&ver=2.0", KH_NAME, KH_OWNERID, KH_SECRET, key];
            
            [[[NSURLSession sharedSession] dataTaskWithURL:[NSURL URLWithString:url] completionHandler:^(NSData *data, NSURLResponse *res, NSError *err) {
                if (data) {
                    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                    BOOL success = [[json objectForKey:@"success"] boolValue];
                    NSString *msg = [[json objectForKey:@"message"] lowercaseString];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        // CHỈ CHO VÀO KHI SUCCESS = TRUE VÀ MESSAGE KHÔNG CHỨA CHỮ "EXPIRED"
                        if (success && ![msg containsString:@"expired"]) {
                            // LOAD MENU MOD TỪ THƯ MỤC APP
                            dlopen([[NSString stringWithFormat:@"%@/aimkill Lol.dylib", [[NSBundle mainBundle] bundlePath]] UTF8String], RTLD_NOW);
                            
                            UIAlertController *ok = [UIAlertController alertControllerWithTitle:@"THÀNH CÔNG" message:@"Đã kích hoạt Menu Hack!" preferredStyle:UIAlertControllerStyleAlert];
                            [ok addAction:[UIAlertAction actionWithTitle:@"Vào Game" style:UIAlertActionStyleDefault handler:nil]];
                            [window.rootViewController presentViewController:ok animated:YES completion:nil];
                        } else {
                            // SAI LÀ KHÓA CỨNG - HIỆN BẢNG LỖI
                            UIAlertController *no = [UIAlertController alertControllerWithTitle:@"TRUY CẬP BỊ TỪ CHỐI" 
                                                                                       message:@"Key sai, hết hạn hoặc không tồn tại!" 
                                                                                preferredStyle:UIAlertControllerStyleAlert];
                            // Nút "Thử lại" này sẽ gọi lại login, không cho nó tắt bảng đi để vào game
                            [no addAction:[UIAlertAction actionWithTitle:@"Nhập lại Key" style:UIAlertActionStyleDestructive handler:^(id a){ 
                                showLogin(); 
                            }]];
                            [window.rootViewController presentViewController:no animated:YES completion:nil];
                        }
                    });
                }
            }] resume];
        }]];
        
        // Ngăn chặn việc bấm ra ngoài để tắt bảng (tùy phiên bản iOS)
        [window.rootViewController presentViewController:alert animated:YES completion:nil];
    });
}

__attribute__((constructor)) static void init() {
    // Đợi 5 giây để Game load xong mới hiện Login
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{ 
        showLogin(); 
    });
}
