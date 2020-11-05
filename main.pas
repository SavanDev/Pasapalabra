program Palapasabra;
{ Trabajo final para Programación II }

function MainMenu : integer;
begin
    writeln('Bienvenido a Pasapalabra!');
    writeln('-------------------------');
    writeln('1. Agregar un jugador');
    writeln('2. Ver lista de jugadores');
    writeln('3. Jugar');
    writeln('4. Salir');
    writeln('-------------------------');
    write('> '); readln(MainMenu);
end;

function NotImplemented : integer;
begin
    writeln('No implementado aun...');
    write('> '); readln(NotImplemented);
end;

procedure Exit();
begin
    writeln('Saliendo...');
end;

procedure HandleMenu(mode : integer);
begin
    if (mode = 1) or (mode = 2) or (mode = 3) then
        HandleMenu(NotImplemented)
    else if mode = 4 then
        Exit()
    else
        HandleMenu(MainMenu);
end;

begin
    HandleMenu(MainMenu);
end.