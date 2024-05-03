/*global WebSocket,console:false */

/**
* @class TCCAgentWS
* Contiene métodos para comunicarse con la CCToolbar así como eventos para recibir notificaciones.
*
* @param port {Number} [required=true]
* Número de puerto que tiene la CCToolbar para establecer la conexión.
* @param host {String} [default="localhost"]
* Equipo donde se está ejecutando la CCToolbar, por defecto es "localhost".
*
* El uso básico de ésta clase será el siguiente:
*
*       @example
*       <script type="text/javascript">
*           // Se crea una instancia de la clase
*           var CCAgentWS = new TCCAgentWS(8890); // El host por defecto es LocalHost
*           // Implementación de los eventos
*           CCAgentWS.onToolbarConnect = function(msg){ alert("Conectado a la toolbar"); };
*           CCAgentWS.onToolbarClose = function(msg){ alert("Desconectado de la toolbar"); };
*           CCAgentWS.onToolbarError = function(msg){ alert("Error con la toolbar: code=" + msg.code + " - reason=" + msg.reason + " - wasClean=" + msg.wasClean + " - status=" + this.readyState);
*           // eventos que se reciben de la CCToolbar
*           CCAgentWS.onToolbarNotify = function(tbEvent){
*               switch (tbEvent.code) {
*                   case this.consts.tbEvents.Error:
*                       alert(tbEvent.data.error);
*                       break;
*                   case this.consts.tbEvents.statechange:
*                       switch (tbEvent.state) {
*                           case this.consts.states.Connect:
*                               // ...
*                               // lógica a implementar ...
*                               // ...
*                               break;
*                           // ...
*                       };
*                   // ...
*                   };
*           };
*           // se inicializa el CCAgentWS
*           CCAgentWS.init();
*     </script>
*/
function TCCAgentWS( port, host ) {
        "use strict";

        /**
        * Constantes que clasifican distintos tipos de comportamiento de la clase.
        * @static
        *
        * La clasificación es la siguiente:
        *
        * - commands: comandos que se envían a la CCToolbar.
        * - states: estados que notifica la CCToolbar.
        * - commTypes: tipos de comunicación.
        * - commDirection: dirección de la comunicación.
        * - tbEvents: eventos de la toolbar.
        * - callProgressCodes: códigos de un llamado en progreso.
        */
        this.consts = {};

        /**
        * Constantes de los comandos
        * @static
        */
        this.consts.commands = {
            /**
            * Atender una llamada
            */
            "AnswerCall": 1,

            /**
            * Alterna entre primera y segunda llamada
            */
            "AlternateCall": 2,
            
            /**
            * Agendar una llamada
            */
            "Callback": 23,

            /**
            * Consulta a interno de la PABX
            */
            "ConsultationExt": 5,

            /**
            * Consulta a puesto del subcentro
            */
            "ConsultationPos": 6,
            
            /**
            * No molestar
            */
            "DND": 9,

            /**
            * Finalizar una llamda
            */
            "EndCall": 10,

            /**
            * Cortar una llamada
            */
            "HangupCall": 12,

            /**
            * Retener una llamada
            */
            "HoldCall": 13,

            /**
            * Identificarse en la CCToolbar
            */
            "Login": 14,

            /**
            * Finalizar sesión en la CCToolbar
            */
            "Logout": 15,

            /**
            * Hacer una llamada
            */
            "MakeCall": 16,

            /**
            * Recuperar una llamada retenida
            */
            "RetrieveCall": 21,

            /**
            * Indicar a la CCToolbar que grabe la llamada
            */
            "RecordCall": 26,

            /**
            * Ponerse en espera para recibir una llamada
            */
            "WaitCall": 28,
            
            /**
            * Pone en conferencia con primera y segunda llamada
            */
            "ConferenceCall": 29,

            /**
            * Pide/cancela ayuda del supervisor
            */
            "SupervisorHelp": 30,

            /**
            * Código de cierre de la llamada
            */
            "CommResultCode": 49,
			"GetState": 36,
            
        };

        /**
        * Constantes de los estados
        * @static
        */
        this.consts.states = {
            /**
            * CnsCall
            */
            "CnsCall": 13,
            "Connect": 3,
            "Disconnect": 4,
            "DND": 8,
            "Hold": 9,
            "Idle": 2,
            "Login": 1,
            "Logout": 5,
            "Locked": 6,
            "Stop": 7,
            "OfhLgo": 10,
            "OfhIdl": 11,
            "OfhDND": 12,
            "Unknown": 0,
            "XtdCoach": 18,
            "XtdFull": 19,
            "XtdRO": 17
        };

        /**
        * Constantes de los tipos de comunicación
        * @static
        */
        this.consts.commTypes = {
            /**
            * Call
            */
            "Call": 1,
            "Consultation": 2,
            "TransferedCall": 3,
            "Unknown": 0
        };

        /**
        * Constantes de la dirección de la comunicación
        * @static
        */
        this.consts.commDirection = {
            /**
            * Incoming
            */
            "Incoming": 1,
            "None": 0,
            "Outgoing": 2
        };

        /**
        * Constantes de los eventos de la CCToolbar
        * @static {Object} tbEvents
        */
        this.consts.tbEvents = {
            /**
            * Evento desconocido
            */
            "unknown": 0,
            "answercall": 1,
            "alternatecall": 2,
            "consultationext": 5,
            "consultationpos": 6,
            "dnd": 9,
            "endcall": 10,
            "hangupcall": 12,
            "holdcall": 13,
            "login": 14,
            "logout": 15,
            "makecall": 16,
            "retrievecall": 21,
            "callback": 23,
            "recordcall": 26,
            "waitcall": 28,
            "conferencecall": 29,
            "supervisorhelp": 30,
            "commresultcode": 49,
            /**
            * DNDClientHangup
            */
            "dndclienthangup": 101,
            "datachange": 102,
            "backtoservice": 103,
            "call2hangup": 104,
            "consultationhangup": 105,
            "clienthangup": 106,
            "outofservice": 107,
            "makecall2": 108,
            "transferredcall": 109,
            "error": 110,
            "callprogress": 111,
            "statechange": 112,
            "returntoivr": 113
        };

        /**
        * Constantes de los códigos del progreso de una llamada
        * @static
        */
        this.consts.callProgressCodes = {
            /**
            * Llamando
            */
            "Calling": 4,
            /**
            * Ocupado
            */
            "Busy": 7,
            /**
            * No responde
            */
            "NoAnswer": 8,
            /**
            * No llama
            */
            "NoRing": 9,
            /**
            * Conectado
            */
            "Connect": 10,
            /**
            * Congestión
            */
            "Congestion": 11,
            /**
            * Se ha priorizado un llamado entrante
            */
            "Glare": 15,
            /**
            * No hay tono
            */
            "NoTone": 17,
            /**
            * Fax
            */
            "Fax": 18
        };

        /**
        * @property {Boolean}
        * Si es true escribe información de debug a la consola del navegador.
        */
        this.debug = false;
        /**
        * @property {Number}
        * Puerto de la CCToolbar a la que se debe conectar.
        */
        this.port = port;
        /**
        * @property host {String}
        * Equipo en donde se encuentra la CCToolbar, por defecto es "localhost".
        */
        this.host = host || "localhost";
        /**
        * @property url {String}
        * @readonly
        * URL hacia la CCToolbar que se genera automáticamente.
        */
        this.url = String( "ws://" ).concat( this.host ).concat( ":" ).concat( port ).concat( "/CCAgent" );
		//this.url = host;
        /**
        * @property cmd {String}
        * @private
        * Estructura de los mensajes JSON que se intercambian con la CCToolbar.
        * @readonly
        */
        this.cmd = '{"cmd":0,"params":[]}';
    
        /**
        * @event onToolbarNotify
        * Evento a través del cuál se reciben notificaciones de la CCToolbar.
        */
        this.onToolbarNotify = null;
    }

