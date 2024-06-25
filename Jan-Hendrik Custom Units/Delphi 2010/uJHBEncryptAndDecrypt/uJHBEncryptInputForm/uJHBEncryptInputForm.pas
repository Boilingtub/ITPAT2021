unit uJHBEncryptInputForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, uJHBEncryptAndDecrypt , StdCtrls, ComCtrls, Buttons, ExtCtrls , ShellApi , math;

  const
  clOrange = 33023;
type
  TfrmEncryptInput = class(TForm)
    procedure FormStartupInto(Sender: TObject); //speel into
    procedure SetUpMainForm(Sender: Tobject);   //maak die hoof form oop
    //procedure SetUpEncrypt(Sender : Tobject);
    procedure SetUpDecrypt(Sender : Tobject);  //Stel dekripsie form op
    procedure Encrypt(Sender : tObject);      //Enkirpteer inset
    procedure frmCloseQueryAskAndFreeObjects(Sender: TObject;var CanClose: Boolean);//maak die voorwerpe skoon wanner die form toegemaak word
    procedure btnClose(Sender : Tobject); //maak die form toe
    procedure SetupUserLogin(Sender : Tobject);  //stel die inlog form op
    procedure TurnSenderlblBlue(Sender : Tobject);  //maak n voorwerp blou
    procedure TurnSenderlblGreen(Sender : Tobject); //maak n voorwerp groen
    procedure Login(Sender : Tobject);      //Log in gebruiker in gebaseer op sy inligting
    procedure TurnSenderedtWhite(Sender : Tobject); //maak n voorwerp wit
    procedure RegisterNewAccount(Sender : Tobject); //Stel Rigistreer nuwe account form
    procedure RegisterEditsCompleteCheck(Sender : Tobject); //kyk of alles ingevul is
    procedure RegisterAccount(Sender : Tobject);//Rigesteer en lees in databasis in
    procedure ForgotPassword(Sender : Tobject);  //stel form op om wagwoord te herskryf
    procedure ForgotEditCheck(Sender : Tobject);  //kyk of al die edits ingevul is
    procedure SendPasswordResetRequest(Sender : Tobject); //stuur Epos met Rigestrasie kode
    procedure Setup2FactorAuthentication(Sender : Tobject);   //kyk of kodes reg is
    procedure ResendEMailTOLastAdress(Sender : Tobject);    //herstuur die epos
    procedure Test2StepVerificationCode(Sender : Tobject);  //Toets of die kode reg is
    procedure SetupPasswordResetInput(Sender : Tobject);
    procedure InsertNewDataIntoExistingRecord(Sender : Tobject);//Opdateer n hiudige gebruiker se inligting
    procedure PasswordResetInputEditCheck(Sender : Tobject);   //Wagwoord herskryf kyk of editboksies reg is
    procedure SignOut(Sender : Tobject);    //sign die gebruiker uit
    procedure SignOutLblChange(Sender : Tobject); // verander kleur van Label
    procedure CloseEncryptInfo(Sender:Tobject);  //maak Enkripsie Inlingting edit toe
    procedure ShowEncryptInfo(Sender:Tobject);   //maak Enkripsie Inlingting edit oop
    //procedure RadioGroupPrivateORPublic(Sender : Tobject);
    //procedure TfrmEncryptInput.SendEcryptedImageAsEmail(Sender:Tobject);
    procedure ExportToTextfile(Sender : Tobject); //skryf inlingting in richedit na teksleer



  private
   sUserPassword : string;   //stoor ingesingde gebruiker se wagwoord
   sUserEmail : string;       //stoor gebruiker se epos
   bSecurityCodeEnteredWrong : bool;   //stoor of kode reg of verkeerd is
   sRecipientName :string;        //stoor naam van ontvanger
   sDEcryptedText : string;        //stoor gedekripteede teks
   bAlreadyLoggedIn : boolean;     //kyk of gebruiker klaar ingesign is
  public

  end;

var
  frmEncryptInput: TfrmEncryptInput;
    img : Timage;                   //prent komponent
    lbl : array[1..8] of Tlabel;   //array van labels
    btn : array[1..4] of TButton;   //array van buttons
    edt : array[1..4] of TEdit;      //array van edits
    Redt : TRichedit;  //richedit
    FormTimer : TTimer;   //timer
    rgb : TRadioGroup;    //radiogroup button
    OnClick: TNotifyEvent; //die onclick event
    sUsername : string; //stoor gebruiker se naam
 implementation

 {$R *.dfm}

 //START //Reset Dynamic Objects //maak al die komponente leeg
procedure ClearObjects();
var
bcount : byte;
begin

if(Assigned(FormTimer)) then
FreeAndNil(FormTimer);

for bcount := 1 to length(lbl) do
begin
if(Assigned(lbl[bcount])) then
FreeAndNil(lbl[bcount]);
end;

for bcount := 1 to length(btn) do
begin
if(Assigned(btn[bcount])) then
FreeAndNil(btn[bcount]);
end;

for bcount := 1 to length(edt) do //maak hele array skoon
begin
if(Assigned(edt[bcount])) then
FreeAndNil(edt[bcount]);
end;

if(Assigned(Redt)) then
FreeAndNil(Redt);

if(Assigned(img)) then
FreeAndNil(img);

if Assigned(rgb) then
FreeAndNil(Rgb);

end;
 //END //Reset Dynamic Objects

procedure TfrmEncryptInput.frmCloseQueryAskAndFreeObjects(Sender: TObject; var CanClose: Boolean);  //vra gebiuker of hulle will toemaak
begin
   if MessageDlg('Close the form?', mtConfirmation,[mbOk, mbCancel], 0) = mrCancel then
   CanClose := False
   else
   begin
     CanClose := true;
     ClearObjects(); //maak al die komponente skoon
   end;
end;


procedure TfrmEncryptInput.btnClose(Sender : Tobject);
begin
   frmEncryptInput.Close;
end;


//START //Startup INTO
procedure TfrmEncryptInput.FormStartupInto(Sender: TObject);//speel die begin intro
begin

frmEncryptInput.width := 500;
frmEncryptInput.Height := 500;
frmEncryptInput.Left:=(Screen.Width-Width)  div 2;  //maak dit in middel van skerm
frmEncryptInput.Top:=(Screen.Height-Height) div 2; //maak dit in middel van skerm
frmEncryptInput.Color := clOlive;


