unit uJHBEncryptAndDecrypt;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls , ExtCtrls, Buttons, Math, MAPI, ShellApi;

const
  MAX64BIT = 18446744073709551615;
  UTF8VALUE = $FFFF;
  ASCIIVALUE = 255;
  BITLENGTHVALUE_BITLENGTH = 64;
  MARKINGSTRING = '!@#$%^&*(ujhbEncryptAndDecrypt!!!!;{[//MARKING\\]})';
  FeistelRounds = 15;
  PublicKey = '';
  // cUnitNameSentinel = '$$$sentinel$$$';

 type
 TGeneric<T> = class   //Inisialisasie van Generiese klas
 Value : T;
 ArrValue : array of T;
 end;

 TArrayofString = array of string; //Array of string
 TArrayofBytes = array of byte;  //Array van bytes
 TBinary = array of boolean; //Array van boolean

var
  TGenericBool : TGeneric<boolean>;  //Gineriese boolean klas
  TGenericInt : TGeneric<integer>;   //Gineriese integer klas
  TGenericStr : TGeneric<string>;    //Gineriese string klas

  sThisUnitDir: string;             //File directory na die hoof unit toe
  sSecurityString: string;          //String wat gebruik word om wagwoorde te reset
  ArrEncryptNumbers : Array[0 .. ASCIIVALUE] of integer;  //Klasifikasie van verskillende Arrays
  BitMap : TBitMap;    //Bitmap om uit te lees en in te skryf
  iCurrentPosInBMP : integer; //hou plek van waar mens in die Bitmap besig is om te lees
  bDEBUGBOOL : boolean;   //Slegs vir Debug gebruik
  sNewFilename : string;  //string na file pad van nuwe bitmap

procedure WriteToDebugtf(Sinput : string); //Skryf waarder in n Teksleer vir debugging


  // shell functions and procedures
function ExecuteExternalProgram(sExecuteFileDir, sParameters,sInitialDir: string): boolean; //Maak n eksterne program oop deurmiddel van SHELL

function JHBEncrypt(SInput , SPassword : string): TBinary;  //Enkrip alles
function JHBDecrypt(sBMPFilepath: string): string; overload; //Dekrup Alles

function StrtoBin(sInput : String ) : TBinary; //verander string na array of boolean (TBinary)
function BintoStr(tbInput : TBinary ) : string; //verander TBinary na string
function BinToInt(Binary: TBinary): uint64;     //verander (TBinary)   na integer
function InttoBin(INumber: integer): TBinary;   //verander integer na TBinary
procedure BinArrDelete(var Arr : TBinary; const RemoveIndex : integer; RemoveAmount:integer);   //Delete index uit skikking
Procedure JoinBinArr(var BinArr : TBinary ;const JoinArrBin : TBinary);    //sit twee Tbinary saam
function LengthenBinary(tbInput : TBinary; bBitLength: byte; bool : Boolean): TBinary; //Maak Binere skikking langer
Function CopyBinArr(Arr: TBinary ; iStart , iEnd : integer) : TBinary;  //kopieer deel van n Binere skikking
function RandomBinary(length:integer) : Tbinary;  //maak random Binere array
function BinXOR(Bin1 , Bin2 : Tbinary) : Tbinary; //XOR operater op Binere waardes
function Feistel(SInput : string ; bForward : boolean ; Keys : Array of TBinary) : String;  //FEistel Enkripsie sisteem
function GenerateKeysAndFeistelEncrypt(SInput : string ; sRecipientKey : String) : String; //Ginereer sleutels en Feistel
function RecoverKeysAndFeistelDecrypt(SInput : string; sRecipientKey : String) : string;  //kry sleutels vanaf skring en Feistel
function BinaryMultiply(Bin1 , Bin2 : TBinary) : TBinary;   //maal  binere arrays saam mekaar
function BinaryAddition(Bin1 , Bin2 : TBinary) : TBinary;   //plus binere arrays saam
function BoolToInt(B : Boolean) : shortint;  //boolean na integer
function IntToBool(si : ShortInt) : Boolean;  //integer na boolean
procedure EqualBinLengths(var Bin1 , Bin2 : TBinary); //maak twee binere arrays ewe lank
function BinaryPower(Bin1 , Bin2 : TBinary) : TBinary; //tot die mag met Binere arrays
function BinarySubtract(Bin1,Bin2 : TBinary) : TBinary;  //minus binere arrays van mekaar af
Function BinaryModulo(Bin1 , Bin2 : TBinary) : TBinary; //Binere Deel en Mod
function StrOrdtoBinArr(sInput : string; BitsPerChar , BinaryLength : integer) : TBinary; //Deel string op in ASCII waardes en sit saam om binere array te vorm
function CheckifBinLarger(Bin1 , Bin2 : TBinary) : ShortInt; //kyk of een binere array langer as ander een is
Procedure TrimBin(var Bin1 : TBinary); //haal onnodige bits uit binere array

procedure CreateBitMap(Width, Height: integer; Color: TColor;const FileName: string);  //maak Bitmap
procedure HideBinaryStringInBitMap(BintoHide: TBinary; const BMPFileName: string); //steek Binere data in n Bitmap Weg
function JHBWIndowsOpenDialog(Title, Filter: string): string; //maak die Open Dialog oop om leer mee te kies
procedure CreateInputFormEncryption();    //maak die enkripsie form oop
function RetriveBinFromBMP(BitMap: TBitmap; StartPoint, StringLength: integer): TBinary; //haal binere string uit die bitmap uit
function ArrDecryptString(bBitlength : byte ; binInput : TBinary) : String;    //dekripteer Binere array met 2020 PAT
function ArrEncryptString(sInput : String ; bBitlength : byte): TBinary;  //Enkripteer String array met 2020 PAT

Function JHBInputQuery(const sCaption , sHeading , sDiscription : string ; var sVar : string) : boolean; overload;// Maak InputQUery om insert vanaf te verkry

// Database functions and procedures;
function  CheckIfUserExistsInDataBase(UserName, UserPassword, UserEmailAdress: string; searchName, searchPassword, searchEmail: boolean): boolean;   //TOets of n gebruiker bestaan in die databasis
procedure InsertRecordsIntoDB_usrtbl(UserName, UserPassword, UserEmailAdress, UserUsage: string); //Sit Nuwe rekord in die databasis
procedure InsertNewDataIntoExistingRecordDB_usrtbl(UserName, UserPassword,UserEmailAdress: string; insertname, insertpassword,insertEmailAdress: boolean); //verander bestaande data in databasis
Function SelectRecipientsFromDB(var arrUsers : TArrayofString) : boolean;  //maak boks oop om gebruikers wat in die databasis bestaan te kies
Procedure LogMessagetoDB(Sender , Receiver , MsgName : string); //log boodskap in databasis

// Email Functions and procedures;
// function SendEmailMAPI( const arrTO ,arrCC , arrBCC , arrAttachments: array of string; const Body , Subject : string ) : integer;
procedure SendEmail(EmailType: byte; sRecipient: array of string; AttachmentDir: string;SenderName: string; sExtraText:string); //Stuur n Epos
function GetSeperatedValues(sInput , sSeperator : string) :  TArrayofString;//kry waardes wat gesperate word met n karakter en sit dit in n databasis

implementation

uses

  uJHBEncryptInputForm , uJHB_DB;

//Stuur Epos
procedure SendEmail(EmailType: byte; sRecipient: array of string; AttachmentDir: string; SenderName: string ; sExtraText:string);
var
  Parameters, __SecurityString: string;
  bcount , bcount2: byte;
begin
for bcount := 0 to length(sRecipient)-1 do  //stuur aan elke gebruiker in die sRecipient array
 begin
  if EmailType = 0 then//Kies ePos tipe
  begin
    for bcount2 := 1 to 6 do
    begin
      __SecurityString := __SecurityString + inttostr(Random(10));
      sSecurityString := __SecurityString;
    end;
    Parameters := '/C java -jar JHBjavaEmail-1.0.jar' + ' ' + inttostr(EmailType) + ' ' + sRecipient[bcount] + ' ' + '''' + AttachmentDir + '''' + ' ' +__SecurityString + ' ' + sExtraText;
  end;

  //STel op met parameters  vir teks

  if EmailType = 1 then
  begin
    Parameters := '/C java -jar JHBjavaEmail-1.0.jar' + ' ' + inttostr(EmailType) + ' ' + sRecipient[bcount] + ' ' + ''''  + AttachmentDir + '''' + ' ' + SenderName + ' ' + sExtraText;
  end;
     //stel op met parametrts vir private boodskap
  ExecuteExternalProgram('powershell', PWideChar(Parameters), sThisUnitDir + '/../uJHBEncryptExternalCode/java/JHBjavaEmail/');