/**
* @method init
* Crea e inicializa el websocket.
*/
TCCAgentWS.prototype.init = function() {
    "use strict";
    var that = this;
    this.socket = new WebSocket( this.url, "CCAgentWSProtocol" );
    this.socket.onopen    = function( msg ) {
		console.log(msg);
        if ( that.debug ) {
            console.log( "onopen: Welcome - status " + this.readyState );
        }
        if ( typeof that.onToolbarConnect === "function" ) {
            that.onToolbarConnect( msg );
        }
    };

    this.socket.onmessage = function( msg ) {
        if ( that.debug ) {
            console.log( msg );
            console.log( "onmessage: (" + msg.data.length + " bytes): " + ( msg.data.length < 5000 ? msg.data : ( msg.data.substr( 0, 30 ) +  "..." ) ) );
        }
        that.internalOnMessage( msg );
    };

    this.socket.onerror   = function( msg ) {
        console.log( msg );
        console.log( "onerror - code:" + msg.code + ", reason:" + msg.reason + ", wasClean:" + msg.wasClean + ", status:" + this.readyState );
        if ( typeof that.onToolbarError === "function" ) {
            that.onToolbarError( msg );
        }
    };

    this.socket.onclose   = function( msg ) {
        if ( that.debug ) {
            console.log( msg );
            console.log( "onclose - code:" + msg.code + ", reason:" + msg.reason + ", wasClean:" + msg.wasClean + ", status:" + this.readyState );
        }
        if ( typeof that.onToolbarClose === "function" ) {
            that.onToolbarClose( msg );
        }
    };
};