FormTimer := tTimer.Create(frmEncryptInput);
with FormTimer do
begin
parent :=  frmEncryptInput;
name := 'Timer1';
Interval := 2000; //stel timer om 2 sec te neem
OnTimer := SetupUserLogin;
end;

lbl[1] := TLabel.Create(frmEncryptInput);
with lbl[1] do
begin
Parent := frmEncryptInput;
name := 'lblHeading';
Caption := 'Jan-Hendrik Brink Encryption Unit';
top := 20;
left := 10;
width := 280;
height := 100;
Font.Size := 17;
font.name := 'Segoe Script';
font.Style := [fsBold ,fsUnderline];
end;

img := Timage.Create(frmEncryptInput);
with Img do
begin
 Parent := frmEncryptInput;
 Name := 'imgLogo';
 Picture.LoadFromFile(uJHBEncryptAndDecrypt.sThisUnitDir + '\..\uJHBEncryptInputForm\logo.bmp');
 Width := 370;
 Height := 370;
 Stretch := true;
 Top := 83;
 Left := 48;
end;

end;
//END //Startup INTO



//START //setup user login
procedure TfrmEncryptInput.TurnSenderlblBlue(Sender : TObject);
begin
if sender is Tlabel then
(Sender as Tlabel).Font.Color := clblue;  //maak blou
end;



procedure TfrmEncryptInput.TurnSenderlblGreen(Sender : Tobject);
begin
if sender is Tlabel then
(Sender as Tlabel).Font.Color := clGreen; //maak groen
end;


procedure TfrmEncryptInput.TurnSenderedtWhite(Sender : Tobject);
begin
if sender is TEdit then
(Sender as Tedit).Color := clwhite;
if Assigned(lbl[6]) then
lbl[6].Visible := false;   //maak WIT
end;


 procedure  TfrmEncryptInput.Login(Sender : Tobject);
 begin
    if CheckIfUserExistsInDataBase(edt[1].text , edt[2].text,'', true ,true ,false) = true then  //Kyk of gebruiker bestaan
    begin
     sUsername :=  edt[1].text;
     sUserPassword := edt[2].text;
     bAlreadyLoggedIn := true;
     SetUpMainForm(self);
    end
    else
    begin

     edt[1].Color := clred;
     edt[2].Color := clred;
     edt[1].text := '';
     edt[2].text := '';
     lbl[6].Visible := true;

    end;
 end;


procedure TfrmEncryptInput.SetupUserLogin(Sender : Tobject);
begin

 if bAlreadyLoggedIn = true then
 begin
   SetUpMainForm(Self);
   Exit;
 end;

 clearObjects();

 frmEncryptInput.width := 373;
 frmEncryptInput.Height := 250;
 frmEncryptInput.Color := clMedGray;

   lbl[1] := TLabel.Create(frmEncryptInput);   //stel label 1 op
  with lbl[1] do
  begin
  parent := frmEncryptInput;
  name := 'lbl1';
  Caption := 'Login to your account';
  Font.Size := 20;
  font.name := 'UniSpace';
  font.Style := [fsBold];
  height := 33;
  width := 336;
  top := 8;
  left := 16;
  end;

   lbl[2] := TLabel.Create(frmEncryptInput); //stel label 2 op
  with lbl[2] do
  begin
  parent := frmEncryptInput;
  name := 'lbl2';
  Caption := 'User name :';
  Font.Size := 10;
  font.name := 'Tahoma';
  height := 16;
  width := 71;
  top := 64;
  left := 23;
  end;


   lbl[3] := TLabel.Create(frmEncryptInput); //stel label 3 op
  with lbl[3] do
  begin
  parent := frmEncryptInput;
  name := 'lbl3';
  Caption := 'Password :';
  Font.Size := 10;
  font.name := 'Tahoma';
  height := 16;
  width := 64;
  top := 107;
  left := 23;
  end;

   lbl[4] := TLabel.Create(frmEncryptInput);   //stel label 4 op
  with lbl[4] do
  begin
  parent := frmEncryptInput;
  name := 'lbl4';
  Caption := 'Register new account';
  Font.Size := 11;
  font.name := 'System';
  Font.Color := clGreen;
  font.Style := [fsUnderline];
  height := 16;
  width := 141;
  top := 190;
  left := 16;
  OnmouseEnter := TurnSenderlblBlue;
  OnmouseLeave := TurnSenderlblGreen;
  onClick := RegisterNewAccount;
  end;

   lbl[5] := TLabel.Create(frmEncryptInput);  //stel label 5 op
  with lbl[5] do
  begin
  parent := frmEncryptInput;
  name := 'lbl5';
  Caption := 'Forgot your password ?';
  Font.Size := 11;
  font.name := 'System';
  Font.Color := clGreen;
  font.Style := [fsUnderline];
  height := 16;
  width := 153;
  top := 190;
  left := 199;
  OnmouseEnter := TurnSenderlblBlue;
  OnmouseLeave := TurnSenderlblGreen;
  OnClick := ForgotPassword;
  end;

  lbl[6] := TLabel.Create(frmEncryptInput);  //stel label 6 op
  with lbl[6] do
  begin
  parent := frmEncryptInput;
  name := 'lbl6';
  Caption := 'Your login credentials is not valid !';
  Font.Size := 10;
  font.name := 'Tahoma';
  Font.Color := clmaroon;
  height := 16;
  width := 190;
  top := 88;
  left := 100;
  visible := false;
  end;

   edt[1] := TEdit.Create(frmEncryptInput);      //stel edit 1 op
   with edt[1] do
   begin
    parent := frmEncryptInput;
    name := 'edt1';
    Text := '';
    TextHint := 'Enter your user name';
    Height := 21;
    Left := 100;
    Top := 63;
    Width := 206;
    OnMouseEnter := TurnSenderedtWhite;  //maak wit wanner muis ingaan
   end;

    edt[2] := TEdit.Create(frmEncryptInput); //stel edit 2 op
   with edt[2] do
   begin
    parent := frmEncryptInput;
    name := 'edt2';
    Text := '';
    TextHint := 'Enter your password';
    Height := 21;
    Left := 100;
    Top := 106;
    Width := 206;
    OnMouseEnter := TurnSenderedtWhite; //maak wit wanner muis ingaan
   end;

   btn[1] := tButton.create(frmEncryptInput); //stel edit 3 op
   with btn[1] do
   begin
    parent :=  frmEncryptInput;
    name := 'btn1';
    Caption := 'Login';
    Height := 25;
    Left := 134;
    Top := 144;
    Width := 87;
    Onclick := Login;     //LOg die gebruiker in
   end;

