program Palapasabra;
{
    Trabajo final para Programación II.
    v0.9.2 (Puede que lo siga después de la entrega).
}

const INPUTMAX = 2; { Si lo dejo en 1 y escribo 30... lo reconoce como 3, por lo que String[2] es suficiente }
    ROSCOPATH = './ip2/palabras.dat';
    PLAYERSPATH = './ip2/DNavas-Jugadores.dat';
    MAXJUGADORES = 2;
type StringInput = String[INPUTMAX];
    reg_jugador = record
        nombre : string;
        partidas_ganadas : integer;
    end;
    reg_palabra = record
        nro_set : integer;
        letra : char;
        palabra : string;
        consigna : string;
    end;
    FileJugadores = file of reg_jugador;
    FileRosco = file of reg_palabra;
    RoscoMode = (Pendiente, Acertada, Errada);
    ArbolJugadores = ^NodoJugador;
    NodoJugador = record
        Nombre : string;
        PartidasGanadas : integer;
        Izquierda, Derecha : ArbolJugadores;
    end;
    ListaRosco = ^NodoRosco;
    NodoRosco = record
        Letra : char;
        Palabra : string;
        Consigna : string;
        Respuesta : RoscoMode;
        Siguiente : ListaRosco;
    end;
    reg_partida = record
        NombreJugador : string;
        Rosco : ListaRosco;
    end;
    ArregloPartida = array[1..2] of reg_partida;
    
    
function FileIsExists(var FJugadores : FileJugadores) : boolean;
begin
    {$I-}
    reset(FJugadores);
    {$I+}
    FileIsExists := (IOResult = 0);
end;

{ BEGIN: Sistema de Jugadores }
function JugadorExiste(AJugadores : ArbolJugadores; nombre : string) : boolean;
begin
    JugadorExiste := false;
    if AJugadores <> nil then
    begin
        if AJugadores^.Nombre > nombre then
            JugadorExiste := JugadorExiste(AJugadores^.Izquierda, nombre)
        else if AJugadores^.Nombre < nombre then
            JugadorExiste := JugadorExiste(AJugadores^.Derecha, nombre)
        else
            JugadorExiste := true;
    end;
end;

procedure AgregarJugadorArchivo(var FJugadores : FileJugadores; RJugador : reg_jugador);
begin
    reset(FJugadores);
    seek(FJugadores, filesize(FJugadores));
    write(FJugadores, RJugador);
    close(FJugadores);
end;

function CrearNodoJugador(RJugador : reg_jugador) : ArbolJugadores;
var nodo : ArbolJugadores;
begin
    new(nodo);
    nodo^.Nombre := RJugador.nombre;
    nodo^.PartidasGanadas := RJugador.partidas_ganadas;
    nodo^.Izquierda := nil;
    nodo^.Derecha := nil;
    
    CrearNodoJugador := nodo;
end;

procedure InsertarJugadorArbol(var AJugadores : ArbolJugadores; NodoJugador : ArbolJugadores);
begin
    if AJugadores = nil then
        AJugadores := NodoJugador
    else if AJugadores^.Nombre > NodoJugador^.Nombre then
        InsertarJugadorArbol(AJugadores^.Izquierda, NodoJugador)
    else
        InsertarJugadorArbol(AJugadores^.Derecha, NodoJugador);
end;

procedure AgregarJugador(var FJugadores : FileJugadores; var AJugadores : ArbolJugadores);
var nombreJugador : string;
    RJugador : reg_jugador;
begin
    WriteLn('Ingrese el nombre del jugador...');
    write('> '); readln(nombreJugador);
    if JugadorExiste(AJugadores, nombreJugador) then
    begin
        WriteLn('Ese nombre ya existe, intente nuevamente.');
        WriteLn();
    end
    else if nombreJugador = '' then
    begin
        WriteLn('El nombre no puede quedar vacío.');
        WriteLn();
    end
    else
    begin
        RJugador.nombre := nombreJugador;
        RJugador.partidas_ganadas := 0;
        AgregarJugadorArchivo(FJugadores, RJugador);
        InsertarJugadorArbol(AJugadores, CrearNodoJugador(RJugador));
        WriteLn('Jugador agregado!');
        WriteLn();
    end;
end;