/**
* @event internalOnMessage
* @private
* Esta función es invocada cuando se recibe un mensaje a través del socket. Siempre recibe un evento por parte de la CCToolbar.
*
* @param msg {Object}
* Mensaje JSON enviado por la CCToolbar.
*
* El formato JSON es el siquientes: {"name":"","code":,"result":,"data":}
* 
* - name: contiene el nombre del evento
* - code: código del evento
* - result: código de resultado donde 0 (cero) indica OK y cualquier otro valor un error
* - data: JSON con datos de la llamada.
*/
TCCAgentWS.prototype.internalOnMessage = function( msg ) {
    "use strict";
    var tbEvent = JSON.parse( msg.data );
    if ( typeof this.onToolbarNotify === "function" ) {
        this.onToolbarNotify( tbEvent );
    };
};

/**
* @method sendCommand
* @private
* Envía un comando a la toolbar a través de websocket.
*
* @param cmdcode {Number}
* Código del comando que se corresponde a TCCAgentWS.consts.commands.
* @param cmdparams {Array}
* JSON array con los valores de los parámetros a enviar a la CCToolbar.
*
* @returns
* True si pudo enviar el mensaje a través de websocket, false de lo contrario. En caso de error se envía a la consola o al evento onError si fué definido.
*/
TCCAgentWS.prototype.sendCommand = function( cmdcode, cmdparams ) {
    "use strict";

    // El socket no está abierto
    if ( this.socket.readyState !== 1 ) {
        return false;
    }
    var lCmd = JSON.parse( this.cmd );
    lCmd.cmd = cmdcode;
    if ( typeof cmdparams === "object" ) {
        lCmd.params = cmdparams;
    }
    try {
        this.socket.send( JSON.stringify( lCmd ) );
        return true;
    } catch ( ex ) {
        if ( typeof this.onError === "function" ) {
            this.onError( ex );
        } else {
            console.log( ex );
        }
        return false;
    }
};

/**
* @method alternateCall
* Alterna entre llamadas.
*/
TCCAgentWS.prototype.alternateCall = function() {
    "use strict";
    this.sendCommand( this.consts.commands.AlternateCall );
};

/**
* @method answerCall
* Atiende una llamada.
*/
TCCAgentWS.prototype.answerCall = function() {
    "use strict";
    this.sendCommand( this.consts.commands.AnswerCall );
};

TCCAgentWS.prototype.getState = function() {
    "use strict";
    this.sendCommand( this.consts.commands.GetState );
};


/**
* @method callBack
* Pone una fecha+hora de rellamada al mismo u otro teléfono.
*
* @param date {Date}
* Fecha de la nueva llamada.
* @param time {Date}
* Hora de la nueva llamada.
* @param phonenumber {String}
* Número de teléfono al que se llamará.
*/

TCCAgentWS.prototype.callBack = function( date, time, phonenumber ) {
    "use strict";
    var lparams = [ date, time, phonenumber ];
    this.sendCommand( this.consts.commands.CallBack, lparams );
};

/**
* @method commResultCode
* Pone un código de cierre de la llamada.
*
* @param tablename {String} 
* Nombre de la tabla de contactación donde se almacenará el código de cierre.
* @param tablerecord {Number} 
* Número del registro dentro de la tabla de contactación.
* @param commresultcode {Number} 
* Código de cierre de la llamada.
*/
TCCAgentWS.prototype.commResultCode = function( tablename, tablerecord, commresultcode ) {
    "use strict";
    var lparams = [ tablename, tablerecord, commresultcode ];
    this.sendCommand( this.consts.commands.CommResultCode, lparams );
};

/**
* @method conferenceCall
* Pone en conferencia con primera y segunda llamada.
*/
TCCAgentWS.prototype.conferenceCall = function() {
    "use strict";
    this.sendCommand( this.consts.commands.ConferenceCall );
};