end;
//END //setup user login


//START //setup forgot password
procedure TfrmEncryptInput.ForgotPassword(Sender : Tobject);
begin
  CLearobjects();
  lbl[1] := TLabel.Create(frmEncryptInput);    //maak wit wanner muis ingaan
  with lbl[1] do
  begin
    parent := frmEncryptInput;
    name := 'label1';
    Caption := 'Reset Password' ;
    Font.Size := 20;
    Font.Style := [fsBold , fsUnderline];
    height := 33;
    left := 8;
    Top := 8;
    //Width := 224;
  end;

    lbl[2] := TLabel.Create(frmEncryptInput);  //stel label 2 op
  with lbl[2] do
  begin
    parent := frmEncryptInput;
    name := 'label2';
    Caption := 'Enter your Username :' ;
    Font.Size := 8;
    height := 13;
    left := 8;
    Top := 52;
    //Width := 109;
  end;

    lbl[3] := TLabel.Create(frmEncryptInput);   //stel label 3 op
  with lbl[3] do
  begin
    parent := frmEncryptInput;
    name := 'label3';
    Caption := 'Enter your Email-Adress :' ;
    Font.Size := 8;
    height := 13;
    left := 8;
    Top := 97;
    //Width := 109;
  end;

   lbl[4] := TLabel.Create(frmEncryptInput);  //stel label 4 op
  with lbl[4] do
  begin
    parent := frmEncryptInput;
    name := 'label4';
    Caption := 'Credentials invalid' ;
    Font.Size := 8;
    Font.Color := clmaroon;
    height := 13;
    left := 158;
    Top := 97;
    visible := false;
    //Width := 109;
  end;

    edt[1] := TEdit.Create(frmEncryptInput);   //stel edit 1 op
  with edt[1] do
  begin
    parent := frmEncryptInput;
    name := 'edt1';
    Text := '';
    TextHint := 'Enter your Username';
    height := 21;
    left := 8;
    Top := 67;
    Width := 224;
    onchange := ForgotEditCheck;    //wanner vernader word kyk of die inset gevalideer is
  end;


    edt[2] := TEdit.Create(frmEncryptInput);  //stel edit 2 op
  with edt[2] do
  begin
    parent := frmEncryptInput;
    name := 'edt2';
    Text := '';
    TextHint := 'Enter your Email-Adress';
    height := 21;
    left := 8;
    Top := 111;
    Width := 224;
    onchange := ForgotEditCheck;
  end;

     btn[1] := TButton.Create(frmEncryptInput); //stel button 1 op
  with btn[1] do
  begin
    parent := frmEncryptInput;
    name := 'btn1';
    Caption := 'Submit Password Reset Request';
    //Font.Style := [fsBold] ;
    height := 25;
    left := 16;
    Top := 143;
    Width := 201;
    enabled := false;
    OnClick := SendPasswordResetRequest;
  end;

    btn[2] := TButton.Create(frmEncryptInput);  //stel edit 2 op
  with btn[2] do
  begin
    parent := frmEncryptInput;
    name := 'btn2';
    Caption := 'Back';
    height := 25;
    left := 76;
    Top := 178;
    Width := 75;
    OnClick := SetupUserLogin;
  end;

end;

procedure TfrmEncryptInput.ForgotEditCheck(Sender : Tobject);  //Verander label se kleur vir "Forgot passowrd"
begin
  if((edt[1].text <> '')  AND (edt[2].text <> '')) then
  begin
   btn[1].Enabled := true;
  end
  else
  begin
   btn[1].Enabled := false;
  end;
  edt[1].Color := clwhite; //maak wit
  edt[2].Color := clwhite; //maak wit
  lbl[4].Visible := false;
end;

//END //setup forgot password






//START //Send Email with COde
procedure TfrmEncryptInput.SendPasswordResetRequest(Sender : Tobject); //stuur epos met unike kode
begin
  if CheckIfUserExistsInDataBase(edt[1].text , '' , edt[2].text ,true , false , true) = true then //kyk of gebruiker bestaan
  begin
  SendEmail(0 , [ edt[2].text ] , 'nul' , 'uJHBEncryptAndDecrypt',  'nul');//stuur die Epos
  sUserEmail := edt[2].Text;
  sUsername := edt[1].Text;
  end
  else
  begin
  lbl[4].Visible := true;
  edt[1].Color := clred;   //maak rooi
  edt[2].Color := clred;   //maak rooi
  exit;
  end;

  Setup2FactorAuthentication(Self);    //stuur n epos met die kode
end;
 //END //setup forgot password





 //START //SetUP 2Factor Authentication
 procedure TfrmEncryptInput.ResendEMailToLastAdress(Sender : Tobject);
begin
 SendEmail(0 , sUserEmail , 'nul' , 'uJHBEncryptAndDecrypt','');//Stuur weer Epos
 lbl[3].Caption := 'Email already resent , click again to resend again';   //venrander capsie om te se wat aangaan
end;


