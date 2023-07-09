package gmdebug.dap;

interface OutputFilterer {

}

enum Filter {
    CLIENT_CONSOLE(id:Int);
    CLIENT_LUA(id:Int);
    SERVER_CONSOLE;
    SERVER_LUA;

}

class OutputFiltererDef {

    public function new() {

    }


    public function filter()
}