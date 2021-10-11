unit About;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Buttons, StdCtrls, ShellApi;

type
  TAboutForm = class(TForm)
    CancelBtn: TSpeedButton;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    procedure CancelBtnClick(Sender: TObject);
    procedure Label5Click(Sender: TObject);
  private
  public
  end;

var
  AboutForm: TAboutForm;

implementation

{$R *.dfm}

procedure TAboutForm.CancelBtnClick(Sender: TObject);
begin
 Close;
end;

procedure TAboutForm.Label5Click(Sender: TObject);
begin
 ShellExecute(Handle,'open','mailto:im_fry@mail.ru','','',0);
end;

end.