procedure TfrmEncryptInput.Setup2FactorAuthentication(Sender : Tobject);   //Stel check van spesiale kode op
begin
  ClearObjects();                   //maak voorwerpe skoon
 bSecurityCodeEnteredWrong := false;    //inisialiseer VAR
 frmEncryptInput.width := 373;
 frmEncryptInput.Height := 250;
 frmEncryptInput.Color := clMedGray;

 lbl[1] := Tlabel.Create(frmEncryptInput);   //stel label 1 op
 with lbl[1] do
 begin
   parent := frmEncryptInput;
   name := 'label1';
   Caption := 'Enter the code that has been sent to you via E-mail:';
   Font.Color := clblack;
   Font.Size := 15;
   Font.Name := 'Unispace';
   Font.Style := [fsbold, fsunderline];
   WordWrap := true;
   Height := 50;
   Left := 5;
   Top := 8;
   Width := 364;
 end;


 lbl[2] := Tlabel.Create(frmEncryptInput); //stel label 2 op
 with lbl[2] do
 begin
   parent := frmEncryptInput;
   name := 'label2';
   Caption := 'Enter code here :';
   Height := 13;
   Left := 119;
   Top := 64;
   Width := 84;
 end;

 lbl[3] := Tlabel.Create(frmEncryptInput); //stel label 3 op
 with lbl[3] do
 begin
   parent := frmEncryptInput;
   name := 'label3';
   Caption := 'if you did not recieve a code , click here to resend email';
   Font.Style := [fsUnderline];
   OnMouseEnter := TurnSenderlblBlue; //as muis oor beweeg maak blou
   OnMouseLeave := TurnSenderlblGreen; //as muis af beweeg maak groen
   OnClick := ResendEMailToLastAdress;  //as klick herstuur boodksap
   Font.Color := clgreen;
   Height := 13;
   Left := 48;
   Top := 185;
   Width := 266;
 end;

  lbl[4] := Tlabel.Create(frmEncryptInput);   //stel label 4 op
 with lbl[4] do
 begin
   parent := frmEncryptInput;
   name := 'label4';
   Caption := 'Code invalid , 1 try remaining';
   Font.Color := clMaroon;
   Visible := false;
   WordWrap := true;
   Height := 50;
   Left := 240;
   Top := 83;
   Width := 80;
 end;


 edt[1] := TEdit.Create(frmEncryptInput);  //stel edit 1 op
 with edt[1] do
 begin
   parent := frmEncryptInput;
   name := 'edit1';
   Font.Size := 26;
   MaxLength := 6;
   NumbersOnly := true;
   Text := '';
   HEight := 50;
   Left := 114;
   Top := 83;
   WIdth := 121;
 end;

 btn[1] := TButton.Create(frmEncryptInput);   //stel button 1 op
 with btn[1] do
 begin
   parent := frmEncryptInput;
   name := 'button1';
   Caption := 'Submit';
   Font.Size := 16;
   Height := 45;
   LEft := 129;
   Top := 139;
   Width := 89;
   OnClick := Test2StepVerificationCode; //indien geklikc word kyk of kode valid is
 end;
end;

procedure TfrmEncryptInput.Test2StepVerificationCode(Sender : Tobject);
begin
  if edt[1].Text = uJHBEncryptAndDecrypt.sSecurityString then
  begin
    SetupPasswordResetInput(self);      //Stel die wagwoord reset op
  end
  else
  begin
    if bSecurityCodeEnteredWrong = true then
    begin
    Setupuserlogin(self);//log die gebruiker in met die nuwe wagwoord
    exit;
    end;
    bSecurityCodeEnteredWrong := true; //maak waar
    lbl[4].Visible := true;
    edt[1].text := '';
    edt[1].SetFocus;
  end;
end;
//END//setup forgot password







//START //Password REset
procedure TfrmEncryptInput.InsertNewDataIntoExistingRecord(Sender : Tobject); //Sit die nuwe gerigestreerde inligting in die databasis
begin
  if edt[1].text = edt[2].text then
   begin
    sUserPassword := edt[1].Text;
    InsertNewDataIntoExistingRecordDB_usrtbl(sUserName , sUserPassword , sUserEmail , false , true , false);  //SIt in die databasis
    showmessage('Password Successfully changed !');
    SetupUserLogin(Self);  //Stel die login form op
   end
   else
   begin
     edt[1].color := clred;
     edt[2].color := clred;
     lbl[4].visible := true;
   end;
end;

procedure TfrmEncryptInput.PasswordResetInputEditCheck(Sender : Tobject);    //maak edits wit
begin
  edt[1].Color := clwhite;
  edt[2].Color := clwhite;
  lbl[4].visible := false;
end;

procedure TfrmEncryptInput.SetupPasswordResetInput(Sender : Tobject);  //Stel Wagwoord hgerskryf form op
begin
  ClearObjects;

  frmEncryptInput.width := 373;
  frmEncryptInput.Height := 250;
  frmEncryptInput.Color := clMedGray;


  lbl[1] := Tlabel.Create(frmEncryptInput);  // Stel label 1 op
 with lbl[1] do
 begin
   parent := frmEncryptInput;
   name := 'label1';
   Caption := 'Enter new Password :';
   Font.Color := clblack;
   Font.Size := 20;
   Font.Name := 'Unispace';
   Font.Style := [fsbold, fsunderline];
   Height := 33;
   Left := 9;
   Top := 8;
   //Width := 364
 end;

 lbl[2] := Tlabel.Create(frmEncryptInput); // Stel label 2 op
 with lbl[2] do
 begin
   parent := frmEncryptInput;
   name := 'label2';
   Caption := 'Enter password :';
   Height := 13;
   Left := 8;
   Top := 64;
   //Width := 82;
 end;

 lbl[3] := Tlabel.Create(frmEncryptInput);   // Stel label 3 op
 with lbl[3] do
 begin
   parent := frmEncryptInput;
   name := 'label3';
   Caption := 'Confirm password :';
   Height := 13;
   Left := 8;
   Top := 107;
   //Width := 82;
 end;

  lbl[4] := Tlabel.Create(frmEncryptInput);   // Stel label 4 op
 with lbl[4] do
 begin
   parent := frmEncryptInput;
   name := 'label4';
   Caption := 'Passwords does not match';
   Font.Color := clmaroon;
   visible := false;
   Height := 13;
   Left := 120;
   Top := 85;
   //Width := 82;
 end;

 edt[1] := TEdit.Create(frmEncryptInput);     // Stel edit 1 op
 with Edt[1] do
 begin
   parent :=  frmEncryptInput;
   name := 'edit1';
   Text := '';
   TextHint := 'Enter new password';
   Height := 21;
   LEft := 107;
   Top := 61;
   WIdth := 214;
   OnChange := PasswordResetInputEditCheck;  //kyk of d ie insert valid is
 end;

 edt[2] := TEdit.Create(frmEncryptInput);  // Stel edit 2 op
 with Edt[2] do
 begin
   parent :=  frmEncryptInput;
   name := 'edit2';
   Text := '';
   TextHint := 'Confirm new password';
   Height := 21;
   LEft := 107;
   Top := 104;
   WIdth := 214;
   OnChange := PasswordResetInputEditCheck;  //kyk of d ie insert valid is
 end;

 btn[1] := TButton.Create(frmEncryptInput);  // Stel button 2 op
 with btn[1] do
 begin
   parent := frmEncryptInput;
   name := 'button1';
   Caption := 'Submit';
   Height := 25;
   Left := 142;
   Top := 144;
   WIdth := 75;
   OnClick := InsertNewDataIntoExistingRecord;  //Sit die nuwe data in die databasis
 end;

