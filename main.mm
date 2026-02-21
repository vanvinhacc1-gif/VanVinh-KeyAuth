#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define KH_NAME    @"VanVinhiOS" 
#define KH_OWNERID @"gnIVuUid3U"
#define KH_SECRET  @"d5b933c3de31702c49156093845b42699e19e71935e4e899666f7f631626210b"

void showLogin() {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"VAN VINH - VER 2.0" 
                                                                       message:@"HỆ THỐNG ĐÃ RESET - NHẬP KEY" 
                                                                preferredStyle:UIAlertControllerStyleAlert];
        [alert addTextFieldWithConfigurationHandler:^(UITextField *t){ t.placeholder=@"Key..."; }];
        
        [alert addAction:[UIAlertAction actionWithTitle:@"Đăng Nhập" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            NSString *key = alert.textFields.firstObject.text;
            // DÙNG VER 2.0 ĐỂ KHỚP VỚI DASHBOARD
            NSString *url = [NSString stringWithFormat:@"https://keyauth.win/api/1.2/?type=login&name=%@&ownerid=%@&secret=%@&key=%@&ver=2.0", KH_NAME, KH_OWNERID, KH_SECRET, key];
            
            [[[NSURLSession sharedSession] dataTaskWithURL:[NSURL URLWithString:url] completionHandler:^(NSData *data, NSURLResponse *res, NSError *err) {
                if (data) {
                    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                    BOOL success = [[json objectForKey:@"success"] boolValue];
                    NSString *msg = [[json objectForKey:@"message"] lowercaseString];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        // CHẶN NGAY NẾU SUCCESS=FALSE HOẶC MESSAGE CÓ CHỮ "EXPIRED"
                        if (success && ![msg containsString:@"expired"]) {
                            UIAlertController *ok = [UIAlertController alertControllerWithTitle:@"Thành Công" message:@"Chào VanVinh, mời vào game!" preferredStyle:UIAlertControllerStyleAlert];
                            [ok addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
                            [window.rootViewController presentViewController:ok animated:YES completion:nil];
                        } else {
                            UIAlertController *no = [UIAlertController alertControllerWithTitle:@"TỪ CHỐI" message:@"Key sai hoặc đã hết hạn!" preferredStyle:UIAlertControllerStyleAlert];
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