end;
end;

function ExecuteExternalProgram(sExecuteFileDir, sParameters , sInitialDir: string): boolean; //hardloop java program uit SHELL
var
  StartupInfo: TStartupInfo;
  ProcessInfo: TProcessInformation;
  //ErrorCode: DWORD;
begin
  Result := true;
  StartupInfo := Default(TStartupInfo);//Maak die startup inligting
  StartupInfo.cb := sizeof(StartupInfo); //stel die grote
  StartupInfo.dwFlags := STARTF_USESHOWWINDOW;  //stel hoe die window wys
  //How to ShellExecute Windows should show
  StartupInfo.wShowWindow := SW_Hide;      //stel of window wys of nie
  //Hardloop ekstene program
  CreateProcess(pChar(nil), PWideChar(WideString(sExecuteFileDir + ' ')+ PWideChar(WideString(sParameters))), nil, nil, false, 0, nil, pChar(WideString(sInitialDir)), StartupInfo, ProcessInfo);
end;

// C:\Users\jhbri\OneDrive\Documents\Embarcadero\Studio\Delphi 2010\Delphi 2010 Custom Units\uJHBEncryptAndDecrypt\uJHBEncryptExternalCode\java\JHBjavaEmail
           //Kyk of die Gebruiker bestaan in die databasis
function CheckIfUserExistsInDataBase(UserName, UserPassword, UserEmailAdress : string; searchName , searchPassword , searchEmail : boolean): boolean;
 var
 bfoundName , bfoundPassword , bfoundEmail : boolean;
begin

  with uJHB_DB.JHBdataModule do
  begin
   DB_usrtbl.First; //stel na eerste rekonrd

    while NOT(DB_usrtbl.Eof) do
     begin

     bfoundName := DB_usrtbl['UserName'] = UserName;    //Kyk of naam kry
     bfoundPassword := DB_usrtbl['UserPassword'] = UserPassword; //kyk of wagwoordkry
     bfoundEmail := DB_usrtbl['UserEmail'] = UserEmailAdress;   //Kyk of EposKry
         //STel waardes of hull in selfde rekord is
     if ((bfoundName = searchName) AND (bfoundPassword = searchPassword) AND (bfoundEmail = searchEmail)) then
     begin
      Result := true;
      exit;
     end;

     DB_usrtbl.Next; //gaan na volende rekord

     end;
   end;
     Result := false;//niks kon kry nie
end;

procedure InsertRecordsIntoDB_usrtbl(UserName, UserPassword, UserEmailAdress,UserUsage: string);//Sit nuwe rekord in databasis
var
sUniqueCOde : string;
icount : integer;
bCodeInvalid : boolean;
begin

  with uJHB_DB.JHBdataModule do
  begin

     bCOdeInvalid := true;//kyk of kode valied is
    while bCodeINvalid = true do
    begin
    sUniqueCode := '';
    for icount := 0 to 254 do//stel nuwe kode op
     begin
      sUniqueCOde := sUniqueCode + chr(RandomRange(1,255));
     end;
     if NOT DB_usrtbl.Locate('UserUniqueCode' , sUniqueCode , []) then  //kyk of kode valied is // nie kaar bestaan nie
     bCodeInvalid := false;
    end;

    DB_usrtbl.Insert;                       //Sit databasis in insert mode
    DB_usrtbl['UserName'] := UserName;       //sit naam in
    DB_usrtbl['UserPassword'] := UserPassword; //Sit wagwoord in
    DB_usrtbl['UserEmail'] := UserEmailAdress; //Sit epos is
    DB_usrtbl['UserUsage'] := UserUsage;       //sit gebruiker gebuiks toestand in
    DB_usrtbl['UserUniqueCode'] := sUniqueCode;  //sit unike kode in
    DB_usrtbl.Post;       //Pos na Databasis

  end;

end;

//Insert NEw Date intop REcord
//verander inligting in huidige rekord
Procedure InsertNewDataIntoExistingRecordDB_usrtbl(UserName, UserPassword,UserEmailAdress : string; insertname, insertpassword,insertEmailAdress : boolean);
var
  bfound: boolean;
begin
  bfound := false;

  with uJHB_DB.JHBdataModule do
  begin
    if (((insertname = true) AND (insertpassword = false) AND(insertEmailAdress = false)) OR ((insertname = false) AND(insertpassword = true) AND (insertEmailAdress = false)) OR((insertname = false) AND (insertpassword = false) AND(insertEmailAdress = true))) then
    begin

        if insertname = true then //kyk of naam ingesit will word
         if (DB_usrtbl.Locate('UserPassword' , UserPassword , []) = true) AND(DB_usrtbl.locate('UserEmail' ,UserEmailAdress , []) = true) then
          begin
            DB_usrtbl.Edit;     //Siot datbasis in eidt mode
            DB_usrtbl['UserName'] := UserName;   //kyk of naam gevind kan word
            bfound := true;

          end;

        if insertpassword = true then  //kyk of wagwoord ingesit will word
         if (DB_usrtbl.locate('UserName' , UserName , []) = true) AND (DB_usrtbl.Locate('UserEmail' , UserEmailAdress , []) = true) then
          begin
            DB_usrtbl.Edit;    //Siot datbasis in eidt mode
            DB_usrtbl['UserPassword'] := UserPassword;  //kyk of wagwoord gevind kan word
            bfound := true;
          end;

        if insertEmailAdress = true then   //kyk of epos ingesit will word
          if (DB_usrtbl.locate('UserName' , UserName , []) = true) AND (DB_usrtbl.Locate('UserPassword' , UserPassword , [])) then
          begin
            DB_usrtbl.Edit;   //Siot datbasis in eidt mode
            DB_usrtbl['UserEmail'] := UserEmailAdress;    //kyk of epos gevind kan word
            bfound := true;
          end;

       if bfound = false then//rekord nie gevind nie
         begin
          showmessage('could not find record to replace');    //wys as nie gevind kan word  nie
         end;

      DB_usrtbl.Post;   //Pos na databasis

      end
      else
      showmessage('only 1 of the last 3 arguments can be true'); //kon nie die ander felde van die rakord kry nie
    end;
   end;




Procedure LogMessagetoDB(Sender , Receiver , MsgName : String); //Log Boodsap lys
begin
   with uJHB_DB.JHBdataModule do
  begin
     DB_MsgLogstbl.Insert;  //Sit databasis in edit mode
     DB_MsgLogsTbl['Date'] := Date();  //lees datum in databasis 'Date' in
     DB_MsgLogsTbl['Time'] := Time();   //lees Tyd in databasis 'Time' in
     DB_MsgLogsTbl['Sender'] := Sender;  //lees Stuurder in databasis 'Sender' in
     DB_MsgLogsTbl['Receiver'] := Receiver;    //lees Ontvanger in databasis 'Reciever' in
     DB_MsgLogsTbl['SentMessageName'] := MsgName;  //lees die BITMAP se naam in databasis 'SentMessageName' in
     DB_MsgLogstbl.Post; //Pos aan Databasis
  end;
end;


/// --------------------------------------------------------
function StrtoBin(sInput : String ) : TBinary; //String na Binary
begin
Setlength(REsult,0);
while sInput <> '' do
begin
 Setlength(Result,length(Result)+1) ;
 if SInput[1] = '1' then       //as String '1' dan Binary TRUE
 Result[length(Result)-1] := true
 else if SInput[1] = '0' then     //AS String '0' da Bianry FALSE
 Result[length(Result)-1] := false;
 Delete(sInput,1,1);   //Delete die karakter
end;
end;

//-------------------------------------------------------------------

function BintoStr(tbInput : TBinary ) : string;  //Binary to String
var
icount : integer;
begin

 Result := '';
 for icount := 0 to length(tbInput)-1 do   //AS Binary TRUE dan string '1'
 begin
 if tbInput[icount] = true then
 Result := Result + '1'     //stel Reuseltaat
 else if tbInput[icount] = false then    //AS Binary False dan string '0'
 Result := Result + '0';   //Stel Russeltaat
 end;

end;

//----------------- ----------------------------------------

function BinToInt(Binary: TBinary): Uint64;  //Binary na Integer
var
  icount , iBinaryNumber, INumber: integer;