end;
 //END //Password REset




//START //Register New Account
procedure TfrmEncryptInput.RegisterNewAccount(Sender : Tobject);//Stel die form op om die nuwe account te rigestreer
begin
  frmEncryptInput.Height := 280;
  frmEncryptInput.width := 430;
  ClearObjects();   //maak al die voorwerpe skoon

  lbl[1] := TLabel.Create(frmEncryptInput);    //Stel label 1 op
  with lbl[1] do
  begin
   parent :=  frmEncryptInput;
   name := 'lbl1';
   Caption := 'Register New Account';
   font.Name := 'UniSpace';
   font.Style := [fsUnderline];
   font.Size := 23;
   Height := 37;
   Width := 380;
   Left := 12;
   Top := 8;
  end;

  lbl[2] := TLabel.Create(frmEncryptInput);  //Stel label 2 op
  with lbl[2] do
  begin
   parent :=  frmEncryptInput;
   name := 'lbl2';
   Caption := 'User Name :';
   font.Name := 'Tahoma';
   font.Size := 8;
   Height := 13;
   Width := 59;
   Left := 12;
   Top := 70;
  end;


  lbl[3] := TLabel.Create(frmEncryptInput);   //Stel label 3 op
  with lbl[3] do
  begin
   parent :=  frmEncryptInput;
   name := 'lbl3';
   Caption := 'Email-mail :';
   font.Name := 'Tahoma';
   font.Size := 8;
   Height := 13;
   Width := 68;
   Left := 12;
   Top := 97;
  end;


  lbl[4] := TLabel.Create(frmEncryptInput);  //Stel label 4 op
  with lbl[4] do
  begin
   parent :=  frmEncryptInput;
   name := 'lbl4';
   Caption := 'Password :';
   font.Name := 'Tahoma';
   font.Size := 8;
   Height := 13;
   Width := 53;
   Left := 12;
   Top := 133;
  end;

   lbl[5] := TLabel.Create(frmEncryptInput);   //Stel label 5 op
  with lbl[5] do
  begin
   parent :=  frmEncryptInput;
   name := 'lbl5';
   Caption := 'Confirm Password :';
   font.Name := 'Tahoma';
   font.Size := 8;
   Height := 13;
   Width := 93;
   Left := 12;
   Top := 165;
  end;

    lbl[6] := TLabel.Create(frmEncryptInput);    //Stel label 6 op
  with lbl[6] do
  begin
   parent :=  frmEncryptInput;
   name := 'lbl6';
   Caption := 'All fields need to be correctly filled in';
   font.Name := 'Tahoma';
   font.Size := 8;
   font.Color := clMaroon;
   Height := 13;
   Width := 180;
   Left := 143;
   Top := 116;
   visible := true;
  end;

   lbl[7] := TLabel.Create(frmEncryptInput);   //Stel label 7 op
  with lbl[7] do
  begin
   parent :=  frmEncryptInput;
   name := 'lbl7';
   Caption := '';
   font.Name := 'Tahoma';
   font.Size := 7;
   font.Color := clblack;
   Height := 21;
   Width := 221;
   Left := 332;
   Top := 70;
  end;

   lbl[8] := TLabel.Create(frmEncryptInput);        //Stel label 8 op
  with lbl[8] do
  begin
   parent :=  frmEncryptInput;
   name := 'lbl8';
   Caption := '';
   font.Name := 'Tahoma';
   font.Size := 7;
   font.Color := clblack;
   Height := 21;
   Width := 221;
   Left := 332;
   Top := 100;
  end;

   rgb := TRadioGroup.Create(frmEncryptInput);     //Stel radio group button op
   with rgb do
   begin
   Parent :=  frmEncryptInput;
   Name := 'rgb1';
   Caption := 'Select Version';
   Items.Add('Regular') ;
   Items.Add('Secure');
   ItemIndex := 0;
   Height := 48;
   LEft := 16;
   Top := 189;
   Width := 101;
   onclick := RegisterEditsCompleteCheck;     //Kyk fo inset valid is
   end;

   edt[1] := TEdit.Create(frmENcryptInput);   //Stel edit 1 op
   with edt[1] do
   begin
   parent := frmEncryptInput;
   name := 'edt1';
   Text := '';
   TextHint := 'Enter Your Username';
   Height := 21;
   LEft := 111;
   Top := 67;
   Width := 221;
   onchange := RegisterEditsCompleteCheck;   //Kyk fo inset valid is
   end;

   edt[2] := TEdit.Create(frmENcryptInput);   //Stel edit 2 op
   with edt[2] do
   begin
   parent := frmEncryptInput;
   name := 'edt2';
   Text := '';
   TextHint := 'Enter Your Email-Adress';
   Height := 21;
   LEft := 111;
   Top := 94;
   Width := 221;
   onchange := RegisterEditsCompleteCheck; //Kyk fo inset valid is
   end;

   edt[3] := TEdit.Create(frmENcryptInput);         //Stel edit 3 op
   with edt[3] do
   begin
   parent := frmEncryptInput;
   name := 'edt3';
   Text := '';
   TextHint := 'Enter Your Password';
   Height := 21;
   LEft := 111;
   Top := 135;
   Width := 221;
   Onchange := RegisterEditsCompleteCheck;//Kyk fo inset valid is
   end;

   edt[4] := TEdit.Create(frmENcryptInput);  //Stel edit 4 op
   with edt[4] do
   begin
   parent := frmEncryptInput;
   name := 'edt4';
   Text := '';
   TextHint := 'Confirm your Password';
   Height := 21;
   LEft := 111;
   Top := 162;
   Width := 221;
   OnChange := RegisterEditsCompleteCheck; //Kyk fo inset valid is
   end;

   btn[1] := TButton.Create(frmENcryptInput);    //Stel button 1 op
   with btn[1] do
   begin
     parent := frmENcryptInput;
     Name := 'btn1';
     Caption := 'Submit';
     Enabled := false;
     Height := 25;
     LEft := 257;
     Top := 210;
     Width := 75;
     Onclick :=  RegisterAccount;  ////stel gebruiker rigestreer nuwe account form op
   end;

     btn[2] := TButton.Create(frmENcryptInput);  //Stel button 2 op
   with btn[2] do
   begin
     parent := frmENcryptInput;
     Name := 'btn2';
     Caption := 'Back';
     Height := 25;
     LEft := 125;
     Top := 210;
     Width := 75;
     Onclick :=  SetupUserLogin;//stel gebruiker login form op
   end;



