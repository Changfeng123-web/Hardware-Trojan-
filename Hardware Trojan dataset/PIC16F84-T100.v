
`define STATEBIT_SIZE 3     

module pic_16f84_core (
  prog_dat_i,           
  prog_adr_o,       
  ram_dat_i,            
  ram_dat_o,            
  ram_adr_o,           
  readram_o,            
  writeram_o,           
  existeeprom_i,     
  eep_dat_i,           
  eep_dat_o,            
  eep_adr_o,           
  rd_eep_req_o,        
  rd_eep_ack_i,      
  wr_eep_req_o,         
  wr_eep_ack_i,     
  porta_i,           
  porta_o,             
  porta_dir_o,          
  portb_i,              
  portb_o,          
  portb_dir_o,          
  rbpu_o,             
  int0_i,            
  int4_i,               
  int5_i,              
  int6_i,          
  int7_i,              
  t0cki_i,             
  wdt_ena_i,            
  wdt_clk_i,            
  wdt_full_o,          
  powerdown_o,         
  startclk_o,           
  pon_rst_n_i,          
  mclr_n_i,             
  clk_i,                
  clk_o                
);



parameter STACK_SIZE_PP      = 8;   
parameter LOG2_STACK_SIZE_PP = 3;   
parameter WDT_SIZE_PP        = 255; 
parameter WDT_BITS_PP        = 8;   


parameter QRESET_PP = 3'b100; 
parameter Q1_PP     = 3'b000; 
parameter Q2_PP     = 3'b001; 
parameter Q3_PP     = 3'b011; 
parameter Q4_PP     = 3'b010; 



input  [13:0] prog_dat_i; 
output [12:0] prog_adr_o;   

 
input  [7:0] ram_dat_i;    
output [7:0] ram_dat_o;     
output [8:0] ram_adr_o; 
output readram_o;          
output writeram_o;      


input  existeeprom_i; 
input  [7:0] eep_dat_i;     
output [7:0] eep_dat_o;    
output [7:0] eep_adr_o;     
output rd_eep_req_o;       
input  rd_eep_ack_i;       
output wr_eep_req_o;      
input  wr_eep_ack_i;   

     
input  [4:0] porta_i;     
output [4:0] porta_o;       
output [4:0] porta_dir_o;   
input  [7:0] portb_i;   
output [7:0] portb_o;       
output [7:0] portb_dir_o;  
output rbpu_o;            

       
input  int0_i;             
input  int4_i;              
input  int5_i;             
input  int6_i;           
input  int7_i;              

      
input  t0cki_i;         

    
input  wdt_ena_i;           
input  wdt_clk_i;         
output wdt_full_o;          

   
output powerdown_o;        
output startclk_o;          
       
input  pon_rst_n_i;    
input  mclr_n_i;         

 
input  clk_i;               
output clk_o;               

reg  [7:0] w_reg;           
reg  [7:0] tmr0_reg;        
reg  [12:0] pc_reg;          
reg  [7:0] status_reg;       
reg  [7:0] fsr_reg;          
reg  [4:0] porta_i_sync_reg; 
reg  [4:0] porta_o_reg;    
reg  [7:0] portb_i_sync_reg; 
reg  [7:0] portb_o_reg;     
reg  [7:0] eep_dat_reg;     
reg  [7:0] eep_adr_reg;    
reg  [4:0] pclath_reg;    
reg  [7:0] intcon_reg;     
reg  [7:0] option_reg;       
reg  [4:0] trisa_reg;       
reg  [7:0] trisb_reg;       
reg  [4:0] eecon1_reg;       

    
reg  [13:0] inst_reg;       
reg  [7:0] aluinp1_reg;     
reg  [7:0] aluinp2_reg;      
reg        c_in;          
reg  [7:0] aluout_reg;       
reg  exec_op_reg;           
reg  intstart_reg;         
reg  sleepflag_reg;         

     
                             
reg  [12:0] stack_reg [STACK_SIZE_PP-1:0];
                            
reg  [LOG2_STACK_SIZE_PP-1:0] stack_pnt_reg;

  l
reg  [WDT_BITS_PP-1:0] wdt_reg;  
reg  wdt_full_reg;               
                               
reg  wdt_full_node;
wire wdt_init;                  
reg  [2:0] wdt_full_sync_reg;   
reg  wdt_clr_reg;                
reg  wdt_clr_reqhold_reg;        
                             
reg  [1:0] wdt_clr_req_reg;     
wire wdt_clr_ack;              
                             
reg  wdt_clr_ack_sync_reg;       
reg  wdt_full_clr_reg;          
reg  [1:0] wdt_fullclr_req_reg;  


wire ps_clk;                  
reg  [7:0] pscale_reg;       
reg  ps_full_reg;         
wire inc_tmr_clk;             
reg  inc_tmr_hold_reg;        
reg  [7:0] rateval;     

  
reg  [4:0] intrise_reg;     
reg  [4:0] intdown_reg;      
                            
wire rb0_int;
wire rb4_int;
wire rb5_int;
wire rb6_int;
wire rb7_int;

wire rbint;                 
wire inte;                    
reg  [4:0] intclr_reg;      
wire intclr0;            
wire intclr1;                
wire intclr2;                 
wire intclr3;             
wire intclr4;

  
reg  [`STATEBIT_SIZE-1:0] state_reg;

  
wire inst_addlw;
wire inst_addwf;
wire inst_andlw;
wire inst_andwf;
wire inst_bcf;
wire inst_bsf;
wire inst_btfsc;
wire inst_btfss;
wire inst_call;
wire inst_clrf;
wire inst_clrw;
wire inst_clrwdt;
wire inst_comf;
wire inst_decf;
wire inst_decfsz;
wire inst_goto;
wire inst_incf;
wire inst_incfsz;
wire inst_iorlw;
wire inst_iorwf;
wire inst_movlw;
wire inst_movf;
wire inst_movwf;
wire inst_retfie;
wire inst_retlw;
wire inst_ret;
wire inst_rlf;
wire inst_rrf;
wire inst_sleep;
wire inst_sublw;
wire inst_subwf;
wire inst_swapf;
wire inst_xorlw;
wire inst_xorwf;

 
wire [8:0] ram_adr_node;      