begin
INumber := 0;
iBinaryNumber := 0;
for icount := 0 to length(Binary)-1 do   //Tel deur hele Binary
  begin
    if Binary[icount] = true then
      iBinaryNumber := 1       //maak TRUE n 1
    else if Binary[icount] = false then
      iBinaryNumber := 0;      //maak FALSE n 0
    INumber := INumber + trunc(iBinaryNumber * Power(2, icount)); //Mag 2 Binary + hudige nommer
  end;
  Result := INumber;  //Stel Russeltaat
end;

//---------------------------------------------------------

function InttoBin(INumber: integer): TBinary;  //Maak Integer n Biner
var
  BinVal: boolean;
  icount : integer;
begin
Setlength(Result,0);
icount := 0;
  while INumber > 0 do  //hou aan tot getal 0 is
  begin
    if odd(INumber) then //kyk of nommer onewe is
      BinVal := true // represents 1 in binary   //indien onewe maak 1 , TRUE
    else
     BinVal := false; // represents 0 in binary //indien ewe maak 0  , FALSE
     Setlength(Result,icount+1);
     Result[icount] := BinVal;
     INumber := INumber DIV 2;//Deel getal met 2
     INC(icount);//maak icount met 1 meer
  end;

end;

//----------------------------------------------------------

procedure BinArrDelete(var Arr : TBinary; const RemoveIndex : integer; RemoveAmount:integer);    //Haal index uit Boolean Array uit
var
iArrLength : integer ;
iRemovecount , icount : integer;
begin
for iRemovecount := 0 to RemoveAmount-1 do
begin
iArrLength := Length(Arr);

if iArrLength <= 0 then
  showmessage('Array is empty');    //Laatweet dat array leeg is
if RemoveIndex > iArrLength then
  showmessage('Remove Index out of bounds');    //Laatweet of arry sover kan reg

for icount := RemoveIndex + 1 to iArrLength  do
  Arr[icount - 1] := Arr[icount];    //Haal index uit en beweeg res om in te vul
  SetLength(Arr, iArrLength - 1);
end;
end;


//---------------------------------------------------

Procedure JoinBinArr(var BinArr : TBinary ;const JoinArrBin : TBinary);//Sit twee Binary arrays saam
var
BinArrLength , icount : integer;
begin
   BinArrLength := Length(BinArr);     //Save waarde van lengte
  SetLength(BinArr, BinArrLength + Length(JoinArrBin)); //SMaak lengte meer
  for icount := 0 to High(JoinArrBin) do
    BinArr[BinArrLength + icount] := JoinArrBin[icount];     //Sit albei saam
end;

// --------------------------------------------------------

Function CopyBinArr(Arr: TBinary ; iStart , iEnd : integer) : TBinary;
var
  icount: Integer;
begin
   if length(Arr) < iStart + iEnd then   //kyk of mens nie dalk te ver kopieeer nie
   showmessage('{CopyBinArr} -> Cannot Copy That Far');
   Setlength(Result,0);
   Setlength(Result,iEnd);  //stel lengte van array
   for icount := iStart to iStart + iEnd do   //begin en eind punt
   Result[icount-iStart] := Arr[icount];  //sell array se start posiseie en eind reg
end;

// ------------------------------------------------------

function LengthenBinary(tbInput : TBinary; bBitLength: byte; bool : Boolean): TBinary;
var
iLength : integer;
icount : integer;
begin
  iLength := length(tbInput);
  if (length(tbInput) > bBitLength) then //Kyk of Array nie te lank is nie
  begin
    showmessage('Bin ' + inttostr(length(tbInput)) + ' is Longer than The bBitLength ' + inttostr(bBitLength) + ' Truncating.....');
    exit;
  end;
  Setlength(tbInput,bBitlength);   //stell lengte

  if bool = true then  //indien TRUE
  for icount := iLength-1 to length(tbInput)-1 do
  tbInput[icount] := true;     //vull met ene


  Result := tbInput;
end;

///--------OBOSLETE-----------------------------------------------
// ----------------------------------------------------------------------------

function STRBinToInt(SBinaryNumString: string): integer;
var
  bcount: byte;
  iBinaryNumber, INumber: integer;
begin
  iBinaryNumber := 0;
  INumber := 0;
  for bcount := 1 to length(SBinaryNumString) do
  begin
    if SBinaryNumString[bcount] = ('1') then
      iBinaryNumber := 1
    else if SBinaryNumString[bcount] = ('0') then
      iBinaryNumber := 0;
    INumber := INumber + trunc(iBinaryNumber * Power(2, bcount - 1));
  end;
  Result := INumber;
end;

// -----------------------------------------------

function STRInttoBin(INumber: integer): string;
var
  cBinCharvalue: Char;
  sOutput: string;
begin
  while INumber > 0 do
  begin
    if odd(INumber) then
      cBinCharvalue := '1' // represents 1 in binary
    else
      cBinCharvalue := '0'; // represents 0 in binary
    Insert(cBinCharvalue, sOutput, length(sOutput) + 1);
    INumber := INumber DIV 2;
  end;
  Result := sOutput;
end;
// ------------------------------------------------------------------

function LengthenBinaryString(SInput: string; bBitLength: byte): string;
begin
  if (length(SInput) > bBitLength) then
  begin
    showmessage('String ' + inttostr(length(SInput)) + ' is Longer than The bBitLength ' + inttostr(bBitLength) + ' Truncating.....');
    exit;
  end;

  while length(SInput) < bBitLength do
  begin
    SInput := SInput + '0';
  end;

  Result := SInput;
end;
//----OBSELETE--------------------------------------------------------------------------------------------------------

// ---------------------------------------------------------------
function BinXOR(Bin1 , Bin2 : Tbinary) : Tbinary; //XOR wiskunde vir boolean
var
icount : integer;
begin
Setlength(Result,0);    //reset die result
EqualBinlengths(Bin1,Bin2); //maak albei ewe lank
Setlength(Result,length(bin1)); //stel ruseltaat lengte
//showmessage('Bin1 : ' + bintostr(Bin1) + ' , ' + 'Bin2 : ' + bintostr(Bin2))  ;
for icount := 0 to length(Result)-1 do  //tell deur hele van Bin1
  begin
    if Bin1[icount] = Bin2[icount] then //As albei gelyk is maak ruseltaal FALSE
    Result[icount] := false
    else
    if  ( Bin1[icount] <> Bin2[icount] ) then //as albei veskillend is maak RUsseltaat TRUE
    Result[icount] := true;
  end;


end;
//-----------------------------------------------------------------
function IntToBool(si : ShortInt) : Boolean;    //integer na boolean
begin
if si > 0 then     //Indien Int Groter as 1 maar TRUE
Result := True
else               //Indien int Keiner as of gelyuk aan 0 maak FALSE
Result := false;
end;
//------------------------------------------------------------------
function BoolToInt(B : Boolean) : shortint;     //boolean  na integer
begin
 if B = true then
 Result := 1       //Indien bool = TRUE maak 1
 else              //Indien Bool = False maak 0
 Result := 0;
end;
//-----------------------------------------------------------------------
function RandomBinary(length:integer) : Tbinary; //set random biner op
var
icount : integer;
begin
Setlength(Result,0);  //reset Russeltaal
Randomize;       //randomize die random funskie
for icount := 0 to length-1 do
JoinBinArr(Result,Strtobin(inttostr(RandomRange(0,2)))); //kies random getal tussen [0;2)
end;
//-------------------------------------------------------------------------
procedure EqualBinLengths(var Bin1 , Bin2 : TBinary);
begin
if length(Bin1) > length(Bin2) then //kyk of Bin1 langer is as Bin2
begin
 Bin2 := LengthenBinary(Bin2,length(Bin1),false) //maak Bin2 solank soos Bin1
end
else if length(Bin1) < length(Bin2) then //kyk of Bin2 langer is as Bin1
begin
 Bin1 := LengthenBinary(Bin1,length(Bin2),false)  //maak bin 1 solank soos Bin2
end;
end;
//----------------------------------------------------------------------------
function BinaryAddition(Bin1 , Bin2 : TBinary) : TBinary;   //Tell Biner saam
var
icount : integer;
Sival : ShortInt;
Bin3 : TBinary ;
begin
Setlength(Result,0);   //reser ruseltaalt

EqualBinLengths(Bin1,Bin2); //maak Hulle lengte ewe
 //showmessage(bintostr(bin1) + chr(10) + bintostr(bin2));