function CargarJugadores(var FJugadores : FileJugadores) : ArbolJugadores;
var RJugador : reg_jugador;
    ArbolAux : ArbolJugadores;
begin
    assign(FJugadores, PLAYERSPATH);
    if FileIsExists(FJugadores) then
        reset(FJugadores)
    else
        rewrite(FJugadores);
    while not eof(FJugadores) do begin
        read(FJugadores, RJugador);
        InsertarJugadorArbol(ArbolAux, CrearNodoJugador(RJugador));
    end;
    close(FJugadores);
    
    CargarJugadores := ArbolAux;
end;

procedure VerJugadores(AJugadores : ArbolJugadores);
begin
    if AJugadores <> nil then
    begin
        VerJugadores(AJugadores^.Izquierda);
        
        WriteLn('--------------');
        write('Jugador: '); WriteLn(AJugadores^.Nombre);
        write('Partidas Ganadas: '); WriteLn(AJugadores^.PartidasGanadas);
        WriteLn('--------------');
        
        VerJugadores(AJugadores^.Derecha);
    end;
end;

procedure AgregarVictoriaJugadorArbol(var AJugadores : ArbolJugadores; nombre : string);
begin
    if AJugadores <> nil then
    begin
        if AJugadores^.Nombre > nombre then
            AgregarVictoriaJugadorArbol(AJugadores^.Izquierda, nombre)
        else if AJugadores^.Nombre < nombre then
            AgregarVictoriaJugadorArbol(AJugadores^.Derecha, nombre)
        else
            AJugadores^.PartidasGanadas := AJugadores^.PartidasGanadas + 1;
    end;
end;

procedure AgregarVictoriaJugadorArchivo(var FJugadores : FileJugadores; nombre : string);
var jugador : reg_jugador;
    playerFound : boolean;
begin
    playerFound := false;
    reset(FJugadores);
    while (not eof(FJugadores)) and (not playerFound) do
    begin
        read(FJugadores, jugador);
        if jugador.nombre = nombre then
            playerFound := true;
    end;
        
    seek(FJugadores, filepos(FJugadores)-1);
    jugador.partidas_ganadas := jugador.partidas_ganadas + 1;
    write(FJugadores, jugador);
    close(FJugadores);
end;

procedure AgregarVictoriaJugador(var AJugadores : ArbolJugadores; var FJugadores : FileJugadores; nombre : string);
begin
    AgregarVictoriaJugadorArbol(AJugadores, nombre);
    AgregarVictoriaJugadorArchivo(FJugadores, nombre);
end;

function ReestablecerArchivoJugadores(var FJugadores : FileJugadores) : ArbolJugadores; { Solo sirve para pruebas, no es parte del programa final }
begin
    rewrite(FJugadores);
    close(FJugadores);
    ReestablecerArchivoJugadores := CargarJugadores(FJugadores);
    WriteLn('Archivo reestablecido');
    WriteLn;
end;
{ END: Sistema de Jugadores }

{ BEGIN: Sistema de Palabras (Rosco) }
function CrearNodoRosco(RPalabra : reg_palabra) : ListaRosco;
var NodoRosco : ListaRosco;
begin
    new(NodoRosco);
    NodoRosco^.Letra := RPalabra.letra;
    NodoRosco^.Palabra := RPalabra.palabra;
    NodoRosco^.Consigna := RPalabra.consigna;
    NodoRosco^.Respuesta := Pendiente;
    NodoRosco^.Siguiente := nil;
    
    CrearNodoRosco := NodoRosco;
end;

procedure InsertarRoscoLista(var Rosco : ListaRosco; nodo : ListaRosco);
var enlace : ListaRosco;
begin
    if Rosco = nil then
    begin
        Rosco := nodo;
        Rosco^.Siguiente := Rosco;
    end
    else
    begin
        enlace := Rosco;
        while (enlace^.Siguiente <> Rosco) do
            enlace := enlace^.Siguiente;
        
        nodo^.Siguiente := Rosco;
        enlace^.Siguiente := nodo;
    end;
end;

function CargarRosco(var FRosco : FileRosco; num_set : integer) : ListaRosco;
var RPalabra : reg_palabra;
    Rosco : ListaRosco;
