unit mainform;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, sqlite3conn, sqldb, db, FileUtil, Forms, Controls,
  Graphics, Dialogs, ExtCtrls, StdCtrls, Menus, DbCtrls;

type

  { Tmainfrm }

  Tmainfrm = class(TForm)
    btn_carilema: TButton;
    edt_lema: TEdit;
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    GroupBox3: TGroupBox;
    list_memuat: TListBox;
    MainMenu1: TMainMenu;
    MenuItem1: TMenuItem;
    MenuItem2: TMenuItem;
    sqlite3con: TSQLite3Connection;
    Query: TSQLQuery;
    SQLTransaction1: TSQLTransaction;
    text_lema: TMemo;
    procedure btn_carilemaClick(Sender: TObject);
    procedure edt_lemaKeyPress(Sender: TObject; var Key: char);
    procedure FormCreate(Sender: TObject);
    procedure list_memuatClick(Sender: TObject);

    procedure MenuItem2Click(Sender: TObject);

  private
    { private declarations }
    procedure CariKata(lema:string);
  public
    { public declarations }
  end;

var
  mainfrm: Tmainfrm;

implementation

{$R *.lfm}

{ Tmainfrm }

function BaseDir(path:string=''): string;
var var_basedir:string;
begin
  if (path = '') then
     Result := ExtractFilePath(Application.ExeName)
  else
    begin
      var_basedir := ExtractFilePath(Application.ExeName);
      Result := var_basedir + path;
    end;
end;

procedure Tmainfrm.CariKata(lema:string);
begin

  if not (lema = '') then
  begin
    Query.Close;
    Query.SQL.Text:='select * from kbbi where key like "' + lema + '%"';

    Query.Open;
    Query.First;

    // Tampilkan arti dari lema pertama
    text_lema.Text := Query.Fields[1].Value;

    // Cek jika lema yang memuat kata-kata lainnya
    // Pertama-tama bersihkan dulu list
    list_memuat.Items.Clear;

    // Lalu kemudian cari
    while not Query.EOF do
    begin
      list_memuat.Items.Add( Query.FieldByName('key').AsString);
      Query.Next;
    end;

    // Jika ada kata yg memuat maka set itemselection pada index awal
    if list_memuat.Count > 0 then
      list_memuat.ItemIndex:=0;
  end;
end;



procedure Tmainfrm.FormCreate(Sender: TObject);
 var dbKBBI:boolean;
begin
  // Cek keberadaan database
  dbKBBI:=FileExists(BaseDir('db/kbbi.sqlite'));

  // Jika database tidak ada maka aplikasi otomatis dihentikan
  if not dbKBBI then
     begin
       ShowMessage('Galat Database tidak ada.');
       Application.Terminate;
     end;

  // Koneksikan ke database
  try
    sqlite3con.DatabaseName:=BaseDir('db/kbbi.sqlite');
    SQLTransaction1.Active:=true;
  except
    ShowMessage('Galat, tidak bisa menyambukan dengan database, kemungkinan database rusak');
  end;
end;

procedure Tmainfrm.list_memuatClick(Sender: TObject);
 var
   kata:string;
 begin
   if list_memuat.Count > 0 then
   begin
     kata := list_memuat.Items[list_memuat.ItemIndex];
     edt_lema.Text := kata;
     CariKata(kata);
   end;
end;

procedure Tmainfrm.MenuItem2Click(Sender: TObject);
 var
   str:String;
 begin

   str := 'KBBI Offline ' + sLineBreak + 'dibangun dengan Lazarus' +
          sLineBreak + sLineBreak + 'oleh Ali' + sLineBreak +
          'Surel: admin@situsali.com';
   ShowMessage(str);
end;

procedure Tmainfrm.btn_carilemaClick(Sender: TObject);
begin
  CariKata(edt_lema.Text);
end;

procedure Tmainfrm.edt_lemaKeyPress(Sender: TObject; var Key: char);
begin
  if ord(Key) = 13 then
   begin
     Key := #0; // prevent beeping
     CariKata(edt_lema.Text);
   end;
end;

end.