Setlength(Bin3,length(Bin1)+1);      //maak lengte groter
for icount := 0 to length(Bin1)-1 do//tel deur Bin1
begin
siVal := BooltoInt(Bin1[icount]) + BooltoInt(Bin2[icount]) +  BooltoInt(Bin3[icount]);   //tel waardes saam
case SiVal of
3 : begin                     //indied dit 3 is 1 1 1 -> 11
    Bin3[icount+1] := true;
    Bin3[icount] := true;
    end;
2 : begin                    //indien dit 2 is 1 1 0 -> 01
    Bin3[icount+1]  := true;
    Bin3[icount] := false;
    end;
1 : Bin3[icount] := true;     //indien dit 1 is 1 0 0 -> 1
end;

end;
 TrimBin(Bin3);   //haal onnodige bits uit
 Result := Bin3 ;   //set russeltaat gelyk aan Bin3
end;
//------------------------------------------------------------------------------
function BinarySubtract(Bin1,Bin2 : TBinary) : TBinary;     //Binere afterek
var
Bin3 : TBinary;
icount , ioffset : Integer;
siVal : ShortInt;
begin

Setlength(Result,0);      //reset ruseltaat
EqualBinLengths(Bin1,Bin2);//maak lengtes ewe
Setlength(Bin3,length(Bin1)); //maak lengte selfde as Bin1
for icount := 0 to length(Bin1)-1 do
begin
 ioffset  := 0;
 siVal := BooltoInt(Bin1[icount]) - BooltoInt(Bin2[icount]);  //Minus getalle en kyl wat is antw

 while siVal < 0 do   //indien getal kleiner as 0 is Dra oor
  begin
   Inc(iOffset);        //Tel iOffeset + 1

   if (icount + ioffset) >= length(Bin1) then
   begin
     showmessage('Awnser is negative'); //indien geen antwoord gevind word nie EXIT
     exit;
   end;

   if Bin1[icount + ioffset] = true then //tell 1 by iOffset en kyk of waar is
   begin
    Bin1[icount + ioffset] := false;//maak false
    siVal := 1;      //maak waar indien intes gevind word
   end
   else
   Bin1[icount + ioffset] := true;   //maak waar indien niks gevind word nie

  end;

Bin3[icount] := inttoBool(SiVal);  //sit antw in Binere array
 //Showmessage(bintostr(Bin1) + chr(10) + Bintostr(Bin2) + chr(10) + Bintostr(Bin3))
end;
TrimBin(Bin3);   //haal onnodige bits uit
Result := Bin3 ;   //set ruseltaat

end;
//--------------------------------------------------------------------------------
Procedure TrimBin(var Bin1 : TBinary);    //haal onnodige bit uit
var
icount : integer;
begin
 for icount := 0 to High(Bin1) do //tell deur die array
 if Bin1[High(bin1)-icount] = true then //kyk waar grootse 1 is
 begin
 setlength(Bin1,(High(bin1)-icount+1));  //stel sy lengte
 break;  //gaan uit die loop uit
 end;
end;
//--------------------------------------------------------------------------------
function CheckifBinLarger(Bin1 , Bin2 : TBinary) : shortint;    //kyk of een groter is as die ander een
var
icount : integer;
begin
TrimBin(Bin1);
TrimBin(Bin2);
Result := 0;
 if Length(Bin1) < length(Bin2) then
 Result := -1                  //indien lengtes groter is , maak antw kleiner as
 else if Length(Bin1) > length(Bin2) then
 Result := 1         //indien lengtes Keliener as  is , maak antw Groter  as
 else if Length(Bin1) = length(Bin2) then //indien lengters dieselfde tel deure array
 begin
 for icount := 0 to High(Bin1) do
 begin
 if (Bin1[High(Bin1)-icount] = false) AND (Bin2[High(Bin2)-icount] = true) then //indien bin 2 het groter TRUE waardie
 begin
 Result:= -1;                       //antw = Kleieras
 exit;
 end
 else  if (Bin1[High(Bin1)-icount] = true) AND (Bin2[High(Bin2)-icount] = false) then     ///indien bin 1 het groter TRUE waardie
 begin
 Result:= 1;             //antw = Groters
 exit;
 end;
 end;
 Result := 0;    //indien niks maak antw gelyk aan
 end;
end;

//-----------------------------------------------------------------------------
Function BinaryModulo(Bin1 , Bin2 : TBinary) : TBinary;
var                                                       //SKIP
Bin3 : TBinary;
begin
TrimBin(bin1);
TrimBin(bin2);
Bin3 := Bin2;

while length(bin1) > length(bin2) do
Bin2 := BinaryAddition(Bin2 , Bin3);                      //SKIP

Bin1 := BinarySubtract(Bin1,Bin2) ;


Result := Bin1;
end;
//---------------------------------------------------------------------------------
function BinaryMultiply(Bin1 , Bin2 : TBinary) : TBinary;  //maal binere getalle
var
Bin3 : TBinary;
icount : integer;
ArrAdders : Array of TBinary;
begin
Setlength(Result,0);         //reset ruseltaat
for icount := 0 to length(bin2) do  //tel deur array
begin
  Setlength(Bin3,0); //Reset BIn3
  Setlength(Bin3,icount); //stellengte van bin3
  if Bin2[icount] = true then  //indien Waar
  begin
  Setlength(ArrAdders,length(ArrAdders)+1);  //Sit een by die TEllers
  JoinBinArr(Bin3,Bin1);                      //Heg Bin1 aan Bin3
  ArrAdders[High(ArrAdders)] := Bin3;         //Maak Adder = aan Bin3
  end;
end;
for icount := 1 to High(ArrAdders) do      //loop duer adders
  begin
  ArrAdders[icount] := BinaryAddition( ArrAdders[icount-1]  , ArrAdders[icount]);    //tell adders saam
  end;
 Result :=   ArrAdders[High(ArrAdders)-1];    //maak ruseltaat gelyk aan laaste Adder

end;
//----------------------------------------------------------------------------

function BinaryPower(Bin1 , Bin2 : TBinary) : TBinary; //Mag Binere getalle
var
Bin3 : TBinary;
begin
Bin3 := Bin1; //maak kopie van bin1
while CheckifBinLarger(Bin2 , strtobin('1')) = 1 do  //kyk of steeds groter is
begin
 Bin3 := BinaryMultiply(Bin3,Bin1);             //maal getalle saam
 Bin2 := BinarySubtract(Bin2 , strtoBin('1'));  //minus een van teller af
end;
Result := Bin3;        //stel russeltaat
end;
//-------------------------------------------------------------------------
function StrOrdtoBinArr(sInput : string; BitsPerChar , BinaryLength : integer) : TBinary;  //ontleed string as Binere array met sekere lengte
var
icount : integer;
begin
Setlength(Result,0);//REset Rusletaat
 icount := 0;
while (length(Result) < BinaryLength) AND (icount < length(sInput)) do//Terwyl die lengtes te lank is loop
   begin
   JoinBinArr(Result , LengthenBinary(inttobin(ord(sInput[icount])),BitsPerChar,false));  //heg die karakter waarder geverleng na 8 bits aan die Rusetlaat
   Inc(icount);      //icount + 1
   end;

   while length(Result) < BinaryLength do     //terwyl te kort
   JoinBinArr(Result , Result);             //dupliseer

   Result := CopyBinArr(Result,0,BinaryLength) ;  //haal slegs sekere lengte uit

end;
//---------------------------------------------------------------

function RecoverKeysAndFeistelDecrypt(SInput : string; sRecipientKey : String) : string;  //Kry seleutel en dekript
var
ArrDividedStr : Array of String;
FeistelKeys : Array[0..FeistelRounds] of TBinary;
RecipientKey : TBinary;
icount , icount2 : integer;
sKeyStr : string;
TempBin : TBinary;
begin

 {for icount := 1 to length(SInput) do
  begin
   SInput[icount] := chr(ord(SInput[icount])-3) ;
  end;    }

 for icount := 1 to length(sInput) do
   if ord(SINput[icount]) > 255 then    //Kyk dat niks te groot is nie
   showmessage('icount : ' + inttostr(icount) + ' ord : ' + inttostr(ord(SInput[icount])));

RecipientKey := StrOrdtoBinArr(SRecipientKey,8,64);   //stel sleutel op

 for icount := 0 to high(FeistelKeys) do     //tell deur arrat
  begin
  sKeyStr := Copy(sInput,1,8);      //kopie 8 karakyer
  Delete(sInput,1,8);               //delte die 8 karakters
  for icount2 := 1 to length(sKeyStr) do
   begin
   TempBin := LengthenBinary(inttoBin(ord(sKeySTr[icount2])),8,false);  //maak binere array van 8 krakters
   JoinBinArr(FeistelKeys[icount] , TempBin);   //heg aan Sleutels array
   end;

  FeistelKeys[icount] := BinXOR(FeistelKeys[icount] ,RecipientKey) ; //XOR met die ontvanger sleutel
  end;