begin
    Rosco := nil;
    reset(FRosco);
    while not eof(FRosco) do begin
        read(FRosco, RPalabra);
        if RPalabra.nro_set = num_set then
            InsertarRoscoLista(Rosco, CrearNodoRosco(RPalabra));
    end;
    close(FRosco);
    
    CargarRosco := Rosco;
end;

procedure MostrarRosco(var FRosco : FileRosco); { Testeos }
var RPalabra : reg_palabra;
begin
    reset(FRosco);
    while not eof(archivo) do
    begin
        read(archivo, RPalabra);
        WriteLn('----------');
        WriteLn(RPalabra.nro_set);
        WriteLn(RPalabra.letra);
        WriteLn(RPalabra.palabra);
        WriteLn(RPalabra.consigna);
        WriteLn('----------');
    end;
    close(FRosco);
end;

procedure InicializarRosco(var FRosco : FileRosco);
begin
    assign(FRosco, ROSCOPATH);
end;
{ END: Sistema de Palabras }

{ BEGIN: Juego }
procedure AgregarJugadoresPartida(var ArrPartida : ArregloPartida; AJugadores : ArbolJugadores);
var nombreJugador : string;
    jugadorValido : boolean;
    i : integer;
begin
    for i := 1 to MAXJUGADORES do
    begin
        jugadorValido := false;
        WriteLn('| Jugador ', i, ' |');
        while jugadorValido = false do begin
            Write('Ingrese un nombre para el jugador: '); readln(nombreJugador);
            if not JugadorExiste(AJugadores, nombreJugador) then
                WriteLn('El jugador no existe, intente con otro')
            else if (i > 1) and (nombreJugador = ArrPartida[i-1].NombreJugador) then { Funciona si sólo son 2 jugadores }
            begin
                WriteLn(nombreJugador, ' ya es el jugador ', i-1, ', seleccione otro!');
            end
            else
                jugadorValido := true;
        end;
        ArrPartida[i].NombreJugador := nombreJugador;
    end;
end;

procedure CargarJugadoresRosco(var ArrPartida : ArregloPartida; var FRosco : FileRosco);
var i : integer;
begin
    for i := 1 to MAXJUGADORES do
        ArrPartida[i].Rosco := CargarRosco(FRosco, Random(5)+1);
end;

function ExistePendientes(Rosco : ListaRosco) : boolean;
var enlace : ListaRosco;
begin
    enlace := Rosco^.Siguiente;
    while (enlace^.Respuesta <> Pendiente) and (enlace <> Rosco) do
        enlace := enlace^.Siguiente;

    if (enlace^.Respuesta <> Pendiente) and (enlace = Rosco) then
        ExistePendientes := false
    else
        ExistePendientes := true;
end;

function ContarAcertadas(Rosco : ListaRosco) : integer;
var enlace : ListaRosco;
    acertadasAux : integer;
begin
    acertadasAux := 0;
    enlace := Rosco^.Siguiente;
    while enlace <> Rosco do
    begin
        if enlace^.Respuesta = Acertada then
            acertadasAux := acertadasAux + 1;
        enlace := enlace^.Siguiente;
    end;
    ContarAcertadas := acertadasAux;
end;

procedure AvanzarRosco(var Rosco : ListaRosco);
var enlace : ListaRosco;
begin
    enlace := Rosco^.Siguiente;
    while (enlace^.Respuesta <> Pendiente) and (enlace <> Rosco) do
    begin
        enlace := enlace^.Siguiente;
    end;
    Rosco := enlace;
end;

procedure MostrarPalabra(Rosco : ListaRosco);
begin
    WriteLn('----------');
    WriteLn('Letra: ', Rosco^.Letra);
    WriteLn(Rosco^.Consigna);
    WriteLn('----------');
end;

procedure ResponderPalabra(var Rosco : ListaRosco);
var respuestaJugador : String;
begin
    Write('> '); ReadLn(respuestaJugador);

    if respuestaJugador <> 'pp' then
    begin
        if respuestaJugador = Rosco^.Palabra then
        begin
            WriteLn('Correcta!');
            Rosco^.Respuesta := Acertada;
        end
        else
        begin
            WriteLn('Incorrecta!');
            Rosco^.Respuesta := Errada;
        end;
    end
    else
        WriteLn('Pasapalabra!');
