#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

// --- THÔNG TIN KEYAUTH CỦA MÀY (ĐÃ ĐIỀN SẴN) ---
#define KH_NAME    @"VanVinhiOS" 
#define KH_OWNERID @"gnIVuUid3U"
#define KH_SECRET  @"d5b933c3de31702c49156093845b42699e19e71935e4e899666f7f631626210b"

void showLogin() {
    dispatch_async(dispatch_get_main_queue(), ^{
        // Tạo bảng thông báo nhập Key
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:KH_NAME 
                                   message:@"Hệ Thống Xác Thực Key" 
                                   preferredStyle:UIAlertControllerStyleAlert];
        
        [alert addTextFieldWithConfigurationHandler:^(UITextField *txt) {
            txt.placeholder = @"Nhập Key tại đây...";
            txt.secureTextEntry = YES; // Ẩn key khi nhập
        }];
        
        UIAlertAction *loginAction = [UIAlertAction actionWithTitle:@"Đăng Nhập" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            NSString *userKey = alert.textFields.firstObject.text;

            // --- GỌI API ĐỂ KIỂM TRA KEY ---
            NSString *urlStr = [NSString stringWithFormat:@"https://keyauth.win/api/1.2/?type=login&name=%@&ownerid=%@&secret=%@&key=%@", 
                               KH_NAME, KH_OWNERID, KH_SECRET, userKey];
            
            NSURLRequest *req = [NSURLRequest requestWithURL:[NSURL URLWithString:urlStr]];
            [[[NSURLSession sharedSession] dataTaskWithRequest:req completionHandler:^(NSData *data, NSURLResponse *res, NSError *err) {
                if (data) {
                    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                    BOOL success = [[json objectForKey:@"success"] boolValue];
                    NSString *msg = [json objectForKey:@"message"];

                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (success) {
                            // TRƯỜNG HỢP KEY ĐÚNG
                            UIAlertController *ok = [UIAlertController alertControllerWithTitle:@"Thành Công" message:@"Key hợp lệ!" preferredStyle:UIAlertControllerStyleAlert];
                            [ok addAction:[UIAlertAction actionWithTitle:@"Vào Game" style:UIAlertActionStyleDefault handler:nil]];
                            [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:ok animated:YES completion:nil];
                        } else {
                            // TRƯỜNG HỢP KEY SAI
                            UIAlertController *no = [UIAlertController alertControllerWithTitle:@"Lỗi" message:msg preferredStyle:UIAlertControllerStyleAlert];
                            [no addAction:[UIAlertAction actionWithTitle:@"Thử lại" style:UIAlertActionStyleDefault handler:^(UIAlertAction *a){ showLogin(); }]];
                            [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:no animated:YES completion:nil];
                        }
                    });
                }
            }] resume];
        }];

        [alert addAction:loginAction];
        [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alert animated:YES completion:nil];
    });
}

__attribute__((constructor))
static void init() {
    // Đợi 5 giây cho game load xong mới hiện bảng nhập Key
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        showLogin();
    });
}