while sInput <> '' do
  begin
  Setlength(arrDividedStr,length(arrDividedstr)+1);  //maak lengte van array meer met 1
  ArrDividedStr[High(ArrDividedStr)] := Copy(sInput,1,16); //kopie 16 karakters in hom in
  Delete(sInput,1,16);      //delete die 16 karakters
  end;

    for icount := 0 to high(arrDividedStr)-1 do  //tel deur array maar los laate een uit
  begin
   arrDividedStr[icount] := Feistel(arrDividedStr[icount],false,FeistelKeys);  //FEitel enkript al 16 karakters
  end;

  if length(arrDividedStr[High(arrDividedStr)]) < 16 then//indien keliner as 16
   for icount2 := 0 to High(FeistelKeys) do      //tell deur sleutels array
   begin
     if length(FeistelKeys[icount2]) > length(arrDividedStr[high(arrDividedStr)])*4 then
      Setlength(FeistelKeys[icount2],length(arrDividedStr[high(arrDividedStr)])*4);      //pas van sleutel lengte aan
   end;

  arrDividedStr[High(arrDividedStr)] := Feistel(arrDividedStr[High(arrDividedStr)],false,FeistelKeys);//ENkript laaste index van die array

  sInput := '';
  for icount := 0 to High(arrDividedStr) do
  SInput := sInput + arrDividedStr[icount];  //tell die string array by mekaar


  Result := sInput;   //stell antwoord

end;
//----------------------------------------------------------------

function GenerateKeysAndFeistelEncrypt(SInput : string ; sRecipientKey : String) : String;  //ginereer sleutels en enkipt
var
icount , icount2 : integer;
FeistelKeys : Array[0..FeistelRounds] of TBinary;
ArrDividedStr : Array of String;
RecipientKey : TBinary;
sKeyStr : String;
begin
  if Odd(length(sInput)) then //kyk of lengte onewe is
  sInput := sInput + ' ';

  RecipientKey := StrOrdtoBinArr(SRecipientKey,8,64);  //stel ontvanger sleutel op

  while sInput <> '' do    //tel duer string
  begin
  Setlength(arrDividedStr,length(arrDividedstr)+1);   //maak string arry met 1 meer
  ArrDividedStr[High(ArrDividedStr)] := Copy(sInput,1,16);  //kopier 16 karaters in die arry is
  Delete(sInput,1,16);   //delete die 16 karakters
  end;


 for icount := 0 to high(FeistelKeys) do //tell deur Array
  begin
  FeistelKeys[icount] := RandomBinary(64); //stel random getal op vir Key
  for icount2 := 0 to 7 do
  begin
  skeyStr := sKeyStr + chr(Bintoint(CopyBinArr(FeistelKeys[icount],icount2*8,8)));//stel string op met sleutels
  end;

  FeistelKeys[icount] := BinXOR(FeistelKeys[icount] ,RecipientKey) ;  //XOR sleutels met Ontavnager sleutel

  end;

  for icount := 0 to high(arrDividedStr)-1 do    //tel deur string array
  begin
   arrDividedStr[icount] := Feistel(arrDividedStr[icount],true,FeistelKeys);  //enkript die string
  end;

  if length(arrDividedStr[High(arrDividedStr)]) < 16 then   //indien finale index kleiner as 16
   for icount2 := 0 to High(FeistelKeys) do        //tel duer array
   begin
     if length(FeistelKeys[icount2]) > length(arrDividedStr[high(arrDividedStr)])*4 then  //pas sleutesl aan
      Setlength(FeistelKeys[icount2],length(arrDividedStr[high(arrDividedStr)])*4) ;
   end;

  arrDividedStr[High(arrDividedStr)] := Feistel(arrDividedStr[High(arrDividedStr)],true,FeistelKeys);  //enkirpt laaste index

  sInput := '';
  for icount := 0 to High(arrDividedStr) do
  SInput := sInput + arrDividedStr[icount];   //heg string array saam in 1 strinh

  Result := skeyStr + sInput;   //maak finale uitset string uit sleutels + SInput

   { for icount := 1 to length(Result) do
  begin
    Result[icount] := chr(Ord(Result[icount]) + 3);
    if Ord(Result[icount]) < 3 then
    showmessage(inttostr(Ord(Result[icount]))) ;
  end;  }

  end;




//----------------------------------------------------------------
function Feistel(SInput : string ; bForward : boolean ; Keys : Array of TBinary) : String; //Feistel
const
ByteLength = 8;
var
Func : Array of TBinary;
Right : Array of TBinary;
Left : Array of TBinary;
TempBin : TBinary;
icount : Integer;
begin
Result := '';
if (odd(length(SInput))) AND bForward = true  then
showmessage('{Feistel} -> Sinput is Odd');

Setlength(Func,length(Keys));
Setlength(Left,length(Keys)+1);
Setlength(Right,length(Keys)+1);

for icount := 1 to length(SInput) DIV 2  do
begin
JoinBinArr(Left[0] , LengthenBinary(inttobin(ord(SInput[icount])),ByteLength,false));
JoinBinArr(Right[0] , LengthenBinary(inttobin(ord(SInput[icount + (length(SInput) DIV 2)])),ByteLength,false));
end;

if bForward = true then
begin

for icount := 0 to length(Keys)-1 do
  begin

    Func[icount] := BinXOR(Right[icount],Keys[icount]);
    Right[icount+1] := BinXOR(Func[icount] , Left[icount]);
    Left[icount+1] := Right[icount];

  end;

end
else
if bForward = false then
begin
   TempBin := Right[0];
   Right[0] := Left[0];
   Left[0] := TempBin;

for icount := 0 to length(Keys)-1 do
  begin

    Func[icount] := BinXOR(Right[icount],Keys[High(Keys)-icount]);
    Right[icount+1] := BinXOR(Func[icount] , Left[icount]);
    Left[icount+1] := Right[icount];

  end;

   TempBin := Right[High(Right)];
   Right[High(Right)] := Left[High(Left)];
   Left[High(Left)] := TempBin;

end;

JoinBinArr(Left[High(Left)] , Right[High(Right)]);
//Showmessage('Length: ' + inttostr(length(Left[High(Left)]))) ;
while length(Left[High(Left)]) > 0 do
  begin
    Result := Result + chr(BintoInt(CopyBinArr(Left[High(left)],0,ByteLength)));
    BinArrDelete(Left[High(Left)],0,ByteLength);
  end;

end;

// ---------------------------------------------------------------

function JHBEncrypt(SInput , SPassword : string): TBinary;
var
  ArrTEMP: Array [0 .. ASCIIVALUE] of integer;
  iPasswordOrdValue : integer;
  icount: integer;
  bRandom, bBitLength : byte;
  binOutput , BinEnd: TBinary;
