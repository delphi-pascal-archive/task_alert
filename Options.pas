unit Options;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Buttons, StdCtrls, Registry;

type
  TOptionsForm = class(TForm)
    OKBtn: TSpeedButton;
    SpeedButton1: TSpeedButton;
    AutoStartCB: TCheckBox;
    procedure SpeedButton1Click(Sender: TObject);
    procedure OKBtnClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
  public
    procedure LoadSettings;
    procedure ApplySettings;
  end;

var
  OptionsForm: TOptionsForm;

implementation

{$R *.dfm}

{ TOptionsForm }

procedure TOptionsForm.ApplySettings;
var R: TRegistry;
begin
  R := TRegistry.Create;
  try
    R.RootKey := HKEY_CURRENT_USER;
    If R.OpenKey('\Software\Microsoft\Windows\CurrentVersion\Run', True) Then Begin
      If AutoStartCB.Checked
        Then R.WriteString('TaskAlert',ParamStr(0))
        Else R.DeleteValue('TaskAlert');
      R.CloseKey;
    End;
  finally
    R.Free;
  end;
end;

procedure TOptionsForm.LoadSettings;
var
 R: TRegistry;
begin
  R := TRegistry.Create;
  try
    R.RootKey := HKEY_CURRENT_USER;
    If R.OpenKey('\Software\Microsoft\Windows\CurrentVersion\Run', True) Then Begin
      AutoStartCB.Checked := AnsiLowerCase(R.ReadString('TaskAlert')) = AnsiLowerCase(ParamStr(0));
      R.CloseKey;
    End;
  finally
    R.Free;
  end;
end;

procedure TOptionsForm.SpeedButton1Click(Sender: TObject);
begin
  Close;
end;

procedure TOptionsForm.OKBtnClick(Sender: TObject);
begin
 ApplySettings;
end;

procedure TOptionsForm.FormShow(Sender: TObject);
begin
 LoadSettings;
end;

end.