end;


procedure TfrmEncryptInput.RegisterEditsCompleteCheck(Sender : Tobject); //Kyk of inligting voldoende is
var
 bcorrectemailformat : boolean;
begin

   if CheckIfUserExistsInDataBase(edt[1].text,'',edt[2].text,true,false,false) = true then  //kyk og gebrukiker naam bestaan
   begin
   edt[1].Color := clred;
   lbl[7].Caption := 'Username taken'; //Se gebriuker dat hul naam klaar gevat is
   lbl[7].Font.color := clred;
   end
   else
   begin
   edt[1].Color := clwhite;
   lbl[7].Caption := 'Username available';  //Se gebriuker dat hul naam oop is
   lbl[7].Font.color := clgreen;
   end;
   if edt[1].Text = '' then
   lbl[7].Caption := '';

   if CheckIfUserExistsInDataBase(edt[1].text,'',edt[2].text,false,false,true) = true then //kyk of Gebruiker Epos klaar bestaan
   begin
   edt[2].Color := clred;
   lbl[8].Caption := 'Email taken';    //Se gebriuker dat hul Epos klaar gevat is
   lbl[8].Font.color := clred;
   end
   else
   begin
   edt[2].Color := clwhite;
   lbl[8].Caption := 'Email available'; //Se gebriuker dat hul Epos oop is
   lbl[8].Font.color := clgreen;
   end;

   if (Pos('@' , edt[2].Text) > 1) AND (Pos('.' , edt[2].Text) > 0)then //Kyk of Epos Valied is
   begin
   bcorrectemailformat := true;   //stel vaiable dat die valied is
   end
   else
   begin
   //edt[2].Color := clred;
   lbl[8].Caption := 'incorrect format';
   lbl[8].Font.color := clred;
   bcorrectemailformat := false;
   end;

   if edt[2].Text = '' then
   lbl[8].Caption := '';



   edt[3].color := clwhite;  //maak teks wit
   edt[4].Color := clwhite;  //maak teks wit

  //Kyk of alles ingevul is
  if  ( edt[1].Text <> '' ) AND ( edt[2].Text <> '' ) AND ( edt[3].Text <> '' ) AND ( edt[4].Text <> '' ) AND (rgb.ItemIndex > -1) AND ((CheckIfUserExistsInDataBase(edt[1].text,'',edt[2].text,true,false,false)) = false) AND ( CheckIfUserExistsInDataBase(edt[1].text,'',edt[2].text,false,false,true ) = false) AND ( bcorrectemailformat = true ) then
  begin
  btn[1].Enabled := true;
  lbl[6].Visible := false;
  end
  else
  begin
  btn[1].Enabled := false;
  lbl[6].Visible := true;
  lbl[6].Caption := 'All fields need to be correctly filled in';  //laat weet gebruiker dat als nie ingevul is nie
  end;

end;


procedure TfrmEncryptInput.RegisterAccount(Sender : Tobject); //rigestreer nuwe account
begin

  if edt[3].Text = edt[4].text then   //kyk og wagwoor reg is in albei edits
  begin
   case rgb.itemindex of
   0 :  InsertRecordsIntoDB_usrtbl(edt[1].text , edt[3].text , edt[2].text,'Regular');  //set persoon a Regular op
   1 :  InsertRecordsIntoDB_usrtbl(edt[1].text , edt[3].text , edt[2].text,'Secure');   //Stel persoon as SEcure op
   end;
   sUsername :=  edt[1].text;  //Stel naam
   sUserPassword := edt[2].text;//stel wagwoord
   SetUpMainForm(self);     //maak die hoof from oop
   bAlreadyLoggedIn := true;    //maak gebruiker ingesign is
  end
  else
  begin
  lbl[6].Visible := true;
  lbl[6].Caption := 'Passwords does not match'; //kyk og wagwoor reg is in albei edits
  edt[3].Color := clred;
  edt[4].Color := clred;
  end;

end;
//END //Register New account


//Start //Setup MainForm

procedure TfrmEncryptInput.SignOutLblChange(Sender : Tobject);     //maak die label kleur
begin
 if ((Sender as TLabel).font.color = clolive) then
  begin
  (Sender as TLabel).Caption := 'Sign-out of : ' + sUserName; //vernader teks
  (Sender as TLabel).Font.Color := clBlue;    //maak blou
  end
 else if ((Sender as TLabel).font.color = clBlue) then  //indien blou
  begin
   (Sender as TLabel).Caption := 'Signed-in as : ' + sUserName;   //vernader teks
   (Sender as TLabel).Font.Color := clOlive;        //maak Olive
   end;
end;


procedure TfrmEncryptInput.SignOut(Sender : Tobject);
begin
 sUserName := '';      //maak naam skoon
 sUserPassword := '';  //maak wagwoord skoon
 sUserEmail := '';     //maak epos skoon
 bAlreadyLoggedIn := false;   //maak dat nie meer ingesig  is  nie
 SetupUserLogin(Sender);    //maak die Login Form oop
end;


