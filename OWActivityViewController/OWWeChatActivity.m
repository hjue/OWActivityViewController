//
// OWWeChatActivity.m
// OWActivityViewController
//
// Copyright (c) 2013 Jason Hao (https://github.com/hjue )
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//

#import "OWWeChatActivity.h"
#import "OWActivityViewController.h"
#import "WXApi.h"
#import "UIImage+Resize.h"

@implementation OWWeChatActivity

- (id)initWithAppId:(NSString *)appId messageType:(int)messageType scene:(int)scene
{

    if (scene == WXSceneSession) {
        self = [super initWithTitle:NSLocalizedStringFromTable(@"activity.WeChat.title", @"OWActivityViewController",  @"WeChat")
                              image:[UIImage imageNamed:@"OWActivityViewController.bundle/Icon_Wechat"]
                        actionBlock:nil];
    }else
    {
        self = [super initWithTitle:NSLocalizedStringFromTable(@"activity.WeChatTimeline.title", @"OWActivityViewController", @"WeChatTimeline")
                              image:[UIImage imageNamed:@"OWActivityViewController.bundle/Icon_Wechat_Timeline"]
                        actionBlock:nil];
    }

    if (!self)
        return nil;
    
    _appId = appId;
    _scene = scene;
    _messageType = messageType;
    
    __typeof(&*self) __weak weakSelf = self;
    self.actionBlock = ^(OWActivity *activity, OWActivityViewController *activityViewController) {
        NSDictionary *userInfo = weakSelf.userInfo ? weakSelf.userInfo : activityViewController.userInfo;
        [activityViewController dismissViewControllerAnimated:YES completion:^{
            NSString *text = [userInfo objectForKey:@"text"];
            NSString *description = [userInfo objectForKey:@"description"];            
            UIImage *image = [userInfo objectForKey:@"image"];
            NSURL *url = [userInfo objectForKey:@"url"];
            
            WXMediaMessage *message = [WXMediaMessage message];
            if (image)
            {
                [message setThumbImage:[image resizedImageByMagick: @"140x140"]];
            }
            
            if (text) {
                [message setTitle:text];
            }
            
            if (description) {
                [message setDescription:description];
            }
            
            
            if (weakSelf.messageType == WXMessageTypeImage && image) {
                
                WXImageObject *ext = [WXImageObject object];
                ext.imageData = UIImagePNGRepresentation(image); 
                message.mediaObject = ext;
                
            }else if (weakSelf.messageType == WXMessageTypeNews)
            {
                WXWebpageObject *ext = [WXWebpageObject object];
                ext.webpageUrl = [url absoluteString];
                message.mediaObject = ext;
                
            }else if (weakSelf.messageType == WXMessageTypeMusic)
            {
                WXMusicObject *ext = [WXMusicObject object];
                ext.musicUrl = [url absoluteString];
                NSURL *musicDataUrl = [userInfo objectForKey:@"musicDataUrl"];
                ext.musicDataUrl = [musicDataUrl absoluteString];
                message.mediaObject = ext;
                
            }else if (weakSelf.messageType == WXMessageTypeVideo)
            {
                WXVideoObject *ext = [WXVideoObject object];
                ext.videoUrl = [url absoluteString];
                message.mediaObject = ext;
                
            }else if (weakSelf.messageType == WXMessageTypeApp)
            {
                WXAppExtendObject *ext = [WXAppExtendObject object];
                ext.url = [url absoluteString];
                
                NSString *extInfo = [userInfo objectForKey:@"extInfo"];
                NSData *fileData = [userInfo objectForKey:@"fileData"];
                if (extInfo) {
                    ext.extInfo = extInfo;
                }
                if (fileData) {
                    ext.fileData = fileData;
                }
                message.mediaObject = ext;
                
                
            }else if (weakSelf.messageType == WXMessageTypeEmoticon)
            {
                
                WXEmoticonObject *ext = [WXEmoticonObject object];
                ext.emoticonData = UIImagePNGRepresentation(image);
                message.mediaObject = ext;
                
            }else  //WXMessageTypeText
            {
                
            }
            
            if (weakSelf.messageType == WXMessageTypeText) {
                SendMessageToWXReq* req = [[SendMessageToWXReq alloc] init];
                req.bText = YES;
                req.text = text;
                req.scene = weakSelf.scene;
                [WXApi sendReq:req];
            }else{
                SendMessageToWXReq* req = [[SendMessageToWXReq alloc] init];
                req.bText = NO;
                req.message = message;
                req.scene = weakSelf.scene;                
                [WXApi sendReq:req];
            }
            

            
        }];
    };
    
    return self;
    
    
}

@end
