#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define KH_NAME    @"VanVinhiOS" 
#define KH_OWNERID @"gnIVuUid3U"
#define KH_SECRET  @"d5b933c3de31702c49156093845b42699e19e71935e4e899666f7f631626210b"

void showLogin() {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:KH_NAME message:@"BẢN QUYỀN VAN VINH" preferredStyle:UIAlertControllerStyleAlert];
        
        [alert addTextFieldWithConfigurationHandler:^(UITextField *txt) {
            txt.placeholder = @"Nhập Key...";
            txt.secureTextEntry = YES;
        }];
        
        [alert addAction:[UIAlertAction actionWithTitle:@"Đăng Nhập" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            NSString *userKey = alert.textFields.firstObject.text;
            // Thêm mã ngẫu nhiên vào URL để ép Server phải check mới, không dùng lại Session cũ
            int random = arc4random_uniform(10000);
            NSString *urlStr = [NSString stringWithFormat:@"https://keyauth.win/api/1.2/?type=login&name=%@&ownerid=%@&secret=%@&key=%@&ver=1.0&r=%d", KH_NAME, KH_OWNERID, KH_SECRET, userKey, random];
            
            [[[NSURLSession sharedSession] dataTaskWithURL:[NSURL URLWithString:urlStr] completionHandler:^(NSData *data, NSURLResponse *res, NSError *err) {
                if (data) {
                    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                    BOOL success = [[json objectForKey:@"success"] boolValue];
                    NSString *msg = [[json objectForKey:@"message"] lowercaseString]; // Chuyển tin nhắn về chữ thường để check cho chuẩn
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        // KIỂM TRA CỰC GẮT: SUCCESS PHẢI LÀ TRUE VÀ TRONG MESSAGE KHÔNG ĐƯỢC CÓ CHỮ "EXPIRED" (HẾT HẠN)
                        if (success && ![msg containsString:@"expired"] && ![msg containsString:@"invalid"]) {
                            UIAlertController *ok = [UIAlertController alertControllerWithTitle:@"Thành Công" message:@"Chào mừng VanVinh!" preferredStyle:UIAlertControllerStyleAlert];
                            [ok addAction:[UIAlertAction actionWithTitle:@"Vào Game" style:UIAlertActionStyleDefault handler:nil]];
                            [window.rootViewController presentViewController:ok animated:YES completion:nil];
                        } else {
                            // NẾU CÓ CHỮ "EXPIRED" TRONG MESSAGE, NÓ SẼ BÁO LỖI NGAY DÙ SERVER CÓ TRẢ VỀ SUCCESS = TRUE
                            NSString *finalMsg = (success && [msg containsString:@"expired"]) ? @"Key của mày đã hết hạn rồi!" : @"Key không đúng hoặc đã hết hạn!";
                            UIAlertController *no = [UIAlertController alertControllerWithTitle:@"TỪ CHỐI" message:finalMsg preferredStyle:UIAlertControllerStyleAlert];
                            [no addAction:[UIAlertAction actionWithTitle:@"Nhập lại" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *a){ showLogin(); }]];
                            [window.rootViewController presentViewController:no animated:YES completion:nil];
                        }
                    });
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
