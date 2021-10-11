unit Main;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Trayicon, IniFiles, StdCtrls, ExtCtrls, Buttons, ComCtrls, DB,
  ADODB, Message, XPMan;

type
  TMainForm = class(TForm)
    TrayIcon: TTrayIcon;
    Panel1: TPanel;
    SpeedButton1: TSpeedButton;
    SpeedButton2: TSpeedButton;
    SpeedButton3: TSpeedButton;
    SpeedButton4: TSpeedButton;
    SpeedButton5: TSpeedButton;
    SpeedButton6: TSpeedButton;
    SpeedButton7: TSpeedButton;
    Label1: TLabel;
    FilterCB: TComboBox;
    StatusBar1: TStatusBar;
    TasksLV: TListView;
    ADOConnection1: TADOConnection;
    ADOQuery1: TADOQuery;
    SpeedButton8: TSpeedButton;
    Timer1: TTimer;
    ADOQuery2: TADOQuery;
    XPManifest1: TXPManifest;
    procedure FormCreate(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure TrayIconClick(Sender: TObject);
    procedure SpeedButton7Click(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
    procedure FilterCBChange(Sender: TObject);
    procedure SpeedButton8Click(Sender: TObject);
    procedure SpeedButton3Click(Sender: TObject);
    procedure SpeedButton2Click(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure SpeedButton6Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
  public
    FCanClose: Boolean;
    procedure LoadIniFile;
    procedure SaveIniFile;
    procedure LoadTasks;
    procedure UpdateStatus;
  end;

var
  MainForm: TMainForm;

implementation

uses Task, About, Options;

{$R *.dfm}

{ TMainForm }

procedure TMainForm.LoadIniFile;
var
 I: TIniFile;
 j: Integer;
begin
  I:=TIniFile.Create(ExtractFilePath(ParamStr(0))+'taskalert.ini');
  top:=strtoint(i.ReadString('Main','Top','10'));
  Left:=strtoint(i.ReadString('Main','Left','10'));
  width:=strtoint(i.ReadString('Main','Width','750'));
  height:=strtoint(i.ReadString('Main','Height','600'));
  if i.ReadString('Main','State','NORMAL')='MAXIMIZED' then WindowState:=wsMaximized;
  for j := 0 to TasksLV.Columns.Count - 1 do
    TasksLV.Columns[j].Width := I.ReadInteger('TasksLV', 'C' + IntToStr(j), TasksLV.Columns[j].Width);
  I.Free;
end;

procedure TMainForm.SaveIniFile;
var I: TIniFile;
    j: Integer;
begin
  I:=TIniFile.Create(ExtractFilePath(ParamStr(0))+'taskalert.ini');
  if WindowState=wsNormal then Begin
    i.WriteString('Main','Top',inttostr(top));
    i.WriteString('Main','Left',inttostr(Left));
    i.WriteString('Main','Width',inttostr(Width));
    i.WriteString('Main','Height',inttostr(Height));
  end;
  if WindowState=wsMaximized then i.WriteString('Main','State','MAXIMIZED')
                             else i.WriteString('Main','State','NORMAL');
  for j := 0 to TasksLV.Columns.Count - 1 do
    I.WriteInteger('TasksLV', 'C' + IntToStr(j), TasksLV.Columns[j].Width);

  with TaskForm do begin
    if WindowState=wsNormal then Begin
      i.WriteString('TaskForm','Top',inttostr(top));
      i.WriteString('TaskForm','Left',inttostr(Left));
      i.WriteString('TaskForm','Width',inttostr(Width));
      i.WriteString('TaskForm','Height',inttostr(Height));
    end;
    if WindowState=wsMaximized then i.WriteString('TaskForm','State','MAXIMIZED')
                              else i.WriteString('TaskForm','State','NORMAL');
  end;
  I.Free;
end;

procedure TMainForm.FormCreate(Sender: TObject);
begin
  ADOConnection1.Close;
  ADOConnection1.ConnectionString := 'Provider=Microsoft.Jet.OLEDB.4.0;Data Source=' +
    ExtractFilePath(ParamStr(0)) + 'db.mdb;Persist Security Info=False';
  ADOConnection1.Open;

  FCanClose := false;
  FilterCB.ItemIndex := 2;

  LoadTasks;
  Timer1.Enabled := true;
end;

procedure TMainForm.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
 CanClose:=FCanClose;
 if not CanClose
 then
  begin
   Hide;
   TrayIcon.Active:=true;
  end
 else SaveIniFile;
end;

procedure TMainForm.TrayIconClick(Sender: TObject);
begin
  TrayIcon.Active := false;
  Show;
end;

procedure TMainForm.SpeedButton7Click(Sender: TObject);
begin
 FCanClose := true;
 Close;
end;

procedure TMainForm.LoadTasks;
var S, S2: String;
begin
 TasksLV.Items.BeginUpdate;
 try
  TasksLV.Items.Clear;
  case FilterCB.ItemIndex of
    0: S := '';
    1: S := 'where Result>0';
    2: S := 'where Result=0';
  end;
  ADOQuery1.SQL.Text := 'select * from tasks ' + S +
    ' order by DateBegin';
  ADOQuery1.Open;
  while not ADOQuery1.Eof do begin
    with TasksLV.Items.Add do begin
      Data := Pointer(ADOQuery1.FieldByName('ID').AsInteger);
      Caption := ADOQuery1.FieldByName('DateBegin').AsString;
      SubItems.Add(ADOQuery1.FieldByName('Name').AsString);
      SubItems.Add(ADOQuery1.FieldByName('DateEnd').AsString);
      if ADOQuery1.FieldByName('Result').AsInteger = 0 then S := 'Нет' else begin
        S := 'Да';
        if ADOQuery1.FieldByName('Result').AsInteger = 1
          then S2 := 'Да'
          else S2 := 'Нет';
      end;
      SubItems.Add(S);
      SubItems.Add(S2);
    end;
    ADOQuery1.Next;
  end;
 finally
  TasksLV.Items.EndUpdate;
 end;
 UpdateStatus;
end;

procedure TMainForm.SpeedButton1Click(Sender: TObject);
begin
 if TaskForm.NewTask
 then LoadTasks;
end;

procedure TMainForm.FilterCBChange(Sender: TObject);
begin
  LoadTasks;
end;

procedure TMainForm.UpdateStatus;
begin
  ADOQuery1.SQL.Text := 'select count(*) from Tasks';
  ADOQuery1.Open;
  StatusBar1.Panels[0].Text := 'Всего: ' + ADOQuery1.Fields[0].AsString;

  ADOQuery1.SQL.Text := 'select count(*) from Tasks where Result=0';
  ADOQuery1.Open;
  StatusBar1.Panels[1].Text := 'Не выполненные: ' + ADOQuery1.Fields[0].AsString;

  ADOQuery1.SQL.Text := 'select count(*) from Tasks where Result<>0';
  ADOQuery1.Open;
  StatusBar1.Panels[2].Text := 'Выполненные: ' + ADOQuery1.Fields[0].AsString;

  ADOQuery1.SQL.Text := 'select count(*) from Tasks where Result=1';
  ADOQuery1.Open;
  StatusBar1.Panels[3].Text := 'Успешно: ' + ADOQuery1.Fields[0].AsString;

  ADOQuery1.SQL.Text := 'select count(*) from Tasks where Result=2';
  ADOQuery1.Open;
  StatusBar1.Panels[4].Text := 'Проваленые: ' + ADOQuery1.Fields[0].AsString;
end;

procedure TMainForm.SpeedButton8Click(Sender: TObject);
begin
 AboutForm.ShowModal;
end;

procedure TMainForm.SpeedButton3Click(Sender: TObject);
begin
  if TasksLV.Selected = nil
  then Exit;
  if MessageDlg('Вы действительно хотите удалить задание "' +
    TasksLV.Selected.SubItems[0] + '"?', mtConfirmation, [mbYes, mbNo], 0) = mrYes then begin
    ADOQuery1.SQL.Text := 'delete from Tasks where id=' +IntToStr(Integer(TasksLV.Selected.Data));
    ADOQuery1.ExecSQL;
    LoadTasks;
  end;
end;

procedure TMainForm.SpeedButton2Click(Sender: TObject);
begin
 if TasksLV.Selected = nil
 then Exit;
 if TaskForm.EditTask(Integer(TasksLV.Selected.Data))
 then LoadTasks;
end;

procedure TMainForm.Timer1Timer(Sender: TObject);
begin
  //TTimer(Sender).Enabled := false;
  try
    ADOQuery1.SQL.Text := 'select * from Tasks where ((Alerted<>1) or' +
      ' (AlertAfter=1))' +
      ' and Alert=1 and Result=0 and DateEnd<' + TaskForm.AntiComa(FloatToStr(Now));
    ADOQuery1.Open;
    while not ADOQuery1.Eof do begin
      if (Now - ADOQuery1.FieldByName('LastAlert').AsDateTime) * 60 * 60 * 24 <
        ADOQuery1.FieldByName('AlertTimeout').AsInteger then begin
          ADOQuery1.Next;
          Continue;
      end;
      Beep;
      with TMessageForm.Create(Self) do begin
        Caption := Caption + ' от ' + DateTimeToStr(Now);
        Memo1.Text := 'Введено: ' + ADOQuery1.FieldByName('DateBegin').AsString + #13#10 +
          'Наименование: ' + ADOQuery1.FieldByName('Name').AsString + #13#10 +
          'Примечание: ' + ADOQuery1.FieldByName('Description').AsString;
        Show;
        ADOQuery2.SQL.Text := 'Update Tasks Set Alerted=1, LastAlert=' +
          TaskForm.AntiComa(FloatToStr(Now)) + ' Where ID=' +
          ADOQuery1.FieldByName('ID').AsString;
        ADOQuery2.ExecSQL;
      end;
      ADOQuery1.Next;
    end;
  finally
    //TTimer(Sender).Enabled := true;
  end;
end;

procedure TMainForm.SpeedButton6Click(Sender: TObject);
begin
 OptionsForm.ShowModal;
end;

procedure TMainForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
 Action:=caFree;
end;

end.
