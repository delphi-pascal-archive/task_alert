unit Task;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Mask, ComCtrls, Buttons, ExtCtrls;

type
  TTaskForm = class(TForm)
    TaskNumL: TLabel;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    NameE: TEdit;
    DescriptionM: TMemo;
    DateEndDTP: TDateTimePicker;
    TimeEndME: TMaskEdit;
    GroupBox1: TGroupBox;
    AlertCB: TCheckBox;
    AlertPCB: TCheckBox;
    Label5: TLabel;
    IntervalCB: TComboBox;
    GroupBox2: TGroupBox;
    CheckBox1: TCheckBox;
    RadioButton1: TRadioButton;
    RadioButton2: TRadioButton;
    Label6: TLabel;
    DateBeginDTP: TDateTimePicker;
    Label7: TLabel;
    TimeBeginME: TMaskEdit;
    OKBtn: TSpeedButton;
    CancelBtn: TSpeedButton;
    MaskEdit1: TMaskEdit;
    Timer1: TTimer;
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure CancelBtnClick(Sender: TObject);
    procedure OKBtnClick(Sender: TObject);
    procedure AlertCBClick(Sender: TObject);
    procedure CheckBox1Click(Sender: TObject);
    procedure IntervalCBChange(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
  private
  public
    procedure Clear;
    function NewTask: Boolean;
    function EditTask(ID: Integer): Boolean;
    function AntiComa(S: string): string;
    function TimeToSecond(S: string): Integer;
  end;

var
  TaskForm: TTaskForm;

implementation

uses Main, DateUtils, DB;

{$R *.dfm}

{ TTaskForm }

function TTaskForm.EditTask(ID: Integer): Boolean;
var
 A, AA, AT, ATO, R, Alerted: string;
 tmp: Integer;
begin
  Clear;
  Timer1.Enabled := false;
  with MainForm do begin
    ADOQuery1.SQL.Text := 'select * from Tasks where id=' + IntToStr(ID);
    ADOQuery1.Open;
    TaskNumL.Caption := 'Задание № ' + ADOQuery1.FieldByName('ID').AsString;
    NameE.Text := ADOQuery1.FieldByName('Name').AsString;
    DateBeginDTP.Date := Int(ADOQuery1.FieldByName('DateBegin').AsDateTime);
    TimeBeginME.Text := TimeToStr(ADOQuery1.FieldByName('DateBegin').AsDateTime);
    DescriptionM.Lines.Text := ADOQuery1.FieldByName('Description').AsString;
    DateEndDTP.Date := Int(ADOQuery1.FieldByName('DateEnd').AsDateTime);
    TimeEndME.Text := TimeToStr(ADOQuery1.FieldByName('DateEnd').AsDateTime);
    AlertCB.Checked := ADOQuery1.FieldByName('Alert').AsInteger = 1;
    AlertPCB.Checked := ADOQuery1.FieldByName('AlertAfter').AsInteger = 1;
    IntervalCB.ItemIndex := ADOQuery1.FieldByName('AlertType').AsInteger;
    tmp := ADOQuery1.FieldByName('AlertTimeout').AsInteger;
    MaskEdit1.Text := format('%0.2u',[tmp div 3600]) +
      ':' + format('%0.2u',[(tmp - (tmp div 3600)) div 60]);
    CheckBox1.Checked := ADOQuery1.FieldByName('Result').AsInteger > 0;
    RadioButton1.Checked := ADOQuery1.FieldByName('Result').AsInteger = 1;
    RadioButton2.Checked := ADOQuery1.FieldByName('Result').AsInteger = 2;
    AlertCBClick(Nil);
    CheckBox1Click(Nil);
  end;
  Result := ShowModal = mrOk;
  if Result then begin
    with MainForm do begin
      if AlertCb.Checked then A := '1' else A := '0';
      if AlertPCB.Checked then AA := '1' else AA := '0';
      AT := IntToStr(IntervalCB.ItemIndex);
      case IntervalCB.ItemIndex of
        0: ATO := IntToStr(3600);
        1: ATO := IntToStr(3600 * 3);
        2: ATO := IntToStr(3600 * 12);
        3: ATO := IntToStr(3600 * 24);
        4: ATO := IntToStr(3600 * 48);
        5: ATO := IntToStr(3600 * 24 * 7);
        6: ATO := IntToStr(3600 * 24 * 30);
        7: ATO := IntToStr(3600 * 24 * 365);
        8: ATO := IntToStr(TimeToSecond(MaskEdit1.Text));
      end;
      if not CheckBox1.Checked then R := '0' else begin
        if RadioButton1.Checked then R := '1' else R := '2';
      end;
      if (Int(DateEndDTP.Date) + StrToTime(TimeEndME.Text)) > Now
        then Alerted := '0' else Alerted := '1';
      ADOQuery1.SQL.Text := 'update Tasks Set ' +
        ' DateBegin=' + AntiComa(FloatToStr(Int(DateBeginDTP.Date) + StrToTime(TimeBeginME.Text))) +
        ', Name="' + NameE.Text + '", Description="' + DescriptionM.Lines.Text +
        '", DateEnd=' + AntiComa(FloatToStr(Int(DateEndDTP.Date) + StrToTime(TimeEndME.Text))) +
        ', Alert=' + A + ', AlertAfter=' + AA + ', AlertType=' + AT +
        ', AlertTimeout=' + ATO + ', Result=' + R +
        ', Alerted=' + Alerted + ' where id=' + IntToStr(ID);
      ADOQuery1.ExecSQL;
    end;
  end;
end;

function TTaskForm.NewTask: Boolean;
var
 A, AA, AT, ATO, R: String;
begin
  Clear;
  Timer1.Enabled := true;
  Result :=  ShowModal = mrOk;
  if Result then begin
    with MainForm do begin
      if AlertCb.Checked then A := '1' else A := '0';
      if AlertPCB.Checked then AA := '1' else AA := '0';
      AT := IntToStr(IntervalCB.ItemIndex);
      case IntervalCB.ItemIndex of
        0: ATO := IntToStr(3600);
        1: ATO := IntToStr(3600 * 3);
        2: ATO := IntToStr(3600 * 12);
        3: ATO := IntToStr(3600 * 24);
        4: ATO := IntToStr(3600 * 48);
        5: ATO := IntToStr(3600 * 24 * 7);
        6: ATO := IntToStr(3600 * 24 * 30);
        7: ATO := IntToStr(3600 * 24 * 365);
        8: ATO := IntToStr(TimeToSecond(MaskEdit1.Text));
      end;
      if not CheckBox1.Checked then R := '0' else begin
        if RadioButton1.Checked then R := '1' else R := '2';
      end;
      ADOQuery1.SQL.Text := 'Insert Into Tasks (DateBegin, Name, Description, ' +
        'DateEnd, Alert, AlertAfter, AlertType, AlertTimeout, Result) Values (' +
        AntiComa(FloatToStr(Int(DateBeginDTP.Date) + StrToTime(TimeBeginME.Text))) + ', "' +
        NameE.Text + '", "' + DescriptionM.Lines.Text + '", ' +
        AntiComa(FloatToStr(Int(DateEndDTP.Date) + StrToTime(TimeEndME.Text))) + ', ' +
        A + ', ' + AA + ', ' + AT + ', ' + ATO + ', ' + R + ')';
      ADOQuery1.ExecSQL;
    end;
  end;
  Timer1.Enabled := false;
end;

procedure TTaskForm.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
 if key=27
 then ModalResult := mrCancel;
end;

procedure TTaskForm.CancelBtnClick(Sender: TObject);
begin
 ModalResult := mrCancel;
end;

procedure TTaskForm.OKBtnClick(Sender: TObject);
begin
 try
  if IntervalCB.ItemIndex = 8
  then TimeToSecond(MaskEdit1.Text);
 except
  MessageDlg('Введите правильный интервал ожидания.', mtError, [mbOk], 0);
  Exit;
 end;
 ModalResult:=mrOk;
end;

procedure TTaskForm.Clear;
begin
 TaskNumL.Caption := 'Новое задание';
 NameE.Text := 'Новое задание';
 DateBeginDTP.Date := Now;
 TimeBeginME.Text := TimeToStr(Now);
 DescriptionM.Lines.Clear;
 DateEndDTP.Date := Now;
 TimeEndME.Text := TimeToStr(Now);
 AlertCB.Checked := true;
 AlertCBClick(nil);
 CheckBox1.Checked := false;
 CheckBox1Click(nil);
 IntervalCB.ItemIndex := 3;
 IntervalCBChange(nil);
 MaskEdit1.Text := '01:00';
end;

procedure TTaskForm.AlertCBClick(Sender: TObject);
begin
 AlertPCB.Enabled := AlertCB.Checked;
 Label5.Enabled := AlertCB.Checked;
 IntervalCB.Enabled := AlertCB.Checked;
 MaskEdit1.Enabled := AlertCB.Checked;
end;

procedure TTaskForm.CheckBox1Click(Sender: TObject);
begin
 RadioButton1.Enabled := CheckBox1.Checked;
 RadioButton2.Enabled := CheckBox1.Checked;
end;

procedure TTaskForm.IntervalCBChange(Sender: TObject);
begin
 MaskEdit1.Enabled:=IntervalCB.ItemIndex=8;
end;

procedure TTaskForm.Timer1Timer(Sender: TObject);
begin
 DateBeginDTP.Date:=Now;
 TimeBeginME.Text:=TimeToStr(Now);
end;

function TTaskForm.AntiComa(S: string): string;
var
 i: Byte;
begin
 Result:=S;
 for i:=1 to Length(Result) do
  if Result[i]=','
 then Result[i]:='.';
end;

function TTaskForm.TimeToSecond(S: string): Integer;
var
 i: integer;
begin
 i:=StrToInt(trim(copy(S,1,2)))*3600+StrToInt(trim(copy(S,4,2)))*60;
 OKBtn.Caption:=IntToStr(i);
 Result:=StrToInt(trim(copy(S,1,2)))*3600+StrToInt(trim(copy(S,4,2)))*60;
end;

end.