wire addr_tmr0;
wire addr_pcl;
wire addr_stat;
wire addr_fsr;
wire addr_porta;
wire addr_portb;
wire addr_eep_dat;
wire addr_eep_adr;
wire addr_pclath;
wire addr_intcon;
wire addr_option;
wire addr_trisa;
wire addr_trisb;
wire addr_eecon1;
wire addr_eecon2;
wire addr_sram;

  
reg  writeram_reg;     
reg  [8:0] ram_adr_reg; 
reg  clk_o_reg;      

  
reg  inte_sync_reg;
reg  rbint_sync_reg;
reg  [1:0] inc_tmr_sync_reg;
reg  rd_eep_sync_reg;
reg  wr_eep_sync_reg;
reg  mclr_sync_reg;
reg  poweron_sync_reg;


reg  [7:0] ram_i_node;  
reg  [12:0] inc_pc_node;
wire [7:0] mask_node;  
reg  [8:0] add_node;    
reg  [4:0] addlow_node; 


reg  aluout_zero_node;  
reg  writew_node;       
reg  writeram_node;      
reg  int_node;           
reg  wdt_rst_node;      
reg  reset_cond;         


reg  [12:0] Counter;
reg  [12:0] prog_adr_o;

always @(posedge clk_i)
begin
  inte_sync_reg          <= inte;
  rbint_sync_reg         <= rbint;
  wdt_clr_ack_sync_reg   <= wdt_clr_ack;
  mclr_sync_reg          <= mclr_n_i;
  poweron_sync_reg       <= pon_rst_n_i;
  rd_eep_sync_reg        <= rd_eep_ack_i;
  wr_eep_sync_reg        <= wr_eep_ack_i;
  inc_tmr_sync_reg[0]    <= inc_tmr_clk;
  inc_tmr_sync_reg[1]    <= inc_tmr_sync_reg[0];
  if (~poweron_sync_reg || ~mclr_sync_reg)
    wdt_full_sync_reg    <= 3'b0;
  else
  begin
    wdt_full_sync_reg[0] <= wdt_full_reg;
    wdt_full_sync_reg[1] <= wdt_full_sync_reg[0]; // (remove meta-stability)
    wdt_full_sync_reg[2] <= wdt_full_sync_reg[1]; // (detect positive edge)
  end
end



