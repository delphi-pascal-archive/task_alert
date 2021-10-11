unit Trayicon;
interface
uses

SysUtils, Windows, Messages, Classes, Graphics, Controls, ShellAPI, Forms,
menus;
const WM_TOOLTRAYICON = WM_USER+1;

WM_RESETTOOLTIP = WM_USER+2;
type

TTrayIcon = class(TComponent)
private
// BDS
{ для внутреннего пользования }
hMapping: THandle;
{ Набор переменных }
IconData: TNOTIFYICONDATA;
fIcon : TIcon;
fToolTip : String;
fWindowHandle : HWND;
fActive : boolean;
fShowApp : boolean;                                     // Добавлено
fSendMsg : string;
fShowDesigning : Boolean;
{ События }
fOnClick     : TNotifyEvent;
fOnDblClick  : TNotifyEvent;
fOnRightClick : TMouseEvent;
fPopupMenu   : TPopupMenu;
function AddIcon : boolean;
function ModifyIcon : boolean;
function DeleteIcon : boolean;
procedure SetActive(Value : boolean);
procedure SetShowApp(Value : boolean);                  // Добавлено
procedure SetShowDesigning(Value : boolean);
procedure SetIcon(Value : TIcon);
procedure SetToolTip(Value : String);
procedure WndProc(var msg : TMessage);
procedure FillDataStructure;
procedure DoRightClick( Sender : TObject );
protected
public
FMessageID: DWORD;
constructor create(aOwner : TComponent); override;
procedure Loaded; override;                             // Добавлено
destructor destroy; override;
procedure GoToPreviousInstance;
published
property Active : boolean read fActive write SetActive;
property ShowDesigning : boolean read fShowDesigning write
SetShowDesigning;

property Icon : TIcon read fIcon write SetIcon;
property IDMessage : string read fSendMsg write fSendMsg;
property ShowApp : boolean read fShowApp write SetShowApp; // Добавлено
property ToolTip : string read fTooltip write SetToolTip;
property OnClick     : TNotifyEvent read FOnClick write FOnClick;
property OnDblClick  : TNotifyEvent read FOnDblClick write FOnDblClick;
property OnRightClick : TMouseEvent  read FOnRightClick write
FonRightClick;

property PopupMenu : TPopupMenu read fPopupMenu write fPopupMenu;
end;

procedure Register;

type

PHWND = ^HWND;

implementation

//{$R TrayIcon.res}

procedure TTrayIcon.GoToPreviousInstance;
begin

PostMessage(hwnd_Broadcast, fMessageID, 0, 0);
end;

procedure TTrayIcon.SetActive(Value : boolean);
begin

if value <> fActive then begin
fActive := Value;
if not (csdesigning in ComponentState) then begin
if Value then begin
AddIcon;
end else begin
DeleteIcon;
end;
end;
end;
end;

procedure TTrayIcon.SetShowApp(Value : boolean);      // Добавлено
begin

if value <> fShowApp then fShowApp := value;
if not (csdesigning in ComponentState) then
begin
if Value then
begin
ShowWindow(Application.Handle, SW_SHOW);
end
else
begin
ShowWindow(Application.Handle, SW_HIDE);
end;
end;
end;

procedure TTrayIcon.SetShowDesigning(Value : boolean);
begin

if csdesigning in ComponentState then begin
if value <> fShowDesigning then begin
fShowDesigning := Value;
if Value then begin
AddIcon;
end else begin
DeleteIcon;
end;
end;
end;
end;

procedure TTrayIcon.SetIcon(Value : Ticon);
begin

if Value <> fIcon then
begin
fIcon.Assign(value);
ModifyIcon;
end;
end;

procedure TTrayIcon.SetToolTip(Value : string);
begin

// Данная программа ВСЕГДА переустанавливает текст подсказки и перезагружает
// иконку. Текст может быть пустым в случае первой инициализации компонента.
// Без инициализации иконка будет пустой и текст подсказки будет отсутствовать.
if length( Value ) > 62 then
Value := copy(Value,1,62);
fToolTip := value;
ModifyIcon;
end;