begin


  iPasswordOrdValue := 0;
   // ascii values of Password characters added together
  for icount := 1 to length(SPassword) do
   iPasswordOrdValue := iPasswordOrdValue + ORD(SPassword[icount]);

  // populate Arrays
  for icount := 0 to length(ArrEncryptNumbers) do
  begin
    ArrEncryptNumbers[icount] := icount;
    ArrTEMP[icount] := icount;
  end;

  // Calculate minimum bit length needed to encrypt the text;
  bBitLength := (length(InttoBin(iPasswordOrdValue + ASCIIVALUE)));
  if (bBitLength < length(InttoBin(length(SInput) + 128 + ASCIIVALUE))) then
    bBitLength := length(InttoBin(length(SInput) + 128 + ASCIIVALUE));
    //showmessage('bBitLength : ' + inttostr(bBitlength));
  // Insert SBitllength into thew begining of soutput to be saved;
  JoinBinArr(binOutput , LengthenBinary(InttoBin(bBitLength), BITLENGTHVALUE_BITLENGTH,false));

  for icount := 1 to length(sInput) do
    if Ord(sInput[icount]) > 255 then
    begin
      //showmessage('message contains unsupported Charcters which will have to be removed : ' + sInput[icount]);
      sInput[icount] := chr(3);
    end;

  // Generate FeistelKeys   // Feistel Encypt SInput;
  sInput := GenerateKeysAndFeistelEncrypt(SInput,SPassword);
 // showmessage(inttostr(length(sInput)));
  //showmessage('Encrypt : ' + sInput[1] + ' : ' + inttostr(ord(sInput[1])) + ' "" ' + sInput[length(sInput)] + ' : ' + inttostr(ord(sInput[length(sInput)]))+ ' [' + inttostr(length(sinput)) + '] ');
  { for icount := 1 to length(sInput) do
     if ORd(sInput[icount]) < 3 then
      showmessage('{E icount: ' + inttostr(icount) + ' ord : ' + inttostr(ORd(sInput[icount]))) ;   }

  { for icount := 1 to length(sInput) do
    begin
      if ord(sInput[icount]) < 2 then
       showmessage('icount : ' + inttostr(icount) + ' char : ' + inttostr(ord(sInput[icount])));
    end;   }

  // Insert Final String end Character into Input string
  SInput := SInput + chr(0);
   // Insert Final String end Character into Password string
  sPassword := sPassword + chr(0);

  // Generate Key
  for icount := ASCIIVALUE downto 1 do
  begin
    Randomize();
    bRandom := RandomRange(icount,1);
    ArrEncryptNumbers[icount] := ArrTEMP[bRandom];
    ArrTEMP[bRandom] := ArrTEMP[icount];

    if (length(InttoBin(ArrEncryptNumbers[icount] + iPasswordOrdValue)) > bBitLength) then
    showmessage(inttostr(ArrEncryptNumbers[icount] + iPasswordOrdValue));
    JoinBinArr(BinOutput , LengthenBinary(InttoBin(ArrEncryptNumbers[icount]+ iPasswordOrdValue), bBitLength,false));
  end;

  //showmessage(bintostr(BinEnd));
  //Encrypt sPassword en SInput met eie array method
  JoinBinArr(binOutput , ArrEncryptString(sPassword,bBitlength));

  JoinBinArr(binOutput , ArrEncryptString(sInput,bBitlength));


  Setlength(BinEnd,1);
  Binend[0] := true;
  BinEnd := LengthenBinary(BinEnd,bBitlength,true);
  //showmessage(bintostr(BinEnd));
  JoinBinArr(binOutput , BinEnd);

  //showmessage(inttostr(bintoint(LengthenBinaryString(InttoBin(ArrEncryptNumbers[3]), bBitLength))));

  Result := binOutput;

end;

// --------------------------------------------------------------

function JHBDecrypt(sBMPFilepath: string): string;
var
  icount, iPasswordOrdValue: integer;
  sOutput , sPassword : string;
  bBitLength: byte;
  binByte , BinInput , binKey , BinEnd : TBinary;
  bSearching : boolean;

begin



  if uJHB_DB.JHBdataModule.DB_usrtbl.Locate('UserName' , sUserName , []) then
  sPassword := uJHB_DB.JHBdataModule.DB_usrtbl['UserUniqueCode'];

  iCurrentPosInBMP := 0;
  iPasswordOrdValue := 0;
   // ascii values of Password characters added together
  for icount := 1 to length(SPassword) do
    iPasswordOrdValue := iPasswordOrdValue + ORD(SPassword[icount]);
  // cut out comment
  { icommentendpos := pos('0' , sencryptedtext);
    Delete(sEncryptedtext , 1 , iCommentENdPos); }

    try
    BitMap := TBitmap.create;

    if (sBMPFilepath = '') then
    begin
      Result := 'no file was chosen';
      exit;
    end;
    BitMap.LoadFromFile(sBMPFilepath);
    bBitLength := BinToInt(RetriveBinFromBMP(BitMap, 0,BITLENGTHVALUE_BITLENGTH));
    iCurrentPosInBMP := BITLENGTHVALUE_BITLENGTH;

    Setlength(BinEnd,1);
    Binend[0] := true;
    BinEnd := LengthenBinary(BinEnd,bBitlength,true);


   // showmessage(inttostr(bintoint(sBMPFinalChar)));
    //Extract String form BitMap !!!
    bSearching := true;
    while bSearching = true do
    begin

       binByte := RetriveBinFromBMP(BitMap, iCurrentPosInBMP, bBitLength);
       iCurrentPosInBMP := iCurrentPosInBMP + bBitLength;

       if bintoint(BinByte) = bintoint(BinEnd) then
        begin
            bSearching := false;
          end
        else
        JoinBinArr(BinInput , BinByte);

    end;
    finally
      FreeAndNil(Bitmap);
    end;

   // Get key from text and remove unneccesary bits
   binKey := CopyBinArr(BinInput, 0, (ASCIIVALUE) * bBitLength);
   BinArrDelete(BinInput , 0, (ASCIIVALUE) * bBitLength);

  // assign ArrEncryptNumbers[icount] to the key values   USING sKEY
   try
  for icount := ASCIIVALUE downto 1 do
  begin

    ArrEncryptNumbers[icount] := BinToInt(CopyBinArr(binKey, 0, bBitLength)) - iPasswordOrdValue;
    //Showmessage(inttostr(icount) + ' ' +  Bintostr(ArrEncryptNumbers[icount]));
    if (ArrEncryptNumbers[icount] < 0) OR (ArrEncryptNumbers[icount] > ASCIIVALUE) then
    begin
      Result := MARKINGSTRING + 'You are not the intended recipient of this message';
      exit;
    end;
    // showmessage(inttostr(BinToInt(COpy(skey,1,bBITLENGTH)) - ipasswordORDvalue));
    BinArrDelete(BinKey, 0, bBitLength);
  end;
  except
  Result := (MARKINGSTRING + 'Something went wrong ! , Image Data may be corrupted Or there is no Data in the image');
  exit;
  end;
       //showmessage(inttostr(length(BinInput) DIV bBitlength))  ;
  //showmessage('Sinput length : ' + inttostr(length(sInput)) + ' / ' + inttostr(bBitlength) + ' = ' + inttostr(length(sInput) DIV bBitlength));
  sOUtput := ArrDecryptString(bBitlength , BinInput);
    // showmessage(inttostr(length(sOutput)))  ;

  // Check if entered password matches encrypted password
  if (copy(sOutput,1,Pos(chr(0),sOutput)-1) <> SPassword) then
  begin
    Result := MARKINGSTRING + 'You are not the intended recipient of this message';
    exit;
  end;
  Delete(sOutput,1,Pos(chr(0),sOutput));
  Delete(sOutput,length(sOutput),1);
 { for icount := 1 to length(sOutput) do
  if ord(sOutput[icount]) < 2 then
  showmessage(inttostr(ord(sOutput[icount]))) ;   }
   //showmessage(inttostr(length(sOutput)));

   {   for icount := 1 to length(sOutput) do
     if ORd(sOutput[icount]) < 3 then
      showmessage('{D icount: ' + inttostr(icount) + ' ord : ' + inttostr(ORd(sOutput[icount]))) ; }
  //showmessage('DeCrypt : ' + sOutput[1] + ' : ' + inttostr(ord(sOutput[1])) + ' "" ' + sOutput[length(sOutput)] + ' : ' + inttostr(ord(sOutput[length(sOutput)])) + ' [' + inttostr(length(sOutput)) + '] ');
  sOutput := RecoverKeysAndFeistelDecrypt(sOutput,sPassword);


  Result := sOutput;


end;





function ArrEncryptString(sInput : String ; bBitlength : byte): TBinary;
var
icount , icount2 : integer;
begin

   for icount := 1 to length(SInput) do
  begin

    for icount2 := 0 to ASCIIVALUE do
    begin
      if chr(icount2) = (Copy(SInput, 1, 1)) then
      begin
        JoinBinARR(Result , LengthenBinary(InttoBin(ArrEncryptNumbers[icount2] + length(sInput)),bBitlength,false));//Insert(LengthenBinaryString(STRInttoBin(ArrEncryptNumbers[icount2] + length(SInput)), bBitLength), Result, length(Result) + 1); // Inserting Numbers and Converting them to CharBin in to sEncryptedText
      end;
    end;
    Delete(SInput, 1, 1);
  end;
end;




function ArrDecryptString(bBitlength : byte ; binInput : TBinary) : String;
var
bSearching : boolean;
icount2  : integer;
binSnippet : TBinary;
begin

Result := '';

