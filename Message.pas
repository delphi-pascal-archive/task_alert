unit Message;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons;

type
  TMessageForm = class(TForm)
    BitBtn1: TBitBtn;
    Memo1: TMemo;
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure BitBtn1Click(Sender: TObject);
  private
  public
  end;

var
  MessageForm: TMessageForm;

implementation

{$R *.dfm}

procedure TMessageForm.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if key=27 then Close;
end;

procedure TMessageForm.BitBtn1Click(Sender: TObject);
begin
  Close;
end;

end.