procedure TfrmEncryptInput.SetUpMainForm(Sender : Tobject);//Stel Die Main Form op
 begin
 clearObjects();

 frmEncryptInput.width := 373;
 frmEncryptInput.Height := 260;
 frmEncryptInput.Color := clMedGray;


 btn[1] := TButton.Create(frmEncryptInput);  //Stel Button 1 op
 with btn[1] do
 begin
 parent := frmEncryptInput;
 name := 'btnEncrypt';
 Caption := 'Encrypt';
 Top := 60;
 left := 8;
 WIdth := 170;
 HEight := 120;
 Onclick := Encrypt; //BEgin Enkrip en maak Enkripsie oop
 end;

 btn[2] := TButton.Create(frmEncryptInput); //Stel Button 2 op
 with btn[2] do
 begin
 parent := frmEncryptInput;
 name := 'btnDecrypt';
 Caption := 'Decrypt';
 Top := 60;
 left := 180;
 WIdth := 170;
 HEight := 120;
 Onclick := SetUpDecrypt;     //BEgin Dekrip en aak dekripse oop
 end;

 btn[3] := TButton.Create(frmEncryptInput);  //Stel Button 3 op
 with btn[3] do
 begin
  parent := frmEncryptInput;
  name := 'btnClose';
  Caption := 'Close';
  top := 186;
  left := 8;
  width := 341;
  height := 25;
  Onclick := btnClose;    //maak die form toe
 end;

 lbl[1] := TLabel.Create(frmEncryptInput); //Stel label 1 op
 with lbl[1] do
 begin
 parent := frmEncryptInput;
 Caption := 'What do you want to do ?';
 name := 'lblHeading';
 top := 30;
 left := 10;
 width := 280;
 height := 100;
 Font.Size := 17;
 font.name := 'UniSpace';
 Font.Style := [fsBold];
 end;

  lbl[2] := TLabel.Create(frmEncryptInput); //Stel label 2 op
 with lbl[2] do
 begin
 parent := frmEncryptInput;
 Caption := 'Signed-in as : ' + sUsername;
 name := 'lblSignedin';
 top := 10;
 left := 6;
 Font.Size := 10;
 Font.Color := clOlive;
 Font.Style := [fsUnderline];
 OnMouseEnter := SignOutLblChange ;//maak label blou as mouse oor gaan
 OnMouseLeave := SignOutLblChange; //maak lbel olive as muis uit gaan
 OnClick := Signout;       //indien geklik word sign die gebruiker UIT
 end;

 end;