while length(BinInput) > 0 do
begin
 bSearching := true;

  while bSearching = true do
   begin
     if (ArrEncryptNumbers[0] = BinToInt(CopyBinArr(BinInput,0,bBitlength)) -1 ) then
     begin
       bSearching := false;
     end;
     JoinBinArr(BinSnippet , CopyBinArr(BinInput,0,bBitlength));
     BinArrDelete(BinInput, 0, bBitLength);
   end;

    while length(binSnippet) > 0 do
    begin
      for icount2 := 0 to ASCIIVALUE do
       begin

        if ArrEncryptNumbers[icount2] = BinToInt(CopyBinArr(BinSnippet, 0, bBitLength)) - (length(BinSnippet) DIV bBitLength) then
         begin
          Result := Result + chr(icount2);
          break;
         end;
       end;

       BinArrDelete(BinSnippet, 0, bBitLength);
    end;
end;
end;









function GetSeperatedValues(sInput , sSeperator : string) :  TArrayofString;
begin
sInput := SInput + sSeperator;
while sInput <> '' do
begin
 if Trim(Copy(sInput,1,Pos(sSeperator,sInput)-1)) <> '' then
  begin
   Setlength(Result , length(Result)+1);
   Result[length(Result)-1] := Trim(Copy(sInput,1,Pos(sSeperator,SInput)-1));
   end;
  Delete(sInput,1,Pos(sSeperator,sInput)) ;
end;
end;









function RetriveBinFromBMP(BitMap: TBitmap; StartPoint, StringLength: integer): TBinary;
var
  icount, x, y: integer;
begin
  Setlength(Result,0);
  x := trunc(StartPoint / BitMap.Height);
  y := round(frac(StartPoint / BitMap.Height) * BitMap.Height) - 1;
  // showmessage(' x : ' + inttostr(x) + ' y : ' + inttostr(y));

  for icount := 1 to StringLength do
  begin

    inc(y);
    if (y >= BitMap.Height) then
    begin
      y := 0;
      inc(x);
    end;

    if ODD(BitMap.Canvas.Pixels[x, y]) then
    JoinBinArr(Result , strtobin('1'))
    else
    JoinBinArr(Result , strtobin('0'));

  end;

end;

procedure HideBinaryStringInBitMap(BintoHide: TBinary; const BMPFileName: string);
var
  BitMap: TBitmap;
  x, y, iStr: integer;
  PixColorBin : TBinary;
