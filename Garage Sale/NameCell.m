//
//  NameCell.m
//  Garage Sale
//
//  Created by Alexander Hammond on 10/18/17.
//  Copyright © 2017 TripleA. All rights reserved.
//

#import "NameCell.h"
#import "Utility.h"

@implementation NameCell



-(IBAction)photo:(id)sender {
    //creates image picker
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = _superView;
    //lets user choose camera or photo library
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    //camera action
    UIAlertAction *camera = [UIAlertAction actionWithTitle:@"Camera" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        //initiates picker with camera
        [picker setSourceType:UIImagePickerControllerSourceTypeCamera];
        [_superView presentViewController:picker animated:true completion:nil];
    }];
    //photo library action
    UIAlertAction *photoAlbum = [UIAlertAction actionWithTitle:@"Photo Library" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        //initiates picker with photo library
        [picker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
        [_superView presentViewController:picker animated:true completion:nil];
    }];
    //cancel action
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {}];
    //adds all of the actions
    [alert addAction:camera];
    [alert addAction:photoAlbum];
    [alert addAction:cancel];
    //presents the options
    [_superView presentViewController:alert animated:true completion:nil];
}

//delegate methods for image picker
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    NSLog(@"Tried setting info");
    //saves the selected image to the image field
    UIImage *tmpImage = info[UIImagePickerControllerEditedImage];
    NSString * documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    [Utility saveImage:tmpImage withFileName:@"user_photo" ofType:@"jpg" inDirectory:documentsDirectory];
    UIImage *reload = [Utility loadImageWithFileName:@"user_photo" ofType:@"jpg" inDirectory:documentsDirectory];
    [userPhotoView setImage:tmpImage forState:UIControlStateNormal];
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [firstNameTextField resignFirstResponder];
    [lastNameTextField resignFirstResponder];
    return true;
}

-(void)textFieldDidEndEditing:(UITextField *)textField {
    _superView.firstName = firstNameTextField.text;
    _superView.lastName = lastNameTextField.text;
}


-(void)updateCell {
    firstNameTextField.text = _firstName;
    lastNameTextField.text = _lastName;
    firstNameTextField.delegate = self;
    lastNameTextField.delegate = self;
    NSString * documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    _userPhoto = [Utility loadImageWithFileName:@"user_photo" ofType:@"jpg" inDirectory:documentsDirectory];
    if (!_userPhoto) {
        _userPhoto = [UIImage imageNamed:@"userlogo.png"];
    }
    [userPhotoView setImage:_userPhoto forState:UIControlStateNormal];
    userPhotoView.imageView.layer.masksToBounds = YES;
    userPhotoView.imageView.layer.cornerRadius = userPhotoView.frame.size.height / 2;

}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

@end
