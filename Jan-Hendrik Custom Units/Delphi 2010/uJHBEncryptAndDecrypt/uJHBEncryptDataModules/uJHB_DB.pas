unit uJHB_DB;

interface

uses
  SysUtils, Classes , ADODB , DB, uJHBEncryptAndDecrypt;
 const
 //String wat gebruik word om aan die databasis te koppel
 CONNECTIONSTRING = 'Provider=Microsoft.Jet.OLEDB.4.0;Data Source=.\Jan-Hendrik Custom Units\Delphi 2010\uJHBEncryptAndDecrypt\uJHBEncryptDataModules\JHBEncryptDecryptDatabase.mdb; Mode=ReadWrite; Persist Security Info=False';
type
  TJHBdataModule = class(TDataModule)
    procedure OnDBCreate(Sender: TObject);
  private
    { Private declarations }
  public
   DB_con : TADOConnection; //TObject vir die ADO koneksie
   DB_usrtbl : TADOTable;   //TObject vir die ADO Tabel van gebruikers
   DB_MsgLogstbl : TADOTable; //TObject vir die ADO Tablel van die boodskap logs

  end;

var
  JHBdataModule: TJHBdataModule;

implementation

{$R *.dfm}

procedure TJHBdataModule.OnDBCreate(Sender: TObject);
begin
DB_con := TADOConnection.Create(JHBdatamodule);  //Stel konneksie op
DB_usrtbl := TADOTable.Create(JHBdatamodule);    //konnekteer tabel
DB_MsgLogstbl := TADOTable.Create(JHBdatamodule);//konnekteer boodskap lyste

DB_con.ConnectionString := CONNECTIONSTRING; //konnekteer die konnksie
DB_con.LoginPrompt := false;      //stel die login prompt af
DB_con.Open; //maak die konneksie oop

DB_usrtbl.Connection := DB_con;   //konekteer Die gebruikers tabel komponent aan die databasis
DB_usrTbl.TableName := 'UsersTable'; //Konnekteer gebruikers tabel kompoment aan gebruikers tabel in databasis
DB_usrTbl.Open;  //maak die gebruikers tabel oop

DB_MsgLogstbl.Connection := DB_con;  //Konnekteer die Boodskaplyste tabel komponent aan die databasis
DB_MsgLogstbl.TableName := 'MsgLogsTable';  //Konnekteer die Boodskaplyste tabel komponent aan boodskap lyste tabel in databasis
DB_MsgLogstbl.Open;   //maak die  boodskap lyste tabel oop


end;

end.

