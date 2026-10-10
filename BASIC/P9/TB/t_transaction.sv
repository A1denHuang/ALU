class ac_transaction;
    rand logic [7:0] data;

    function new(
        logic [7:0] data = 0
    );
        this.data = data;
    endfunction

    function void display ();
        $display("[TRANS]data=%0d",data);
    endfunction
endclass