/**
* @method consultationExt
* Consulta a interno de la PABX.
*
* @param ext {String} Extensión a consultar
*/
TCCAgentWS.prototype.consultationExt = function( ext ) {
    "use strict";
    var lparams = [ ext ];
    this.sendCommand( this.consts.commands.ConsultationExt, lparams );
};

/**
* @method consultationPos
* Consulta a puesto del subcentro.
*
* @param destwsnumber {Number}
* Número de puesto a consultar
* @param subject {String}
* Asunto de la consulta
*/
TCCAgentWS.prototype.consultationPos = function( destwsnumber, subject ) {
    "use strict";
    var lparams = [ destwsnumber, subject ];
    this.sendCommand( this.consts.commands.ConsultationPos, lparams );
};

/**
* @method dnd
* Pasa el puesto a "no molestar".
*
* @param reason {Integer} Motivo de la no atención
*/
TCCAgentWS.prototype.dnd = function( reason ) {
    "use strict";
    var lparams;
    if (reason == "" || reason > 14) {
        lparams = [ 0 ];
    } else {
        lparams = [ reason ];
    }
    this.sendCommand( this.consts.commands.DND, lparams );
};

/**
* @method endCall
* Finaliza la comunicación en curso.
*/
TCCAgentWS.prototype.endCall = function() {
    "use strict";
    this.sendCommand( this.consts.commands.EndCall );
};

/**
* @method hangupCall
* Corta la comunicación en curso.
*
* @param returncode
* Código de retorno.
* @param appparm
* Parámetros asociados al código de retorno.
*/
TCCAgentWS.prototype.hangupCall = function(returncode, appparm) {
    "use strict";
    var lparams = [returncode, appparm]
    this.sendCommand( this.consts.commands.HangupCall, lparams );
};

/**
* @method holdCall
* Retiene la llamada en curso.
*/
TCCAgentWS.prototype.holdCall = function() {
    "use strict";
    this.sendCommand( this.consts.commands.HoldCall );
};

/**
* @method login
* Envía a la CCToolbar la identificación del agente para su validación.
*
* @param agentID {String}
* Identificador del agente.
* @param agentPassword {String}
* Contraseña del agente.
*/
TCCAgentWS.prototype.login = function( agentID, agentPassword ) {
    "use strict";
    var lparams = [ agentID, agentPassword ];
    this.sendCommand( this.consts.commands.Login, lparams );
};

/**
* @method logout
* Finaliza la sesión del agente en la CCToolbar.
*/
TCCAgentWS.prototype.logout = function() {
    "use strict";
    this.sendCommand( this.consts.commands.Logout );
};

/**
* @method makeCall
* Realiza una llamada.
*
* @param phone {String}
* Número de teléfono a llamar.
* @param alias {String}
* Alias o comentario
*/
TCCAgentWS.prototype.makeCall = function( phone, comment ) {
    "use strict";
    var lparams = [ phone, comment || "" ];
    this.sendCommand( this.consts.commands.MakeCall, lparams );
};

/**
* @method retrieveCall
* Recupera una llamada retenida.
*/
TCCAgentWS.prototype.retrieveCall = function() {
    "use strict";
    this.sendCommand( this.consts.commands.RetrieveCall );
};

/**
* @method recordCall
* Notifica a la CCToolbar que grabe la llamada en curso.
*
* @param comment {String}
* Comentario sobre la grabación.
*/
TCCAgentWS.prototype.recordCall = function( comment ) {
    "use strict";
    var lparams = [ comment ];
    this.sendCommand( this.consts.commands.RecordCall, lparams );
};

/**
* @method returnToIVR
* Devuelve la llamada al IVR.
*
* @param returncode {Number}
* Código de retorno.
* @param appparam {String}
* Párametros recibidos en el modelo de conversación enviados por una aplicación.
*/
TCCAgentWS.prototype.returnToIVR = function( returncode, appparam ) {
    "use strict";
    var lparams = [ returncode, appparam ];
    this.sendCommand( this.consts.commands.HangupCall, lparams );
};

/**
* @method supervisorHelp
* Pide/cancela ayuda del supervisor.
*
* @param help {Boolean}
* Si es true pide ayuda, sino cancela.
*/
TCCAgentWS.prototype.supervisorHelp = function( help ) {
    "use strict";
    var lparams = [ help ];
    this.sendCommand( this.consts.commands.SupervisorHelp, lparams );
};

/**
* @method waitCall
* Se pone en espera para recibir una llamada.
*/
TCCAgentWS.prototype.waitCall = function() {
    "use strict";
    this.sendCommand( this.consts.commands.WaitCall );
};

