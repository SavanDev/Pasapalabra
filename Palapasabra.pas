program Palapasabra;
{
    Trabajo final para Programación II.
    v0.9 (Puede que lo siga después de la entrega).
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
    GameMode = (Menu, Juego, Finalizado);
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
    
    
function FileIsExists(var archivo : FileJugadores) : boolean;
begin
    {$I-}
    reset(archivo);
    {$I+}
    FileIsExists := (IOResult = 0);
end;

{ BEGIN: Sistema de Jugadores }
function JugadorExiste(arbol : ArbolJugadores; nombre : string) : boolean;
begin
    JugadorExiste := false;
    if arbol <> nil then
    begin
        if arbol^.Nombre > nombre then
            JugadorExiste := JugadorExiste(arbol^.Izquierda, nombre)
        else if arbol^.Nombre < nombre then
            JugadorExiste := JugadorExiste(arbol^.Derecha, nombre)
        else
            JugadorExiste := true;
    end;
end;

procedure AgregarJugadorArchivo(var archivo : FileJugadores; jugador : reg_jugador);
begin
    reset(archivo);
    seek(archivo, filesize(archivo));
    write(archivo, jugador);
    close(archivo);
end;

function CrearNodoJugador(jugador : reg_jugador) : ArbolJugadores;
var nodo : ArbolJugadores;
begin
    new(nodo);
    nodo^.Nombre := jugador.nombre;
    nodo^.PartidasGanadas := jugador.partidas_ganadas;
    nodo^.Izquierda := nil;
    nodo^.Derecha := nil;
    
    CrearNodoJugador := nodo;
end;

procedure InsertarJugadorArbol(var arbol : ArbolJugadores; nodo : ArbolJugadores);
begin
    if arbol = nil then
        arbol := nodo
    else if arbol^.Nombre > nodo^.Nombre then
        InsertarJugadorArbol(arbol^.Izquierda, nodo)
    else
        InsertarJugadorArbol(arbol^.Derecha, nodo);
end;

procedure AgregarJugador(var archivo : FileJugadores; var arbol : ArbolJugadores);
var nombreJugador : string;
    registro : reg_jugador;
begin
    WriteLn('Ingrese el nombre del jugador...');
    write('> '); readln(nombreJugador);
    if JugadorExiste(arbol, nombreJugador) then
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
        registro.nombre := nombreJugador;
        registro.partidas_ganadas := 0;
        AgregarJugadorArchivo(archivo, registro);
        InsertarJugadorArbol(arbol, CrearNodoJugador(registro));
        WriteLn('Jugador agregado!');
        WriteLn();
    end;
end;

function CargarJugadores(var archivo : FileJugadores) : ArbolJugadores;
var jugador : reg_jugador;
    arbol : ArbolJugadores;
begin
    assign(archivo, PLAYERSPATH);
    if FileIsExists(archivo) then
        reset(archivo)
    else
        rewrite(archivo);
    while not eof(archivo) do begin
        read(archivo, jugador);
        InsertarJugadorArbol(arbol, CrearNodoJugador(jugador));
    end;
    close(archivo);
    
    CargarJugadores := arbol;
end;

procedure VerJugadores(arbol : ArbolJugadores);
begin
    if arbol <> nil then
    begin
        VerJugadores(arbol^.Izquierda);
        
        WriteLn('--------------');
        write('Jugador: '); WriteLn(arbol^.Nombre);
        write('Partidas Ganadas: '); WriteLn(arbol^.PartidasGanadas);
        WriteLn('--------------');
        
        VerJugadores(arbol^.Derecha);
    end;
end;

procedure AgregarVictoriaJugadorArbol(var arbol : ArbolJugadores; nombre : string);
begin
    if arbol <> nil then
    begin
        if arbol^.Nombre > nombre then
            AgregarVictoriaJugadorArbol(arbol^.Izquierda, nombre)
        else if arbol^.Nombre < nombre then
            AgregarVictoriaJugadorArbol(arbol^.Derecha, nombre)
        else
            arbol^.PartidasGanadas := arbol^.PartidasGanadas + 1;
    end;
end;

procedure AgregarVictoriaJugadorArchivo(var archivo : FileJugadores; nombre : string);
var jugador : reg_jugador;
    playerFound : boolean;
begin
    playerFound := false;
    reset(archivo);
    while (not eof(archivo)) and (not playerFound) do
    begin
        read(archivo, jugador);
        if jugador.nombre = nombre then
            playerFound := true;
    end;
        
    seek(archivo, filepos(archivo)-1);
    jugador.partidas_ganadas := jugador.partidas_ganadas + 1;
    write(archivo, jugador);
    close(archivo);
end;

procedure AgregarVictoriaJugador(var arbol : ArbolJugadores; var archivo : FileJugadores; nombre : string);
begin
    AgregarVictoriaJugadorArbol(arbol, nombre);
    AgregarVictoriaJugadorArchivo(archivo, nombre);
end;

function ReestablecerArchivoJugadores(var archivo : FileJugadores) : ArbolJugadores; { Solo sirve para pruebas, no es parte del programa final }
begin
    rewrite(archivo);
    close(archivo);
    ReestablecerArchivoJugadores := CargarJugadores(archivo);
    WriteLn('Archivo reestablecido');
    WriteLn();
end;
{ END: Sistema de Jugadores }

{ BEGIN: Sistema de Palabras (Rosco) }
function CrearNodoRosco(registro : reg_palabra) : ListaRosco;
var nodo : ListaRosco;
begin
    new(nodo);
    nodo^.Letra := registro.letra;
    nodo^.Palabra := registro.palabra;
    nodo^.Consigna := registro.consigna;
    nodo^.Respuesta := Pendiente;
    nodo^.Siguiente := nil;
    
    CrearNodoRosco := nodo;
end;

procedure InsertarRoscoLista(var lista : ListaRosco; nodo : ListaRosco);
var enlace : ListaRosco;
begin
    if lista = nil then
    begin
        lista := nodo;
        lista^.Siguiente := lista;
    end
    else
    begin
        enlace := lista;
        while (enlace^.Siguiente <> lista) do
            enlace := enlace^.Siguiente;
        
        nodo^.Siguiente := lista;
        enlace^.Siguiente := nodo;
    end;
end;

function CargarRosco(var archivo : FileRosco; num_set : integer) : ListaRosco;
var palabra : reg_palabra;
    lista : ListaRosco;
begin
    lista := nil;
    reset(archivo);
    while not eof(archivo) do begin
        read(archivo, palabra);
        if palabra.nro_set = num_set then
            InsertarRoscoLista(lista, CrearNodoRosco(palabra));
    end;
    close(archivo);
    
    CargarRosco := lista;
end;

procedure MostrarRosco(var archivo : FileRosco); { Testeos }
var palabra : reg_palabra;
begin
    reset(archivo);
    while not eof(archivo) do
    begin
        read(archivo, palabra);
        WriteLn('----------');
        WriteLn(palabra.nro_set);
        WriteLn(palabra.letra);
        WriteLn(palabra.palabra);
        WriteLn(palabra.consigna);
        WriteLn('----------');
    end;
end;

procedure InicializarRosco(var archivo : FileRosco);
begin
    assign(archivo, ROSCOPATH);
end;
{ END: Sistema de Palabras }

{ BEGIN: Juego }
procedure AgregarJugadoresPartida(var APartida : ArregloPartida; AJugadores : ArbolJugadores);
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
            else if (i > 1) and (nombreJugador = APartida[i-1].NombreJugador) then { Funciona si sólo son 2 jugadores }
            begin
                WriteLn(nombreJugador, ' ya es el jugador ', i-1, ', seleccione otro!');
            end
            else
                jugadorValido := true;
        end;
        APartida[i].NombreJugador := nombreJugador;
    end;
end;

procedure CargarJugadoresRosco(var APartida : ArregloPartida; var FRosco : FileRosco);
var i : integer;
begin
    for i := 1 to MAXJUGADORES do
        APartida[i].Rosco := CargarRosco(FRosco, Random(5)+1);
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

procedure MostrarPalabra(var Rosco : ListaRosco);
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

procedure TurnoJugador(var Jugador : reg_partida; var finished : boolean);
var finTurno : boolean;
begin
    finTurno := false;
    WriteLn('Es el turno de ', Jugador.NombreJugador, '!');
    while not finTurno do
    begin
        MostrarPalabra(Jugador.Rosco);
        ResponderPalabra(Jugador.Rosco);

        if Jugador.Rosco^.Respuesta <> Acertada then
            finTurno := true;

        if ExistePendientes(Jugador.Rosco) then
            AvanzarRosco(Jugador.Rosco)
        else
        begin
            finished := true;
            finTurno := true;
        end;
    end;
end;

procedure Partida(var APartida : ArregloPartida);
var finPartida : boolean;
    turno : integer;
begin
    finPartida := false;
    turno := 1;
    while not finPartida do
    begin
        TurnoJugador(APartida[turno], finPartida);
        
        if turno < MAXJUGADORES then
            turno := turno + 1
        else
            turno := 1;
    end;
end;

procedure DefinirGanador(APartida : ArregloPartida; var AJugadores : ArbolJugadores; var FJugadores : FileJugadores);
begin
    if ContarAcertadas(APartida[1].Rosco) > ContarAcertadas(APartida[2].Rosco) then
    begin
        WriteLn(APartida[1].NombreJugador, ' ha ganado!');
        AgregarVictoriaJugador(AJugadores, FJugadores, APartida[1].NombreJugador);
    end
    else if ContarAcertadas(APartida[1].Rosco) < ContarAcertadas(APartida[2].Rosco) then
    begin
        WriteLn(APartida[2].NombreJugador, ' ha ganado!');
        AgregarVictoriaJugador(AJugadores, FJugadores, APartida[2].NombreJugador);
    end
    else
        WriteLn('Empate!');
end;

procedure IniciarJuego(var AJugadores : ArbolJugadores; var FJugadores : FileJugadores; var FRosco : FileRosco);
var APartida : ArregloPartida;
begin
    AgregarJugadoresPartida(APartida, AJugadores);
    CargarJugadoresRosco(APartida, FRosco);
    WriteLn('Comenzando partida...');
    Partida(APartida);
    DefinirGanador(APartida, AJugadores, FJugadores);
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