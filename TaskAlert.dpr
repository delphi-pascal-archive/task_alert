program TaskAlert;

uses
  Forms,
  Main in 'Main.pas' {MainForm},
  Task in 'Task.pas' {TaskForm},
  About in 'About.pas' {AboutForm},
  Message in 'Message.pas' {MessageForm},
  Options in 'Options.pas' {OptionsForm};

{$R *.res}

begin
  Application.Initialize;
  Application.Title:='TaskAlert';
  Application.CreateForm(TMainForm, MainForm);
  Application.CreateForm(TTaskForm, TaskForm);
  Application.CreateForm(TAboutForm, AboutForm);
  Application.CreateForm(TMessageForm, MessageForm);
  Application.CreateForm(TOptionsForm, OptionsForm);
  MainForm.LoadIniFile;
  Application.Run;
end.
