package gmdebug.dap.clients;


interface ClientInit {}


class ClientInitDef implements ClientInit {


}


enum ClientInitState {
    WAITING_FOR_LAUNCH;
    CONNECTED_TO_CONSOLE;
}