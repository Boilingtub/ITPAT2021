unit uITPAT;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs , Buttons, StdCtrls , uJHBEncryptAndDecrypt , math , uJHB_DB ,  uJHBEncryptInputForm;

type
  TForm1 = class(TForm)
    Label1: TLabel;
    Button1: TButton;
    BitBtn1: TBitBtn;
    Button2: TButton;
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

procedure TForm1.Button1Click(Sender: TObject);
begin
 CreateInputFormEncryption();   //Open die Hoof Program
end;

end.