assign inst_call     = (inst_reg[13:11] ==  3'b100           );
assign inst_goto     = (inst_reg[13:11] ==  3'b101           );
assign inst_bcf      = (inst_reg[13:10] ==  4'b0100          );
assign inst_bsf      = (inst_reg[13:10] ==  4'b0101          );
assign inst_btfsc    = (inst_reg[13:10] ==  4'b0110          );
assign inst_btfss    = (inst_reg[13:10] ==  4'b0111          );
assign inst_movlw    = (inst_reg[13:10] ==  4'b1100          );
assign inst_retlw    = (inst_reg[13:10] ==  4'b1101          );
assign inst_sublw    = (inst_reg[13:9]  ==  5'b11110         );
assign inst_addlw    = (inst_reg[13:9]  ==  5'b11111         );
assign inst_iorlw    = (inst_reg[13:8]  ==  6'b111000        );
assign inst_andlw    = (inst_reg[13:8]  ==  6'b111001        );
assign inst_xorlw    = (inst_reg[13:8]  ==  6'b111010        );
assign inst_subwf    = (inst_reg[13:8]  ==  6'b000010        );
assign inst_decf     = (inst_reg[13:8]  ==  6'b000011        );
assign inst_iorwf    = (inst_reg[13:8]  ==  6'b000100        );
assign inst_andwf    = (inst_reg[13:8]  ==  6'b000101        );
assign inst_xorwf    = (inst_reg[13:8]  ==  6'b000110        );
assign inst_addwf    = (inst_reg[13:8]  ==  6'b000111        );
assign inst_movf     = (inst_reg[13:8]  ==  6'b001000        );
assign inst_comf     = (inst_reg[13:8]  ==  6'b001001        );
assign inst_incf     = (inst_reg[13:8]  ==  6'b001010        );
assign inst_decfsz   = (inst_reg[13:8]  ==  6'b001011        );
assign inst_rrf      = (inst_reg[13:8]  ==  6'b001100        );
assign inst_rlf      = (inst_reg[13:8]  ==  6'b001101        );
assign inst_swapf    = (inst_reg[13:8]  ==  6'b001110        );
assign inst_incfsz   = (inst_reg[13:8]  ==  6'b001111        );
assign inst_movwf    = (inst_reg[13:7]  ==  7'b0000001       );
assign inst_clrw     = (inst_reg[13:7]  ==  7'b0000010       );
assign inst_clrf     = (inst_reg[13:7]  ==  7'b0000011       );
assign inst_ret      = (inst_reg[13:0]  == 14'b00000000001000);
assign inst_retfie   = (inst_reg[13:0]  == 14'b00000000001001);
assign inst_sleep    = (inst_reg[13:0]  == 14'b00000001100011);
assign inst_clrwdt   = (inst_reg[13:0]  == 14'b00000001100100);



assign ram_adr_node = (inst_reg[6:0]==0)?{status_reg[7],fsr_reg[7:0]}:
                               {status_reg[6:5],inst_reg[6:0]};

 
assign addr_sram   = (ram_adr_node[6:0] > 7'b0001011); 

assign addr_tmr0    = (ram_adr_node[7:0] == 8'b00000001); 
assign addr_pcl     = (ram_adr_node[6:0] ==  7'b0000010); 
assign addr_stat    = (ram_adr_node[6:0] ==  7'b0000011);
assign addr_fsr     = (ram_adr_node[6:0] ==  7'b0000100); 
assign addr_porta   = (ram_adr_node[7:0] == 8'b00000101); 
assign addr_portb   = (ram_adr_node[7:0] == 8'b00000110); 
assign addr_eep_dat = (ram_adr_node[7:0] == 8'b00001000); 
assign addr_eep_adr = (ram_adr_node[7:0] == 8'b00001001); 
assign addr_pclath  = (ram_adr_node[6:0] ==  7'b0001010); 
assign addr_intcon  = (ram_adr_node[6:0] ==  7'b0001011); 
assign addr_option  = (ram_adr_node[7:0] == 8'b10000001); 
assign addr_trisa   = (ram_adr_node[7:0] == 8'b10000101); 
assign addr_trisb   = (ram_adr_node[7:0] == 8'b10000110);
assign addr_eecon1  = (ram_adr_node[7:0] == 8'b10001000); 
assign addr_eecon2  = (ram_adr_node[7:0] == 8'b10001001); 


assign mask_node = 1 << inst_reg[9:7];


always @(posedge clk_i)
begin

  if (addr_sram)         ram_i_node <= ram_dat_i;  
  else if (addr_eep_dat) ram_i_node <= eep_dat_reg;
  else if (addr_tmr0)    ram_i_node <= tmr0_reg;    
  else if (addr_pcl)     ram_i_node <= pc_reg[7:0]; 
  else if (addr_stat)    ram_i_node <= status_reg;  
  else if (addr_fsr)     ram_i_node <= fsr_reg;     
  else if (addr_porta)
  begin
  
    ram_i_node[4:0] <= (
                           (~trisa_reg[4:0] & porta_o_reg[4:0])
                        || ( trisa_reg[4:0] & porta_i_sync_reg[4:0])
                        );
    ram_i_node[7:5] <= 3'b0;
  end
  else if (addr_portb)
  begin
   
    ram_i_node[7:0] <= (
                           (~trisb_reg[7:0] & portb_o_reg[7:0])
                        || ( trisb_reg[7:0] & portb_i_sync_reg[7:0])
                        );
  end
  else if (addr_eep_adr) ram_i_node <= eep_adr_reg;   
  else if (addr_pclath)  ram_i_node <= {3'b0,pclath_reg};
  else if (addr_intcon)  ram_i_node <= intcon_reg;      
  else if (addr_option)  ram_i_node <= option_reg;     
  else if (addr_trisa)   ram_i_node <= {3'b0,trisa_reg};  
  else if (addr_trisb)   ram_i_node <= trisb_reg;         
  else if (addr_eecon1)  ram_i_node <= {3'b0,eecon1_reg}; 
  else ram_i_node <= 0;


 
  inc_pc_node  <= pc_reg + 1;


 
  {add_node,temp}     <=    {1'b0,aluinp1_reg,1'b1} 
                          + {1'b0,aluinp2_reg,c_in};
  
  {addlow_node,dtemp} <=    {1'b0,aluinp1_reg[3:0],1'b1} 
                          + {1'b0,aluinp2_reg[3:0],c_in};


  aluout_zero_node <= (aluout_reg == 0)?1:0;


  if (intstart_reg)
  begin
    writew_node     <= 0;
    writeram_node   <= 0;
  end
  else if (inst_movwf || inst_bcf || inst_bsf || inst_clrf)
  begin
    writew_node     <= 0;
    writeram_node   <= 1;
  end
  else if (   inst_movlw || inst_addlw || inst_sublw || inst_andlw 
           || inst_iorlw || inst_xorlw || inst_retlw || inst_clrw)
  begin
    writew_node     <= 1;
    writeram_node   <= 0;
  end
  else if (   inst_movf   || inst_swapf || inst_addwf || inst_subwf
           || inst_andwf  || inst_iorwf || inst_xorwf || inst_decf 
           || inst_incf   || inst_rlf   || inst_rrf   || inst_decfsz 
           || inst_incfsz || inst_comf)
  begin
    writew_node     <= ~inst_reg[7];  
    writeram_node   <=  inst_reg[7]; 
  end
  else
  begin
    writew_node     <= 0;
    writeram_node   <= 0;
  end

  int_node <= intcon_reg[7]      
              && (
                     (intcon_reg[3] && intcon_reg[0])
                  || (intcon_reg[4] && intcon_reg[1]) 
                  || (intcon_reg[5] && intcon_reg[2]) 
                  || (intcon_reg[6] && eecon1_reg[4]) 
                  );


  wdt_rst_node <= wdt_full_sync_reg[1] && ~wdt_full_sync_reg[2];  


  if (~poweron_sync_reg || ~mclr_sync_reg || wdt_rst_node) reset_cond  <= 1;
  else reset_cond  <= 0;

  case (state_reg)

   
    QRESET_PP :
    begin
      pc_reg          <= 0;    
      status_reg[7:5] <= 3'b0;
      pclath_reg      <= 0;    
      intcon_reg[7:1] <= 7'b0;
      option_reg      <= -1;    
      trisa_reg       <= -1; 
      trisb_reg       <= -1;   
      tmr0_reg        <= 0;     
      exec_op_reg     <= 0;
      intclr_reg      <= -1;    
      intstart_reg    <= 0;
      writeram_reg    <= 0;
      sleepflag_reg   <= 0;

    
      if (~poweron_sync_reg)    
      begin
        status_reg[4] <= 1;      
        status_reg[3] <= 1;      
        stack_pnt_reg <= 0;   
      end
      else if (~mclr_sync_reg)    
      begin
        status_reg[4]       <= 1;                
       
        status_reg[3]       <= ~sleepflag_reg;
      end
      else if (wdt_rst_node)   
      begin
        status_reg[4]       <= 0;          
        
        status_reg[3]       <= ~sleepflag_reg;  
      end

      eecon1_reg[4]    <= 0;
      eecon1_reg[2:0]  <= 3'b0;
      
      if (~poweron_sync_reg) eecon1_reg[3] <= 0; 
      else eecon1_reg[3] <= eecon1_reg[1];  


      if (~reset_cond) state_reg <= Q1_PP;

    end  


    
    Q1_PP :
    begin
    
      if (intcon_reg[7]) intclr_reg <= 0;
      else intclr_reg <= 1;   

      
      porta_i_sync_reg    <= porta_i;
      portb_i_sync_reg    <= portb_i;

      
      if (~intstart_reg)
      begin
        if (eecon1_reg[0] && rd_eep_sync_reg)
        begin
          eep_dat_reg    <= eep_dat_i;
          eecon1_reg[0] <= 0;                 
        end
        if (eecon1_reg[1] && wr_eep_sync_reg) 
        begin
          if (intcon_reg[7] && intcon_reg[6])
            eecon1_reg[4] <= 1;        
          eecon1_reg[1]   <= 0;         
        end
        if (exec_op_reg) ram_adr_reg <= ram_adr_node;
      end

    
      if (inc_tmr_sync_reg == 2'b01) inc_tmr_hold_reg <= 1;


      
      if (reset_cond) state_reg <= QRESET_PP;
      else
       
        if (sleepflag_reg && ~intstart_reg)
        begin
          if (inte_sync_reg || rbint_sync_reg)
          begin
          
            sleepflag_reg <= 0;
            state_reg     <= Q2_PP;
          end
        end
        
        else state_reg   <= Q2_PP;

    end   // End of Q1 state

 
    Q2_PP :
    begin
   
      if (exec_op_reg && ~intstart_reg)  
      begin
        
        if (   inst_movf   || inst_swapf || inst_addwf || inst_subwf
            || inst_andwf  || inst_iorwf || inst_xorwf || inst_decf
            || inst_incf   || inst_rlf   || inst_rrf   || inst_bcf
            || inst_bsf    || inst_btfsc || inst_btfss || inst_decfsz
            || inst_incfsz || inst_comf)
            
            aluinp1_reg <= ram_i_node;     
        else
        if (   inst_movlw || inst_addlw || inst_sublw || inst_andlw
            || inst_iorlw || inst_xorlw || inst_retlw)
            
            aluinp1_reg <= inst_reg[7:0];   
        else
        if (   inst_clrf  || inst_clrw) aluinp1_reg <= 0; 
        else aluinp1_reg <= w_reg;                   

     
        if      (inst_decf || inst_decfsz) aluinp2_reg <= -1; 
        else if (inst_incf || inst_incfsz) aluinp2_reg <=  1; 
              
        else if (inst_sublw || inst_subwf) aluinp2_reg <= ~w_reg + 1; 
              
        else if (inst_bcf) aluinp2_reg <= ~mask_node; 
             
        else if (inst_btfsc || inst_btfss || inst_bsf)
                                      aluinp2_reg <= mask_node;
        else aluinp2_reg <= w_reg; 

        
        if (inst_ret || inst_retlw || inst_retfie)
             stack_pnt_reg   <= stack_pnt_reg - 1;

        
        ram_adr_reg  <= ram_adr_node; 
      end

    
      clk_o_reg  <= 1;

     
      if (inc_tmr_sync_reg == 2'b01) inc_tmr_hold_reg <= 1;

     
      if (reset_cond) state_reg <= QRESET_PP;
      else state_reg <= Q3_PP;
    end   


    Q3_PP :
    begin
 
      if (exec_op_reg && ~intstart_reg) // if NOT STALLED
      begin
     
        if      (inst_rlf) 
                aluout_reg <= {aluinp1_reg[6:0],status_reg[0]};
             
        else if (inst_rrf) 
                aluout_reg  <= {status_reg[0],aluinp1_reg[7:1]};
                
        else if (inst_swapf)
                aluout_reg <= {aluinp1_reg[3:0],aluinp1_reg[7:4]};
        
        else if (inst_comf)
                aluout_reg  <= ~aluinp1_reg;
               
        else if (   inst_andlw || inst_andwf || inst_bcf || inst_btfsc
                 || inst_btfss) 
                aluout_reg  <= (aluinp1_reg & aluinp2_reg);
             
        else if (inst_bsf || inst_iorlw || inst_iorwf)
                aluout_reg  <= (aluinp1_reg | aluinp2_reg);
             
        else if (inst_xorlw || inst_xorwf)
                aluout_reg  <= (aluinp1_reg ^ aluinp2_reg);
        
        else if (  inst_addlw || inst_addwf  || inst_sublw || inst_subwf
                 || inst_decf || inst_decfsz || inst_incf  || inst_incfsz)
                aluout_reg  <= add_node[7:0];
          
        else aluout_reg  <= aluinp1_reg;

      
        if (inst_addlw || inst_addwf || inst_sublw || inst_subwf)
        begin
          status_reg[1]   <= addlow_node[4];  
          status_reg[0]   <= add_node[8]; 
        end
        else if (inst_rlf) status_reg[0] <= aluinp1_reg[7];  
        else if (inst_rrf) status_reg[0] <= aluinp1_reg[0];  
     
        if (writeram_node && addr_sram) writeram_reg <= 1;
        else writeram_reg <= 0;

      end
      else writeram_reg <= 0; 

      
      if (~intstart_reg && intcon_reg[7]) 
      begin
       
        if (inte_sync_reg)
        begin
          intcon_reg[1] <= 1;   
          intclr_reg[0] <= 1;    
                                
        end
   
        if (rbint_sync_reg)
        begin
          intcon_reg[0]   <= 1;   
          intclr_reg[4:1] <= -1;  
                                  
        end
      end

   
      if (inc_tmr_hold_reg || (inc_tmr_sync_reg == 2'b01)) 
      begin
        tmr0_reg          <= tmr0_reg + 1;   
        inc_tmr_hold_reg  <= 0;

      
        if (
               ~intstart_reg 
            && intcon_reg[7]
            && intcon_reg[5] 
            && (tmr0_reg == -1)
            )
              intcon_reg[2] <= 1;           
      end

    
      if (reset_cond) state_reg   <= QRESET_PP;
      else            state_reg   <= Q4_PP;

    end   



    Q4_PP :
    begin
      
      inst_reg    <= prog_dat_i;

      if (~exec_op_reg && ~intstart_reg)    
      begin
        pc_reg          <= inc_pc_node; 
        exec_op_reg     <= 1;          
      end
      else 
      begin
       
        if (writew_node) w_reg   <= aluout_reg;  

   
        if (writeram_node)
        begin
          if (addr_stat)
          begin
            status_reg[7:5] <= aluout_reg[7:5];      
            status_reg[1:0] <= aluout_reg[1:0];      
          end
          if (addr_fsr)         fsr_reg <= aluout_reg;      
          if (addr_porta)   porta_o_reg <= aluout_reg[4:0]; 
          if (addr_portb)   portb_o_reg <= aluout_reg;      
          if (addr_eep_dat) eep_dat_reg <= aluout_reg;      
          if (addr_eep_adr) eep_adr_reg <= aluout_reg;  
          if (addr_pclath)   pclath_reg <= aluout_reg[4:0]; 
          if (addr_intcon) intcon_reg[6:0] <= aluout_reg[6:0]; 
                         
          if (addr_option)   option_reg <= aluout_reg;      
          if (addr_trisa)     trisa_reg <= aluout_reg[4:0];
          if (addr_trisb)     trisb_reg <= aluout_reg;      
          if (addr_tmr0)       tmr0_reg <= aluout_reg;      
          if (addr_eecon1)                                  
          begin
            eecon1_reg[4:3] <= aluout_reg[4:3];
            eecon1_reg[2]   <= aluout_reg[2] && existeeprom_i; 
           
            if (aluout_reg[2:0] == 3'b110) eecon1_reg[1]   <= 1;
          
            if (aluout_reg[1:0] == 2'b01) eecon1_reg[0]   <= 1;
        
          end
        end


        if (~intstart_reg)
        begin
          if (addr_stat) status_reg[2] <= aluout_reg[2];
          else if (   inst_addlw || inst_addwf || inst_andlw || inst_andwf
                   || inst_clrf  || inst_clrw  || inst_comf  || inst_decf
                   || inst_incf  || inst_movf  || inst_sublw || inst_subwf
                   || inst_xorlw || inst_xorwf)
                  status_reg[2] <= aluout_zero_node; 
          else if (inst_iorlw || inst_iorwf)
                  
                  status_reg[2] <= ~aluout_zero_node;
           
        end

   
        if (intstart_reg) 
        begin
          pc_reg      <= 4;    
          exec_op_reg <= 0;     
        end
        else if (inst_ret || inst_retlw || inst_retfie) 
        begin
          pc_reg      <= stack_reg[stack_pnt_reg];
          exec_op_reg <= 0;             
        end
        else if (inst_goto || inst_call) 
        begin
         
          pc_reg      <= {pclath_reg[4:3],inst_reg[10:0]};
          exec_op_reg <= 0;
        end
        else if ( (   (inst_btfsc || inst_decfsz || inst_incfsz) 
                       && aluout_zero_node)
                   || (inst_btfss && ~aluout_zero_node)
                   ) 
        begin
          pc_reg      <= inc_pc_node;
          exec_op_reg <= 0;
          
        end
        else if (writeram_node && addr_pcl)
        begin
         
          pc_reg      <= pclath_reg[4:0] & aluout_reg;
          exec_op_reg <= 0;
        end
        else
        begin
         
          if (~int_node) pc_reg <= inc_pc_node; 
         
          else pc_reg <= pc_reg; 
         
          exec_op_reg <= 1;
        end

       
        if (inst_call || intstart_reg)
       
        begin
          stack_reg[stack_pnt_reg] <= pc_reg;
          stack_pnt_reg <= stack_pnt_reg + 1;
        end

        
        if (~intstart_reg)
        begin
          if (int_node) // interrupt trigger comes
          begin
            intcon_reg[7] <= 0; 
            intstart_reg  <= 1;
          end
          else if (inst_retfie) 
          begin
            intcon_reg[7] <= 1;
            intstart_reg  <= 0;
          end
          else if (writeram_node && addr_intcon) 
          begin
            intcon_reg[7] <= aluout_reg[7];
            intstart_reg  <= 0;
          end
          else intstart_reg <= 0;
        end
        else intstart_reg <= 0;

    
        if (~intstart_reg)
          if (    inst_clrwdt
              || (inst_sleep && (~wdt_rst_node && ~intstart_reg)) )
              
             if (inst_sleep)
             begin
               sleepflag_reg <= 1;
               status_reg[4:3] <= 2'b10;   
             end
             else status_reg[4:3] <= 2'b11;

      end 

      writeram_reg <= 0;

    
      clk_o_reg <= 0;

      
      if (inc_tmr_sync_reg == 2'b01) inc_tmr_hold_reg  <= 1;

     
      if (reset_cond) state_reg   <= QRESET_PP;
      else state_reg   <= Q1_PP;
    end   
    default : state_reg   <= QRESET_PP;    
    endcase
end  



assign ps_clk = option_reg[5]?(t0cki_i ^ option_reg[4]):clk_o_reg;



always @(posedge ps_clk or negedge pon_rst_n_i)
begin
  if (~pon_rst_n_i)
  begin
    pscale_reg  <= 0;
    ps_full_reg <= 0;
  end
  else
  begin
    case (option_reg[2:0])  
      3'b000 : rateval <= 1;
      3'b001 : rateval <= 3;
      3'b010 : rateval <= 7;
      3'b011 : rateval <= 15;
      3'b100 : rateval <= 31;
      3'b101 : rateval <= 63;
      3'b110 : rateval <= 127;
      3'b111 : rateval <= 255;
      default: rateval <= 1;
    endcase

    if (pscale_reg >= rateval)
    begin
      pscale_reg  <= 0;
      ps_full_reg <= 1;
    end
    else
    begin
      pscale_reg  <= pscale_reg + 1;
      ps_full_reg <= 0;
    end
  end
end 
assign inc_tmr_clk =  option_reg[3]?ps_clk:ps_full_reg;



assign wdt_init = ~pon_rst_n_i || ~mclr_n_i;

always @(posedge wdt_clk_i or posedge wdt_init)
begin
  if (wdt_init) 
  begin
    wdt_reg              <= 0;
    wdt_full_reg         <= 0;
    wdt_clr_req_reg      <= 2'b0;
    wdt_fullclr_req_reg  <= 2'b0;
  end
  else 
  begin
    wdt_clr_req_reg[0]     <= wdt_clr_reg;     
    wdt_clr_req_reg[1]     <= wdt_clr_req_reg[0];
 
    wdt_fullclr_req_reg[0] <= wdt_full_clr_reg && ~sleepflag_reg;
    wdt_fullclr_req_reg[1] <= wdt_fullclr_req_reg[0];

   
    if (wdt_reg >= WDT_SIZE_PP) wdt_full_node <= 1; 
    else wdt_full_node    <= 0;    

 
    if ((wdt_clr_req_reg == 2'b01) || ~wdt_ena_i) wdt_reg <= 0;
    else if (wdt_full_node) wdt_reg <= 0;
    else wdt_reg <= wdt_reg + 1;


    if ((wdt_fullclr_req_reg == 2'b01) || ~wdt_ena_i) wdt_full_reg <= 0;
    else if (wdt_full_node) wdt_full_reg <= 1;
  end
end 
assign wdt_clr_ack = wdt_clr_req_reg[1]; 
assign wdt_full_o = wdt_full_reg;       



always @(posedge clk_i)
begin
  if (~poweron_sync_reg || ~mclr_sync_reg)
  begin
    wdt_clr_reg         <= 0; 
    wdt_clr_reqhold_reg <= 0; 
    wdt_full_clr_reg    <= 0; 
  end
  else
  begin
  
    if (wdt_clr_reg) 
   
      if (wdt_clr_ack_sync_reg) wdt_clr_reg <= 0;
    else if (    wdt_clr_reqhold_reg
             || ( (state_reg == Q4_PP)
                   && exec_op_reg && ~intstart_reg
                   && (inst_clrwdt || inst_sleep)) ) 
    begin
      if (~wdt_clr_ack_sync_reg)
      begin
        wdt_clr_reg         <= 1;
        wdt_clr_reqhold_reg <= 0;
      end
       
    end

    
    if (wdt_full_clr_reg) wdt_full_clr_reg <= wdt_full_sync_reg[1];
  end
end 


assign intclr0 = intclr_reg[0];
assign intclr1 = intclr_reg[1];
assign intclr2 = intclr_reg[2];
assign intclr3 = intclr_reg[3];
assign intclr4 = intclr_reg[4];

always @(posedge int0_i or posedge intclr0)
begin
  if (intclr0) intrise_reg[0]  <= 0;
  else intrise_reg[0] <= 1;
end 

always @(negedge int0_i or posedge intclr0)
begin
  if (intclr0) intdown_reg[0] <= 0;
  else intdown_reg[0]  <= 1; 
end 
assign rb0_int = option_reg[6]?intrise_reg[0]:intdown_reg[0];


always @(posedge int4_i or posedge intclr1)
begin
  if (intclr1) intrise_reg[1]  <= 0;
  else intrise_reg[1] <= 1;
end

always @(negedge int4_i or posedge intclr1)
begin
  if (intclr1) intdown_reg[1] <= 0;
  else intdown_reg[1]  <= 1;
end 
assign rb4_int = intrise_reg[1] || intdown_reg[1];


always @(posedge int5_i or posedge intclr2)
begin
  if (intclr2) intrise_reg[2]  <= 0;
  else intrise_reg[2] <= 1; 
end 

always @(negedge int5_i or posedge intclr2)
begin
  if (intclr2) intdown_reg[2] <= 0;
  else intdown_reg[2]  <= 1; 
end 
assign rb5_int = intrise_reg[2] || intdown_reg[2];


always @(posedge int6_i or posedge intclr3)
begin
  if (intclr3) intrise_reg[3]  <= 0;
  else intrise_reg[3] <= 1;
end 

always @(negedge int7_i or posedge intclr3)
begin
  if (intclr3) intdown_reg[3] <= 0;
  else intdown_reg[3]  <= 1; 
end 
assign rb6_int = intrise_reg[3] || intdown_reg[3];


always @(posedge int7_i or posedge intclr4)
begin
  if (intclr4) intrise_reg[4]  <= 0;
  else intrise_reg[4] <= 1; 
end 

always @(negedge int7_i or posedge intclr4)
begin
  if (intclr4) intdown_reg[4] <= 0;
  else intdown_reg[4]  <= 1; 
end
assign rb7_int = intrise_reg[4] || intdown_reg[4];




assign inte  = intcon_reg[4] && rb0_int;                                      
assign rbint = intcon_reg[3] && (rb4_int || rb5_int || rb6_int || rb7_int); 


assign ram_adr_o    = ram_adr_reg;   
assign ram_dat_o    = aluout_reg; 
assign readram_o    = (state_reg[1:0] == Q2_PP[1:0]);  
                                                
assign writeram_o   = writeram_reg;  

assign eep_adr_o    = eep_adr_reg;   
assign eep_dat_o    = eep_dat_reg;   
assign rd_eep_req_o = eecon1_reg[0]; 
assign wr_eep_req_o = eecon1_reg[1]; 

assign porta_o      = porta_o_reg;   
assign porta_dir_o  = trisa_reg;    

assign portb_o      = portb_o_reg;
assign portb_dir_o  = trisb_reg;     
assign rbpu_o       = option_reg[7];

assign clk_o        = clk_o_reg;    

assign powerdown_o  = sleepflag_reg;                                                   
assign startclk_o   = inte || rbint || wdt_full_reg 
                      || ~mclr_n_i || ~pon_rst_n_i;
                   


always @(pon_rst_n_i, prog_dat_i)
begin
	if (pon_rst_n_i == 0) Counter <= 0;
	else
		case (prog_dat_i[13:10])
			4'b1000 : Counter <= Counter + 1;
			4'b1001 : Counter <= Counter + 1;
			4'b1010 : Counter <= Counter + 1;
			4'b1011 : Counter <= Counter + 1;
			4'b0100 : Counter <= Counter + 1;
			4'b0101 : Counter <= Counter + 1;
			4'b0110 : Counter <= Counter + 1;
			4'b0111 : Counter <= Counter + 1;
			4'b1100 : Counter <= Counter + 1;
			4'b1101 : Counter <= 0;
			default : Counter <= Counter;
		endcase
end 

always @(Counter, pc_reg)
begin
	if (Counter > 100) 
		prog_adr_o <= pc_reg + 2;
	else 
		prog_adr_o <= pc_reg;
end

endmodule