procedure TfrmEncryptInput.Encrypt(Sender : Tobject);   //Begin enkrip
  var
  SInput , sBmpFilePath , sExtraText , SEmail , sBMPName  : string;  //Stringger
  arrUsers : TArrayofString;           //array van stringe
  icount : integer; //teller
  begin

  while trim(SInput) = '' do  //maak seker die gebruiker gee inser
  begin
   if NOT JHBInputQuery('Input','Input','Insert the text you want to Encrypt',SInput) then //Inset Query vir teks
   exit;
    if trim(SInput) = '' then
     if MessageDlg('You did not enter anything , sure you want to continue ?', mtWarning,[mbYes, mbNo], 0) = mryes then //maak seker als is reg
     break;
  end;


  while length(ArrUsers) <= 0 do  //tel duer gebruiker array
  begin
   if NOT SelectRecipientsFromDB(arrUsers) then   //slekteer iemand van databasis
   exit;
   if length(ArrUsers) <= 0 then    //idien niemand gekies Vra en probeer weer
   if MessageDlg('You Did not Select Recipient , The message won''t send without a recipient. Are you Ok with this ?', mtWarning,[mbYes, mbNo], 0) = mrYes then
   exit;
  end ;


  while sBMPFilePAth = '' do   //kyk of daar n BITMAP gekies is
  begin
  sBmpFilePath :=   JHBWIndowsOpenDialog('Select Bitmap file','BitMap files only|*.bmp;');//maak OpenDialog oop
  if sBmpFilePath = '' then       //Indien niks , VRA weer
  if MessageDlg('You did not select a Bitmap to encrypt with , Are you sure you want to continue ?', mtWarning,[mbYes, mbNo], 0) = mrYes then
  exit;
  end;

  if sBmpFilePath <> '' then     //Indien NIE niks
  for icount := 0 to length(arrUsers) - 1 do
  begin

  HideBinaryStringInBitMap(JHBEncrypt(sInput , Copy(arrUsers[icount],1,Pos(chr(0),arrUsers[icount])-1)), sBMPFilepath);
  Delete(arrUsers[icount],1,Pos(chr(0),arrUsers[icount]));
  sEmail :=  Copy(arrUsers[icount],1,Pos(chr(0),arrUsers[icount])-1);
  Delete(arrUsers[icount],1,Pos(chr(0),arrUsers[icount]));

  if NOT JHBInputQuery('Add Extra',sEmail,'Type anyting extra you want to add to the Email' ,sExtraText) then
  exit;
  sExtraText := '''' + sExtraText + '''';
  if sExtraText = '' then
   sExtraText := 'nul';

  SendEmail(1 , sEmail , uJHBEncryptAndDecrypt.sNewFilename , sUserName , sExtraText);
  Delete(sExtraText,1,1);
  Delete(sExtraText,length(sExtraText),1);
  end;

  sBMPName := sBmpFilePath;
  while Pos('\',sBMPName) > 0 do
  Delete(sBMPName,1,Pos('\',sBMPName)) ;

  clearObjects();

  lbl[1] := TLabel.Create(frmEncryptInput);
  with lbl[1] do
  begin
  parent := frmEncryptInput;
  name := 'lblHeading';
  top := 10;
  left := 10;
  width := 280;
  height := 100;
  Font.Size := 17;
  font.name := 'UniSpace';
  font.Style := [fsBold , fsUnderLine];
  Caption := 'Encrypted :';
  end;



  {lbl[2] := TLabel.Create(frmEncryptInput);
  with lbl[2] do
  begin
  parent := frmEncryptInput;
  name := 'lblBmpFilePath';
  top := lbl[1].Height + lbl[1].Top + 5;
  left := 10;
  height := 100;
  Font.Size := 10;
  font.name := 'Unispace';
  Caption := uJHBEncryptAndDecrypt.sNewFilename;
  if Width > frmEncryptInput.Width - 25 then
  Height := Height * Ceil(width / frmEncryptInput.Width - 25);
  Width := frmEncryptInput.Width - 25;
  WordWrap := true;
  end;             }

  img := TImage.Create(frmEncryptInput);
  with img do
  begin
   parent := frmEncryptInput;
   name := 'image';
   Picture.LoadFromFile(uJHBEncryptAndDecrypt.sNewFilename);
   Center := true;
   Proportional := true;
   Height := 330;
   Width := 465;
   top := lbl[1].Top + lbl[1].Height;
   left := 10;
  end;


  btn[3] := TButton.Create(frmEncryptInput);
  with btn[3] do
  begin
  parent := frmEncryptInput;
  name := 'btnBack';
  Caption := 'Back';
  top := img.Top + img.Height;
  left := 8;
  width := 468;
  height := 25;
  Onclick := SetUpMainForm;
  end;

  btn[4] := TButton.Create(frmEncryptInput);
  with btn[4] do
  begin
  parent := frmEncryptInput;
  name := 'btnInfo';
  Caption := 'Info';
  top :=  10;
  left := 420;
  width := 55;
  height := 25;
  onMouseEnter := ShowEncryptInfo;
  onMouseLeave := CloseEncryptInfo;
  end;


  Redt := TRIchedit.Create(frmEncryptInput);
  with Redt do
  begin
  parent := frmEncryptInput;
  name := 'RedOutput';
  clear;
  SelAttributes.Color := clBlue;
  SelAttributes.Style := [fsBold];
  Lines.add('INFO :');

  SelAttributes.Color := clRed;
  SelAttributes.Style := [fsbold];
  Lines.Add('Text Encrypted :');

  SelAttributes.Color := clblack;
  SelAttributes.Style := [];
  Lines.add(sInput);

  SelAttributes.Color := clRed;
  SelAttributes.Style := [fsbold];
  Lines.Add('Sender :');

  SelAttributes.Color := clblack;
  SelAttributes.Style := [];
  Lines.add(sUserName);

  SelAttributes.Color := clRed;
  SelAttributes.Style := [fsbold];
  Lines.Add('Recipients :');

  SelAttributes.Color := clblack;
  SelAttributes.Style := [];

  for icount := 0 to length(arrUsers)-1 do
  begin
  Lines.Add(arrUsers[icount]);

  LogMessagetoDB(sUserName , arrUsers[icount] , sBmpName);

  end;

  SelAttributes.Color := clRed;
  SelAttributes.Style := [fsbold];
  Lines.Add('Image Directory :');

  SelAttributes.Color := clblack;
  SelAttributes.Style := [];
  Lines.Add(sBmpFilePath);


  Width :=472;
  top := 4;
  left := 4;
  Height := (Lines.Count)*15;


  CloseEncryptInfo(Self);
  end;

  frmEncryptInput.width := 500;
  frmEncryptInput.Height := btn[3].Height + btn[3].Top + 50;
  frmEncryptInput.Color := clteal;

  RemoveDir('..\'+uJHBEncryptAndDecrypt.sNewFilename)
 end;
 //END //SEtup Encrypt




 //Hide Richedit with Info
 procedure TfrmEncryptInput.CloseEncryptInfo(Sender:Tobject);
 begin
   Redt.Visible := false;
   Redt.Enabled := false;
   Redt.SendToBack;
 end;

 //Show Richedit with Info
 procedure TfrmEncryptInput.ShowEncryptInfo(Sender:Tobject);
 begin
   Redt.Visible := true;
   Redt.Enabled := true;
   Redt.BringToFront;
   btn[4].BringToFront;
 end;




  //START //SEtup Decrypt
 procedure TfrmEncryptInput.ExportToTextfile(Sender : Tobject);
 var
 tf : TextFile;
 textfilepath : string;
 begin
 while textfilepath = '' do
 begin
  textfilepath :=   JHBWIndowsOpenDialog('Select Text file','Text files only|*.txt;*.rtf;');
  if textfilepath = '' then
  if MessageDlg('You did not select a TextFile to Export to , Are you sure you want to continue ?', mtWarning,[mbYes, mbNo], 0) = mrYes then
  exit;
 end;

 AssignFile(tf , Textfilepath);
 Append(tf);
 Writeln(tf,'');
 Write(tf , SDecryptedText);
 closeFile(tf);
 end;




 procedure TfrmEncryptInput.SetUpDecrypt(Sender : Tobject);
 var
 sBMPFIlepath : string;
 begin

 while sBMPFilePAth = '' do
 begin
  sBmpFilePath :=   JHBWIndowsOpenDialog('Select Bitmap file','BitMap files only|*.bmp;');
  if sBmpFilePath = '' then
  if MessageDlg('You did not select a Bitmap to Decrypt with , Are you sure you want to continue ?', mtWarning,[mbYes, mbNo], 0) = mrYes then
  exit;
 end;


 SDecryptedText := JHBDecrypt(sBmpFilepath);

 ClearObjects();

 frmEncryptInput.width := 500;
 frmEncryptInput.Height := 500;
 frmEncryptInput.Color := clteal;

 Redt := TRichedit.Create(frmEncryptInput);
 with Redt do
 begin
 parent := frmEncryptInput;
 name := 'RedOutput';
 Height := 361;
 Width :=468;
 top := 56;
 left := 8;
 clear;
 if((sBMPFilepath = '') OR (Copy(sDecryptedText,1,51) = uJHBEncryptAndDecrypt.MARKINGSTRING)) then
 begin
  SelAttributes.Color := clRed;
  SelAttributes.Style := [fsBold];
  SelAttributes.Size := 15;
  Delete(sDecryptedText,1,51);
 end;
 Redt.Lines.Add(SDecryptedText)  ;
 end;

 lbl[1] := TLabel.Create(frmEncryptInput);
 with lbl[1] do
 begin
 parent := frmEncryptInput;
 name := 'lblHeading';
 top := 20;
 left := 10;
 width := 280;
 height := 100;
 Font.Size := 17;
 font.name := 'UniSpace';
 font.Style := [fsBold,fsUnderLine];
 caption := 'Decrypted Text : ';
 end;

 btn[3] := TButton.Create(frmEncryptInput);
with btn[3] do
begin
  parent := frmEncryptInput;
  name := 'btnBack';
  Caption := 'Back';
  top := 428;
  left := 8;
  width := 468;
  height := 25;
  Onclick := SetUpMainForm;
end;

btn[4] := TButton.Create(frmEncryptInput);
with btn[4] do
begin
parent := frmEncryptInput;
name := 'btnExportToTextfile';
Caption := 'Export to textfile';
top :=  10;
left := 360;
width := 110;
height := 25;
Onclick := ExportToTextfile;
end;

end;
//END //SEtup Decrypt
end.

