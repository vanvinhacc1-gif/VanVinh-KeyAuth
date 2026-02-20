#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#include <string>
std::string name = "Free Fire"; 
std::string ownerid = "gnIVuUid3U";
std::string secret = "d5b933c3de31702c49156c02f6096e8e8da83375d1a02baf1dba0f3928eb2777";
std::string version = "1.0";

// Ham tu dong hien thong bao khi mo App
__attribute__((constructor))
static void init() {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"VanVinh iOS" 
            message:@"Vui long nhap Key de su dung" 
            preferredStyle:UIAlertControllerStyleAlert];
            
        [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
            textField.placeholder = @"Nhap License Key tai day...";
        }];
        
        UIAlertAction *login = [UIAlertAction actionWithTitle:@"Dang Nhap" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            // Tam thoi de trong de may test cach nhung vao IPA truoc
        }];
        
        [alert addAction:login];
        [[[UIApplication sharedApplication] keyWindow].rootViewController presentViewController:alert animated:YES completion:nil];
    });
}