end;

function TurnoJugador(var Jugador : reg_partida) : boolean;
var finTurno : boolean;
begin
    finTurno := false;
    WriteLn('Es el turno de ', Jugador.NombreJugador, '!');
    while not finTurno do
    begin
        MostrarPalabra(Jugador.Rosco);
        ResponderPalabra(Jugador.Rosco);

        if Jugador.Rosco^.Respuesta <> Acertada then
        begin
            TurnoJugador := false;
            finTurno := true;
        end;

        if ExistePendientes(Jugador.Rosco) then
            AvanzarRosco(Jugador.Rosco)
        else
        begin
            TurnoJugador := true;
            finTurno := true;
        end;
    end;
end;

procedure Partida(var ArrPartida : ArregloPartida);
var finPartida : boolean;
    turno : integer;
begin
    finPartida := false;
    turno := 1;
    while not finPartida do
    begin
        finPartida := TurnoJugador(ArrPartida[turno]);
        
        if turno < MAXJUGADORES then
            turno := turno + 1
        else
            turno := 1;
    end;
end;

procedure DefinirGanador(ArrPartida : ArregloPartida; var AJugadores : ArbolJugadores; var FJugadores : FileJugadores);
begin
    if ContarAcertadas(ArrPartida[1].Rosco) > ContarAcertadas(ArrPartida[2].Rosco) then
    begin
        WriteLn(ArrPartida[1].NombreJugador, ' ha ganado!');
        AgregarVictoriaJugador(AJugadores, FJugadores, ArrPartida[1].NombreJugador);
    end
    else if ContarAcertadas(ArrPartida[1].Rosco) < ContarAcertadas(ArrPartida[2].Rosco) then
    begin
        WriteLn(ArrPartida[2].NombreJugador, ' ha ganado!');
        AgregarVictoriaJugador(AJugadores, FJugadores, ArrPartida[2].NombreJugador);
    end
    else
        WriteLn('Empate!');
end;

procedure IniciarJuego(var AJugadores : ArbolJugadores; var FJugadores : FileJugadores; var FRosco : FileRosco);
var ArrPartida : ArregloPartida;
begin
    AgregarJugadoresPartida(ArrPartida, AJugadores);
    CargarJugadoresRosco(ArrPartida, FRosco);
    WriteLn('Comenzando partida...');
    Partida(ArrPartida);
    DefinirGanador(ArrPartida, AJugadores, FJugadores);
end;
{ END: Juego }

{ BEGIN: Sistema de Menú }
procedure MenuPrincipal;
begin
    WriteLn('Bienvenido a Pasapalabra!');
    WriteLn('-------------------------');
    WriteLn('1. Jugar');
    WriteLn('2. Agregar jugador');
    WriteLn('3. Ver jugadores');
    WriteLn('4. Salir');
    WriteLn('-- Made by Dylan Navas --');
end;

function MenuSalir : boolean;
begin
    WriteLn('Saliendo...');
    MenuSalir := True;
end;

function MenuSystem(var FJugadores : FileJugadores; var FRosco : FileRosco; var AJugadores : ArbolJugadores) : boolean;
var input : StringInput;
begin
    input := '';
    MenuSystem := false;
    while input <> '4' do
    begin
        WriteLn;
        MenuPrincipal;
        write('> '); readln(input);
        WriteLn;
        case (input) of
            'R' : AJugadores := ReestablecerArchivoJugadores(FJugadores); { Sólo para pruebas }
            'M' : MostrarRosco(FRosco); { Sólo para pruebas }
            '1' : IniciarJuego(AJugadores, FJugadores, FRosco);
            '2' : AgregarJugador(FJugadores, AJugadores);
            '3' : VerJugadores(AJugadores);
            '4' : MenuSystem := MenuSalir;
        end;
    end;
end;
{ END: Sistema de menú }

var FJugadores : FileJugadores;
    FRosco : FileRosco;
    AJugadores : ArbolJugadores;
    Finished : boolean;
begin
    Randomize;
    InicializarRosco(FRosco);
    AJugadores := CargarJugadores(FJugadores);
    Finished := false;
    while not Finished do begin
        Finished := MenuSystem(FJugadores, FRosco, AJugadores);
    end;
end.