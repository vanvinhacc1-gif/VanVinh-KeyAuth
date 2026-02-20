#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define KH_NAME    @"VanVinhiOS" 
#define KH_OWNERID @"gnIVuUid3U"
#define KH_SECRET  @"d5b933c3de31702c49156093845b42699e19e71935e4e899666f7f631626210b"

void showLogin() {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"XÁC THỰC CUỐI CÙNG" message:@"Nhập Key để kiểm tra hạn dùng" preferredStyle:UIAlertControllerStyleAlert];
        [alert addTextFieldWithConfigurationHandler:^(UITextField *t){ t.placeholder=@"Key..."; }];
        
        [alert addAction:[UIAlertAction actionWithTitle:@"Kích Hoạt" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            NSString *key = alert.textFields.firstObject.text;
            NSString *url = [NSString stringWithFormat:@"https://keyauth.win/api/1.2/?type=login&name=%@&ownerid=%@&secret=%@&key=%@", KH_NAME, KH_OWNERID, KH_SECRET, key];
            
            [[[NSURLSession sharedSession] dataTaskWithURL:[NSURL URLWithString:url] completionHandler:^(NSData *data, NSURLResponse *res, NSError *err) {
                if (data) {
                    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                    // LẤY TRỰC TIẾP SỐ NGÀY CÒN LẠI TỪ SERVER
                    id info = [json objectForKey:@"info"];
                    if (info && [info isKindOfClass:[NSDictionary class]]) {
                        NSArray *subscriptions = [info objectForKey:@"subscriptions"];
                        if (subscriptions.count > 0) {
                            long long expiry = [[subscriptions[0] objectForKey:@"expiry"] longLongValue];
                            long long now = (long long)[[NSDate date] timeIntervalSince1970];
                            
                            dispatch_async(dispatch_get_main_queue(), ^{
                                // TỰ SO SÁNH: NẾU THỜI GIAN HẾT HẠN NHỎ HƠN THỜI GIAN HIỆN TẠI -> CÚT
                                if (expiry > now) {
                                    UIAlertController *ok = [UIAlertController alertControllerWithTitle:@"Hợp Lệ" message:@"Chào VanVinh, mời vào game!" preferredStyle:UIAlertControllerStyleAlert];
                                    [ok addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
                                    [window.rootViewController presentViewController:ok animated:YES completion:nil];
                                } else {
                                    UIAlertController *no = [UIAlertController alertControllerWithTitle:@"HẾT HẠN" message:@"Key này đã hết thời gian sử dụng!" preferredStyle:UIAlertControllerStyleAlert];
                                    [no addAction:[UIAlertAction actionWithTitle:@"Thoát" style:UIAlertActionStyleDestructive handler:^(id a){ showLogin(); }]];
                                    [window.rootViewController presentViewController:no animated:YES completion:nil];
                                }
                            });
                            return;
                        }
                    }
                    dispatch_async(dispatch_get_main_queue(), ^{
                        showLogin(); // Sai key hoặc lỗi info thì bắt nhập lại
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
