#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define KH_NAME    @"VanVinhiOS" 
#define KH_OWNERID @"gnIVuUid3U"
#define KH_SECRET  @"d5b933c3de31702c49156093845b42699e19e71935e4e899666f7f631626210b"

void showLogin() {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:KH_NAME message:@"Hệ Thống Xác Thực - VanVinh" preferredStyle:UIAlertControllerStyleAlert];
        
        [alert addTextFieldWithConfigurationHandler:^(UITextField *txt) {
            txt.placeholder = @"Nhập Key...";
            txt.secureTextEntry = YES;
        }];
        
        [alert addAction:[UIAlertAction actionWithTitle:@"Đăng Nhập" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            NSString *userKey = alert.textFields.firstObject.text;
            NSString *urlStr = [NSString stringWithFormat:@"https://keyauth.win/api/1.2/?type=login&name=%@&ownerid=%@&secret=%@&key=%@", KH_NAME, KH_OWNERID, KH_SECRET, userKey];
            
            [[[NSURLSession sharedSession] dataTaskWithURL:[NSURL URLWithString:urlStr] completionHandler:^(NSData *data, NSURLResponse *res, NSError *err) {
                if (data) {
                    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                    if ([[json objectForKey:@"success"] boolValue]) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            UIAlertController *ok = [UIAlertController alertControllerWithTitle:@"Thành Công" message:@"Chào mừng VanVinh đã quay trở lại!" preferredStyle:UIAlertControllerStyleAlert];
                            [ok addAction:[UIAlertAction actionWithTitle:@"Vào Game" style:UIAlertActionStyleDefault handler:nil]];
                            [window.rootViewController presentViewController:ok animated:YES completion:nil];
                        });
                    } else {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            UIAlertController *no = [UIAlertController alertControllerWithTitle:@"Lỗi Key" message:[json objectForKey:@"message"] preferredStyle:UIAlertControllerStyleAlert];
                            [no addAction:[UIAlertAction actionWithTitle:@"Thử lại" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *a){ showLogin(); }]];
                            [window.rootViewController presentViewController:no animated:YES completion:nil];
                        });
                    }
                }
            }] resume];
        }]];
        [window.rootViewController presentViewController:alert animated:YES completion:nil];
    });
}

__attribute__((constructor))
static void init() {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        showLogin();
    });
}