constructor TTrayIcon.create(aOwner : Tcomponent);
begin

inherited create(aOwner);
FWindowHandle := AllocateHWnd( WndProc );
FIcon := TIcon.Create;
SetShowApp(False);
end;

destructor TTrayIcon.destroy;
begin

// BDS
CloseHandle(hMapping);


if (not (csDesigning in ComponentState) and fActive)
or ((csDesigning in ComponentState) and fShowDesigning) then
DeleteIcon;
FIcon.Free;
DeAllocateHWnd( FWindowHandle );
inherited destroy;
end;

procedure TTrayIcon.Loaded;
var

// BDS
// hMapping: HWND;
tmp, tmpID: PChar;
begin

inherited Loaded;
if fSendMsg <> '' then
begin
GetMem(tmp, Length(fSendMsg) + 1);
GetMem(tmpID, Length(fSendMsg) + 1);
StrPCopy(tmp, fSendMsg);
StrPCopy(tmpID, fSendMsg);
fMessageID := RegisterWindowMessage(tmp);
FreeMem(tmp);
hMapping := CreateFileMapping(HWND($FFFFFFFF), nil, PAGE_READONLY, 0, 32, tmpID);
if (hMapping <> 0) and (GetLastError = ERROR_ALREADY_EXISTS) then
begin
if not (csDesigning in ComponentState) then
begin
GotoPreviousInstance;
FreeMem(tmpID);
halt;
end;
end;
FreeMem(tmpID);
end;
SetShowApp(fShowApp);
end;

procedure TTrayIcon.FillDataStructure;
begin

with IconData do begin
cbSize := sizeof(TNOTIFYICONDATA);
wnd := FWindowHandle;
uID := 0; // определенный приложением идентификатор иконки
uFlags := NIF_MESSAGE + NIF_ICON + NIF_TIP;
hIcon := fIcon.Handle;
StrPCopy(szTip,fToolTip);
uCallbackMessage := WM_TOOLTRAYICON;
end;
end;

function TTrayIcon.AddIcon : boolean;
begin

FillDataStructure;
result := Shell_NotifyIcon(NIM_ADD,@IconData);
// По неизвестной причине, если не задан текст всплывающей
// подсказки, иконка не выводится. Здесь это учтено.
if fToolTip = '' then
PostMessage( fWindowHandle, WM_RESETTOOLTIP,0,0 );
end;

function TTrayIcon.ModifyIcon : boolean;
begin

FillDataStructure;
if fActive then
result := Shell_NotifyIcon(NIM_MODIFY,@IconData)
else
result := True;
end;

procedure TTrayIcon.DoRightClick( Sender : TObject );
var MouseCo: Tpoint;
begin

GetCursorPos(MouseCo);
if assigned( fPopupMenu ) then begin
SetForegroundWindow( Application.Handle );
Application.ProcessMessages;
fPopupmenu.Popup( Mouseco.X, Mouseco.Y );
end;
if assigned( FOnRightClick ) then
begin
FOnRightClick(self,mbRight,[],MouseCo.x,MouseCo.y);
end;
end;

function TTrayIcon.DeleteIcon : boolean;
begin

result := Shell_NotifyIcon(NIM_DELETE,@IconData);
end;

procedure TTrayIcon.WndProc(var msg : TMessage);
begin

with msg do
if (msg = WM_RESETTOOLTIP) then
SetToolTip( fToolTip )
else if (msg = WM_TOOLTRAYICON) then begin
case lParam of
WM_LBUTTONDBLCLK   : if assigned (FOnDblClick) then FOnDblClick(self);
WM_LBUTTONUP       : if assigned(FOnClick)then FOnClick(self);
WM_RBUTTONUP       : DoRightClick(self);
end;
end
else // Обработка всех сообщений с дескриптором по умолчанию
Result := DefWindowProc(FWindowHandle, Msg, wParam, lParam);
end;

procedure Register;
begin

RegisterComponents('MyComp', [TTrayIcon]);
end;
end.  
[000266