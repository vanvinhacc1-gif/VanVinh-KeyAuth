#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#include <dlfcn.h> // Thư viện để gọi file dylib khác

#define KH_NAME    @"VanVinhiOS" 
#define KH_OWNERID @"gnIVuUid3U"
#define KH_SECRET  @"d5b933c3de31702c49156093845b42699e19e71935e4e899666f7f631626210b"

void showLogin() {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"VAN VINH - VER 2.0" message:@"NHẬP KEY ĐỂ MỞ MENU HACK" preferredStyle:UIAlertControllerStyleAlert];
        [alert addTextFieldWithConfigurationHandler:^(UITextField *t){ t.placeholder=@"Key..."; }];
        
        [alert addAction:[UIAlertAction actionWithTitle:@"Đăng Nhập" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            NSString *key = alert.textFields.firstObject.text;
            NSString *url = [NSString stringWithFormat:@"https://keyauth.win/api/1.2/?type=login&name=%@&ownerid=%@&secret=%@&key=%@&ver=2.0", KH_NAME, KH_OWNERID, KH_SECRET, key];
            
            [[[NSURLSession sharedSession] dataTaskWithURL:[NSURL URLWithString:url] completionHandler:^(NSData *data, NSURLResponse *res, NSError *err) {
                if (data) {
                    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                    BOOL success = [[json objectForKey:@"success"] boolValue];
                    NSString *msg = [[json objectForKey:@"message"] lowercaseString];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (success && ![msg containsString:@"expired"]) {
                            
                            // === ĐÂY LÀ CHỖ QUAN TRỌNG: GỌI MENU MOD ===
                            // Nó sẽ load file có tên là MenuMod.dylib nằm trong thư mục App
                            dlopen([[NSString stringWithFormat:@"%@/MenuMod.dylib", [[NSBundle mainBundle] bundlePath]] UTF8String], RTLD_NOW);
                            
                            UIAlertController *ok = [UIAlertController alertControllerWithTitle:@"Thành Công" message:@"Menu Mod đã được kích hoạt!" preferredStyle:UIAlertControllerStyleAlert];
                            [ok addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
                            [window.rootViewController presentViewController:ok animated:YES completion:nil];
                        } else {
                            // Hiện bảng từ chối nếu key sai hoặc hết hạn
                            showLogin(); 
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