begin
  BitMap := TBitmap.create;
  try

    if (BMPFileName = '') then
    begin
      showmessage('there is no file selected');
      exit;
    end;

    BitMap.LoadFromFile(BMPFileName);

    x := 0;
    y := -1;

    if ((BitMap.Height) * (BitMap.Width) < length(BinToHide)+1) then
    begin
      showmessage('This Image is to small to hold all the Data. Please choose a larger image');
      exit;
    end;

    for iStr := 0 to length(BinToHide)-1 do
    begin

      {if NOT(CharinSet(BinToHide[iStr], ['1', '0'])) then
      begin
        showmessage(
          'the String you are Trying to hide is not binary. Please Encrypt again and retry');
        exit;
      end;  }

      inc(y);
      if y >= BitMap.Height then
      begin
        y := 0;
        inc(x);
      end;

      case BitMap.PixelFormat of
        pf1bit : begin
                 if BinToHide[iStr] = false then
                 BitMap.Canvas.Pixels[x, y] := 0
                 else
                 if BinToHide[iStr] = true then
                 BitMap.Canvas.Pixels[x, y] := 16777215;
                 end;

        pf4bit : begin
                 BitMap.PixelFormat := pf24bit ;
                 HideBinaryStringInBitMap(BintoHide,BMPFileName) ;
                 end;

        pf8bit : begin
                 BitMap.PixelFormat := pf24bit ;
                 HideBinaryStringInBitMap(BintoHide,BMPFileName);
                 end;

        pf15bit : begin
                  BitMap.PixelFormat := pf24bit ;
                  HideBinaryStringInBitMap(BintoHide,BMPFileName);
                  end;

        pf16bit : begin
                  BitMap.PixelFormat := pf24bit ;
                  HideBinaryStringInBitMap(BintoHide,BMPFileName);
                  end;

        pf24bit , pf32bit : begin
                            PixColorBin := InttoBin(BitMap.Canvas.Pixels[x, y]);
                            PixColorBin := StrtoBin(inttostr(ABS(strtoint(Booltostr(BinToHide[istr])))) + Copy(BintoStr(Pixcolorbin),2,length(PixcolorBin)+1));
                            BitMap.Canvas.Pixels[x, y] := BinToInt(PixColorBin);
                            end ;
      end;
    end;

    sNewFilename := BMPFileName;
    while Pos('\',sNewFilename) > 0 do
    Delete(sNewFileName,1,Pos('\',sNewFileName));

    sNewFileName := 'C:\uJHBENcryptAndDecryptEncryptedImage\' + sNEwFileName;
    ForceDirectories('C:\uJHBENcryptAndDecryptEncryptedImage\');
    BitMap.SaveTofile(sNewFilename);

  finally
    BitMap.Free;
  end;
end;

function JHBWIndowsOpenDialog(Title, Filter: string): string;
var
  opendialog: topendialog;
begin
  opendialog := topendialog.create(nil);
  opendialog.Title := Title;
  opendialog.Filter := Filter;
  opendialog.InitialDir := GetCurrentDir;
  opendialog.Options := [ofFileMustExist];
  if opendialog.Execute then
    Result := opendialog.FileName;
  opendialog.Free;

end;

procedure CreateBitMap(Width, Height: integer; Color: TColor; const FileName: string);
var
  BitMap: TBitmap;
begin
  BitMap := TBitmap.create;
  try

    BitMap.PixelFormat := pf32bit;
    BitMap.Width := Width;
    BitMap.Height := Height;
    BitMap.Canvas.Brush.Color := Color;
    BitMap.Canvas.FillRect(Rect(0, 0, Width, Height));
    BitMap.SaveTofile(FileName);

  finally
    BitMap.Free;
  end;
end;

procedure CreateInputFormEncryption();
var
  FormEI: Tform;
begin
  FormEI := frmEncryptInput.create(nil);
  FormEI.Showmodal;
end;






Function SelectRecipientsFromDB(var arrUsers : TArrayofString) : boolean;
const
mrUpdate = 30;
var
Form : TForm;
cb : Array of TCheckBox;
btn : Array[0..2] of TButton;
rgb : TRadioGroup;
lblHeading : Tlabel;
ScrollBox : TScrollBox;
iFormModal , icount : integer;
bFormOpen : boolean;
sField : string;
begin
Result := false;
 try

 Form := TForm.Create(application);
 with Form do
  begin
    Canvas.Font := Font;
    Caption := 'Select Recipients';
    BorderStyle := bsDialog;
    color := clmedgray;
    PopupMode := pmAuto;
    Position := poScreenCenter;
    Width := 550;
    Height := 324;
  end;

  lblHeading := TLabel.Create(Form);
  with lblHeading do
  begin
   Parent := Form;
   name := 'lblHeading';
   Caption := 'Select the Recipients of this message :';
   //Color := clMedGray;
   Font.Name := 'Tahoma';
   Font.Style := [fsBold , fsUnderline];
   Font.Size := 20;
   Visible := true;
   Enabled := true;
   Height := 39;
   Left := 8;
   Top := 0;
   if Width > FOrm.Width - 25 then
   Height := Height * Ceil(width / Form.Width - 25);
   Width := Form.Width - 25;
   WordWrap := true;
  end;

  rgb := TRadioGroup.Create(Form);
  with rgb do
  begin
   Parent := Form;
   Name := 'rgbSelect';
   Caption := 'Selection Filter';
   Items.Add('Name');
   Items.Add('Email-Adress');
   ItemIndex := 0;
   sField := 'UserName';
   Width := 97;
   Top := lblHeading.Top + lblHEading.Height + 5;
   HEight := 42;
   LEft := 13;

  end;

    ScrollBox := TScrollBox.Create(Form);
  with ScrollBox do
  begin
   Parent := Form;
   Name := 'ScrollBox';
   Left := (rgb.Left + rgb.Width + 5);
   Width := FOrm.Width - (rgb.Left + rgb.Width + 20) ;
   Top := lblHeading.Top + lblHEading.Height + 5;
   Height := (FOrm.Height) - (lblHeading.Top + lblHEading.Height + 80);
  end;

  btn[0] := TButton.Create(Form);
  with btn[0] do
  begin
   Parent := Form;
   Name := 'btnCancel';
   Caption := 'Cancel';
   Top := ScrollBox.Top + ScrollBox.Height + 10;
   Width := 75;
   Height := 25;
   LEft := 194;
   ModalResult := mrcancel;
  end;

  btn[1] := TButton.Create(Form);
  with btn[1] do
  begin
   Parent := Form;
   Name := 'btnContinue';
   Caption := 'Continue';
   Top := ScrollBox.Top + ScrollBox.Height + 10;
   Width := 75;
   Height := 25;
   LEft := 304;
   ModalResult := mrok;
  end;

  btn[2] := TButton.Create(Form);
  with btn[2] do
  begin
   Parent := Form;
   Name := 'btnUpdate';
   Caption := 'Update';
   Top := rgb.Top + rgb.Height;
   Width := rgb.Width;
   Height := 25;
   LEft := rgb.left;
   ModalResult := mrUpdate;
  end;



   uJHB_DB.JHBdataModule.DB_usrtbl.First;
    while NOT(uJHB_DB.JHBdataModule.DB_usrtbl.Eof) do
     begin

      Setlength(cb , length(cb)+1);
      cb[length(cb)-1] := TCheckBox.Create(Form);

      with cb[length(cb)-1] do
      begin
        Parent := ScrollBox;
        Name := 'cb' + inttostr(length(cb)-1);
        Caption := uJHB_DB.JHBdataModule.DB_usrtbl['UserName'];
        Font.Size := 10;
        Width := (Length(Caption)*8)+16;
        if length(cb) > 1 then
        Top := cb[length(cb)-2].HEight + cb[length(cb)-2].Top;
      end;

      uJHB_DB.JHBdataModule.DB_usrtbl.Next;
     end;



  bFormOpen := true;
  while bFormOpen = true do
  begin

   iFormModal := Form.ShowMOdal;

   if iFormModal = mrCancel then
   begin
     Result := false;
     bFormOpen := false;
   end;

   if iFormModal = mrUpdate then
   begin
    case rgb.ItemIndex of
    0 : sField := 'UserName';
    1 : sField := 'UserEmail';
    end;
    icount := -1;
    uJHB_DB.JHBdataModule.DB_usrtbl.First;
    while NOT(uJHB_DB.JHBdataModule.DB_usrtbl.Eof) do
     begin
        INC(icount);
        cb[icount].Caption := uJHB_DB.JHBdataModule.DB_usrtbl[sField];
        cb[icount].Width := (Length(cb[icount].Caption)*8)+16;
        uJHB_DB.JHBdataModule.DB_usrtbl.Next;
     end;
   end;



    if iFormModal = mrok then
   begin

     Result := true;
     bFormOpen := false;
     Setlength(arrUsers,0);
     for icount := 0 to length(cb)-1 do
       begin
        if cb[icount].Checked = true then
         begin
         if (uJHB_DB.JHBdataModule.DB_usrtbl.Locate(sField , cb[icount].Caption , []) = true) then
           begin
           Setlength(arrUsers,length(arrUsers)+1);
           ArrUsers[length(arrUsers)-1] := uJHB_DB.JHBdataModule.DB_usrtbl['UserUniqueCode'] + chr(0) + uJHB_DB.JHBdataModule.DB_usrtbl['UserEmail'] + chr(0)
            + uJHB_DB.JHBdataModule.DB_usrtbl['UserName'];
           end
           else
           begin
             showmessage('This user does not exist in the database : ' + cb[icount].Caption)
           end;


         end;

       end;

   end;



  end;



 finally
  FreeAndNil(Form);
 end;

end;





Function JHBInputQuery(const sCaption , sHeading , sDiscription : string ; var sVar : string) : boolean; overload;
var
Form : TForm;
lblHeading : Tlabel;
lblDescription : TLabel;
RedtVar : TRichEdit;
btn : Array[0..2] of TButton;
TF : TextFile;
sPath , sLine : string;
iFormModal : integer;
bFormOpen : boolean;
begin
 Result := false;

 try
 Form := TForm.Create(application);
 with Form do
  begin
    Canvas.Font := Font;
    Caption := sCaption;
    BorderStyle := bsDialog;
    color := clmedgray;
    PopupMode := pmAuto;
    Position := poScreenCenter;
    Width := 638;
    Height := 324;
  end;

 lblHeading := TLabel.Create(Form);
 with lblHeading do
 begin
  Parent := Form;
  name := 'lblHeading';
  Caption := sHeading;
  //Color := clMedGray;
  Font.Name := 'Tahoma';
  Font.Style := [fsBold , fsUnderline];
  Font.Size := 24;
  Visible := true;
  Enabled := true;
  Height := 39;
  Left := 8;
  Top := -5;
  if Width > FOrm.Width - 25 then
  Height := Height * Ceil(width / Form.Width - 25);
  Width := Form.Width - 25;
  WordWrap := true;
 end;

 lblDescription := TLabel.Create(Form);
 with lblDescription do
 begin
  Parent := Form;
  name := 'lblDescription';
  Caption := sDiscription;
  Font.name :=   'Tahoma' ;
  Font.Size :=  12 ;
  Visible :=   true ;
  Enabled :=  true ;
  Height := 23;
  left :=   8;
  Top :=  lblHeading.Top + lblHeading.Height ;
  if Width > FOrm.Width - 25 then
  Height := Height * Ceil(width / Form.Width - 25);
  Width := Form.Width - 25;
  WordWrap := true;
 end;

 RedtVar := TRichedit.Create(Form);
 with RedtVar do
 begin
   Parent := Form;
   name := 'RedtVar';
   Lines.clear;
   Lines[0] := (sVar);
   Top := lblDescription.Top + lblDescription.Height + 21;
   left := 8;
   Height := 160;
   Width := Form.Width - 25;
 end;


    btn[0] := tButton.Create(Form);
 with btn[0] do
 begin
   parent := Form;
   Name := 'BtnReadFromTF';
   Caption := 'Get From TextFile';
   Width :=  109;
   Height := 20;
   Top :=  lblDescription.Top + lblDescription.Height;
   Left := 8;
   btn[0].ModalResult := 99;

 end;

 btn[1] := tButton.Create(Form);
 with btn[1] do
 begin
   parent := Form;
   Name := 'BtnContinue';
   ModalResult := mrOk;
   Caption := 'Continue';
   HEight :=  25;
   Width :=   75;
   Top :=  RedtVar.Height + RedtVar.Top + 9;
   Left :=  (Form.Width DIV 2);
 end;

 btn[2] := tButton.Create(Form);
 with btn[2] do
 begin
   parent := Form;
   Name := 'BtnCancel';
   ModalResult := mrCancel;
   Caption := 'Cancel';
   HEight :=  25;
   Width := 75;
   Top :=   RedtVar.Height + RedtVar.Top + 9;
   Left :=  (Form.Width DIV 2)- (width) ;
 end;

 Form.Height := Btn[2].Height + btn[2].Top + 35;
 bFormOpen := true;
 while bFormOpen = true do
 begin
 iFormModal := Form.ShowModal;

 if iFormModal = mrCancel then
  begin
    Result := false;
    bFormOpen := false;

  end;

    if iFormModal = mrok then
 begin
   Result := true;
   sVar := RedtVar.Text;
   bFormOpen := false;
 end;

  if iFormModal = 99 then
 begin

 while sPath = '' do
 begin
 sPath := JHBWindowsOpenDialog('Select Text File','Text files only|*.txt;*.rtf;');
 if sPath = '' then
 if messageDLG('You did not select a text file , are you sure you want to continue' , mtWarning , [mbYes , mbNo] , 0) = mrYes then
 begin
 JHBInputQuery(sCaption , sHeading ,sDiscription , sVar);
 Exit;
 end;
 end;
 RedtVar.Clear;
 AssignFile(TF , sPath);
 Reset(TF);
   while not EOF(TF) do
   begin
     Readln(TF , sLine);
     RedtVar.Lines.add(sLine);
   end;
  CloseFile(TF);

 end;
 end;

 finally
  FreeAndNil(Form);
 end;


end;


procedure WriteToDebugtf(Sinput : string);
var
TF : TextFile;
begin
AssignFile(tf,'C:\Users\jhbri\OneDrive\Desktop\tf.txt');
if Not FileExists('C:\Users\jhbri\OneDrive\Desktop\tf.txt') then
Rewrite(tf);

Append(tf);
Writeln(tf,SInput);
closeFile(tf);
end;


function GetThisUnitName: string;
begin
  try
    assert(false, '#');
  except
    on Exception: EAssertionFailed do
      Result := Copy(Exception.Message, 4, length(Exception.Message) - 14);
    // Dirty solution
  end;
end;

Initialization

sThisUnitDir := GetThisUnitName;

end.
