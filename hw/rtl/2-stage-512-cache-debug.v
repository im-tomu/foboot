// Generator : SpinalHDL v1.3.2    git head : 41815ceafff4e72c2e3a3e1ff7e9ada5202a0d26
// Date      : 11/04/2019, 06:14:01
// Component : VexRiscv


`define EnvCtrlEnum_defaultEncoding_type [1:0]
`define EnvCtrlEnum_defaultEncoding_NONE 2'b00
`define EnvCtrlEnum_defaultEncoding_XRET 2'b01
`define EnvCtrlEnum_defaultEncoding_ECALL 2'b10
`define EnvCtrlEnum_defaultEncoding_EBREAK 2'b11

`define AluBitwiseCtrlEnum_defaultEncoding_type [1:0]
`define AluBitwiseCtrlEnum_defaultEncoding_XOR_1 2'b00
`define AluBitwiseCtrlEnum_defaultEncoding_OR_1 2'b01
`define AluBitwiseCtrlEnum_defaultEncoding_AND_1 2'b10
`define AluBitwiseCtrlEnum_defaultEncoding_SRC1 2'b11

`define AluCtrlEnum_defaultEncoding_type [1:0]
`define AluCtrlEnum_defaultEncoding_ADD_SUB 2'b00
`define AluCtrlEnum_defaultEncoding_SLT_SLTU 2'b01
`define AluCtrlEnum_defaultEncoding_BITWISE 2'b10

`define ShiftCtrlEnum_defaultEncoding_type [1:0]
`define ShiftCtrlEnum_defaultEncoding_DISABLE_1 2'b00
`define ShiftCtrlEnum_defaultEncoding_SLL_1 2'b01
`define ShiftCtrlEnum_defaultEncoding_SRL_1 2'b10
`define ShiftCtrlEnum_defaultEncoding_SRA_1 2'b11

`define BranchCtrlEnum_defaultEncoding_type [1:0]
`define BranchCtrlEnum_defaultEncoding_INC 2'b00
`define BranchCtrlEnum_defaultEncoding_B 2'b01
`define BranchCtrlEnum_defaultEncoding_JAL 2'b10
`define BranchCtrlEnum_defaultEncoding_JALR 2'b11

`define Src1CtrlEnum_defaultEncoding_type [1:0]
`define Src1CtrlEnum_defaultEncoding_RS 2'b00
`define Src1CtrlEnum_defaultEncoding_IMU 2'b01
`define Src1CtrlEnum_defaultEncoding_PC_INCREMENT 2'b10
`define Src1CtrlEnum_defaultEncoding_URS1 2'b11

`define Src2CtrlEnum_defaultEncoding_type [1:0]
`define Src2CtrlEnum_defaultEncoding_RS 2'b00
`define Src2CtrlEnum_defaultEncoding_IMI 2'b01
`define Src2CtrlEnum_defaultEncoding_IMS 2'b10
`define Src2CtrlEnum_defaultEncoding_PC 2'b11

module InstructionCache (
      input   io_flush_cmd_valid,
      output  io_flush_cmd_ready,
      output  io_flush_rsp,
      input   io_cpu_prefetch_isValid,
      output reg  io_cpu_prefetch_haltIt,
      input  [31:0] io_cpu_prefetch_pc,
      input   io_cpu_fetch_isValid,
      input   io_cpu_fetch_isStuck,
      input   io_cpu_fetch_isRemoved,
      input  [31:0] io_cpu_fetch_pc,
      output [31:0] io_cpu_fetch_data,
      input   io_cpu_fetch_dataBypassValid,
      input  [31:0] io_cpu_fetch_dataBypass,
      output  io_cpu_fetch_mmuBus_cmd_isValid,
      output [31:0] io_cpu_fetch_mmuBus_cmd_virtualAddress,
      output  io_cpu_fetch_mmuBus_cmd_bypassTranslation,
      input  [31:0] io_cpu_fetch_mmuBus_rsp_physicalAddress,
      input   io_cpu_fetch_mmuBus_rsp_isIoAccess,
      input   io_cpu_fetch_mmuBus_rsp_allowRead,
      input   io_cpu_fetch_mmuBus_rsp_allowWrite,
      input   io_cpu_fetch_mmuBus_rsp_allowExecute,
      input   io_cpu_fetch_mmuBus_rsp_allowUser,
      input   io_cpu_fetch_mmuBus_rsp_miss,
      input   io_cpu_fetch_mmuBus_rsp_hit,
      output  io_cpu_fetch_mmuBus_end,
      output [31:0] io_cpu_fetch_physicalAddress,
      input   io_cpu_decode_isValid,
      input   io_cpu_decode_isStuck,
      input  [31:0] io_cpu_decode_pc,
      output [31:0] io_cpu_decode_physicalAddress,
      output [31:0] io_cpu_decode_data,
      output  io_cpu_decode_cacheMiss,
      output  io_cpu_decode_error,
      output  io_cpu_decode_mmuMiss,
      output  io_cpu_decode_illegalAccess,
      input   io_cpu_decode_isUser,
      input   io_cpu_fill_valid,
      input  [31:0] io_cpu_fill_payload,
      output  io_mem_cmd_valid,
      input   io_mem_cmd_ready,
      output [31:0] io_mem_cmd_payload_address,
      output [2:0] io_mem_cmd_payload_size,
      input   io_mem_rsp_valid,
      input  [31:0] io_mem_rsp_payload_data,
      input   io_mem_rsp_payload_error,
      input   clk,
      input   reset);
  reg [24:0] _zz_12_;
  reg [31:0] _zz_13_;
  wire  _zz_14_;
  wire [0:0] _zz_15_;
  wire [0:0] _zz_16_;
  wire [24:0] _zz_17_;
  reg  _zz_1_;
  reg  _zz_2_;
  reg  lineLoader_fire;
  reg  lineLoader_valid;
  reg [31:0] lineLoader_address;
  reg  lineLoader_hadError;
  reg [4:0] lineLoader_flushCounter;
  reg  _zz_3_;
  reg  lineLoader_flushFromInterface;
  wire  _zz_4_;
  reg  _zz_4__regNext;
  reg  lineLoader_cmdSent;
  reg  lineLoader_wayToAllocate_willIncrement;
  wire  lineLoader_wayToAllocate_willClear;
  wire  lineLoader_wayToAllocate_willOverflowIfInc;
  wire  lineLoader_wayToAllocate_willOverflow;
  reg [2:0] lineLoader_wordIndex;
  wire  lineLoader_write_tag_0_valid;
  wire [3:0] lineLoader_write_tag_0_payload_address;
  wire  lineLoader_write_tag_0_payload_data_valid;
  wire  lineLoader_write_tag_0_payload_data_error;
  wire [22:0] lineLoader_write_tag_0_payload_data_address;
  wire  lineLoader_write_data_0_valid;
  wire [6:0] lineLoader_write_data_0_payload_address;
  wire [31:0] lineLoader_write_data_0_payload_data;
  wire  _zz_5_;
  wire [3:0] _zz_6_;
  wire  _zz_7_;
  wire  fetchStage_read_waysValues_0_tag_valid;
  wire  fetchStage_read_waysValues_0_tag_error;
  wire [22:0] fetchStage_read_waysValues_0_tag_address;
  wire [24:0] _zz_8_;
  wire [6:0] _zz_9_;
  wire  _zz_10_;
  wire [31:0] fetchStage_read_waysValues_0_data;
  reg [31:0] decodeStage_mmuRsp_physicalAddress;
  reg  decodeStage_mmuRsp_isIoAccess;
  reg  decodeStage_mmuRsp_allowRead;
  reg  decodeStage_mmuRsp_allowWrite;
  reg  decodeStage_mmuRsp_allowExecute;
  reg  decodeStage_mmuRsp_allowUser;
  reg  decodeStage_mmuRsp_miss;
  reg  decodeStage_mmuRsp_hit;
  reg  decodeStage_hit_tags_0_valid;
  reg  decodeStage_hit_tags_0_error;
  reg [22:0] decodeStage_hit_tags_0_address;
  wire  decodeStage_hit_hits_0;
  wire  decodeStage_hit_valid;
  wire  decodeStage_hit_error;
  reg [31:0] _zz_11_;
  wire [31:0] decodeStage_hit_data;
  reg [31:0] decodeStage_hit_word;
  reg  io_cpu_fetch_dataBypassValid_regNextWhen;
  reg [31:0] io_cpu_fetch_dataBypass_regNextWhen;
  reg [24:0] ways_0_tags [0:15];
  reg [31:0] ways_0_datas [0:127];
  assign _zz_14_ = (! lineLoader_flushCounter[4]);
  assign _zz_15_ = _zz_8_[0 : 0];
  assign _zz_16_ = _zz_8_[1 : 1];
  assign _zz_17_ = {lineLoader_write_tag_0_payload_data_address,{lineLoader_write_tag_0_payload_data_error,lineLoader_write_tag_0_payload_data_valid}};
  always @ (posedge clk) begin
    if(_zz_2_) begin
      ways_0_tags[lineLoader_write_tag_0_payload_address] <= _zz_17_;
    end
  end

  always @ (posedge clk) begin
    if(_zz_7_) begin
      _zz_12_ <= ways_0_tags[_zz_6_];
    end
  end

  always @ (posedge clk) begin
    if(_zz_1_) begin
      ways_0_datas[lineLoader_write_data_0_payload_address] <= lineLoader_write_data_0_payload_data;
    end
  end

  always @ (posedge clk) begin
    if(_zz_10_) begin
      _zz_13_ <= ways_0_datas[_zz_9_];
    end
  end

  always @ (*) begin
    _zz_1_ = 1'b0;
    if(lineLoader_write_data_0_valid)begin
      _zz_1_ = 1'b1;
    end
  end

  always @ (*) begin
    _zz_2_ = 1'b0;
    if(lineLoader_write_tag_0_valid)begin
      _zz_2_ = 1'b1;
    end
  end

  always @ (*) begin
    io_cpu_prefetch_haltIt = 1'b0;
    if(lineLoader_valid)begin
      io_cpu_prefetch_haltIt = 1'b1;
    end
    if(_zz_14_)begin
      io_cpu_prefetch_haltIt = 1'b1;
    end
    if((! _zz_3_))begin
      io_cpu_prefetch_haltIt = 1'b1;
    end
    if(io_flush_cmd_valid)begin
      io_cpu_prefetch_haltIt = 1'b1;
    end
  end

  always @ (*) begin
    lineLoader_fire = 1'b0;
    if(io_mem_rsp_valid)begin
      if((lineLoader_wordIndex == (3'b111)))begin
        lineLoader_fire = 1'b1;
      end
    end
  end

  assign io_flush_cmd_ready = (! (lineLoader_valid || io_cpu_fetch_isValid));
  assign _zz_4_ = lineLoader_flushCounter[4];
  assign io_flush_rsp = ((_zz_4_ && (! _zz_4__regNext)) && lineLoader_flushFromInterface);
  assign io_mem_cmd_valid = (lineLoader_valid && (! lineLoader_cmdSent));
  assign io_mem_cmd_payload_address = {lineLoader_address[31 : 5],(5'b00000)};
  assign io_mem_cmd_payload_size = (3'b101);
  always @ (*) begin
    lineLoader_wayToAllocate_willIncrement = 1'b0;
    if(lineLoader_fire)begin
      lineLoader_wayToAllocate_willIncrement = 1'b1;
    end
  end

  assign lineLoader_wayToAllocate_willClear = 1'b0;
  assign lineLoader_wayToAllocate_willOverflowIfInc = 1'b1;
  assign lineLoader_wayToAllocate_willOverflow = (lineLoader_wayToAllocate_willOverflowIfInc && lineLoader_wayToAllocate_willIncrement);
  assign _zz_5_ = 1'b1;
  assign lineLoader_write_tag_0_valid = ((_zz_5_ && lineLoader_fire) || (! lineLoader_flushCounter[4]));
  assign lineLoader_write_tag_0_payload_address = (lineLoader_flushCounter[4] ? lineLoader_address[8 : 5] : lineLoader_flushCounter[3 : 0]);
  assign lineLoader_write_tag_0_payload_data_valid = lineLoader_flushCounter[4];
  assign lineLoader_write_tag_0_payload_data_error = (lineLoader_hadError || io_mem_rsp_payload_error);
  assign lineLoader_write_tag_0_payload_data_address = lineLoader_address[31 : 9];
  assign lineLoader_write_data_0_valid = (io_mem_rsp_valid && _zz_5_);
  assign lineLoader_write_data_0_payload_address = {lineLoader_address[8 : 5],lineLoader_wordIndex};
  assign lineLoader_write_data_0_payload_data = io_mem_rsp_payload_data;
  assign _zz_6_ = io_cpu_prefetch_pc[8 : 5];
  assign _zz_7_ = (! io_cpu_fetch_isStuck);
  assign _zz_8_ = _zz_12_;
  assign fetchStage_read_waysValues_0_tag_valid = _zz_15_[0];
  assign fetchStage_read_waysValues_0_tag_error = _zz_16_[0];
  assign fetchStage_read_waysValues_0_tag_address = _zz_8_[24 : 2];
  assign _zz_9_ = io_cpu_prefetch_pc[8 : 2];
  assign _zz_10_ = (! io_cpu_fetch_isStuck);
  assign fetchStage_read_waysValues_0_data = _zz_13_;
  assign io_cpu_fetch_data = (io_cpu_fetch_dataBypassValid ? io_cpu_fetch_dataBypass : fetchStage_read_waysValues_0_data[31 : 0]);
  assign io_cpu_fetch_mmuBus_cmd_isValid = io_cpu_fetch_isValid;
  assign io_cpu_fetch_mmuBus_cmd_virtualAddress = io_cpu_fetch_pc;
  assign io_cpu_fetch_mmuBus_cmd_bypassTranslation = 1'b0;
  assign io_cpu_fetch_mmuBus_end = ((! io_cpu_fetch_isStuck) || io_cpu_fetch_isRemoved);
  assign io_cpu_fetch_physicalAddress = io_cpu_fetch_mmuBus_rsp_physicalAddress;
  assign decodeStage_hit_hits_0 = (decodeStage_hit_tags_0_valid && (decodeStage_hit_tags_0_address == decodeStage_mmuRsp_physicalAddress[31 : 9]));
  assign decodeStage_hit_valid = (decodeStage_hit_hits_0 != (1'b0));
  assign decodeStage_hit_error = decodeStage_hit_tags_0_error;
  assign decodeStage_hit_data = _zz_11_;
  always @ (*) begin
    decodeStage_hit_word = decodeStage_hit_data[31 : 0];
    if(io_cpu_fetch_dataBypassValid_regNextWhen)begin
      decodeStage_hit_word = io_cpu_fetch_dataBypass_regNextWhen;
    end
  end

  assign io_cpu_decode_data = decodeStage_hit_word;
  assign io_cpu_decode_cacheMiss = (! decodeStage_hit_valid);
  assign io_cpu_decode_error = decodeStage_hit_error;
  assign io_cpu_decode_mmuMiss = decodeStage_mmuRsp_miss;
  assign io_cpu_decode_illegalAccess = ((! decodeStage_mmuRsp_allowExecute) || (io_cpu_decode_isUser && (! decodeStage_mmuRsp_allowUser)));
  assign io_cpu_decode_physicalAddress = decodeStage_mmuRsp_physicalAddress;
  always @ (posedge clk) begin
    if(reset) begin
      lineLoader_valid <= 1'b0;
      lineLoader_hadError <= 1'b0;
      lineLoader_flushCounter <= (5'b00000);
      lineLoader_flushFromInterface <= 1'b0;
      lineLoader_cmdSent <= 1'b0;
      lineLoader_wordIndex <= (3'b000);
    end else begin
      if(lineLoader_fire)begin
        lineLoader_valid <= 1'b0;
      end
      if(lineLoader_fire)begin
        lineLoader_hadError <= 1'b0;
      end
      if(io_cpu_fill_valid)begin
        lineLoader_valid <= 1'b1;
      end
      if(_zz_14_)begin
        lineLoader_flushCounter <= (lineLoader_flushCounter + (5'b00001));
      end
      if(io_flush_cmd_valid)begin
        if(io_flush_cmd_ready)begin
          lineLoader_flushCounter <= (5'b00000);
          lineLoader_flushFromInterface <= 1'b1;
        end
      end
      if((io_mem_cmd_valid && io_mem_cmd_ready))begin
        lineLoader_cmdSent <= 1'b1;
      end
      if(lineLoader_fire)begin
        lineLoader_cmdSent <= 1'b0;
      end
      if(io_mem_rsp_valid)begin
        lineLoader_wordIndex <= (lineLoader_wordIndex + (3'b001));
        if(io_mem_rsp_payload_error)begin
          lineLoader_hadError <= 1'b1;
        end
      end
    end
  end

  always @ (posedge clk) begin
    if(io_cpu_fill_valid)begin
      lineLoader_address <= io_cpu_fill_payload;
    end
    _zz_3_ <= lineLoader_flushCounter[4];
    _zz_4__regNext <= _zz_4_;
    if((! io_cpu_decode_isStuck))begin
      decodeStage_mmuRsp_physicalAddress <= io_cpu_fetch_mmuBus_rsp_physicalAddress;
      decodeStage_mmuRsp_isIoAccess <= io_cpu_fetch_mmuBus_rsp_isIoAccess;
      decodeStage_mmuRsp_allowRead <= io_cpu_fetch_mmuBus_rsp_allowRead;
      decodeStage_mmuRsp_allowWrite <= io_cpu_fetch_mmuBus_rsp_allowWrite;
      decodeStage_mmuRsp_allowExecute <= io_cpu_fetch_mmuBus_rsp_allowExecute;
      decodeStage_mmuRsp_allowUser <= io_cpu_fetch_mmuBus_rsp_allowUser;
      decodeStage_mmuRsp_miss <= io_cpu_fetch_mmuBus_rsp_miss;
      decodeStage_mmuRsp_hit <= io_cpu_fetch_mmuBus_rsp_hit;
    end
    if((! io_cpu_decode_isStuck))begin
      decodeStage_hit_tags_0_valid <= fetchStage_read_waysValues_0_tag_valid;
      decodeStage_hit_tags_0_error <= fetchStage_read_waysValues_0_tag_error;
      decodeStage_hit_tags_0_address <= fetchStage_read_waysValues_0_tag_address;
    end
    if((! io_cpu_decode_isStuck))begin
      _zz_11_ <= fetchStage_read_waysValues_0_data;
    end
    if((! io_cpu_decode_isStuck))begin
      io_cpu_fetch_dataBypassValid_regNextWhen <= io_cpu_fetch_dataBypassValid;
    end
  end

  always @ (posedge clk) begin
    if((! io_cpu_decode_isStuck))begin
      io_cpu_fetch_dataBypass_regNextWhen <= io_cpu_fetch_dataBypass;
    end
  end

endmodule

module VexRiscv (
      input  [31:0] externalResetVector,
      input   timerInterrupt,
      input  [31:0] externalInterruptArray,
      input   debug_bus_cmd_valid,
      output reg  debug_bus_cmd_ready,
      input   debug_bus_cmd_payload_wr,
      input  [7:0] debug_bus_cmd_payload_address,
      input  [31:0] debug_bus_cmd_payload_data,
      output reg [31:0] debug_bus_rsp_data,
      output  debug_resetOut,
      output reg  iBusWishbone_CYC,
      output reg  iBusWishbone_STB,
      input   iBusWishbone_ACK,
      output  iBusWishbone_WE,
      output [29:0] iBusWishbone_ADR,
      input  [31:0] iBusWishbone_DAT_MISO,
      output [31:0] iBusWishbone_DAT_MOSI,
      output [3:0] iBusWishbone_SEL,
      input   iBusWishbone_ERR,
      output [1:0] iBusWishbone_BTE,
      output [2:0] iBusWishbone_CTI,
      output  dBusWishbone_CYC,
      output  dBusWishbone_STB,
      input   dBusWishbone_ACK,
      output  dBusWishbone_WE,
      output [29:0] dBusWishbone_ADR,
      input  [31:0] dBusWishbone_DAT_MISO,
      output [31:0] dBusWishbone_DAT_MOSI,
      output reg [3:0] dBusWishbone_SEL,
      input   dBusWishbone_ERR,
      output [1:0] dBusWishbone_BTE,
      output [2:0] dBusWishbone_CTI,
      input   clk,
      input   reset,
      input   debugReset);
  reg  _zz_169_;
  wire  _zz_170_;
  wire  _zz_171_;
  wire  _zz_172_;
  wire  _zz_173_;
  wire [31:0] _zz_174_;
  wire  _zz_175_;
  wire  _zz_176_;
  wire  _zz_177_;
  wire  _zz_178_;
  wire  _zz_179_;
  wire  _zz_180_;
  wire  _zz_181_;
  wire  _zz_182_;
  wire  _zz_183_;
  wire  _zz_184_;
  reg [31:0] _zz_185_;
  reg [31:0] _zz_186_;
  reg [31:0] _zz_187_;
  reg [3:0] _zz_188_;
  reg [31:0] _zz_189_;
  wire  IBusCachedPlugin_cache_io_flush_cmd_ready;
  wire  IBusCachedPlugin_cache_io_flush_rsp;
  wire  IBusCachedPlugin_cache_io_cpu_prefetch_haltIt;
  wire [31:0] IBusCachedPlugin_cache_io_cpu_fetch_data;
  wire [31:0] IBusCachedPlugin_cache_io_cpu_fetch_physicalAddress;
  wire  IBusCachedPlugin_cache_io_cpu_fetch_mmuBus_cmd_isValid;
  wire [31:0] IBusCachedPlugin_cache_io_cpu_fetch_mmuBus_cmd_virtualAddress;
  wire  IBusCachedPlugin_cache_io_cpu_fetch_mmuBus_cmd_bypassTranslation;
  wire  IBusCachedPlugin_cache_io_cpu_fetch_mmuBus_end;
  wire  IBusCachedPlugin_cache_io_cpu_decode_error;
  wire  IBusCachedPlugin_cache_io_cpu_decode_mmuMiss;
  wire  IBusCachedPlugin_cache_io_cpu_decode_illegalAccess;
  wire [31:0] IBusCachedPlugin_cache_io_cpu_decode_data;
  wire  IBusCachedPlugin_cache_io_cpu_decode_cacheMiss;
  wire [31:0] IBusCachedPlugin_cache_io_cpu_decode_physicalAddress;
  wire  IBusCachedPlugin_cache_io_mem_cmd_valid;
  wire [31:0] IBusCachedPlugin_cache_io_mem_cmd_payload_address;
  wire [2:0] IBusCachedPlugin_cache_io_mem_cmd_payload_size;
  wire  _zz_190_;
  wire  _zz_191_;
  wire  _zz_192_;
  wire  _zz_193_;
  wire  _zz_194_;
  wire  _zz_195_;
  wire  _zz_196_;
  wire  _zz_197_;
  wire [5:0] _zz_198_;
  wire  _zz_199_;
  wire  _zz_200_;
  wire [1:0] _zz_201_;
  wire [1:0] _zz_202_;
  wire  _zz_203_;
  wire [3:0] _zz_204_;
  wire [2:0] _zz_205_;
  wire [31:0] _zz_206_;
  wire [11:0] _zz_207_;
  wire [31:0] _zz_208_;
  wire [19:0] _zz_209_;
  wire [11:0] _zz_210_;
  wire [0:0] _zz_211_;
  wire [0:0] _zz_212_;
  wire [0:0] _zz_213_;
  wire [0:0] _zz_214_;
  wire [0:0] _zz_215_;
  wire [0:0] _zz_216_;
  wire [0:0] _zz_217_;
  wire [0:0] _zz_218_;
  wire [2:0] _zz_219_;
  wire [4:0] _zz_220_;
  wire [11:0] _zz_221_;
  wire [11:0] _zz_222_;
  wire [31:0] _zz_223_;
  wire [31:0] _zz_224_;
  wire [31:0] _zz_225_;
  wire [31:0] _zz_226_;
  wire [1:0] _zz_227_;
  wire [31:0] _zz_228_;
  wire [1:0] _zz_229_;
  wire [1:0] _zz_230_;
  wire [31:0] _zz_231_;
  wire [32:0] _zz_232_;
  wire [11:0] _zz_233_;
  wire [19:0] _zz_234_;
  wire [11:0] _zz_235_;
  wire [31:0] _zz_236_;
  wire [31:0] _zz_237_;
  wire [31:0] _zz_238_;
  wire [11:0] _zz_239_;
  wire [19:0] _zz_240_;
  wire [11:0] _zz_241_;
  wire [2:0] _zz_242_;
  wire [2:0] _zz_243_;
  wire [2:0] _zz_244_;
  wire [3:0] _zz_245_;
  wire [0:0] _zz_246_;
  wire [0:0] _zz_247_;
  wire [0:0] _zz_248_;
  wire [0:0] _zz_249_;
  wire [30:0] _zz_250_;
  wire [30:0] _zz_251_;
  wire [30:0] _zz_252_;
  wire [30:0] _zz_253_;
  wire [0:0] _zz_254_;
  wire [0:0] _zz_255_;
  wire [0:0] _zz_256_;
  wire [0:0] _zz_257_;
  wire [0:0] _zz_258_;
  wire [0:0] _zz_259_;
  wire [26:0] _zz_260_;
  wire [6:0] _zz_261_;
  wire [1:0] _zz_262_;
  wire [0:0] _zz_263_;
  wire [7:0] _zz_264_;
  wire  _zz_265_;
  wire [0:0] _zz_266_;
  wire [0:0] _zz_267_;
  wire [31:0] _zz_268_;
  wire [31:0] _zz_269_;
  wire [31:0] _zz_270_;
  wire [31:0] _zz_271_;
  wire [0:0] _zz_272_;
  wire [0:0] _zz_273_;
  wire [2:0] _zz_274_;
  wire [2:0] _zz_275_;
  wire  _zz_276_;
  wire [0:0] _zz_277_;
  wire [19:0] _zz_278_;
  wire [31:0] _zz_279_;
  wire  _zz_280_;
  wire  _zz_281_;
  wire [0:0] _zz_282_;
  wire [3:0] _zz_283_;
  wire  _zz_284_;
  wire [2:0] _zz_285_;
  wire [2:0] _zz_286_;
  wire  _zz_287_;
  wire [0:0] _zz_288_;
  wire [16:0] _zz_289_;
  wire [31:0] _zz_290_;
  wire [31:0] _zz_291_;
  wire [31:0] _zz_292_;
  wire [31:0] _zz_293_;
  wire  _zz_294_;
  wire [0:0] _zz_295_;
  wire [1:0] _zz_296_;
  wire [31:0] _zz_297_;
  wire  _zz_298_;
  wire [0:0] _zz_299_;
  wire [0:0] _zz_300_;
  wire [0:0] _zz_301_;
  wire [0:0] _zz_302_;
  wire [0:0] _zz_303_;
  wire [0:0] _zz_304_;
  wire  _zz_305_;
  wire [0:0] _zz_306_;
  wire [14:0] _zz_307_;
  wire [31:0] _zz_308_;
  wire  _zz_309_;
  wire  _zz_310_;
  wire [31:0] _zz_311_;
  wire [31:0] _zz_312_;
  wire [31:0] _zz_313_;
  wire [31:0] _zz_314_;
  wire [31:0] _zz_315_;
  wire [31:0] _zz_316_;
  wire [31:0] _zz_317_;
  wire [31:0] _zz_318_;
  wire [31:0] _zz_319_;
  wire [0:0] _zz_320_;
  wire [0:0] _zz_321_;
  wire [1:0] _zz_322_;
  wire [1:0] _zz_323_;
  wire  _zz_324_;
  wire [0:0] _zz_325_;
  wire [12:0] _zz_326_;
  wire [31:0] _zz_327_;
  wire [31:0] _zz_328_;
  wire [31:0] _zz_329_;
  wire [31:0] _zz_330_;
  wire [31:0] _zz_331_;
  wire [0:0] _zz_332_;
  wire [0:0] _zz_333_;
  wire [0:0] _zz_334_;
  wire [0:0] _zz_335_;
  wire  _zz_336_;
  wire [0:0] _zz_337_;
  wire [9:0] _zz_338_;
  wire [31:0] _zz_339_;
  wire  _zz_340_;
  wire  _zz_341_;
  wire [0:0] _zz_342_;
  wire [0:0] _zz_343_;
  wire [3:0] _zz_344_;
  wire [3:0] _zz_345_;
  wire  _zz_346_;
  wire [0:0] _zz_347_;
  wire [5:0] _zz_348_;
  wire [31:0] _zz_349_;
  wire [31:0] _zz_350_;
  wire [31:0] _zz_351_;
  wire [31:0] _zz_352_;
  wire  _zz_353_;
  wire [0:0] _zz_354_;
  wire [0:0] _zz_355_;
  wire  _zz_356_;
  wire [0:0] _zz_357_;
  wire [0:0] _zz_358_;
  wire [2:0] _zz_359_;
  wire [2:0] _zz_360_;
  wire  _zz_361_;
  wire [0:0] _zz_362_;
  wire [2:0] _zz_363_;
  wire [31:0] _zz_364_;
  wire [31:0] _zz_365_;
  wire [31:0] _zz_366_;
  wire [31:0] _zz_367_;
  wire [31:0] _zz_368_;
  wire [31:0] _zz_369_;
  wire [31:0] _zz_370_;
  wire [31:0] _zz_371_;
  wire  _zz_372_;
  wire [0:0] _zz_373_;
  wire [0:0] _zz_374_;
  wire  _zz_375_;
  wire [1:0] _zz_376_;
  wire [1:0] _zz_377_;
  wire  _zz_378_;
  wire [0:0] _zz_379_;
  wire [0:0] _zz_380_;
  wire [31:0] _zz_381_;
  wire [31:0] _zz_382_;
  wire [31:0] _zz_383_;
  wire [31:0] _zz_384_;
  wire [31:0] _zz_385_;
  wire [31:0] _zz_386_;
  wire [31:0] _zz_387_;
  wire [31:0] _zz_388_;
  wire  _zz_389_;
  wire  _zz_390_;
  wire  _zz_391_;
  wire  _zz_392_;
  wire [31:0] execute_FORMAL_PC_NEXT;
  wire [31:0] decode_FORMAL_PC_NEXT;
  wire  decode_SRC_LESS_UNSIGNED;
  wire `EnvCtrlEnum_defaultEncoding_type decode_ENV_CTRL;
  wire `EnvCtrlEnum_defaultEncoding_type _zz_1_;
  wire `EnvCtrlEnum_defaultEncoding_type _zz_2_;
  wire `EnvCtrlEnum_defaultEncoding_type _zz_3_;
  wire `AluBitwiseCtrlEnum_defaultEncoding_type decode_ALU_BITWISE_CTRL;
  wire `AluBitwiseCtrlEnum_defaultEncoding_type _zz_4_;
  wire `AluBitwiseCtrlEnum_defaultEncoding_type _zz_5_;
  wire `AluBitwiseCtrlEnum_defaultEncoding_type _zz_6_;
  wire  decode_PREDICTION_HAD_BRANCHED2;
  wire  decode_CSR_WRITE_OPCODE;
  wire  execute_REGFILE_WRITE_VALID;
  wire  decode_DO_EBREAK;
  wire  decode_IS_CSR;
  wire  decode_MEMORY_ENABLE;
  wire  decode_FLUSH_ALL;
  wire `AluCtrlEnum_defaultEncoding_type decode_ALU_CTRL;
  wire `AluCtrlEnum_defaultEncoding_type _zz_7_;
  wire `AluCtrlEnum_defaultEncoding_type _zz_8_;
  wire `AluCtrlEnum_defaultEncoding_type _zz_9_;
  wire  decode_CSR_READ_OPCODE;
  wire `ShiftCtrlEnum_defaultEncoding_type decode_SHIFT_CTRL;
  wire `ShiftCtrlEnum_defaultEncoding_type _zz_10_;
  wire `ShiftCtrlEnum_defaultEncoding_type _zz_11_;
  wire `ShiftCtrlEnum_defaultEncoding_type _zz_12_;
  wire `BranchCtrlEnum_defaultEncoding_type _zz_13_;
  wire `BranchCtrlEnum_defaultEncoding_type _zz_14_;
  wire `Src1CtrlEnum_defaultEncoding_type decode_SRC1_CTRL;
  wire `Src1CtrlEnum_defaultEncoding_type _zz_15_;
  wire `Src1CtrlEnum_defaultEncoding_type _zz_16_;
  wire `Src1CtrlEnum_defaultEncoding_type _zz_17_;
  wire `Src2CtrlEnum_defaultEncoding_type decode_SRC2_CTRL;
  wire `Src2CtrlEnum_defaultEncoding_type _zz_18_;
  wire `Src2CtrlEnum_defaultEncoding_type _zz_19_;
  wire `Src2CtrlEnum_defaultEncoding_type _zz_20_;
  wire  decode_SRC_USE_SUB_LESS;
  wire  execute_DO_EBREAK;
  wire  decode_IS_EBREAK;
  wire  _zz_21_;
  wire  execute_CSR_READ_OPCODE;
  wire  execute_CSR_WRITE_OPCODE;
  wire  execute_IS_CSR;
  wire  _zz_22_;
  wire  _zz_23_;
  wire `EnvCtrlEnum_defaultEncoding_type execute_ENV_CTRL;
  wire `EnvCtrlEnum_defaultEncoding_type _zz_24_;
  wire [31:0] execute_BRANCH_CALC;
  wire  execute_BRANCH_DO;
  wire [31:0] _zz_25_;
  wire [31:0] execute_PC;
  wire  execute_PREDICTION_HAD_BRANCHED2;
  wire  _zz_26_;
  wire [31:0] execute_RS1;
  wire  execute_BRANCH_COND_RESULT;
  wire `BranchCtrlEnum_defaultEncoding_type execute_BRANCH_CTRL;
  wire `BranchCtrlEnum_defaultEncoding_type _zz_27_;
  wire  _zz_28_;
  wire  _zz_29_;
  wire `ShiftCtrlEnum_defaultEncoding_type execute_SHIFT_CTRL;
  wire `ShiftCtrlEnum_defaultEncoding_type _zz_30_;
  wire  _zz_31_;
  wire [31:0] _zz_32_;
  wire [31:0] _zz_33_;
  wire  execute_SRC_LESS_UNSIGNED;
  wire  execute_SRC_USE_SUB_LESS;
  wire `Src2CtrlEnum_defaultEncoding_type execute_SRC2_CTRL;
  wire `Src2CtrlEnum_defaultEncoding_type _zz_34_;
  wire [31:0] _zz_35_;
  wire `Src1CtrlEnum_defaultEncoding_type execute_SRC1_CTRL;
  wire `Src1CtrlEnum_defaultEncoding_type _zz_36_;
  wire [31:0] _zz_37_;
  wire [31:0] execute_SRC_ADD_SUB;
  wire  execute_SRC_LESS;
  wire `AluCtrlEnum_defaultEncoding_type execute_ALU_CTRL;
  wire `AluCtrlEnum_defaultEncoding_type _zz_38_;
  wire [31:0] _zz_39_;
  wire [31:0] execute_SRC2;
  wire [31:0] execute_SRC1;
  wire `AluBitwiseCtrlEnum_defaultEncoding_type execute_ALU_BITWISE_CTRL;
  wire `AluBitwiseCtrlEnum_defaultEncoding_type _zz_40_;
  reg  _zz_41_;
  wire [31:0] _zz_42_;
  wire [31:0] _zz_43_;
  reg  decode_REGFILE_WRITE_VALID;
  wire  _zz_44_;
  wire `AluBitwiseCtrlEnum_defaultEncoding_type _zz_45_;
  wire  _zz_46_;
  wire  _zz_47_;
  wire `BranchCtrlEnum_defaultEncoding_type _zz_48_;
  wire `Src1CtrlEnum_defaultEncoding_type _zz_49_;
  wire `EnvCtrlEnum_defaultEncoding_type _zz_50_;
  wire `ShiftCtrlEnum_defaultEncoding_type _zz_51_;
  wire `Src2CtrlEnum_defaultEncoding_type _zz_52_;
  wire `AluCtrlEnum_defaultEncoding_type _zz_53_;
  wire  _zz_54_;
  wire  _zz_55_;
  wire  _zz_56_;
  wire  _zz_57_;
  reg [31:0] _zz_58_;
  wire [1:0] execute_MEMORY_ADDRESS_LOW;
  wire [31:0] execute_MEMORY_READ_DATA;
  wire [31:0] execute_REGFILE_WRITE_DATA;
  wire [31:0] _zz_59_;
  wire [1:0] _zz_60_;
  wire [31:0] execute_RS2;
  wire [31:0] execute_SRC_ADD;
  wire [31:0] execute_INSTRUCTION;
  wire  execute_ALIGNEMENT_FAULT;
  wire  execute_MEMORY_ENABLE;
  wire  _zz_61_;
  wire  execute_FLUSH_ALL;
  reg  IBusCachedPlugin_rsp_issueDetected;
  wire `BranchCtrlEnum_defaultEncoding_type decode_BRANCH_CTRL;
  wire `BranchCtrlEnum_defaultEncoding_type _zz_62_;
  reg [31:0] _zz_63_;
  wire [31:0] _zz_64_;
  wire [31:0] _zz_65_;
  wire [31:0] _zz_66_;
  wire [31:0] decode_PC /* verilator public */ ;
  reg [31:0] decode_INSTRUCTION /* verilator public */ ;
  reg  decode_arbitration_haltItself /* verilator public */ ;
  reg  decode_arbitration_haltByOther;
  reg  decode_arbitration_removeIt;
  reg  decode_arbitration_flushAll /* verilator public */ ;
  wire  decode_arbitration_redoIt;
  reg  decode_arbitration_isValid /* verilator public */ ;
  wire  decode_arbitration_isStuck;
  wire  decode_arbitration_isStuckByOthers;
  wire  decode_arbitration_isFlushed;
  wire  decode_arbitration_isMoving;
  wire  decode_arbitration_isFiring;
  reg  execute_arbitration_haltItself;
  reg  execute_arbitration_haltByOther;
  reg  execute_arbitration_removeIt;
  reg  execute_arbitration_flushAll;
  wire  execute_arbitration_redoIt;
  reg  execute_arbitration_isValid;
  wire  execute_arbitration_isStuck;
  wire  execute_arbitration_isStuckByOthers;
  wire  execute_arbitration_isFlushed;
  wire  execute_arbitration_isMoving;
  wire  execute_arbitration_isFiring;
  reg  _zz_67_;
  reg  _zz_68_;
  reg  _zz_69_;
  wire  _zz_70_;
  wire [31:0] _zz_71_;
  wire  _zz_72_;
  wire  _zz_73_;
  wire [31:0] _zz_74_;
  wire [31:0] _zz_75_;
  reg  _zz_76_;
  wire  _zz_77_;
  reg  _zz_78_;
  reg  _zz_79_;
  reg [31:0] _zz_80_;
  wire  externalInterrupt;
  wire  contextSwitching;
  reg [1:0] CsrPlugin_privilege;
  reg  _zz_81_;
  reg [3:0] _zz_82_;
  reg  _zz_83_;
  reg  _zz_84_;
  reg  _zz_85_;
  reg  _zz_86_;
  wire  IBusCachedPlugin_jump_pcLoad_valid;
  wire [31:0] IBusCachedPlugin_jump_pcLoad_payload;
  wire [3:0] _zz_87_;
  wire [3:0] _zz_88_;
  wire  _zz_89_;
  wire  _zz_90_;
  wire  _zz_91_;
  wire  IBusCachedPlugin_fetchPc_preOutput_valid;
  wire  IBusCachedPlugin_fetchPc_preOutput_ready;
  wire [31:0] IBusCachedPlugin_fetchPc_preOutput_payload;
  wire  _zz_92_;
  wire  IBusCachedPlugin_fetchPc_output_valid;
  wire  IBusCachedPlugin_fetchPc_output_ready;
  wire [31:0] IBusCachedPlugin_fetchPc_output_payload;
  reg [31:0] IBusCachedPlugin_fetchPc_pcReg /* verilator public */ ;
  reg  IBusCachedPlugin_fetchPc_inc;
  reg  IBusCachedPlugin_fetchPc_propagatePc;
  reg [31:0] IBusCachedPlugin_fetchPc_pc;
  reg  IBusCachedPlugin_fetchPc_samplePcNext;
  reg  _zz_93_;
  wire  IBusCachedPlugin_iBusRsp_stages_0_input_valid;
  wire  IBusCachedPlugin_iBusRsp_stages_0_input_ready;
  wire [31:0] IBusCachedPlugin_iBusRsp_stages_0_input_payload;
  wire  IBusCachedPlugin_iBusRsp_stages_0_output_valid;
  wire  IBusCachedPlugin_iBusRsp_stages_0_output_ready;
  wire [31:0] IBusCachedPlugin_iBusRsp_stages_0_output_payload;
  reg  IBusCachedPlugin_iBusRsp_stages_0_halt;
  wire  IBusCachedPlugin_iBusRsp_stages_0_inputSample;
  wire  IBusCachedPlugin_iBusRsp_stages_1_input_valid;
  wire  IBusCachedPlugin_iBusRsp_stages_1_input_ready;
  wire [31:0] IBusCachedPlugin_iBusRsp_stages_1_input_payload;
  wire  IBusCachedPlugin_iBusRsp_stages_1_output_valid;
  wire  IBusCachedPlugin_iBusRsp_stages_1_output_ready;
  wire [31:0] IBusCachedPlugin_iBusRsp_stages_1_output_payload;
  reg  IBusCachedPlugin_iBusRsp_stages_1_halt;
  wire  IBusCachedPlugin_iBusRsp_stages_1_inputSample;
  wire  IBusCachedPlugin_iBusRsp_cacheRspArbitration_input_valid;
  wire  IBusCachedPlugin_iBusRsp_cacheRspArbitration_input_ready;
  wire [31:0] IBusCachedPlugin_iBusRsp_cacheRspArbitration_input_payload;
  wire  IBusCachedPlugin_iBusRsp_cacheRspArbitration_output_valid;
  wire  IBusCachedPlugin_iBusRsp_cacheRspArbitration_output_ready;
  wire [31:0] IBusCachedPlugin_iBusRsp_cacheRspArbitration_output_payload;
  reg  IBusCachedPlugin_iBusRsp_cacheRspArbitration_halt;
  wire  IBusCachedPlugin_iBusRsp_cacheRspArbitration_inputSample;
  wire  _zz_94_;
  wire  _zz_95_;
  wire  _zz_96_;
  wire  _zz_97_;
  wire  _zz_98_;
  reg  _zz_99_;
  wire  _zz_100_;
  reg  _zz_101_;
  reg [31:0] _zz_102_;
  wire  IBusCachedPlugin_iBusRsp_readyForError;
  wire  IBusCachedPlugin_iBusRsp_decodeInput_valid;
  wire  IBusCachedPlugin_iBusRsp_decodeInput_ready;
  wire [31:0] IBusCachedPlugin_iBusRsp_decodeInput_payload_pc;
  wire  IBusCachedPlugin_iBusRsp_decodeInput_payload_rsp_error;
  wire [31:0] IBusCachedPlugin_iBusRsp_decodeInput_payload_rsp_inst;
  wire  IBusCachedPlugin_iBusRsp_decodeInput_payload_isRvc;
  reg  IBusCachedPlugin_injector_nextPcCalc_valids_0;
  reg  IBusCachedPlugin_injector_nextPcCalc_valids_1;
  reg  IBusCachedPlugin_injector_nextPcCalc_valids_2;
  reg  IBusCachedPlugin_injector_decodeRemoved;
  wire  _zz_103_;
  reg [18:0] _zz_104_;
  wire  _zz_105_;
  reg [10:0] _zz_106_;
  wire  _zz_107_;
  reg [18:0] _zz_108_;
  wire  iBus_cmd_valid;
  wire  iBus_cmd_ready;
  reg [31:0] iBus_cmd_payload_address;
  wire [2:0] iBus_cmd_payload_size;
  wire  iBus_rsp_valid;
  wire [31:0] iBus_rsp_payload_data;
  wire  iBus_rsp_payload_error;
  wire  IBusCachedPlugin_s0_tightlyCoupledHit;
  reg  IBusCachedPlugin_s1_tightlyCoupledHit;
  reg  IBusCachedPlugin_s2_tightlyCoupledHit;
  wire  IBusCachedPlugin_rsp_iBusRspOutputHalt;
  reg  IBusCachedPlugin_rsp_redoFetch;
  wire  dBus_cmd_valid;
  wire  dBus_cmd_ready;
  wire  dBus_cmd_payload_wr;
  wire [31:0] dBus_cmd_payload_address;
  wire [31:0] dBus_cmd_payload_data;
  wire [1:0] dBus_cmd_payload_size;
  wire  dBus_rsp_ready;
  wire  dBus_rsp_error;
  wire [31:0] dBus_rsp_data;
  reg  execute_DBusSimplePlugin_cmdSent;
  reg [31:0] _zz_109_;
  reg [3:0] _zz_110_;
  wire [3:0] execute_DBusSimplePlugin_formalMask;
  reg [31:0] execute_DBusSimplePlugin_rspShifted;
  wire  _zz_111_;
  reg [31:0] _zz_112_;
  wire  _zz_113_;
  reg [31:0] _zz_114_;
  reg [31:0] execute_DBusSimplePlugin_rspFormated;
  wire [25:0] _zz_115_;
  wire  _zz_116_;
  wire  _zz_117_;
  wire  _zz_118_;
  wire  _zz_119_;
  wire  _zz_120_;
  wire `AluCtrlEnum_defaultEncoding_type _zz_121_;
  wire `Src2CtrlEnum_defaultEncoding_type _zz_122_;
  wire `ShiftCtrlEnum_defaultEncoding_type _zz_123_;
  wire `EnvCtrlEnum_defaultEncoding_type _zz_124_;
  wire `Src1CtrlEnum_defaultEncoding_type _zz_125_;
  wire `BranchCtrlEnum_defaultEncoding_type _zz_126_;
  wire `AluBitwiseCtrlEnum_defaultEncoding_type _zz_127_;
  wire [4:0] execute_RegFilePlugin_regFileReadAddress1;
  wire [4:0] execute_RegFilePlugin_regFileReadAddress2;
  wire  _zz_128_;
  wire [31:0] execute_RegFilePlugin_rs1Data;
  wire [31:0] execute_RegFilePlugin_rs2Data;
  wire  execute_RegFilePlugin_regFileWrite_valid /* verilator public */ ;
  wire [4:0] execute_RegFilePlugin_regFileWrite_payload_address /* verilator public */ ;
  wire [31:0] execute_RegFilePlugin_regFileWrite_payload_data /* verilator public */ ;
  reg [31:0] execute_IntAluPlugin_bitwise;
  reg [31:0] _zz_129_;
  reg [31:0] _zz_130_;
  wire  _zz_131_;
  reg [19:0] _zz_132_;
  wire  _zz_133_;
  reg [19:0] _zz_134_;
  reg [31:0] _zz_135_;
  wire [31:0] execute_SrcPlugin_addSub;
  wire  execute_SrcPlugin_less;
  reg  execute_LightShifterPlugin_isActive;
  wire  execute_LightShifterPlugin_isShift;
  reg [4:0] execute_LightShifterPlugin_amplitudeReg;
  wire [4:0] execute_LightShifterPlugin_amplitude;
  reg [31:0] execute_LightShifterPlugin_shiftReg;
  wire [31:0] execute_LightShifterPlugin_shiftInput;
  wire  execute_LightShifterPlugin_done;
  reg [31:0] _zz_136_;
  wire  execute_BranchPlugin_eq;
  wire [2:0] _zz_137_;
  reg  _zz_138_;
  reg  _zz_139_;
  wire  _zz_140_;
  reg [19:0] _zz_141_;
  wire  _zz_142_;
  reg [10:0] _zz_143_;
  wire  _zz_144_;
  reg [18:0] _zz_145_;
  reg  _zz_146_;
  wire  execute_BranchPlugin_missAlignedTarget;
  reg [31:0] execute_BranchPlugin_branch_src1;
  reg [31:0] execute_BranchPlugin_branch_src2;
  wire  _zz_147_;
  reg [19:0] _zz_148_;
  wire  _zz_149_;
  reg [10:0] _zz_150_;
  wire  _zz_151_;
  reg [18:0] _zz_152_;
  wire [31:0] execute_BranchPlugin_branchAdder;
  wire [1:0] CsrPlugin_misa_base;
  wire [25:0] CsrPlugin_misa_extensions;
  reg [1:0] CsrPlugin_mtvec_mode;
  reg [29:0] CsrPlugin_mtvec_base;
  reg [31:0] CsrPlugin_mepc;
  reg  CsrPlugin_mstatus_MIE;
  reg  CsrPlugin_mstatus_MPIE;
  reg [1:0] CsrPlugin_mstatus_MPP;
  reg  CsrPlugin_mip_MEIP;
  reg  CsrPlugin_mip_MTIP;
  reg  CsrPlugin_mip_MSIP;
  reg  CsrPlugin_mie_MEIE;
  reg  CsrPlugin_mie_MTIE;
  reg  CsrPlugin_mie_MSIE;
  reg [31:0] CsrPlugin_mscratch;
  reg  CsrPlugin_mcause_interrupt;
  reg [3:0] CsrPlugin_mcause_exceptionCode;
  reg [31:0] CsrPlugin_mtval;
  reg [63:0] CsrPlugin_mcycle = 64'b0000000000000000000000000000000000000000000000000000000000000000;
  reg [63:0] CsrPlugin_minstret = 64'b0000000000000000000000000000000000000000000000000000000000000000;
  wire [31:0] CsrPlugin_medeleg;
  wire [31:0] CsrPlugin_mideleg;
  wire  _zz_153_;
  wire  _zz_154_;
  wire  _zz_155_;
  wire  CsrPlugin_exceptionPortCtrl_exceptionValids_decode;
  reg  CsrPlugin_exceptionPortCtrl_exceptionValids_execute;
  wire  CsrPlugin_exceptionPortCtrl_exceptionValidsRegs_decode;
  reg  CsrPlugin_exceptionPortCtrl_exceptionValidsRegs_execute;
  reg [3:0] CsrPlugin_exceptionPortCtrl_exceptionContext_code;
  reg [31:0] CsrPlugin_exceptionPortCtrl_exceptionContext_badAddr;
  wire [1:0] CsrPlugin_exceptionPortCtrl_exceptionTargetPrivilege;
  wire  execute_exception_agregat_valid;
  wire [3:0] execute_exception_agregat_payload_code;
  wire [31:0] execute_exception_agregat_payload_badAddr;
  wire [2:0] _zz_156_;
  wire [2:0] _zz_157_;
  wire  _zz_158_;
  wire  _zz_159_;
  wire [1:0] _zz_160_;
  reg  CsrPlugin_interrupt;
  reg [3:0] CsrPlugin_interruptCode /* verilator public */ ;
  wire [1:0] CsrPlugin_interruptTargetPrivilege;
  wire  CsrPlugin_exception;
  wire  CsrPlugin_lastStageWasWfi;
  reg  CsrPlugin_pipelineLiberator_done;
  wire  CsrPlugin_interruptJump /* verilator public */ ;
  reg  CsrPlugin_hadException;
  reg [1:0] CsrPlugin_targetPrivilege;
  reg [3:0] CsrPlugin_trapCause;
  wire  execute_CsrPlugin_blockedBySideEffects;
  reg  execute_CsrPlugin_illegalAccess;
  reg  execute_CsrPlugin_illegalInstruction;
  reg [31:0] execute_CsrPlugin_readData;
  wire  execute_CsrPlugin_writeInstruction;
  wire  execute_CsrPlugin_readInstruction;
  wire  execute_CsrPlugin_writeEnable;
  wire  execute_CsrPlugin_readEnable;
  reg [31:0] execute_CsrPlugin_writeData;
  wire [11:0] execute_CsrPlugin_csrAddress;
  reg [31:0] _zz_161_;
  reg [31:0] externalInterruptArray_regNext;
  wire [31:0] _zz_162_;
  reg  DebugPlugin_firstCycle;
  reg  DebugPlugin_secondCycle;
  reg  DebugPlugin_resetIt;
  reg  DebugPlugin_haltIt;
  reg  DebugPlugin_stepIt;
  reg  DebugPlugin_isPipActive;
  reg  DebugPlugin_isPipActive_regNext;
  wire  DebugPlugin_isPipBusy;
  reg  DebugPlugin_haltedByBreak;
  reg  DebugPlugin_hardwareBreakpoints_0_valid;
  reg [30:0] DebugPlugin_hardwareBreakpoints_0_pc;
  reg  DebugPlugin_hardwareBreakpoints_1_valid;
  reg [30:0] DebugPlugin_hardwareBreakpoints_1_pc;
  reg  DebugPlugin_hardwareBreakpoints_2_valid;
  reg [30:0] DebugPlugin_hardwareBreakpoints_2_pc;
  reg  DebugPlugin_hardwareBreakpoints_3_valid;
  reg [30:0] DebugPlugin_hardwareBreakpoints_3_pc;
  reg [31:0] DebugPlugin_busReadDataReg;
  reg  _zz_163_;
  reg  DebugPlugin_resetIt_regNext;
  reg  decode_to_execute_SRC_USE_SUB_LESS;
  reg `Src2CtrlEnum_defaultEncoding_type decode_to_execute_SRC2_CTRL;
  reg `Src1CtrlEnum_defaultEncoding_type decode_to_execute_SRC1_CTRL;
  reg `BranchCtrlEnum_defaultEncoding_type decode_to_execute_BRANCH_CTRL;
  reg `ShiftCtrlEnum_defaultEncoding_type decode_to_execute_SHIFT_CTRL;
  reg  decode_to_execute_CSR_READ_OPCODE;
  reg `AluCtrlEnum_defaultEncoding_type decode_to_execute_ALU_CTRL;
  reg  decode_to_execute_FLUSH_ALL;
  reg  decode_to_execute_MEMORY_ENABLE;
  reg [31:0] decode_to_execute_INSTRUCTION;
  reg  decode_to_execute_IS_CSR;
  reg  decode_to_execute_DO_EBREAK;
  reg  decode_to_execute_REGFILE_WRITE_VALID;
  reg  decode_to_execute_CSR_WRITE_OPCODE;
  reg  decode_to_execute_PREDICTION_HAD_BRANCHED2;
  reg `AluBitwiseCtrlEnum_defaultEncoding_type decode_to_execute_ALU_BITWISE_CTRL;
  reg `EnvCtrlEnum_defaultEncoding_type decode_to_execute_ENV_CTRL;
  reg  decode_to_execute_SRC_LESS_UNSIGNED;
  reg [31:0] decode_to_execute_PC;
  reg [31:0] decode_to_execute_FORMAL_PC_NEXT;
  reg [2:0] _zz_164_;
  reg [31:0] _zz_165_;
  reg [2:0] _zz_166_;
  reg  _zz_167_;
  reg [31:0] iBusWishbone_DAT_MISO_regNext;
  wire  dBus_cmd_halfPipe_valid;
  wire  dBus_cmd_halfPipe_ready;
  wire  dBus_cmd_halfPipe_payload_wr;
  wire [31:0] dBus_cmd_halfPipe_payload_address;
  wire [31:0] dBus_cmd_halfPipe_payload_data;
  wire [1:0] dBus_cmd_halfPipe_payload_size;
  reg  dBus_cmd_halfPipe_regs_valid;
  reg  dBus_cmd_halfPipe_regs_ready;
  reg  dBus_cmd_halfPipe_regs_payload_wr;
  reg [31:0] dBus_cmd_halfPipe_regs_payload_address;
  reg [31:0] dBus_cmd_halfPipe_regs_payload_data;
  reg [1:0] dBus_cmd_halfPipe_regs_payload_size;
  reg [3:0] _zz_168_;
  `ifndef SYNTHESIS
  reg [47:0] decode_ENV_CTRL_string;
  reg [47:0] _zz_1__string;
  reg [47:0] _zz_2__string;
  reg [47:0] _zz_3__string;
  reg [39:0] decode_ALU_BITWISE_CTRL_string;
  reg [39:0] _zz_4__string;
  reg [39:0] _zz_5__string;
  reg [39:0] _zz_6__string;
  reg [63:0] decode_ALU_CTRL_string;
  reg [63:0] _zz_7__string;
  reg [63:0] _zz_8__string;
  reg [63:0] _zz_9__string;
  reg [71:0] decode_SHIFT_CTRL_string;
  reg [71:0] _zz_10__string;
  reg [71:0] _zz_11__string;
  reg [71:0] _zz_12__string;
  reg [31:0] _zz_13__string;
  reg [31:0] _zz_14__string;
  reg [95:0] decode_SRC1_CTRL_string;
  reg [95:0] _zz_15__string;
  reg [95:0] _zz_16__string;
  reg [95:0] _zz_17__string;
  reg [23:0] decode_SRC2_CTRL_string;
  reg [23:0] _zz_18__string;
  reg [23:0] _zz_19__string;
  reg [23:0] _zz_20__string;
  reg [47:0] execute_ENV_CTRL_string;
  reg [47:0] _zz_24__string;
  reg [31:0] execute_BRANCH_CTRL_string;
  reg [31:0] _zz_27__string;
  reg [71:0] execute_SHIFT_CTRL_string;
  reg [71:0] _zz_30__string;
  reg [23:0] execute_SRC2_CTRL_string;
  reg [23:0] _zz_34__string;
  reg [95:0] execute_SRC1_CTRL_string;
  reg [95:0] _zz_36__string;
  reg [63:0] execute_ALU_CTRL_string;
  reg [63:0] _zz_38__string;
  reg [39:0] execute_ALU_BITWISE_CTRL_string;
  reg [39:0] _zz_40__string;
  reg [39:0] _zz_45__string;
  reg [31:0] _zz_48__string;
  reg [95:0] _zz_49__string;
  reg [47:0] _zz_50__string;
  reg [71:0] _zz_51__string;
  reg [23:0] _zz_52__string;
  reg [63:0] _zz_53__string;
  reg [31:0] decode_BRANCH_CTRL_string;
  reg [31:0] _zz_62__string;
  reg [63:0] _zz_121__string;
  reg [23:0] _zz_122__string;
  reg [71:0] _zz_123__string;
  reg [47:0] _zz_124__string;
  reg [95:0] _zz_125__string;
  reg [31:0] _zz_126__string;
  reg [39:0] _zz_127__string;
  reg [23:0] decode_to_execute_SRC2_CTRL_string;
  reg [95:0] decode_to_execute_SRC1_CTRL_string;
  reg [31:0] decode_to_execute_BRANCH_CTRL_string;
  reg [71:0] decode_to_execute_SHIFT_CTRL_string;
  reg [63:0] decode_to_execute_ALU_CTRL_string;
  reg [39:0] decode_to_execute_ALU_BITWISE_CTRL_string;
  reg [47:0] decode_to_execute_ENV_CTRL_string;
  `endif

  reg [31:0] RegFilePlugin_regFile [0:31] /* verilator public */ ;
  assign _zz_190_ = ((execute_arbitration_isValid && execute_LightShifterPlugin_isShift) && (execute_SRC2[4 : 0] != (5'b00000)));
  assign _zz_191_ = (! execute_arbitration_isStuckByOthers);
  assign _zz_192_ = (CsrPlugin_hadException || CsrPlugin_interruptJump);
  assign _zz_193_ = (execute_arbitration_isValid && (execute_ENV_CTRL == `EnvCtrlEnum_defaultEncoding_XRET));
  assign _zz_194_ = (execute_arbitration_isValid && execute_DO_EBREAK);
  assign _zz_195_ = (1'b0 == 1'b0);
  assign _zz_196_ = (DebugPlugin_stepIt && _zz_69_);
  assign _zz_197_ = (IBusCachedPlugin_fetchPc_preOutput_valid && IBusCachedPlugin_fetchPc_preOutput_ready);
  assign _zz_198_ = debug_bus_cmd_payload_address[7 : 2];
  assign _zz_199_ = (iBus_cmd_valid || (_zz_166_ != (3'b000)));
  assign _zz_200_ = (! dBus_cmd_halfPipe_regs_valid);
  assign _zz_201_ = execute_INSTRUCTION[13 : 12];
  assign _zz_202_ = execute_INSTRUCTION[29 : 28];
  assign _zz_203_ = execute_INSTRUCTION[13];
  assign _zz_204_ = (_zz_87_ - (4'b0001));
  assign _zz_205_ = {IBusCachedPlugin_fetchPc_inc,(2'b00)};
  assign _zz_206_ = {29'd0, _zz_205_};
  assign _zz_207_ = {{{decode_INSTRUCTION[31],decode_INSTRUCTION[7]},decode_INSTRUCTION[30 : 25]},decode_INSTRUCTION[11 : 8]};
  assign _zz_208_ = {{_zz_104_,{{{decode_INSTRUCTION[31],decode_INSTRUCTION[7]},decode_INSTRUCTION[30 : 25]},decode_INSTRUCTION[11 : 8]}},1'b0};
  assign _zz_209_ = {{{decode_INSTRUCTION[31],decode_INSTRUCTION[19 : 12]},decode_INSTRUCTION[20]},decode_INSTRUCTION[30 : 21]};
  assign _zz_210_ = {{{decode_INSTRUCTION[31],decode_INSTRUCTION[7]},decode_INSTRUCTION[30 : 25]},decode_INSTRUCTION[11 : 8]};
  assign _zz_211_ = _zz_115_[0 : 0];
  assign _zz_212_ = _zz_115_[1 : 1];
  assign _zz_213_ = _zz_115_[2 : 2];
  assign _zz_214_ = _zz_115_[3 : 3];
  assign _zz_215_ = _zz_115_[19 : 19];
  assign _zz_216_ = _zz_115_[21 : 21];
  assign _zz_217_ = _zz_115_[25 : 25];
  assign _zz_218_ = execute_SRC_LESS;
  assign _zz_219_ = (3'b100);
  assign _zz_220_ = execute_INSTRUCTION[19 : 15];
  assign _zz_221_ = execute_INSTRUCTION[31 : 20];
  assign _zz_222_ = {execute_INSTRUCTION[31 : 25],execute_INSTRUCTION[11 : 7]};
  assign _zz_223_ = ($signed(_zz_224_) + $signed(_zz_228_));
  assign _zz_224_ = ($signed(_zz_225_) + $signed(_zz_226_));
  assign _zz_225_ = execute_SRC1;
  assign _zz_226_ = (execute_SRC_USE_SUB_LESS ? (~ execute_SRC2) : execute_SRC2);
  assign _zz_227_ = (execute_SRC_USE_SUB_LESS ? _zz_229_ : _zz_230_);
  assign _zz_228_ = {{30{_zz_227_[1]}}, _zz_227_};
  assign _zz_229_ = (2'b01);
  assign _zz_230_ = (2'b00);
  assign _zz_231_ = (_zz_232_ >>> 1);
  assign _zz_232_ = {((execute_SHIFT_CTRL == `ShiftCtrlEnum_defaultEncoding_SRA_1) && execute_LightShifterPlugin_shiftInput[31]),execute_LightShifterPlugin_shiftInput};
  assign _zz_233_ = execute_INSTRUCTION[31 : 20];
  assign _zz_234_ = {{{execute_INSTRUCTION[31],execute_INSTRUCTION[19 : 12]},execute_INSTRUCTION[20]},execute_INSTRUCTION[30 : 21]};
  assign _zz_235_ = {{{execute_INSTRUCTION[31],execute_INSTRUCTION[7]},execute_INSTRUCTION[30 : 25]},execute_INSTRUCTION[11 : 8]};
  assign _zz_236_ = {_zz_141_,execute_INSTRUCTION[31 : 20]};
  assign _zz_237_ = {{_zz_143_,{{{execute_INSTRUCTION[31],execute_INSTRUCTION[19 : 12]},execute_INSTRUCTION[20]},execute_INSTRUCTION[30 : 21]}},1'b0};
  assign _zz_238_ = {{_zz_145_,{{{execute_INSTRUCTION[31],execute_INSTRUCTION[7]},execute_INSTRUCTION[30 : 25]},execute_INSTRUCTION[11 : 8]}},1'b0};
  assign _zz_239_ = execute_INSTRUCTION[31 : 20];
  assign _zz_240_ = {{{execute_INSTRUCTION[31],execute_INSTRUCTION[19 : 12]},execute_INSTRUCTION[20]},execute_INSTRUCTION[30 : 21]};
  assign _zz_241_ = {{{execute_INSTRUCTION[31],execute_INSTRUCTION[7]},execute_INSTRUCTION[30 : 25]},execute_INSTRUCTION[11 : 8]};
  assign _zz_242_ = (3'b100);
  assign _zz_243_ = (_zz_156_ - (3'b001));
  assign _zz_244_ = (execute_INSTRUCTION[5] ? (3'b110) : (3'b100));
  assign _zz_245_ = {1'd0, _zz_244_};
  assign _zz_246_ = debug_bus_cmd_payload_data[0 : 0];
  assign _zz_247_ = debug_bus_cmd_payload_data[0 : 0];
  assign _zz_248_ = debug_bus_cmd_payload_data[0 : 0];
  assign _zz_249_ = debug_bus_cmd_payload_data[0 : 0];
  assign _zz_250_ = (decode_PC >>> 1);
  assign _zz_251_ = (decode_PC >>> 1);
  assign _zz_252_ = (decode_PC >>> 1);
  assign _zz_253_ = (decode_PC >>> 1);
  assign _zz_254_ = execute_CsrPlugin_writeData[7 : 7];
  assign _zz_255_ = execute_CsrPlugin_writeData[3 : 3];
  assign _zz_256_ = execute_CsrPlugin_writeData[3 : 3];
  assign _zz_257_ = execute_CsrPlugin_writeData[11 : 11];
  assign _zz_258_ = execute_CsrPlugin_writeData[7 : 7];
  assign _zz_259_ = execute_CsrPlugin_writeData[3 : 3];
  assign _zz_260_ = (iBus_cmd_payload_address >>> 5);
  assign _zz_261_ = ({3'd0,_zz_168_} <<< dBus_cmd_halfPipe_payload_address[1 : 0]);
  assign _zz_262_ = {_zz_91_,_zz_90_};
  assign _zz_263_ = decode_INSTRUCTION[31];
  assign _zz_264_ = decode_INSTRUCTION[19 : 12];
  assign _zz_265_ = decode_INSTRUCTION[20];
  assign _zz_266_ = decode_INSTRUCTION[31];
  assign _zz_267_ = decode_INSTRUCTION[7];
  assign _zz_268_ = (decode_INSTRUCTION & (32'b00000000000000000001000001010000));
  assign _zz_269_ = (32'b00000000000000000001000001010000);
  assign _zz_270_ = (decode_INSTRUCTION & (32'b00000000000000000010000001010000));
  assign _zz_271_ = (32'b00000000000000000010000001010000);
  assign _zz_272_ = ((decode_INSTRUCTION & _zz_279_) == (32'b00000000000000000001000000000000));
  assign _zz_273_ = _zz_117_;
  assign _zz_274_ = {_zz_117_,{_zz_280_,_zz_281_}};
  assign _zz_275_ = (3'b000);
  assign _zz_276_ = ({_zz_119_,{_zz_282_,_zz_283_}} != (6'b000000));
  assign _zz_277_ = (_zz_284_ != (1'b0));
  assign _zz_278_ = {(_zz_285_ != _zz_286_),{_zz_287_,{_zz_288_,_zz_289_}}};
  assign _zz_279_ = (32'b00000000000000000001000000000000);
  assign _zz_280_ = ((decode_INSTRUCTION & _zz_290_) == (32'b00000000000000000001000000000000));
  assign _zz_281_ = ((decode_INSTRUCTION & _zz_291_) == (32'b00000000000000000010000000000000));
  assign _zz_282_ = (_zz_292_ == _zz_293_);
  assign _zz_283_ = {_zz_294_,{_zz_295_,_zz_296_}};
  assign _zz_284_ = ((decode_INSTRUCTION & _zz_297_) == (32'b00000000000000000000000000010000));
  assign _zz_285_ = {_zz_298_,{_zz_299_,_zz_300_}};
  assign _zz_286_ = (3'b000);
  assign _zz_287_ = ({_zz_301_,_zz_302_} != (2'b00));
  assign _zz_288_ = (_zz_303_ != _zz_304_);
  assign _zz_289_ = {_zz_305_,{_zz_306_,_zz_307_}};
  assign _zz_290_ = (32'b00000000000000000011000000000000);
  assign _zz_291_ = (32'b00000000000000000011000000000000);
  assign _zz_292_ = (decode_INSTRUCTION & (32'b00000000000000000001000000010000));
  assign _zz_293_ = (32'b00000000000000000001000000010000);
  assign _zz_294_ = ((decode_INSTRUCTION & _zz_308_) == (32'b00000000000000000010000000010000));
  assign _zz_295_ = _zz_120_;
  assign _zz_296_ = {_zz_309_,_zz_310_};
  assign _zz_297_ = (32'b00000000000000000000000000010000);
  assign _zz_298_ = ((decode_INSTRUCTION & _zz_311_) == (32'b00000000000000000000000001000000));
  assign _zz_299_ = (_zz_312_ == _zz_313_);
  assign _zz_300_ = (_zz_314_ == _zz_315_);
  assign _zz_301_ = _zz_119_;
  assign _zz_302_ = (_zz_316_ == _zz_317_);
  assign _zz_303_ = (_zz_318_ == _zz_319_);
  assign _zz_304_ = (1'b0);
  assign _zz_305_ = ({_zz_320_,_zz_321_} != (2'b00));
  assign _zz_306_ = (_zz_322_ != _zz_323_);
  assign _zz_307_ = {_zz_324_,{_zz_325_,_zz_326_}};
  assign _zz_308_ = (32'b00000000000000000010000000010000);
  assign _zz_309_ = ((decode_INSTRUCTION & (32'b00000000000000000000000000101000)) == (32'b00000000000000000000000000000000));
  assign _zz_310_ = ((decode_INSTRUCTION & (32'b00000000000000000101000000000100)) == (32'b00000000000000000000000000000100));
  assign _zz_311_ = (32'b00000000000000000000000001000100);
  assign _zz_312_ = (decode_INSTRUCTION & (32'b01000000000000000000000000110000));
  assign _zz_313_ = (32'b01000000000000000000000000110000);
  assign _zz_314_ = (decode_INSTRUCTION & (32'b00000000000000000010000000010100));
  assign _zz_315_ = (32'b00000000000000000010000000010000);
  assign _zz_316_ = (decode_INSTRUCTION & (32'b00000000000000000101000000010100));
  assign _zz_317_ = (32'b00000000000000000000000000000100);
  assign _zz_318_ = (decode_INSTRUCTION & (32'b00000000000000000000000001011000));
  assign _zz_319_ = (32'b00000000000000000000000001000000);
  assign _zz_320_ = ((decode_INSTRUCTION & _zz_327_) == (32'b00000000000000000000000000000100));
  assign _zz_321_ = _zz_118_;
  assign _zz_322_ = {(_zz_328_ == _zz_329_),_zz_118_};
  assign _zz_323_ = (2'b00);
  assign _zz_324_ = ((_zz_330_ == _zz_331_) != (1'b0));
  assign _zz_325_ = ({_zz_332_,_zz_333_} != (2'b00));
  assign _zz_326_ = {(_zz_334_ != _zz_335_),{_zz_336_,{_zz_337_,_zz_338_}}};
  assign _zz_327_ = (32'b00000000000000000000000000010100);
  assign _zz_328_ = (decode_INSTRUCTION & (32'b00000000000000000000000001000100));
  assign _zz_329_ = (32'b00000000000000000000000000000100);
  assign _zz_330_ = (decode_INSTRUCTION & (32'b00010000000000000011000001010000));
  assign _zz_331_ = (32'b00000000000000000000000001010000);
  assign _zz_332_ = _zz_116_;
  assign _zz_333_ = ((decode_INSTRUCTION & (32'b00010000010000000011000001010000)) == (32'b00010000000000000000000001010000));
  assign _zz_334_ = ((decode_INSTRUCTION & (32'b00000000000000000000000000000000)) == (32'b00000000000000000000000000000000));
  assign _zz_335_ = (1'b0);
  assign _zz_336_ = (((decode_INSTRUCTION & _zz_339_) == (32'b00000000000000000101000000010000)) != (1'b0));
  assign _zz_337_ = ({_zz_340_,_zz_341_} != (2'b00));
  assign _zz_338_ = {({_zz_342_,_zz_343_} != (2'b00)),{(_zz_344_ != _zz_345_),{_zz_346_,{_zz_347_,_zz_348_}}}};
  assign _zz_339_ = (32'b00000000000000000111000001010100);
  assign _zz_340_ = ((decode_INSTRUCTION & (32'b01000000000000000011000001010100)) == (32'b01000000000000000001000000010000));
  assign _zz_341_ = ((decode_INSTRUCTION & (32'b00000000000000000111000001010100)) == (32'b00000000000000000001000000010000));
  assign _zz_342_ = ((decode_INSTRUCTION & _zz_349_) == (32'b00000000000000000000000000100000));
  assign _zz_343_ = ((decode_INSTRUCTION & _zz_350_) == (32'b00000000000000000000000000100000));
  assign _zz_344_ = {(_zz_351_ == _zz_352_),{_zz_353_,{_zz_354_,_zz_355_}}};
  assign _zz_345_ = (4'b0000);
  assign _zz_346_ = ({_zz_117_,_zz_356_} != (2'b00));
  assign _zz_347_ = ({_zz_357_,_zz_358_} != (2'b00));
  assign _zz_348_ = {(_zz_359_ != _zz_360_),{_zz_361_,{_zz_362_,_zz_363_}}};
  assign _zz_349_ = (32'b00000000000000000000000000110100);
  assign _zz_350_ = (32'b00000000000000000000000001100100);
  assign _zz_351_ = (decode_INSTRUCTION & (32'b00000000000000000000000001000100));
  assign _zz_352_ = (32'b00000000000000000000000000000000);
  assign _zz_353_ = ((decode_INSTRUCTION & _zz_364_) == (32'b00000000000000000000000000000000));
  assign _zz_354_ = (_zz_365_ == _zz_366_);
  assign _zz_355_ = (_zz_367_ == _zz_368_);
  assign _zz_356_ = ((decode_INSTRUCTION & _zz_369_) == (32'b00000000000000000000000000100000));
  assign _zz_357_ = _zz_117_;
  assign _zz_358_ = (_zz_370_ == _zz_371_);
  assign _zz_359_ = {_zz_372_,{_zz_373_,_zz_374_}};
  assign _zz_360_ = (3'b000);
  assign _zz_361_ = (_zz_375_ != (1'b0));
  assign _zz_362_ = (_zz_376_ != _zz_377_);
  assign _zz_363_ = {_zz_378_,{_zz_379_,_zz_380_}};
  assign _zz_364_ = (32'b00000000000000000000000000011000);
  assign _zz_365_ = (decode_INSTRUCTION & (32'b00000000000000000110000000000100));
  assign _zz_366_ = (32'b00000000000000000010000000000000);
  assign _zz_367_ = (decode_INSTRUCTION & (32'b00000000000000000101000000000100));
  assign _zz_368_ = (32'b00000000000000000001000000000000);
  assign _zz_369_ = (32'b00000000000000000000000001110000);
  assign _zz_370_ = (decode_INSTRUCTION & (32'b00000000000000000000000000100000));
  assign _zz_371_ = (32'b00000000000000000000000000000000);
  assign _zz_372_ = ((decode_INSTRUCTION & (32'b00000000000000000000000001100100)) == (32'b00000000000000000000000000100100));
  assign _zz_373_ = ((decode_INSTRUCTION & _zz_381_) == (32'b00000000000000000100000000010000));
  assign _zz_374_ = ((decode_INSTRUCTION & _zz_382_) == (32'b00000000000000000001000000010000));
  assign _zz_375_ = ((decode_INSTRUCTION & (32'b00000000000000000110000000010100)) == (32'b00000000000000000010000000010000));
  assign _zz_376_ = {(_zz_383_ == _zz_384_),(_zz_385_ == _zz_386_)};
  assign _zz_377_ = (2'b00);
  assign _zz_378_ = ((_zz_387_ == _zz_388_) != (1'b0));
  assign _zz_379_ = (_zz_116_ != (1'b0));
  assign _zz_380_ = (_zz_389_ != (1'b0));
  assign _zz_381_ = (32'b00000000000000000100000000010100);
  assign _zz_382_ = (32'b00000000000000000011000000010100);
  assign _zz_383_ = (decode_INSTRUCTION & (32'b00000000000000000010000000010000));
  assign _zz_384_ = (32'b00000000000000000010000000000000);
  assign _zz_385_ = (decode_INSTRUCTION & (32'b00000000000000000101000000000000));
  assign _zz_386_ = (32'b00000000000000000001000000000000);
  assign _zz_387_ = (decode_INSTRUCTION & (32'b00000000000000000000000001011000));
  assign _zz_388_ = (32'b00000000000000000000000000000000);
  assign _zz_389_ = ((decode_INSTRUCTION & (32'b00000000000000000001000001001000)) == (32'b00000000000000000000000000001000));
  assign _zz_390_ = execute_INSTRUCTION[31];
  assign _zz_391_ = execute_INSTRUCTION[31];
  assign _zz_392_ = execute_INSTRUCTION[7];
  always @ (posedge clk) begin
    if(_zz_41_) begin
      RegFilePlugin_regFile[execute_RegFilePlugin_regFileWrite_payload_address] <= execute_RegFilePlugin_regFileWrite_payload_data;
    end
  end

  always @ (posedge clk) begin
    if(_zz_128_) begin
      _zz_185_ <= RegFilePlugin_regFile[execute_RegFilePlugin_regFileReadAddress1];
    end
  end

  always @ (posedge clk) begin
    if(_zz_128_) begin
      _zz_186_ <= RegFilePlugin_regFile[execute_RegFilePlugin_regFileReadAddress2];
    end
  end

  InstructionCache IBusCachedPlugin_cache ( 
    .io_flush_cmd_valid(_zz_169_),
    .io_flush_cmd_ready(IBusCachedPlugin_cache_io_flush_cmd_ready),
    .io_flush_rsp(IBusCachedPlugin_cache_io_flush_rsp),
    .io_cpu_prefetch_isValid(_zz_170_),
    .io_cpu_prefetch_haltIt(IBusCachedPlugin_cache_io_cpu_prefetch_haltIt),
    .io_cpu_prefetch_pc(IBusCachedPlugin_iBusRsp_stages_0_input_payload),
    .io_cpu_fetch_isValid(_zz_171_),
    .io_cpu_fetch_isStuck(_zz_172_),
    .io_cpu_fetch_isRemoved(_zz_173_),
    .io_cpu_fetch_pc(IBusCachedPlugin_iBusRsp_stages_1_input_payload),
    .io_cpu_fetch_data(IBusCachedPlugin_cache_io_cpu_fetch_data),
    .io_cpu_fetch_dataBypassValid(IBusCachedPlugin_s1_tightlyCoupledHit),
    .io_cpu_fetch_dataBypass(_zz_174_),
    .io_cpu_fetch_mmuBus_cmd_isValid(IBusCachedPlugin_cache_io_cpu_fetch_mmuBus_cmd_isValid),
    .io_cpu_fetch_mmuBus_cmd_virtualAddress(IBusCachedPlugin_cache_io_cpu_fetch_mmuBus_cmd_virtualAddress),
    .io_cpu_fetch_mmuBus_cmd_bypassTranslation(IBusCachedPlugin_cache_io_cpu_fetch_mmuBus_cmd_bypassTranslation),
    .io_cpu_fetch_mmuBus_rsp_physicalAddress(_zz_75_),
    .io_cpu_fetch_mmuBus_rsp_isIoAccess(_zz_175_),
    .io_cpu_fetch_mmuBus_rsp_allowRead(_zz_176_),
    .io_cpu_fetch_mmuBus_rsp_allowWrite(_zz_177_),
    .io_cpu_fetch_mmuBus_rsp_allowExecute(_zz_178_),
    .io_cpu_fetch_mmuBus_rsp_allowUser(_zz_179_),
    .io_cpu_fetch_mmuBus_rsp_miss(_zz_180_),
    .io_cpu_fetch_mmuBus_rsp_hit(_zz_181_),
    .io_cpu_fetch_mmuBus_end(IBusCachedPlugin_cache_io_cpu_fetch_mmuBus_end),
    .io_cpu_fetch_physicalAddress(IBusCachedPlugin_cache_io_cpu_fetch_physicalAddress),
    .io_cpu_decode_isValid(_zz_182_),
    .io_cpu_decode_isStuck(_zz_183_),
    .io_cpu_decode_pc(IBusCachedPlugin_iBusRsp_cacheRspArbitration_input_payload),
    .io_cpu_decode_physicalAddress(IBusCachedPlugin_cache_io_cpu_decode_physicalAddress),
    .io_cpu_decode_data(IBusCachedPlugin_cache_io_cpu_decode_data),
    .io_cpu_decode_cacheMiss(IBusCachedPlugin_cache_io_cpu_decode_cacheMiss),
    .io_cpu_decode_error(IBusCachedPlugin_cache_io_cpu_decode_error),
    .io_cpu_decode_mmuMiss(IBusCachedPlugin_cache_io_cpu_decode_mmuMiss),
    .io_cpu_decode_illegalAccess(IBusCachedPlugin_cache_io_cpu_decode_illegalAccess),
    .io_cpu_decode_isUser(_zz_184_),
    .io_cpu_fill_valid(IBusCachedPlugin_rsp_redoFetch),
    .io_cpu_fill_payload(IBusCachedPlugin_cache_io_cpu_decode_physicalAddress),
    .io_mem_cmd_valid(IBusCachedPlugin_cache_io_mem_cmd_valid),
    .io_mem_cmd_ready(iBus_cmd_ready),
    .io_mem_cmd_payload_address(IBusCachedPlugin_cache_io_mem_cmd_payload_address),
    .io_mem_cmd_payload_size(IBusCachedPlugin_cache_io_mem_cmd_payload_size),
    .io_mem_rsp_valid(iBus_rsp_valid),
    .io_mem_rsp_payload_data(iBus_rsp_payload_data),
    .io_mem_rsp_payload_error(iBus_rsp_payload_error),
    .clk(clk),
    .reset(reset) 
  );
  always @(*) begin
    case(_zz_262_)
      2'b00 : begin
        _zz_187_ = execute_BRANCH_CALC;
      end
      2'b01 : begin
        _zz_187_ = _zz_80_;
      end
      2'b10 : begin
        _zz_187_ = _zz_74_;
      end
      default : begin
        _zz_187_ = _zz_71_;
      end
    endcase
  end

  always @(*) begin
    case(_zz_160_)
      2'b00 : begin
        _zz_188_ = _zz_245_;
        _zz_189_ = execute_REGFILE_WRITE_DATA;
      end
      2'b01 : begin
        _zz_188_ = (4'b0000);
        _zz_189_ = execute_BRANCH_CALC;
      end
      default : begin
        _zz_188_ = _zz_82_;
        _zz_189_ = (32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx);
      end
    endcase
  end

  `ifndef SYNTHESIS
  always @(*) begin
    case(decode_ENV_CTRL)
      `EnvCtrlEnum_defaultEncoding_NONE : decode_ENV_CTRL_string = "NONE  ";
      `EnvCtrlEnum_defaultEncoding_XRET : decode_ENV_CTRL_string = "XRET  ";
      `EnvCtrlEnum_defaultEncoding_ECALL : decode_ENV_CTRL_string = "ECALL ";
      `EnvCtrlEnum_defaultEncoding_EBREAK : decode_ENV_CTRL_string = "EBREAK";
      default : decode_ENV_CTRL_string = "??????";
    endcase
  end
  always @(*) begin
    case(_zz_1_)
      `EnvCtrlEnum_defaultEncoding_NONE : _zz_1__string = "NONE  ";
      `EnvCtrlEnum_defaultEncoding_XRET : _zz_1__string = "XRET  ";
      `EnvCtrlEnum_defaultEncoding_ECALL : _zz_1__string = "ECALL ";
      `EnvCtrlEnum_defaultEncoding_EBREAK : _zz_1__string = "EBREAK";
      default : _zz_1__string = "??????";
    endcase
  end
  always @(*) begin
    case(_zz_2_)
      `EnvCtrlEnum_defaultEncoding_NONE : _zz_2__string = "NONE  ";
      `EnvCtrlEnum_defaultEncoding_XRET : _zz_2__string = "XRET  ";
      `EnvCtrlEnum_defaultEncoding_ECALL : _zz_2__string = "ECALL ";
      `EnvCtrlEnum_defaultEncoding_EBREAK : _zz_2__string = "EBREAK";
      default : _zz_2__string = "??????";
    endcase
  end
  always @(*) begin
    case(_zz_3_)
      `EnvCtrlEnum_defaultEncoding_NONE : _zz_3__string = "NONE  ";
      `EnvCtrlEnum_defaultEncoding_XRET : _zz_3__string = "XRET  ";
      `EnvCtrlEnum_defaultEncoding_ECALL : _zz_3__string = "ECALL ";
      `EnvCtrlEnum_defaultEncoding_EBREAK : _zz_3__string = "EBREAK";
      default : _zz_3__string = "??????";
    endcase
  end
  always @(*) begin
    case(decode_ALU_BITWISE_CTRL)
      `AluBitwiseCtrlEnum_defaultEncoding_XOR_1 : decode_ALU_BITWISE_CTRL_string = "XOR_1";
      `AluBitwiseCtrlEnum_defaultEncoding_OR_1 : decode_ALU_BITWISE_CTRL_string = "OR_1 ";
      `AluBitwiseCtrlEnum_defaultEncoding_AND_1 : decode_ALU_BITWISE_CTRL_string = "AND_1";
      `AluBitwiseCtrlEnum_defaultEncoding_SRC1 : decode_ALU_BITWISE_CTRL_string = "SRC1 ";
      default : decode_ALU_BITWISE_CTRL_string = "?????";
    endcase
  end
  always @(*) begin
    case(_zz_4_)
      `AluBitwiseCtrlEnum_defaultEncoding_XOR_1 : _zz_4__string = "XOR_1";
      `AluBitwiseCtrlEnum_defaultEncoding_OR_1 : _zz_4__string = "OR_1 ";
      `AluBitwiseCtrlEnum_defaultEncoding_AND_1 : _zz_4__string = "AND_1";
      `AluBitwiseCtrlEnum_defaultEncoding_SRC1 : _zz_4__string = "SRC1 ";
      default : _zz_4__string = "?????";
    endcase
  end
  always @(*) begin
    case(_zz_5_)
      `AluBitwiseCtrlEnum_defaultEncoding_XOR_1 : _zz_5__string = "XOR_1";
      `AluBitwiseCtrlEnum_defaultEncoding_OR_1 : _zz_5__string = "OR_1 ";
      `AluBitwiseCtrlEnum_defaultEncoding_AND_1 : _zz_5__string = "AND_1";
      `AluBitwiseCtrlEnum_defaultEncoding_SRC1 : _zz_5__string = "SRC1 ";
      default : _zz_5__string = "?????";
    endcase
  end
  always @(*) begin
    case(_zz_6_)
      `AluBitwiseCtrlEnum_defaultEncoding_XOR_1 : _zz_6__string = "XOR_1";
      `AluBitwiseCtrlEnum_defaultEncoding_OR_1 : _zz_6__string = "OR_1 ";
      `AluBitwiseCtrlEnum_defaultEncoding_AND_1 : _zz_6__string = "AND_1";
      `AluBitwiseCtrlEnum_defaultEncoding_SRC1 : _zz_6__string = "SRC1 ";
      default : _zz_6__string = "?????";
    endcase
  end
  always @(*) begin
    case(decode_ALU_CTRL)
      `AluCtrlEnum_defaultEncoding_ADD_SUB : decode_ALU_CTRL_string = "ADD_SUB ";
      `AluCtrlEnum_defaultEncoding_SLT_SLTU : decode_ALU_CTRL_string = "SLT_SLTU";
      `AluCtrlEnum_defaultEncoding_BITWISE : decode_ALU_CTRL_string = "BITWISE ";
      default : decode_ALU_CTRL_string = "????????";
    endcase
  end
  always @(*) begin
    case(_zz_7_)
      `AluCtrlEnum_defaultEncoding_ADD_SUB : _zz_7__string = "ADD_SUB ";
      `AluCtrlEnum_defaultEncoding_SLT_SLTU : _zz_7__string = "SLT_SLTU";
      `AluCtrlEnum_defaultEncoding_BITWISE : _zz_7__string = "BITWISE ";
      default : _zz_7__string = "????????";
    endcase
  end
  always @(*) begin
    case(_zz_8_)
      `AluCtrlEnum_defaultEncoding_ADD_SUB : _zz_8__string = "ADD_SUB ";
      `AluCtrlEnum_defaultEncoding_SLT_SLTU : _zz_8__string = "SLT_SLTU";
      `AluCtrlEnum_defaultEncoding_BITWISE : _zz_8__string = "BITWISE ";
      default : _zz_8__string = "????????";
    endcase
  end
  always @(*) begin
    case(_zz_9_)
      `AluCtrlEnum_defaultEncoding_ADD_SUB : _zz_9__string = "ADD_SUB ";
      `AluCtrlEnum_defaultEncoding_SLT_SLTU : _zz_9__string = "SLT_SLTU";
      `AluCtrlEnum_defaultEncoding_BITWISE : _zz_9__string = "BITWISE ";
      default : _zz_9__string = "????????";
    endcase
  end
  always @(*) begin
    case(decode_SHIFT_CTRL)
      `ShiftCtrlEnum_defaultEncoding_DISABLE_1 : decode_SHIFT_CTRL_string = "DISABLE_1";
      `ShiftCtrlEnum_defaultEncoding_SLL_1 : decode_SHIFT_CTRL_string = "SLL_1    ";
      `ShiftCtrlEnum_defaultEncoding_SRL_1 : decode_SHIFT_CTRL_string = "SRL_1    ";
      `ShiftCtrlEnum_defaultEncoding_SRA_1 : decode_SHIFT_CTRL_string = "SRA_1    ";
      default : decode_SHIFT_CTRL_string = "?????????";
    endcase
  end
  always @(*) begin
    case(_zz_10_)
      `ShiftCtrlEnum_defaultEncoding_DISABLE_1 : _zz_10__string = "DISABLE_1";
      `ShiftCtrlEnum_defaultEncoding_SLL_1 : _zz_10__string = "SLL_1    ";
      `ShiftCtrlEnum_defaultEncoding_SRL_1 : _zz_10__string = "SRL_1    ";
      `ShiftCtrlEnum_defaultEncoding_SRA_1 : _zz_10__string = "SRA_1    ";
      default : _zz_10__string = "?????????";
    endcase
  end
  always @(*) begin
    case(_zz_11_)
      `ShiftCtrlEnum_defaultEncoding_DISABLE_1 : _zz_11__string = "DISABLE_1";
      `ShiftCtrlEnum_defaultEncoding_SLL_1 : _zz_11__string = "SLL_1    ";
      `ShiftCtrlEnum_defaultEncoding_SRL_1 : _zz_11__string = "SRL_1    ";
      `ShiftCtrlEnum_defaultEncoding_SRA_1 : _zz_11__string = "SRA_1    ";
      default : _zz_11__string = "?????????";
    endcase
  end
  always @(*) begin
    case(_zz_12_)
      `ShiftCtrlEnum_defaultEncoding_DISABLE_1 : _zz_12__string = "DISABLE_1";
      `ShiftCtrlEnum_defaultEncoding_SLL_1 : _zz_12__string = "SLL_1    ";
      `ShiftCtrlEnum_defaultEncoding_SRL_1 : _zz_12__string = "SRL_1    ";
      `ShiftCtrlEnum_defaultEncoding_SRA_1 : _zz_12__string = "SRA_1    ";
      default : _zz_12__string = "?????????";
    endcase
  end
  always @(*) begin
    case(_zz_13_)
      `BranchCtrlEnum_defaultEncoding_INC : _zz_13__string = "INC ";
      `BranchCtrlEnum_defaultEncoding_B : _zz_13__string = "B   ";
      `BranchCtrlEnum_defaultEncoding_JAL : _zz_13__string = "JAL ";
      `BranchCtrlEnum_defaultEncoding_JALR : _zz_13__string = "JALR";
      default : _zz_13__string = "????";
    endcase
  end
  always @(*) begin
    case(_zz_14_)
      `BranchCtrlEnum_defaultEncoding_INC : _zz_14__string = "INC ";
      `BranchCtrlEnum_defaultEncoding_B : _zz_14__string = "B   ";
      `BranchCtrlEnum_defaultEncoding_JAL : _zz_14__string = "JAL ";
      `BranchCtrlEnum_defaultEncoding_JALR : _zz_14__string = "JALR";
      default : _zz_14__string = "????";
    endcase
  end
  always @(*) begin
    case(decode_SRC1_CTRL)
      `Src1CtrlEnum_defaultEncoding_RS : decode_SRC1_CTRL_string = "RS          ";
      `Src1CtrlEnum_defaultEncoding_IMU : decode_SRC1_CTRL_string = "IMU         ";
      `Src1CtrlEnum_defaultEncoding_PC_INCREMENT : decode_SRC1_CTRL_string = "PC_INCREMENT";
      `Src1CtrlEnum_defaultEncoding_URS1 : decode_SRC1_CTRL_string = "URS1        ";
      default : decode_SRC1_CTRL_string = "????????????";
    endcase
  end
  always @(*) begin
    case(_zz_15_)
      `Src1CtrlEnum_defaultEncoding_RS : _zz_15__string = "RS          ";
      `Src1CtrlEnum_defaultEncoding_IMU : _zz_15__string = "IMU         ";
      `Src1CtrlEnum_defaultEncoding_PC_INCREMENT : _zz_15__string = "PC_INCREMENT";
      `Src1CtrlEnum_defaultEncoding_URS1 : _zz_15__string = "URS1        ";
      default : _zz_15__string = "????????????";
    endcase
  end
  always @(*) begin
    case(_zz_16_)
      `Src1CtrlEnum_defaultEncoding_RS : _zz_16__string = "RS          ";
      `Src1CtrlEnum_defaultEncoding_IMU : _zz_16__string = "IMU         ";
      `Src1CtrlEnum_defaultEncoding_PC_INCREMENT : _zz_16__string = "PC_INCREMENT";
      `Src1CtrlEnum_defaultEncoding_URS1 : _zz_16__string = "URS1        ";
      default : _zz_16__string = "????????????";
    endcase
  end
  always @(*) begin
    case(_zz_17_)
      `Src1CtrlEnum_defaultEncoding_RS : _zz_17__string = "RS          ";
      `Src1CtrlEnum_defaultEncoding_IMU : _zz_17__string = "IMU         ";
      `Src1CtrlEnum_defaultEncoding_PC_INCREMENT : _zz_17__string = "PC_INCREMENT";
      `Src1CtrlEnum_defaultEncoding_URS1 : _zz_17__string = "URS1        ";
      default : _zz_17__string = "????????????";
    endcase
  end
  always @(*) begin
    case(decode_SRC2_CTRL)
      `Src2CtrlEnum_defaultEncoding_RS : decode_SRC2_CTRL_string = "RS ";
      `Src2CtrlEnum_defaultEncoding_IMI : decode_SRC2_CTRL_string = "IMI";
      `Src2CtrlEnum_defaultEncoding_IMS : decode_SRC2_CTRL_string = "IMS";
      `Src2CtrlEnum_defaultEncoding_PC : decode_SRC2_CTRL_string = "PC ";
      default : decode_SRC2_CTRL_string = "???";
    endcase
  end
  always @(*) begin
    case(_zz_18_)
      `Src2CtrlEnum_defaultEncoding_RS : _zz_18__string = "RS ";
      `Src2CtrlEnum_defaultEncoding_IMI : _zz_18__string = "IMI";
      `Src2CtrlEnum_defaultEncoding_IMS : _zz_18__string = "IMS";
      `Src2CtrlEnum_defaultEncoding_PC : _zz_18__string = "PC ";
      default : _zz_18__string = "???";
    endcase
  end
  always @(*) begin
    case(_zz_19_)
      `Src2CtrlEnum_defaultEncoding_RS : _zz_19__string = "RS ";
      `Src2CtrlEnum_defaultEncoding_IMI : _zz_19__string = "IMI";
      `Src2CtrlEnum_defaultEncoding_IMS : _zz_19__string = "IMS";
      `Src2CtrlEnum_defaultEncoding_PC : _zz_19__string = "PC ";
      default : _zz_19__string = "???";
    endcase
  end
  always @(*) begin
    case(_zz_20_)
      `Src2CtrlEnum_defaultEncoding_RS : _zz_20__string = "RS ";
      `Src2CtrlEnum_defaultEncoding_IMI : _zz_20__string = "IMI";
      `Src2CtrlEnum_defaultEncoding_IMS : _zz_20__string = "IMS";
      `Src2CtrlEnum_defaultEncoding_PC : _zz_20__string = "PC ";
      default : _zz_20__string = "???";
    endcase
  end
  always @(*) begin
    case(execute_ENV_CTRL)
      `EnvCtrlEnum_defaultEncoding_NONE : execute_ENV_CTRL_string = "NONE  ";
      `EnvCtrlEnum_defaultEncoding_XRET : execute_ENV_CTRL_string = "XRET  ";
      `EnvCtrlEnum_defaultEncoding_ECALL : execute_ENV_CTRL_string = "ECALL ";
      `EnvCtrlEnum_defaultEncoding_EBREAK : execute_ENV_CTRL_string = "EBREAK";
      default : execute_ENV_CTRL_string = "??????";
    endcase
  end
  always @(*) begin
    case(_zz_24_)
      `EnvCtrlEnum_defaultEncoding_NONE : _zz_24__string = "NONE  ";
      `EnvCtrlEnum_defaultEncoding_XRET : _zz_24__string = "XRET  ";
      `EnvCtrlEnum_defaultEncoding_ECALL : _zz_24__string = "ECALL ";
      `EnvCtrlEnum_defaultEncoding_EBREAK : _zz_24__string = "EBREAK";
      default : _zz_24__string = "??????";
    endcase
  end
  always @(*) begin
    case(execute_BRANCH_CTRL)
      `BranchCtrlEnum_defaultEncoding_INC : execute_BRANCH_CTRL_string = "INC ";
      `BranchCtrlEnum_defaultEncoding_B : execute_BRANCH_CTRL_string = "B   ";
      `BranchCtrlEnum_defaultEncoding_JAL : execute_BRANCH_CTRL_string = "JAL ";
      `BranchCtrlEnum_defaultEncoding_JALR : execute_BRANCH_CTRL_string = "JALR";
      default : execute_BRANCH_CTRL_string = "????";
    endcase
  end
  always @(*) begin
    case(_zz_27_)
      `BranchCtrlEnum_defaultEncoding_INC : _zz_27__string = "INC ";
      `BranchCtrlEnum_defaultEncoding_B : _zz_27__string = "B   ";
      `BranchCtrlEnum_defaultEncoding_JAL : _zz_27__string = "JAL ";
      `BranchCtrlEnum_defaultEncoding_JALR : _zz_27__string = "JALR";
      default : _zz_27__string = "????";
    endcase
  end
  always @(*) begin
    case(execute_SHIFT_CTRL)
      `ShiftCtrlEnum_defaultEncoding_DISABLE_1 : execute_SHIFT_CTRL_string = "DISABLE_1";
      `ShiftCtrlEnum_defaultEncoding_SLL_1 : execute_SHIFT_CTRL_string = "SLL_1    ";
      `ShiftCtrlEnum_defaultEncoding_SRL_1 : execute_SHIFT_CTRL_string = "SRL_1    ";
      `ShiftCtrlEnum_defaultEncoding_SRA_1 : execute_SHIFT_CTRL_string = "SRA_1    ";
      default : execute_SHIFT_CTRL_string = "?????????";
    endcase
  end
  always @(*) begin
    case(_zz_30_)
      `ShiftCtrlEnum_defaultEncoding_DISABLE_1 : _zz_30__string = "DISABLE_1";
      `ShiftCtrlEnum_defaultEncoding_SLL_1 : _zz_30__string = "SLL_1    ";
      `ShiftCtrlEnum_defaultEncoding_SRL_1 : _zz_30__string = "SRL_1    ";
      `ShiftCtrlEnum_defaultEncoding_SRA_1 : _zz_30__string = "SRA_1    ";
      default : _zz_30__string = "?????????";
    endcase
  end
  always @(*) begin
    case(execute_SRC2_CTRL)
      `Src2CtrlEnum_defaultEncoding_RS : execute_SRC2_CTRL_string = "RS ";
      `Src2CtrlEnum_defaultEncoding_IMI : execute_SRC2_CTRL_string = "IMI";
      `Src2CtrlEnum_defaultEncoding_IMS : execute_SRC2_CTRL_string = "IMS";
      `Src2CtrlEnum_defaultEncoding_PC : execute_SRC2_CTRL_string = "PC ";
      default : execute_SRC2_CTRL_string = "???";
    endcase
  end
  always @(*) begin
    case(_zz_34_)
      `Src2CtrlEnum_defaultEncoding_RS : _zz_34__string = "RS ";
      `Src2CtrlEnum_defaultEncoding_IMI : _zz_34__string = "IMI";
      `Src2CtrlEnum_defaultEncoding_IMS : _zz_34__string = "IMS";
      `Src2CtrlEnum_defaultEncoding_PC : _zz_34__string = "PC ";
      default : _zz_34__string = "???";
    endcase
  end
  always @(*) begin
    case(execute_SRC1_CTRL)
      `Src1CtrlEnum_defaultEncoding_RS : execute_SRC1_CTRL_string = "RS          ";
      `Src1CtrlEnum_defaultEncoding_IMU : execute_SRC1_CTRL_string = "IMU         ";
      `Src1CtrlEnum_defaultEncoding_PC_INCREMENT : execute_SRC1_CTRL_string = "PC_INCREMENT";
      `Src1CtrlEnum_defaultEncoding_URS1 : execute_SRC1_CTRL_string = "URS1        ";
      default : execute_SRC1_CTRL_string = "????????????";
    endcase
  end
  always @(*) begin
    case(_zz_36_)
      `Src1CtrlEnum_defaultEncoding_RS : _zz_36__string = "RS          ";
      `Src1CtrlEnum_defaultEncoding_IMU : _zz_36__string = "IMU         ";
      `Src1CtrlEnum_defaultEncoding_PC_INCREMENT : _zz_36__string = "PC_INCREMENT";
      `Src1CtrlEnum_defaultEncoding_URS1 : _zz_36__string = "URS1        ";
      default : _zz_36__string = "????????????";
    endcase
  end
  always @(*) begin
    case(execute_ALU_CTRL)
      `AluCtrlEnum_defaultEncoding_ADD_SUB : execute_ALU_CTRL_string = "ADD_SUB ";
      `AluCtrlEnum_defaultEncoding_SLT_SLTU : execute_ALU_CTRL_string = "SLT_SLTU";
      `AluCtrlEnum_defaultEncoding_BITWISE : execute_ALU_CTRL_string = "BITWISE ";
      default : execute_ALU_CTRL_string = "????????";
    endcase
  end
  always @(*) begin
    case(_zz_38_)
      `AluCtrlEnum_defaultEncoding_ADD_SUB : _zz_38__string = "ADD_SUB ";
      `AluCtrlEnum_defaultEncoding_SLT_SLTU : _zz_38__string = "SLT_SLTU";
      `AluCtrlEnum_defaultEncoding_BITWISE : _zz_38__string = "BITWISE ";
      default : _zz_38__string = "????????";
    endcase
  end
  always @(*) begin
    case(execute_ALU_BITWISE_CTRL)
      `AluBitwiseCtrlEnum_defaultEncoding_XOR_1 : execute_ALU_BITWISE_CTRL_string = "XOR_1";
      `AluBitwiseCtrlEnum_defaultEncoding_OR_1 : execute_ALU_BITWISE_CTRL_string = "OR_1 ";
      `AluBitwiseCtrlEnum_defaultEncoding_AND_1 : execute_ALU_BITWISE_CTRL_string = "AND_1";
      `AluBitwiseCtrlEnum_defaultEncoding_SRC1 : execute_ALU_BITWISE_CTRL_string = "SRC1 ";
      default : execute_ALU_BITWISE_CTRL_string = "?????";
    endcase
  end
  always @(*) begin
    case(_zz_40_)
      `AluBitwiseCtrlEnum_defaultEncoding_XOR_1 : _zz_40__string = "XOR_1";
      `AluBitwiseCtrlEnum_defaultEncoding_OR_1 : _zz_40__string = "OR_1 ";
      `AluBitwiseCtrlEnum_defaultEncoding_AND_1 : _zz_40__string = "AND_1";
      `AluBitwiseCtrlEnum_defaultEncoding_SRC1 : _zz_40__string = "SRC1 ";
      default : _zz_40__string = "?????";
    endcase
  end
  always @(*) begin
    case(_zz_45_)
      `AluBitwiseCtrlEnum_defaultEncoding_XOR_1 : _zz_45__string = "XOR_1";
      `AluBitwiseCtrlEnum_defaultEncoding_OR_1 : _zz_45__string = "OR_1 ";
      `AluBitwiseCtrlEnum_defaultEncoding_AND_1 : _zz_45__string = "AND_1";
      `AluBitwiseCtrlEnum_defaultEncoding_SRC1 : _zz_45__string = "SRC1 ";
      default : _zz_45__string = "?????";
    endcase
  end
  always @(*) begin
    case(_zz_48_)
      `BranchCtrlEnum_defaultEncoding_INC : _zz_48__string = "INC ";
      `BranchCtrlEnum_defaultEncoding_B : _zz_48__string = "B   ";
      `BranchCtrlEnum_defaultEncoding_JAL : _zz_48__string = "JAL ";
      `BranchCtrlEnum_defaultEncoding_JALR : _zz_48__string = "JALR";
      default : _zz_48__string = "????";
    endcase
  end
  always @(*) begin
    case(_zz_49_)
      `Src1CtrlEnum_defaultEncoding_RS : _zz_49__string = "RS          ";
      `Src1CtrlEnum_defaultEncoding_IMU : _zz_49__string = "IMU         ";
      `Src1CtrlEnum_defaultEncoding_PC_INCREMENT : _zz_49__string = "PC_INCREMENT";
      `Src1CtrlEnum_defaultEncoding_URS1 : _zz_49__string = "URS1        ";
      default : _zz_49__string = "????????????";
    endcase
  end
  always @(*) begin
    case(_zz_50_)
      `EnvCtrlEnum_defaultEncoding_NONE : _zz_50__string = "NONE  ";
      `EnvCtrlEnum_defaultEncoding_XRET : _zz_50__string = "XRET  ";
      `EnvCtrlEnum_defaultEncoding_ECALL : _zz_50__string = "ECALL ";
      `EnvCtrlEnum_defaultEncoding_EBREAK : _zz_50__string = "EBREAK";
      default : _zz_50__string = "??????";
    endcase
  end
  always @(*) begin
    case(_zz_51_)
      `ShiftCtrlEnum_defaultEncoding_DISABLE_1 : _zz_51__string = "DISABLE_1";
      `ShiftCtrlEnum_defaultEncoding_SLL_1 : _zz_51__string = "SLL_1    ";
      `ShiftCtrlEnum_defaultEncoding_SRL_1 : _zz_51__string = "SRL_1    ";
      `ShiftCtrlEnum_defaultEncoding_SRA_1 : _zz_51__string = "SRA_1    ";
      default : _zz_51__string = "?????????";
    endcase
  end
  always @(*) begin
    case(_zz_52_)
      `Src2CtrlEnum_defaultEncoding_RS : _zz_52__string = "RS ";
      `Src2CtrlEnum_defaultEncoding_IMI : _zz_52__string = "IMI";
      `Src2CtrlEnum_defaultEncoding_IMS : _zz_52__string = "IMS";
      `Src2CtrlEnum_defaultEncoding_PC : _zz_52__string = "PC ";
      default : _zz_52__string = "???";
    endcase
  end
  always @(*) begin
    case(_zz_53_)
      `AluCtrlEnum_defaultEncoding_ADD_SUB : _zz_53__string = "ADD_SUB ";
      `AluCtrlEnum_defaultEncoding_SLT_SLTU : _zz_53__string = "SLT_SLTU";
      `AluCtrlEnum_defaultEncoding_BITWISE : _zz_53__string = "BITWISE ";
      default : _zz_53__string = "????????";
    endcase
  end
  always @(*) begin
    case(decode_BRANCH_CTRL)
      `BranchCtrlEnum_defaultEncoding_INC : decode_BRANCH_CTRL_string = "INC ";
      `BranchCtrlEnum_defaultEncoding_B : decode_BRANCH_CTRL_string = "B   ";
      `BranchCtrlEnum_defaultEncoding_JAL : decode_BRANCH_CTRL_string = "JAL ";
      `BranchCtrlEnum_defaultEncoding_JALR : decode_BRANCH_CTRL_string = "JALR";
      default : decode_BRANCH_CTRL_string = "????";
    endcase
  end
  always @(*) begin
    case(_zz_62_)
      `BranchCtrlEnum_defaultEncoding_INC : _zz_62__string = "INC ";
      `BranchCtrlEnum_defaultEncoding_B : _zz_62__string = "B   ";
      `BranchCtrlEnum_defaultEncoding_JAL : _zz_62__string = "JAL ";
      `BranchCtrlEnum_defaultEncoding_JALR : _zz_62__string = "JALR";
      default : _zz_62__string = "????";
    endcase
  end
  always @(*) begin
    case(_zz_121_)
      `AluCtrlEnum_defaultEncoding_ADD_SUB : _zz_121__string = "ADD_SUB ";
      `AluCtrlEnum_defaultEncoding_SLT_SLTU : _zz_121__string = "SLT_SLTU";
      `AluCtrlEnum_defaultEncoding_BITWISE : _zz_121__string = "BITWISE ";
      default : _zz_121__string = "????????";
    endcase
  end
  always @(*) begin
    case(_zz_122_)
      `Src2CtrlEnum_defaultEncoding_RS : _zz_122__string = "RS ";
      `Src2CtrlEnum_defaultEncoding_IMI : _zz_122__string = "IMI";
      `Src2CtrlEnum_defaultEncoding_IMS : _zz_122__string = "IMS";
      `Src2CtrlEnum_defaultEncoding_PC : _zz_122__string = "PC ";
      default : _zz_122__string = "???";
    endcase
  end
  always @(*) begin
    case(_zz_123_)
      `ShiftCtrlEnum_defaultEncoding_DISABLE_1 : _zz_123__string = "DISABLE_1";
      `ShiftCtrlEnum_defaultEncoding_SLL_1 : _zz_123__string = "SLL_1    ";
      `ShiftCtrlEnum_defaultEncoding_SRL_1 : _zz_123__string = "SRL_1    ";
      `ShiftCtrlEnum_defaultEncoding_SRA_1 : _zz_123__string = "SRA_1    ";
      default : _zz_123__string = "?????????";
    endcase
  end
  always @(*) begin
    case(_zz_124_)
      `EnvCtrlEnum_defaultEncoding_NONE : _zz_124__string = "NONE  ";
      `EnvCtrlEnum_defaultEncoding_XRET : _zz_124__string = "XRET  ";
      `EnvCtrlEnum_defaultEncoding_ECALL : _zz_124__string = "ECALL ";
      `EnvCtrlEnum_defaultEncoding_EBREAK : _zz_124__string = "EBREAK";
      default : _zz_124__string = "??????";
    endcase
  end
  always @(*) begin
    case(_zz_125_)
      `Src1CtrlEnum_defaultEncoding_RS : _zz_125__string = "RS          ";
      `Src1CtrlEnum_defaultEncoding_IMU : _zz_125__string = "IMU         ";
      `Src1CtrlEnum_defaultEncoding_PC_INCREMENT : _zz_125__string = "PC_INCREMENT";
      `Src1CtrlEnum_defaultEncoding_URS1 : _zz_125__string = "URS1        ";
      default : _zz_125__string = "????????????";
    endcase
  end
  always @(*) begin
    case(_zz_126_)
      `BranchCtrlEnum_defaultEncoding_INC : _zz_126__string = "INC ";
      `BranchCtrlEnum_defaultEncoding_B : _zz_126__string = "B   ";
      `BranchCtrlEnum_defaultEncoding_JAL : _zz_126__string = "JAL ";
      `BranchCtrlEnum_defaultEncoding_JALR : _zz_126__string = "JALR";
      default : _zz_126__string = "????";
    endcase
  end
  always @(*) begin
    case(_zz_127_)
      `AluBitwiseCtrlEnum_defaultEncoding_XOR_1 : _zz_127__string = "XOR_1";
      `AluBitwiseCtrlEnum_defaultEncoding_OR_1 : _zz_127__string = "OR_1 ";
      `AluBitwiseCtrlEnum_defaultEncoding_AND_1 : _zz_127__string = "AND_1";
      `AluBitwiseCtrlEnum_defaultEncoding_SRC1 : _zz_127__string = "SRC1 ";
      default : _zz_127__string = "?????";
    endcase
  end
  always @(*) begin
    case(decode_to_execute_SRC2_CTRL)
      `Src2CtrlEnum_defaultEncoding_RS : decode_to_execute_SRC2_CTRL_string = "RS ";
      `Src2CtrlEnum_defaultEncoding_IMI : decode_to_execute_SRC2_CTRL_string = "IMI";
      `Src2CtrlEnum_defaultEncoding_IMS : decode_to_execute_SRC2_CTRL_string = "IMS";
      `Src2CtrlEnum_defaultEncoding_PC : decode_to_execute_SRC2_CTRL_string = "PC ";
      default : decode_to_execute_SRC2_CTRL_string = "???";
    endcase
  end
  always @(*) begin
    case(decode_to_execute_SRC1_CTRL)
      `Src1CtrlEnum_defaultEncoding_RS : decode_to_execute_SRC1_CTRL_string = "RS          ";
      `Src1CtrlEnum_defaultEncoding_IMU : decode_to_execute_SRC1_CTRL_string = "IMU         ";
      `Src1CtrlEnum_defaultEncoding_PC_INCREMENT : decode_to_execute_SRC1_CTRL_string = "PC_INCREMENT";
      `Src1CtrlEnum_defaultEncoding_URS1 : decode_to_execute_SRC1_CTRL_string = "URS1        ";
      default : decode_to_execute_SRC1_CTRL_string = "????????????";
    endcase
  end
  always @(*) begin
    case(decode_to_execute_BRANCH_CTRL)
      `BranchCtrlEnum_defaultEncoding_INC : decode_to_execute_BRANCH_CTRL_string = "INC ";
      `BranchCtrlEnum_defaultEncoding_B : decode_to_execute_BRANCH_CTRL_string = "B   ";
      `BranchCtrlEnum_defaultEncoding_JAL : decode_to_execute_BRANCH_CTRL_string = "JAL ";
      `BranchCtrlEnum_defaultEncoding_JALR : decode_to_execute_BRANCH_CTRL_string = "JALR";
      default : decode_to_execute_BRANCH_CTRL_string = "????";
    endcase
  end
  always @(*) begin
    case(decode_to_execute_SHIFT_CTRL)
      `ShiftCtrlEnum_defaultEncoding_DISABLE_1 : decode_to_execute_SHIFT_CTRL_string = "DISABLE_1";
      `ShiftCtrlEnum_defaultEncoding_SLL_1 : decode_to_execute_SHIFT_CTRL_string = "SLL_1    ";
      `ShiftCtrlEnum_defaultEncoding_SRL_1 : decode_to_execute_SHIFT_CTRL_string = "SRL_1    ";
      `ShiftCtrlEnum_defaultEncoding_SRA_1 : decode_to_execute_SHIFT_CTRL_string = "SRA_1    ";
      default : decode_to_execute_SHIFT_CTRL_string = "?????????";
    endcase
  end
  always @(*) begin
    case(decode_to_execute_ALU_CTRL)
      `AluCtrlEnum_defaultEncoding_ADD_SUB : decode_to_execute_ALU_CTRL_string = "ADD_SUB ";
      `AluCtrlEnum_defaultEncoding_SLT_SLTU : decode_to_execute_ALU_CTRL_string = "SLT_SLTU";
      `AluCtrlEnum_defaultEncoding_BITWISE : decode_to_execute_ALU_CTRL_string = "BITWISE ";
      default : decode_to_execute_ALU_CTRL_string = "????????";
    endcase
  end
  always @(*) begin
    case(decode_to_execute_ALU_BITWISE_CTRL)
      `AluBitwiseCtrlEnum_defaultEncoding_XOR_1 : decode_to_execute_ALU_BITWISE_CTRL_string = "XOR_1";
      `AluBitwiseCtrlEnum_defaultEncoding_OR_1 : decode_to_execute_ALU_BITWISE_CTRL_string = "OR_1 ";
      `AluBitwiseCtrlEnum_defaultEncoding_AND_1 : decode_to_execute_ALU_BITWISE_CTRL_string = "AND_1";
      `AluBitwiseCtrlEnum_defaultEncoding_SRC1 : decode_to_execute_ALU_BITWISE_CTRL_string = "SRC1 ";
      default : decode_to_execute_ALU_BITWISE_CTRL_string = "?????";
    endcase
  end
  always @(*) begin
    case(decode_to_execute_ENV_CTRL)
      `EnvCtrlEnum_defaultEncoding_NONE : decode_to_execute_ENV_CTRL_string = "NONE  ";
      `EnvCtrlEnum_defaultEncoding_XRET : decode_to_execute_ENV_CTRL_string = "XRET  ";
      `EnvCtrlEnum_defaultEncoding_ECALL : decode_to_execute_ENV_CTRL_string = "ECALL ";
      `EnvCtrlEnum_defaultEncoding_EBREAK : decode_to_execute_ENV_CTRL_string = "EBREAK";
      default : decode_to_execute_ENV_CTRL_string = "??????";
    endcase
  end
  `endif

  assign execute_FORMAL_PC_NEXT = decode_to_execute_FORMAL_PC_NEXT;
  assign decode_FORMAL_PC_NEXT = _zz_64_;
  assign decode_SRC_LESS_UNSIGNED = _zz_54_;
  assign decode_ENV_CTRL = _zz_1_;
  assign _zz_2_ = _zz_3_;
  assign decode_ALU_BITWISE_CTRL = _zz_4_;
  assign _zz_5_ = _zz_6_;
  assign decode_PREDICTION_HAD_BRANCHED2 = _zz_29_;
  assign decode_CSR_WRITE_OPCODE = _zz_23_;
  assign execute_REGFILE_WRITE_VALID = decode_to_execute_REGFILE_WRITE_VALID;
  assign decode_DO_EBREAK = _zz_21_;
  assign decode_IS_CSR = _zz_44_;
  assign decode_MEMORY_ENABLE = _zz_55_;
  assign decode_FLUSH_ALL = _zz_57_;
  assign decode_ALU_CTRL = _zz_7_;
  assign _zz_8_ = _zz_9_;
  assign decode_CSR_READ_OPCODE = _zz_22_;
  assign decode_SHIFT_CTRL = _zz_10_;
  assign _zz_11_ = _zz_12_;
  assign _zz_13_ = _zz_14_;
  assign decode_SRC1_CTRL = _zz_15_;
  assign _zz_16_ = _zz_17_;
  assign decode_SRC2_CTRL = _zz_18_;
  assign _zz_19_ = _zz_20_;
  assign decode_SRC_USE_SUB_LESS = _zz_47_;
  assign execute_DO_EBREAK = decode_to_execute_DO_EBREAK;
  assign decode_IS_EBREAK = _zz_56_;
  assign execute_CSR_READ_OPCODE = decode_to_execute_CSR_READ_OPCODE;
  assign execute_CSR_WRITE_OPCODE = decode_to_execute_CSR_WRITE_OPCODE;
  assign execute_IS_CSR = decode_to_execute_IS_CSR;
  assign execute_ENV_CTRL = _zz_24_;
  assign execute_BRANCH_CALC = _zz_25_;
  assign execute_BRANCH_DO = _zz_26_;
  assign execute_PC = decode_to_execute_PC;
  assign execute_PREDICTION_HAD_BRANCHED2 = decode_to_execute_PREDICTION_HAD_BRANCHED2;
  assign execute_RS1 = _zz_43_;
  assign execute_BRANCH_COND_RESULT = _zz_28_;
  assign execute_BRANCH_CTRL = _zz_27_;
  assign execute_SHIFT_CTRL = _zz_30_;
  assign execute_SRC_LESS_UNSIGNED = decode_to_execute_SRC_LESS_UNSIGNED;
  assign execute_SRC_USE_SUB_LESS = decode_to_execute_SRC_USE_SUB_LESS;
  assign execute_SRC2_CTRL = _zz_34_;
  assign execute_SRC1_CTRL = _zz_36_;
  assign execute_SRC_ADD_SUB = _zz_33_;
  assign execute_SRC_LESS = _zz_31_;
  assign execute_ALU_CTRL = _zz_38_;
  assign execute_SRC2 = _zz_35_;
  assign execute_SRC1 = _zz_37_;
  assign execute_ALU_BITWISE_CTRL = _zz_40_;
  always @ (*) begin
    _zz_41_ = 1'b0;
    if(execute_RegFilePlugin_regFileWrite_valid)begin
      _zz_41_ = 1'b1;
    end
  end

  always @ (*) begin
    decode_REGFILE_WRITE_VALID = _zz_46_;
    if((decode_INSTRUCTION[11 : 7] == (5'b00000)))begin
      decode_REGFILE_WRITE_VALID = 1'b0;
    end
  end

  always @ (*) begin
    _zz_58_ = execute_REGFILE_WRITE_DATA;
    execute_arbitration_haltItself = 1'b0;
    _zz_169_ = 1'b0;
    if((execute_arbitration_isValid && execute_FLUSH_ALL))begin
      _zz_169_ = 1'b1;
      if((! IBusCachedPlugin_cache_io_flush_cmd_ready))begin
        execute_arbitration_haltItself = 1'b1;
      end
    end
    if(((((execute_arbitration_isValid && execute_MEMORY_ENABLE) && (! dBus_cmd_ready)) && (! execute_ALIGNEMENT_FAULT)) && (! execute_DBusSimplePlugin_cmdSent)))begin
      execute_arbitration_haltItself = 1'b1;
    end
    if((((execute_arbitration_isValid && execute_MEMORY_ENABLE) && (! execute_INSTRUCTION[5])) && (! dBus_rsp_ready)))begin
      execute_arbitration_haltItself = 1'b1;
    end
    if((execute_arbitration_isValid && execute_MEMORY_ENABLE))begin
      _zz_58_ = execute_DBusSimplePlugin_rspFormated;
    end
    if(_zz_190_)begin
      _zz_58_ = _zz_136_;
      if(_zz_191_)begin
        if(! execute_LightShifterPlugin_done) begin
          execute_arbitration_haltItself = 1'b1;
        end
      end
    end
    if((execute_arbitration_isValid && execute_IS_CSR))begin
      _zz_58_ = execute_CsrPlugin_readData;
      if(execute_CsrPlugin_blockedBySideEffects)begin
        execute_arbitration_haltItself = 1'b1;
      end
    end
  end

  assign execute_MEMORY_ADDRESS_LOW = _zz_60_;
  assign execute_MEMORY_READ_DATA = _zz_59_;
  assign execute_REGFILE_WRITE_DATA = _zz_39_;
  assign execute_RS2 = _zz_42_;
  assign execute_SRC_ADD = _zz_32_;
  assign execute_INSTRUCTION = decode_to_execute_INSTRUCTION;
  assign execute_ALIGNEMENT_FAULT = _zz_61_;
  assign execute_MEMORY_ENABLE = decode_to_execute_MEMORY_ENABLE;
  assign execute_FLUSH_ALL = decode_to_execute_FLUSH_ALL;
  always @ (*) begin
    IBusCachedPlugin_rsp_issueDetected = 1'b0;
    IBusCachedPlugin_rsp_redoFetch = 1'b0;
    if(((_zz_182_ && IBusCachedPlugin_cache_io_cpu_decode_cacheMiss) && (! 1'b0)))begin
      IBusCachedPlugin_rsp_issueDetected = 1'b1;
      IBusCachedPlugin_rsp_redoFetch = IBusCachedPlugin_iBusRsp_readyForError;
    end
  end

  assign decode_BRANCH_CTRL = _zz_62_;
  always @ (*) begin
    _zz_63_ = decode_FORMAL_PC_NEXT;
    if(_zz_70_)begin
      _zz_63_ = _zz_71_;
    end
    if(_zz_73_)begin
      _zz_63_ = _zz_74_;
    end
  end

  assign decode_PC = _zz_66_;
  always @ (*) begin
    decode_INSTRUCTION = _zz_65_;
    if((_zz_164_ != (3'b000)))begin
      decode_INSTRUCTION = _zz_165_;
    end
  end

  always @ (*) begin
    decode_arbitration_haltItself = 1'b0;
    decode_arbitration_isValid = (IBusCachedPlugin_iBusRsp_decodeInput_valid && (! IBusCachedPlugin_injector_decodeRemoved));
    _zz_86_ = 1'b0;
    case(_zz_164_)
      3'b000 : begin
      end
      3'b001 : begin
      end
      3'b010 : begin
        decode_arbitration_isValid = 1'b1;
        decode_arbitration_haltItself = 1'b1;
      end
      3'b011 : begin
        decode_arbitration_isValid = 1'b1;
      end
      3'b100 : begin
        _zz_86_ = 1'b1;
      end
      default : begin
      end
    endcase
  end

  always @ (*) begin
    decode_arbitration_haltByOther = 1'b0;
    if((CsrPlugin_interrupt && decode_arbitration_isValid))begin
      decode_arbitration_haltByOther = 1'b1;
    end
    if(1'b0)begin
      decode_arbitration_haltByOther = 1'b1;
    end
  end

  always @ (*) begin
    decode_arbitration_removeIt = 1'b0;
    if(decode_arbitration_isFlushed)begin
      decode_arbitration_removeIt = 1'b1;
    end
  end

  always @ (*) begin
    decode_arbitration_flushAll = 1'b0;
    execute_arbitration_removeIt = 1'b0;
    _zz_79_ = 1'b0;
    _zz_80_ = (32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx);
    if(_zz_77_)begin
      decode_arbitration_flushAll = 1'b1;
    end
    CsrPlugin_exceptionPortCtrl_exceptionValids_execute = CsrPlugin_exceptionPortCtrl_exceptionValidsRegs_execute;
    if(execute_exception_agregat_valid)begin
      decode_arbitration_flushAll = 1'b1;
      execute_arbitration_removeIt = 1'b1;
      CsrPlugin_exceptionPortCtrl_exceptionValids_execute = 1'b1;
    end
    if(_zz_192_)begin
      _zz_79_ = 1'b1;
      _zz_80_ = {CsrPlugin_mtvec_base,(2'b00)};
      decode_arbitration_flushAll = 1'b1;
    end
    if(_zz_193_)begin
      _zz_80_ = CsrPlugin_mepc;
      _zz_79_ = 1'b1;
      decode_arbitration_flushAll = 1'b1;
    end
    if(execute_arbitration_isFlushed)begin
      execute_arbitration_removeIt = 1'b1;
    end
  end

  assign decode_arbitration_redoIt = 1'b0;
  always @ (*) begin
    execute_arbitration_haltByOther = 1'b0;
    _zz_67_ = 1'b0;
    _zz_68_ = 1'b0;
    if(({CsrPlugin_exceptionPortCtrl_exceptionValidsRegs_execute,CsrPlugin_exceptionPortCtrl_exceptionValidsRegs_decode} != (2'b00)))begin
      _zz_67_ = 1'b1;
    end
    if(_zz_194_)begin
      execute_arbitration_haltByOther = 1'b1;
      if(_zz_195_)begin
        _zz_68_ = 1'b1;
        _zz_67_ = 1'b1;
      end
    end
    if(DebugPlugin_haltIt)begin
      _zz_67_ = 1'b1;
    end
    if(_zz_196_)begin
      _zz_67_ = 1'b1;
    end
  end

  always @ (*) begin
    execute_arbitration_flushAll = 1'b0;
    if(_zz_194_)begin
      if(_zz_195_)begin
        execute_arbitration_flushAll = 1'b1;
      end
    end
  end

  assign execute_arbitration_redoIt = 1'b0;
  always @ (*) begin
    _zz_69_ = 1'b0;
    if((IBusCachedPlugin_iBusRsp_stages_1_input_valid || IBusCachedPlugin_iBusRsp_cacheRspArbitration_input_valid))begin
      _zz_69_ = 1'b1;
    end
  end

  always @ (*) begin
    _zz_83_ = 1'b1;
    if((DebugPlugin_haltIt || DebugPlugin_stepIt))begin
      _zz_83_ = 1'b0;
    end
  end

  always @ (*) begin
    _zz_84_ = 1'b1;
    if(DebugPlugin_haltIt)begin
      _zz_84_ = 1'b0;
    end
  end

  assign IBusCachedPlugin_jump_pcLoad_valid = ({_zz_79_,{_zz_77_,{_zz_73_,_zz_70_}}} != (4'b0000));
  assign _zz_87_ = {_zz_70_,{_zz_73_,{_zz_79_,_zz_77_}}};
  assign _zz_88_ = (_zz_87_ & (~ _zz_204_));
  assign _zz_89_ = _zz_88_[3];
  assign _zz_90_ = (_zz_88_[1] || _zz_89_);
  assign _zz_91_ = (_zz_88_[2] || _zz_89_);
  assign IBusCachedPlugin_jump_pcLoad_payload = _zz_187_;
  assign _zz_92_ = (! _zz_67_);
  assign IBusCachedPlugin_fetchPc_output_valid = (IBusCachedPlugin_fetchPc_preOutput_valid && _zz_92_);
  assign IBusCachedPlugin_fetchPc_preOutput_ready = (IBusCachedPlugin_fetchPc_output_ready && _zz_92_);
  assign IBusCachedPlugin_fetchPc_output_payload = IBusCachedPlugin_fetchPc_preOutput_payload;
  always @ (*) begin
    IBusCachedPlugin_fetchPc_propagatePc = 1'b0;
    if((IBusCachedPlugin_iBusRsp_stages_1_input_valid && IBusCachedPlugin_iBusRsp_stages_1_input_ready))begin
      IBusCachedPlugin_fetchPc_propagatePc = 1'b1;
    end
  end

  always @ (*) begin
    IBusCachedPlugin_fetchPc_pc = (IBusCachedPlugin_fetchPc_pcReg + _zz_206_);
    IBusCachedPlugin_fetchPc_samplePcNext = 1'b0;
    if(IBusCachedPlugin_fetchPc_propagatePc)begin
      IBusCachedPlugin_fetchPc_samplePcNext = 1'b1;
    end
    if(IBusCachedPlugin_jump_pcLoad_valid)begin
      IBusCachedPlugin_fetchPc_samplePcNext = 1'b1;
      IBusCachedPlugin_fetchPc_pc = IBusCachedPlugin_jump_pcLoad_payload;
    end
    if(_zz_197_)begin
      IBusCachedPlugin_fetchPc_samplePcNext = 1'b1;
    end
    IBusCachedPlugin_fetchPc_pc[0] = 1'b0;
    IBusCachedPlugin_fetchPc_pc[1] = 1'b0;
  end

  assign IBusCachedPlugin_fetchPc_preOutput_valid = _zz_93_;
  assign IBusCachedPlugin_fetchPc_preOutput_payload = IBusCachedPlugin_fetchPc_pc;
  assign IBusCachedPlugin_iBusRsp_stages_0_input_valid = IBusCachedPlugin_fetchPc_output_valid;
  assign IBusCachedPlugin_fetchPc_output_ready = IBusCachedPlugin_iBusRsp_stages_0_input_ready;
  assign IBusCachedPlugin_iBusRsp_stages_0_input_payload = IBusCachedPlugin_fetchPc_output_payload;
  assign IBusCachedPlugin_iBusRsp_stages_0_inputSample = 1'b1;
  always @ (*) begin
    IBusCachedPlugin_iBusRsp_stages_0_halt = 1'b0;
    if(IBusCachedPlugin_cache_io_cpu_prefetch_haltIt)begin
      IBusCachedPlugin_iBusRsp_stages_0_halt = 1'b1;
    end
  end

  assign _zz_94_ = (! IBusCachedPlugin_iBusRsp_stages_0_halt);
  assign IBusCachedPlugin_iBusRsp_stages_0_input_ready = (IBusCachedPlugin_iBusRsp_stages_0_output_ready && _zz_94_);
  assign IBusCachedPlugin_iBusRsp_stages_0_output_valid = (IBusCachedPlugin_iBusRsp_stages_0_input_valid && _zz_94_);
  assign IBusCachedPlugin_iBusRsp_stages_0_output_payload = IBusCachedPlugin_iBusRsp_stages_0_input_payload;
  always @ (*) begin
    IBusCachedPlugin_iBusRsp_stages_1_halt = 1'b0;
    if(((IBusCachedPlugin_cache_io_cpu_fetch_mmuBus_cmd_isValid && (! 1'b1)) && (! 1'b0)))begin
      IBusCachedPlugin_iBusRsp_stages_1_halt = 1'b1;
    end
  end

  assign _zz_95_ = (! IBusCachedPlugin_iBusRsp_stages_1_halt);
  assign IBusCachedPlugin_iBusRsp_stages_1_input_ready = (IBusCachedPlugin_iBusRsp_stages_1_output_ready && _zz_95_);
  assign IBusCachedPlugin_iBusRsp_stages_1_output_valid = (IBusCachedPlugin_iBusRsp_stages_1_input_valid && _zz_95_);
  assign IBusCachedPlugin_iBusRsp_stages_1_output_payload = IBusCachedPlugin_iBusRsp_stages_1_input_payload;
  always @ (*) begin
    IBusCachedPlugin_iBusRsp_cacheRspArbitration_halt = 1'b0;
    if((IBusCachedPlugin_rsp_issueDetected || IBusCachedPlugin_rsp_iBusRspOutputHalt))begin
      IBusCachedPlugin_iBusRsp_cacheRspArbitration_halt = 1'b1;
    end
  end

  assign _zz_96_ = (! IBusCachedPlugin_iBusRsp_cacheRspArbitration_halt);
  assign IBusCachedPlugin_iBusRsp_cacheRspArbitration_input_ready = (IBusCachedPlugin_iBusRsp_cacheRspArbitration_output_ready && _zz_96_);
  assign IBusCachedPlugin_iBusRsp_cacheRspArbitration_output_valid = (IBusCachedPlugin_iBusRsp_cacheRspArbitration_input_valid && _zz_96_);
  assign IBusCachedPlugin_iBusRsp_cacheRspArbitration_output_payload = IBusCachedPlugin_iBusRsp_cacheRspArbitration_input_payload;
  assign IBusCachedPlugin_iBusRsp_stages_0_output_ready = _zz_97_;
  assign _zz_97_ = ((1'b0 && (! _zz_98_)) || IBusCachedPlugin_iBusRsp_stages_1_input_ready);
  assign _zz_98_ = _zz_99_;
  assign IBusCachedPlugin_iBusRsp_stages_1_input_valid = _zz_98_;
  assign IBusCachedPlugin_iBusRsp_stages_1_input_payload = IBusCachedPlugin_fetchPc_pcReg;
  assign IBusCachedPlugin_iBusRsp_stages_1_output_ready = ((1'b0 && (! _zz_100_)) || IBusCachedPlugin_iBusRsp_cacheRspArbitration_input_ready);
  assign _zz_100_ = _zz_101_;
  assign IBusCachedPlugin_iBusRsp_cacheRspArbitration_input_valid = _zz_100_;
  assign IBusCachedPlugin_iBusRsp_cacheRspArbitration_input_payload = _zz_102_;
  assign IBusCachedPlugin_iBusRsp_readyForError = 1'b1;
  assign IBusCachedPlugin_iBusRsp_decodeInput_ready = (! decode_arbitration_isStuck);
  assign _zz_66_ = IBusCachedPlugin_iBusRsp_decodeInput_payload_pc;
  assign _zz_65_ = IBusCachedPlugin_iBusRsp_decodeInput_payload_rsp_inst;
  assign _zz_64_ = (decode_PC + (32'b00000000000000000000000000000100));
  assign _zz_103_ = _zz_207_[11];
  always @ (*) begin
    _zz_104_[18] = _zz_103_;
    _zz_104_[17] = _zz_103_;
    _zz_104_[16] = _zz_103_;
    _zz_104_[15] = _zz_103_;
    _zz_104_[14] = _zz_103_;
    _zz_104_[13] = _zz_103_;
    _zz_104_[12] = _zz_103_;
    _zz_104_[11] = _zz_103_;
    _zz_104_[10] = _zz_103_;
    _zz_104_[9] = _zz_103_;
    _zz_104_[8] = _zz_103_;
    _zz_104_[7] = _zz_103_;
    _zz_104_[6] = _zz_103_;
    _zz_104_[5] = _zz_103_;
    _zz_104_[4] = _zz_103_;
    _zz_104_[3] = _zz_103_;
    _zz_104_[2] = _zz_103_;
    _zz_104_[1] = _zz_103_;
    _zz_104_[0] = _zz_103_;
  end

  assign _zz_72_ = ((decode_BRANCH_CTRL == `BranchCtrlEnum_defaultEncoding_JAL) || ((decode_BRANCH_CTRL == `BranchCtrlEnum_defaultEncoding_B) && _zz_208_[31]));
  assign _zz_70_ = (_zz_72_ && decode_arbitration_isFiring);
  assign _zz_105_ = _zz_209_[19];
  always @ (*) begin
    _zz_106_[10] = _zz_105_;
    _zz_106_[9] = _zz_105_;
    _zz_106_[8] = _zz_105_;
    _zz_106_[7] = _zz_105_;
    _zz_106_[6] = _zz_105_;
    _zz_106_[5] = _zz_105_;
    _zz_106_[4] = _zz_105_;
    _zz_106_[3] = _zz_105_;
    _zz_106_[2] = _zz_105_;
    _zz_106_[1] = _zz_105_;
    _zz_106_[0] = _zz_105_;
  end

  assign _zz_107_ = _zz_210_[11];
  always @ (*) begin
    _zz_108_[18] = _zz_107_;
    _zz_108_[17] = _zz_107_;
    _zz_108_[16] = _zz_107_;
    _zz_108_[15] = _zz_107_;
    _zz_108_[14] = _zz_107_;
    _zz_108_[13] = _zz_107_;
    _zz_108_[12] = _zz_107_;
    _zz_108_[11] = _zz_107_;
    _zz_108_[10] = _zz_107_;
    _zz_108_[9] = _zz_107_;
    _zz_108_[8] = _zz_107_;
    _zz_108_[7] = _zz_107_;
    _zz_108_[6] = _zz_107_;
    _zz_108_[5] = _zz_107_;
    _zz_108_[4] = _zz_107_;
    _zz_108_[3] = _zz_107_;
    _zz_108_[2] = _zz_107_;
    _zz_108_[1] = _zz_107_;
    _zz_108_[0] = _zz_107_;
  end

  assign _zz_71_ = (decode_PC + ((decode_BRANCH_CTRL == `BranchCtrlEnum_defaultEncoding_JAL) ? {{_zz_106_,{{{_zz_263_,_zz_264_},_zz_265_},decode_INSTRUCTION[30 : 21]}},1'b0} : {{_zz_108_,{{{_zz_266_,_zz_267_},decode_INSTRUCTION[30 : 25]},decode_INSTRUCTION[11 : 8]}},1'b0}));
  assign iBus_cmd_valid = IBusCachedPlugin_cache_io_mem_cmd_valid;
  always @ (*) begin
    iBus_cmd_payload_address = IBusCachedPlugin_cache_io_mem_cmd_payload_address;
    iBus_cmd_payload_address = IBusCachedPlugin_cache_io_mem_cmd_payload_address;
  end

  assign iBus_cmd_payload_size = IBusCachedPlugin_cache_io_mem_cmd_payload_size;
  assign IBusCachedPlugin_s0_tightlyCoupledHit = 1'b0;
  assign _zz_170_ = (IBusCachedPlugin_iBusRsp_stages_0_input_valid && (! IBusCachedPlugin_s0_tightlyCoupledHit));
  assign _zz_173_ = (IBusCachedPlugin_jump_pcLoad_valid || _zz_68_);
  assign _zz_174_ = (32'b00000000000000000000000000000000);
  assign _zz_171_ = (IBusCachedPlugin_iBusRsp_stages_1_input_valid && (! IBusCachedPlugin_s1_tightlyCoupledHit));
  assign _zz_172_ = (! IBusCachedPlugin_iBusRsp_stages_1_input_ready);
  assign _zz_182_ = (IBusCachedPlugin_iBusRsp_cacheRspArbitration_input_valid && (! IBusCachedPlugin_s2_tightlyCoupledHit));
  assign _zz_183_ = (! IBusCachedPlugin_iBusRsp_cacheRspArbitration_input_ready);
  assign _zz_184_ = (CsrPlugin_privilege == (2'b00));
  assign IBusCachedPlugin_rsp_iBusRspOutputHalt = 1'b0;
  assign _zz_73_ = IBusCachedPlugin_rsp_redoFetch;
  assign _zz_74_ = IBusCachedPlugin_iBusRsp_cacheRspArbitration_input_payload;
  assign IBusCachedPlugin_iBusRsp_decodeInput_valid = IBusCachedPlugin_iBusRsp_cacheRspArbitration_output_valid;
  assign IBusCachedPlugin_iBusRsp_cacheRspArbitration_output_ready = IBusCachedPlugin_iBusRsp_decodeInput_ready;
  assign IBusCachedPlugin_iBusRsp_decodeInput_payload_rsp_inst = IBusCachedPlugin_cache_io_cpu_decode_data;
  assign IBusCachedPlugin_iBusRsp_decodeInput_payload_pc = IBusCachedPlugin_iBusRsp_cacheRspArbitration_output_payload;
  assign _zz_175_ = _zz_75_[31];
  assign _zz_176_ = 1'b1;
  assign _zz_177_ = 1'b1;
  assign _zz_178_ = 1'b1;
  assign _zz_179_ = 1'b1;
  assign _zz_180_ = 1'b0;
  assign _zz_181_ = 1'b1;
  assign _zz_61_ = (((dBus_cmd_payload_size == (2'b10)) && (dBus_cmd_payload_address[1 : 0] != (2'b00))) || ((dBus_cmd_payload_size == (2'b01)) && (dBus_cmd_payload_address[0 : 0] != (1'b0))));
  assign dBus_cmd_valid = (((((execute_arbitration_isValid && execute_MEMORY_ENABLE) && (! execute_arbitration_isStuckByOthers)) && (! execute_arbitration_isFlushed)) && (! execute_ALIGNEMENT_FAULT)) && (! execute_DBusSimplePlugin_cmdSent));
  assign dBus_cmd_payload_wr = execute_INSTRUCTION[5];
  assign dBus_cmd_payload_address = execute_SRC_ADD;
  assign dBus_cmd_payload_size = execute_INSTRUCTION[13 : 12];
  always @ (*) begin
    case(dBus_cmd_payload_size)
      2'b00 : begin
        _zz_109_ = {{{execute_RS2[7 : 0],execute_RS2[7 : 0]},execute_RS2[7 : 0]},execute_RS2[7 : 0]};
      end
      2'b01 : begin
        _zz_109_ = {execute_RS2[15 : 0],execute_RS2[15 : 0]};
      end
      default : begin
        _zz_109_ = execute_RS2[31 : 0];
      end
    endcase
  end

  assign dBus_cmd_payload_data = _zz_109_;
  assign _zz_60_ = dBus_cmd_payload_address[1 : 0];
  always @ (*) begin
    case(dBus_cmd_payload_size)
      2'b00 : begin
        _zz_110_ = (4'b0001);
      end
      2'b01 : begin
        _zz_110_ = (4'b0011);
      end
      default : begin
        _zz_110_ = (4'b1111);
      end
    endcase
  end

  assign execute_DBusSimplePlugin_formalMask = (_zz_110_ <<< dBus_cmd_payload_address[1 : 0]);
  assign _zz_59_ = dBus_rsp_data;
  always @ (*) begin
    _zz_76_ = execute_ALIGNEMENT_FAULT;
    if((! ((execute_arbitration_isValid && execute_MEMORY_ENABLE) && (! execute_arbitration_isStuckByOthers))))begin
      _zz_76_ = 1'b0;
    end
  end

  always @ (*) begin
    execute_DBusSimplePlugin_rspShifted = execute_MEMORY_READ_DATA;
    case(execute_MEMORY_ADDRESS_LOW)
      2'b01 : begin
        execute_DBusSimplePlugin_rspShifted[7 : 0] = execute_MEMORY_READ_DATA[15 : 8];
      end
      2'b10 : begin
        execute_DBusSimplePlugin_rspShifted[15 : 0] = execute_MEMORY_READ_DATA[31 : 16];
      end
      2'b11 : begin
        execute_DBusSimplePlugin_rspShifted[7 : 0] = execute_MEMORY_READ_DATA[31 : 24];
      end
      default : begin
      end
    endcase
  end

  assign _zz_111_ = (execute_DBusSimplePlugin_rspShifted[7] && (! execute_INSTRUCTION[14]));
  always @ (*) begin
    _zz_112_[31] = _zz_111_;
    _zz_112_[30] = _zz_111_;
    _zz_112_[29] = _zz_111_;
    _zz_112_[28] = _zz_111_;
    _zz_112_[27] = _zz_111_;
    _zz_112_[26] = _zz_111_;
    _zz_112_[25] = _zz_111_;
    _zz_112_[24] = _zz_111_;
    _zz_112_[23] = _zz_111_;
    _zz_112_[22] = _zz_111_;
    _zz_112_[21] = _zz_111_;
    _zz_112_[20] = _zz_111_;
    _zz_112_[19] = _zz_111_;
    _zz_112_[18] = _zz_111_;
    _zz_112_[17] = _zz_111_;
    _zz_112_[16] = _zz_111_;
    _zz_112_[15] = _zz_111_;
    _zz_112_[14] = _zz_111_;
    _zz_112_[13] = _zz_111_;
    _zz_112_[12] = _zz_111_;
    _zz_112_[11] = _zz_111_;
    _zz_112_[10] = _zz_111_;
    _zz_112_[9] = _zz_111_;
    _zz_112_[8] = _zz_111_;
    _zz_112_[7 : 0] = execute_DBusSimplePlugin_rspShifted[7 : 0];
  end

  assign _zz_113_ = (execute_DBusSimplePlugin_rspShifted[15] && (! execute_INSTRUCTION[14]));
  always @ (*) begin
    _zz_114_[31] = _zz_113_;
    _zz_114_[30] = _zz_113_;
    _zz_114_[29] = _zz_113_;
    _zz_114_[28] = _zz_113_;
    _zz_114_[27] = _zz_113_;
    _zz_114_[26] = _zz_113_;
    _zz_114_[25] = _zz_113_;
    _zz_114_[24] = _zz_113_;
    _zz_114_[23] = _zz_113_;
    _zz_114_[22] = _zz_113_;
    _zz_114_[21] = _zz_113_;
    _zz_114_[20] = _zz_113_;
    _zz_114_[19] = _zz_113_;
    _zz_114_[18] = _zz_113_;
    _zz_114_[17] = _zz_113_;
    _zz_114_[16] = _zz_113_;
    _zz_114_[15 : 0] = execute_DBusSimplePlugin_rspShifted[15 : 0];
  end

  always @ (*) begin
    case(_zz_201_)
      2'b00 : begin
        execute_DBusSimplePlugin_rspFormated = _zz_112_;
      end
      2'b01 : begin
        execute_DBusSimplePlugin_rspFormated = _zz_114_;
      end
      default : begin
        execute_DBusSimplePlugin_rspFormated = execute_DBusSimplePlugin_rspShifted;
      end
    endcase
  end

  assign _zz_75_ = IBusCachedPlugin_cache_io_cpu_fetch_mmuBus_cmd_virtualAddress;
  assign _zz_116_ = ((decode_INSTRUCTION & (32'b00010000000100000011000001010000)) == (32'b00000000000100000000000001010000));
  assign _zz_117_ = ((decode_INSTRUCTION & (32'b00000000000000000000000000000100)) == (32'b00000000000000000000000000000100));
  assign _zz_118_ = ((decode_INSTRUCTION & (32'b00000000000000000100000001010000)) == (32'b00000000000000000100000001010000));
  assign _zz_119_ = ((decode_INSTRUCTION & (32'b00000000000000000000000001001000)) == (32'b00000000000000000000000001001000));
  assign _zz_120_ = ((decode_INSTRUCTION & (32'b00000000000000000000000001010000)) == (32'b00000000000000000000000000010000));
  assign _zz_115_ = {({(_zz_268_ == _zz_269_),(_zz_270_ == _zz_271_)} != (2'b00)),{(_zz_120_ != (1'b0)),{({_zz_272_,_zz_273_} != (2'b00)),{(_zz_274_ != _zz_275_),{_zz_276_,{_zz_277_,_zz_278_}}}}}};
  assign _zz_57_ = _zz_211_[0];
  assign _zz_56_ = _zz_212_[0];
  assign _zz_55_ = _zz_213_[0];
  assign _zz_54_ = _zz_214_[0];
  assign _zz_121_ = _zz_115_[5 : 4];
  assign _zz_53_ = _zz_121_;
  assign _zz_122_ = _zz_115_[7 : 6];
  assign _zz_52_ = _zz_122_;
  assign _zz_123_ = _zz_115_[11 : 10];
  assign _zz_51_ = _zz_123_;
  assign _zz_124_ = _zz_115_[14 : 13];
  assign _zz_50_ = _zz_124_;
  assign _zz_125_ = _zz_115_[16 : 15];
  assign _zz_49_ = _zz_125_;
  assign _zz_126_ = _zz_115_[18 : 17];
  assign _zz_48_ = _zz_126_;
  assign _zz_47_ = _zz_215_[0];
  assign _zz_46_ = _zz_216_[0];
  assign _zz_127_ = _zz_115_[23 : 22];
  assign _zz_45_ = _zz_127_;
  assign _zz_44_ = _zz_217_[0];
  assign execute_RegFilePlugin_regFileReadAddress1 = decode_INSTRUCTION[19 : 15];
  assign execute_RegFilePlugin_regFileReadAddress2 = decode_INSTRUCTION[24 : 20];
  assign _zz_128_ = (! execute_arbitration_isStuck);
  assign execute_RegFilePlugin_rs1Data = _zz_185_;
  assign execute_RegFilePlugin_rs2Data = _zz_186_;
  assign _zz_43_ = execute_RegFilePlugin_rs1Data;
  assign _zz_42_ = execute_RegFilePlugin_rs2Data;
  assign execute_RegFilePlugin_regFileWrite_valid = (execute_REGFILE_WRITE_VALID && execute_arbitration_isFiring);
  assign execute_RegFilePlugin_regFileWrite_payload_address = execute_INSTRUCTION[11 : 7];
  assign execute_RegFilePlugin_regFileWrite_payload_data = _zz_58_;
  always @ (*) begin
    case(execute_ALU_BITWISE_CTRL)
      `AluBitwiseCtrlEnum_defaultEncoding_AND_1 : begin
        execute_IntAluPlugin_bitwise = (execute_SRC1 & execute_SRC2);
      end
      `AluBitwiseCtrlEnum_defaultEncoding_OR_1 : begin
        execute_IntAluPlugin_bitwise = (execute_SRC1 | execute_SRC2);
      end
      `AluBitwiseCtrlEnum_defaultEncoding_XOR_1 : begin
        execute_IntAluPlugin_bitwise = (execute_SRC1 ^ execute_SRC2);
      end
      default : begin
        execute_IntAluPlugin_bitwise = execute_SRC1;
      end
    endcase
  end

  always @ (*) begin
    case(execute_ALU_CTRL)
      `AluCtrlEnum_defaultEncoding_BITWISE : begin
        _zz_129_ = execute_IntAluPlugin_bitwise;
      end
      `AluCtrlEnum_defaultEncoding_SLT_SLTU : begin
        _zz_129_ = {31'd0, _zz_218_};
      end
      default : begin
        _zz_129_ = execute_SRC_ADD_SUB;
      end
    endcase
  end

  assign _zz_39_ = _zz_129_;
  always @ (*) begin
    case(execute_SRC1_CTRL)
      `Src1CtrlEnum_defaultEncoding_RS : begin
        _zz_130_ = execute_RS1;
      end
      `Src1CtrlEnum_defaultEncoding_PC_INCREMENT : begin
        _zz_130_ = {29'd0, _zz_219_};
      end
      `Src1CtrlEnum_defaultEncoding_IMU : begin
        _zz_130_ = {execute_INSTRUCTION[31 : 12],(12'b000000000000)};
      end
      default : begin
        _zz_130_ = {27'd0, _zz_220_};
      end
    endcase
  end

  assign _zz_37_ = _zz_130_;
  assign _zz_131_ = _zz_221_[11];
  always @ (*) begin
    _zz_132_[19] = _zz_131_;
    _zz_132_[18] = _zz_131_;
    _zz_132_[17] = _zz_131_;
    _zz_132_[16] = _zz_131_;
    _zz_132_[15] = _zz_131_;
    _zz_132_[14] = _zz_131_;
    _zz_132_[13] = _zz_131_;
    _zz_132_[12] = _zz_131_;
    _zz_132_[11] = _zz_131_;
    _zz_132_[10] = _zz_131_;
    _zz_132_[9] = _zz_131_;
    _zz_132_[8] = _zz_131_;
    _zz_132_[7] = _zz_131_;
    _zz_132_[6] = _zz_131_;
    _zz_132_[5] = _zz_131_;
    _zz_132_[4] = _zz_131_;
    _zz_132_[3] = _zz_131_;
    _zz_132_[2] = _zz_131_;
    _zz_132_[1] = _zz_131_;
    _zz_132_[0] = _zz_131_;
  end

  assign _zz_133_ = _zz_222_[11];
  always @ (*) begin
    _zz_134_[19] = _zz_133_;
    _zz_134_[18] = _zz_133_;
    _zz_134_[17] = _zz_133_;
    _zz_134_[16] = _zz_133_;
    _zz_134_[15] = _zz_133_;
    _zz_134_[14] = _zz_133_;
    _zz_134_[13] = _zz_133_;
    _zz_134_[12] = _zz_133_;
    _zz_134_[11] = _zz_133_;
    _zz_134_[10] = _zz_133_;
    _zz_134_[9] = _zz_133_;
    _zz_134_[8] = _zz_133_;
    _zz_134_[7] = _zz_133_;
    _zz_134_[6] = _zz_133_;
    _zz_134_[5] = _zz_133_;
    _zz_134_[4] = _zz_133_;
    _zz_134_[3] = _zz_133_;
    _zz_134_[2] = _zz_133_;
    _zz_134_[1] = _zz_133_;
    _zz_134_[0] = _zz_133_;
  end

  always @ (*) begin
    case(execute_SRC2_CTRL)
      `Src2CtrlEnum_defaultEncoding_RS : begin
        _zz_135_ = execute_RS2;
      end
      `Src2CtrlEnum_defaultEncoding_IMI : begin
        _zz_135_ = {_zz_132_,execute_INSTRUCTION[31 : 20]};
      end
      `Src2CtrlEnum_defaultEncoding_IMS : begin
        _zz_135_ = {_zz_134_,{execute_INSTRUCTION[31 : 25],execute_INSTRUCTION[11 : 7]}};
      end
      default : begin
        _zz_135_ = execute_PC;
      end
    endcase
  end

  assign _zz_35_ = _zz_135_;
  assign execute_SrcPlugin_addSub = _zz_223_;
  assign execute_SrcPlugin_less = ((execute_SRC1[31] == execute_SRC2[31]) ? execute_SrcPlugin_addSub[31] : (execute_SRC_LESS_UNSIGNED ? execute_SRC2[31] : execute_SRC1[31]));
  assign _zz_33_ = execute_SrcPlugin_addSub;
  assign _zz_32_ = execute_SrcPlugin_addSub;
  assign _zz_31_ = execute_SrcPlugin_less;
  assign execute_LightShifterPlugin_isShift = (execute_SHIFT_CTRL != `ShiftCtrlEnum_defaultEncoding_DISABLE_1);
  assign execute_LightShifterPlugin_amplitude = (execute_LightShifterPlugin_isActive ? execute_LightShifterPlugin_amplitudeReg : execute_SRC2[4 : 0]);
  assign execute_LightShifterPlugin_shiftInput = (execute_LightShifterPlugin_isActive ? execute_LightShifterPlugin_shiftReg : execute_SRC1);
  assign execute_LightShifterPlugin_done = (execute_LightShifterPlugin_amplitude[4 : 1] == (4'b0000));
  always @ (*) begin
    case(execute_SHIFT_CTRL)
      `ShiftCtrlEnum_defaultEncoding_SLL_1 : begin
        _zz_136_ = (execute_LightShifterPlugin_shiftInput <<< 1);
      end
      default : begin
        _zz_136_ = _zz_231_;
      end
    endcase
  end

  assign _zz_29_ = _zz_72_;
  assign execute_BranchPlugin_eq = (execute_SRC1 == execute_SRC2);
  assign _zz_137_ = execute_INSTRUCTION[14 : 12];
  always @ (*) begin
    if((_zz_137_ == (3'b000))) begin
        _zz_138_ = execute_BranchPlugin_eq;
    end else if((_zz_137_ == (3'b001))) begin
        _zz_138_ = (! execute_BranchPlugin_eq);
    end else if((((_zz_137_ & (3'b101)) == (3'b101)))) begin
        _zz_138_ = (! execute_SRC_LESS);
    end else begin
        _zz_138_ = execute_SRC_LESS;
    end
  end

  always @ (*) begin
    case(execute_BRANCH_CTRL)
      `BranchCtrlEnum_defaultEncoding_INC : begin
        _zz_139_ = 1'b0;
      end
      `BranchCtrlEnum_defaultEncoding_JAL : begin
        _zz_139_ = 1'b1;
      end
      `BranchCtrlEnum_defaultEncoding_JALR : begin
        _zz_139_ = 1'b1;
      end
      default : begin
        _zz_139_ = _zz_138_;
      end
    endcase
  end

  assign _zz_28_ = _zz_139_;
  assign _zz_140_ = _zz_233_[11];
  always @ (*) begin
    _zz_141_[19] = _zz_140_;
    _zz_141_[18] = _zz_140_;
    _zz_141_[17] = _zz_140_;
    _zz_141_[16] = _zz_140_;
    _zz_141_[15] = _zz_140_;
    _zz_141_[14] = _zz_140_;
    _zz_141_[13] = _zz_140_;
    _zz_141_[12] = _zz_140_;
    _zz_141_[11] = _zz_140_;
    _zz_141_[10] = _zz_140_;
    _zz_141_[9] = _zz_140_;
    _zz_141_[8] = _zz_140_;
    _zz_141_[7] = _zz_140_;
    _zz_141_[6] = _zz_140_;
    _zz_141_[5] = _zz_140_;
    _zz_141_[4] = _zz_140_;
    _zz_141_[3] = _zz_140_;
    _zz_141_[2] = _zz_140_;
    _zz_141_[1] = _zz_140_;
    _zz_141_[0] = _zz_140_;
  end

  assign _zz_142_ = _zz_234_[19];
  always @ (*) begin
    _zz_143_[10] = _zz_142_;
    _zz_143_[9] = _zz_142_;
    _zz_143_[8] = _zz_142_;
    _zz_143_[7] = _zz_142_;
    _zz_143_[6] = _zz_142_;
    _zz_143_[5] = _zz_142_;
    _zz_143_[4] = _zz_142_;
    _zz_143_[3] = _zz_142_;
    _zz_143_[2] = _zz_142_;
    _zz_143_[1] = _zz_142_;
    _zz_143_[0] = _zz_142_;
  end

  assign _zz_144_ = _zz_235_[11];
  always @ (*) begin
    _zz_145_[18] = _zz_144_;
    _zz_145_[17] = _zz_144_;
    _zz_145_[16] = _zz_144_;
    _zz_145_[15] = _zz_144_;
    _zz_145_[14] = _zz_144_;
    _zz_145_[13] = _zz_144_;
    _zz_145_[12] = _zz_144_;
    _zz_145_[11] = _zz_144_;
    _zz_145_[10] = _zz_144_;
    _zz_145_[9] = _zz_144_;
    _zz_145_[8] = _zz_144_;
    _zz_145_[7] = _zz_144_;
    _zz_145_[6] = _zz_144_;
    _zz_145_[5] = _zz_144_;
    _zz_145_[4] = _zz_144_;
    _zz_145_[3] = _zz_144_;
    _zz_145_[2] = _zz_144_;
    _zz_145_[1] = _zz_144_;
    _zz_145_[0] = _zz_144_;
  end

  always @ (*) begin
    case(execute_BRANCH_CTRL)
      `BranchCtrlEnum_defaultEncoding_JALR : begin
        _zz_146_ = (_zz_236_[1] ^ execute_RS1[1]);
      end
      `BranchCtrlEnum_defaultEncoding_JAL : begin
        _zz_146_ = _zz_237_[1];
      end
      default : begin
        _zz_146_ = _zz_238_[1];
      end
    endcase
  end

  assign execute_BranchPlugin_missAlignedTarget = (execute_BRANCH_COND_RESULT && _zz_146_);
  assign _zz_26_ = ((execute_PREDICTION_HAD_BRANCHED2 != execute_BRANCH_COND_RESULT) || execute_BranchPlugin_missAlignedTarget);
  always @ (*) begin
    case(execute_BRANCH_CTRL)
      `BranchCtrlEnum_defaultEncoding_JALR : begin
        execute_BranchPlugin_branch_src1 = execute_RS1;
        execute_BranchPlugin_branch_src2 = {_zz_148_,execute_INSTRUCTION[31 : 20]};
      end
      default : begin
        execute_BranchPlugin_branch_src1 = execute_PC;
        execute_BranchPlugin_branch_src2 = ((execute_BRANCH_CTRL == `BranchCtrlEnum_defaultEncoding_JAL) ? {{_zz_150_,{{{_zz_390_,execute_INSTRUCTION[19 : 12]},execute_INSTRUCTION[20]},execute_INSTRUCTION[30 : 21]}},1'b0} : {{_zz_152_,{{{_zz_391_,_zz_392_},execute_INSTRUCTION[30 : 25]},execute_INSTRUCTION[11 : 8]}},1'b0});
        if((execute_PREDICTION_HAD_BRANCHED2 && (! execute_BranchPlugin_missAlignedTarget)))begin
          execute_BranchPlugin_branch_src2 = {29'd0, _zz_242_};
        end
      end
    endcase
  end

  assign _zz_147_ = _zz_239_[11];
  always @ (*) begin
    _zz_148_[19] = _zz_147_;
    _zz_148_[18] = _zz_147_;
    _zz_148_[17] = _zz_147_;
    _zz_148_[16] = _zz_147_;
    _zz_148_[15] = _zz_147_;
    _zz_148_[14] = _zz_147_;
    _zz_148_[13] = _zz_147_;
    _zz_148_[12] = _zz_147_;
    _zz_148_[11] = _zz_147_;
    _zz_148_[10] = _zz_147_;
    _zz_148_[9] = _zz_147_;
    _zz_148_[8] = _zz_147_;
    _zz_148_[7] = _zz_147_;
    _zz_148_[6] = _zz_147_;
    _zz_148_[5] = _zz_147_;
    _zz_148_[4] = _zz_147_;
    _zz_148_[3] = _zz_147_;
    _zz_148_[2] = _zz_147_;
    _zz_148_[1] = _zz_147_;
    _zz_148_[0] = _zz_147_;
  end

  assign _zz_149_ = _zz_240_[19];
  always @ (*) begin
    _zz_150_[10] = _zz_149_;
    _zz_150_[9] = _zz_149_;
    _zz_150_[8] = _zz_149_;
    _zz_150_[7] = _zz_149_;
    _zz_150_[6] = _zz_149_;
    _zz_150_[5] = _zz_149_;
    _zz_150_[4] = _zz_149_;
    _zz_150_[3] = _zz_149_;
    _zz_150_[2] = _zz_149_;
    _zz_150_[1] = _zz_149_;
    _zz_150_[0] = _zz_149_;
  end

  assign _zz_151_ = _zz_241_[11];
  always @ (*) begin
    _zz_152_[18] = _zz_151_;
    _zz_152_[17] = _zz_151_;
    _zz_152_[16] = _zz_151_;
    _zz_152_[15] = _zz_151_;
    _zz_152_[14] = _zz_151_;
    _zz_152_[13] = _zz_151_;
    _zz_152_[12] = _zz_151_;
    _zz_152_[11] = _zz_151_;
    _zz_152_[10] = _zz_151_;
    _zz_152_[9] = _zz_151_;
    _zz_152_[8] = _zz_151_;
    _zz_152_[7] = _zz_151_;
    _zz_152_[6] = _zz_151_;
    _zz_152_[5] = _zz_151_;
    _zz_152_[4] = _zz_151_;
    _zz_152_[3] = _zz_151_;
    _zz_152_[2] = _zz_151_;
    _zz_152_[1] = _zz_151_;
    _zz_152_[0] = _zz_151_;
  end

  assign execute_BranchPlugin_branchAdder = (execute_BranchPlugin_branch_src1 + execute_BranchPlugin_branch_src2);
  assign _zz_25_ = {execute_BranchPlugin_branchAdder[31 : 1],(1'b0)};
  assign _zz_77_ = ((execute_arbitration_isValid && (! execute_arbitration_isStuckByOthers)) && execute_BRANCH_DO);
  always @ (*) begin
    _zz_78_ = (execute_arbitration_isValid && (execute_BRANCH_DO && execute_BRANCH_CALC[1]));
    if(1'b0)begin
      _zz_78_ = 1'b0;
    end
  end

  assign CsrPlugin_misa_base = (2'b01);
  assign CsrPlugin_misa_extensions = (26'b00000000000000000000000000);
  assign CsrPlugin_medeleg = (32'b00000000000000000000000000000000);
  assign CsrPlugin_mideleg = (32'b00000000000000000000000000000000);
  assign _zz_153_ = (CsrPlugin_mip_MTIP && CsrPlugin_mie_MTIE);
  assign _zz_154_ = (CsrPlugin_mip_MSIP && CsrPlugin_mie_MSIE);
  assign _zz_155_ = (CsrPlugin_mip_MEIP && CsrPlugin_mie_MEIE);
  assign CsrPlugin_exceptionPortCtrl_exceptionValidsRegs_decode = 1'b0;
  assign CsrPlugin_exceptionPortCtrl_exceptionTargetPrivilege = (2'b11);
  assign execute_exception_agregat_valid = ({_zz_81_,{_zz_78_,_zz_76_}} != (3'b000));
  assign _zz_156_ = {_zz_81_,{_zz_78_,_zz_76_}};
  assign _zz_157_ = (_zz_156_ & (~ _zz_243_));
  assign _zz_158_ = _zz_157_[1];
  assign _zz_159_ = _zz_157_[2];
  assign _zz_160_ = {_zz_159_,_zz_158_};
  assign execute_exception_agregat_payload_code = _zz_188_;
  assign execute_exception_agregat_payload_badAddr = _zz_189_;
  assign CsrPlugin_exceptionPortCtrl_exceptionValids_decode = CsrPlugin_exceptionPortCtrl_exceptionValidsRegs_decode;
  always @ (*) begin
    CsrPlugin_interrupt = 1'b0;
    CsrPlugin_interruptCode = (4'bxxxx);
    if(CsrPlugin_mstatus_MIE)begin
      if(({_zz_155_,{_zz_154_,_zz_153_}} != (3'b000)))begin
        CsrPlugin_interrupt = 1'b1;
      end
      if(_zz_153_)begin
        CsrPlugin_interruptCode = (4'b0111);
      end
      if(_zz_154_)begin
        CsrPlugin_interruptCode = (4'b0011);
      end
      if(_zz_155_)begin
        CsrPlugin_interruptCode = (4'b1011);
      end
    end
    if((! _zz_83_))begin
      CsrPlugin_interrupt = 1'b0;
    end
  end

  assign CsrPlugin_interruptTargetPrivilege = (2'b11);
  assign CsrPlugin_exception = (CsrPlugin_exceptionPortCtrl_exceptionValids_execute && _zz_84_);
  assign CsrPlugin_lastStageWasWfi = 1'b0;
  always @ (*) begin
    CsrPlugin_pipelineLiberator_done = ((! (execute_arbitration_isValid != (1'b0))) && IBusCachedPlugin_injector_nextPcCalc_valids_2);
    if((CsrPlugin_exceptionPortCtrl_exceptionValidsRegs_execute != (1'b0)))begin
      CsrPlugin_pipelineLiberator_done = 1'b0;
    end
    if(CsrPlugin_hadException)begin
      CsrPlugin_pipelineLiberator_done = 1'b0;
    end
  end

  assign CsrPlugin_interruptJump = (CsrPlugin_interrupt && CsrPlugin_pipelineLiberator_done);
  always @ (*) begin
    CsrPlugin_targetPrivilege = CsrPlugin_interruptTargetPrivilege;
    if(CsrPlugin_hadException)begin
      CsrPlugin_targetPrivilege = CsrPlugin_exceptionPortCtrl_exceptionTargetPrivilege;
    end
  end

  always @ (*) begin
    CsrPlugin_trapCause = CsrPlugin_interruptCode;
    if(CsrPlugin_hadException)begin
      CsrPlugin_trapCause = CsrPlugin_exceptionPortCtrl_exceptionContext_code;
    end
  end

  assign contextSwitching = _zz_79_;
  assign _zz_23_ = (! (((decode_INSTRUCTION[14 : 13] == (2'b01)) && (decode_INSTRUCTION[19 : 15] == (5'b00000))) || ((decode_INSTRUCTION[14 : 13] == (2'b11)) && (decode_INSTRUCTION[19 : 15] == (5'b00000)))));
  assign _zz_22_ = (decode_INSTRUCTION[13 : 7] != (7'b0100000));
  assign execute_CsrPlugin_blockedBySideEffects = 1'b0;
  always @ (*) begin
    execute_CsrPlugin_illegalAccess = 1'b1;
    execute_CsrPlugin_readData = (32'b00000000000000000000000000000000);
    case(execute_CsrPlugin_csrAddress)
      12'b101111000000 : begin
        execute_CsrPlugin_illegalAccess = 1'b0;
        execute_CsrPlugin_readData[31 : 0] = _zz_161_;
      end
      12'b001100000000 : begin
        execute_CsrPlugin_illegalAccess = 1'b0;
        execute_CsrPlugin_readData[12 : 11] = CsrPlugin_mstatus_MPP;
        execute_CsrPlugin_readData[7 : 7] = CsrPlugin_mstatus_MPIE;
        execute_CsrPlugin_readData[3 : 3] = CsrPlugin_mstatus_MIE;
      end
      12'b001101000001 : begin
        execute_CsrPlugin_illegalAccess = 1'b0;
        execute_CsrPlugin_readData[31 : 0] = CsrPlugin_mepc;
      end
      12'b001100000101 : begin
        if(execute_CSR_WRITE_OPCODE)begin
          execute_CsrPlugin_illegalAccess = 1'b0;
        end
      end
      12'b001101000100 : begin
        execute_CsrPlugin_illegalAccess = 1'b0;
        execute_CsrPlugin_readData[11 : 11] = CsrPlugin_mip_MEIP;
        execute_CsrPlugin_readData[7 : 7] = CsrPlugin_mip_MTIP;
        execute_CsrPlugin_readData[3 : 3] = CsrPlugin_mip_MSIP;
      end
      12'b001101000011 : begin
        if(execute_CSR_READ_OPCODE)begin
          execute_CsrPlugin_illegalAccess = 1'b0;
        end
        execute_CsrPlugin_readData[31 : 0] = CsrPlugin_mtval;
      end
      12'b111111000000 : begin
        if(execute_CSR_READ_OPCODE)begin
          execute_CsrPlugin_illegalAccess = 1'b0;
        end
        execute_CsrPlugin_readData[31 : 0] = _zz_162_;
      end
      12'b001101000000 : begin
        execute_CsrPlugin_illegalAccess = 1'b0;
        execute_CsrPlugin_readData[31 : 0] = CsrPlugin_mscratch;
      end
      12'b001100000100 : begin
        execute_CsrPlugin_illegalAccess = 1'b0;
        execute_CsrPlugin_readData[11 : 11] = CsrPlugin_mie_MEIE;
        execute_CsrPlugin_readData[7 : 7] = CsrPlugin_mie_MTIE;
        execute_CsrPlugin_readData[3 : 3] = CsrPlugin_mie_MSIE;
      end
      12'b001101000010 : begin
        if(execute_CSR_READ_OPCODE)begin
          execute_CsrPlugin_illegalAccess = 1'b0;
        end
        execute_CsrPlugin_readData[31 : 31] = CsrPlugin_mcause_interrupt;
        execute_CsrPlugin_readData[3 : 0] = CsrPlugin_mcause_exceptionCode;
      end
      default : begin
      end
    endcase
    if((CsrPlugin_privilege < execute_CsrPlugin_csrAddress[9 : 8]))begin
      execute_CsrPlugin_illegalAccess = 1'b1;
    end
    if(((! execute_arbitration_isValid) || (! execute_IS_CSR)))begin
      execute_CsrPlugin_illegalAccess = 1'b0;
    end
  end

  always @ (*) begin
    execute_CsrPlugin_illegalInstruction = 1'b0;
    if((execute_arbitration_isValid && (execute_ENV_CTRL == `EnvCtrlEnum_defaultEncoding_XRET)))begin
      if((execute_INSTRUCTION[29 : 28] != CsrPlugin_privilege))begin
        execute_CsrPlugin_illegalInstruction = 1'b1;
      end
    end
  end

  always @ (*) begin
    _zz_81_ = 1'b0;
    _zz_82_ = (4'bxxxx);
    if((execute_arbitration_isValid && (execute_ENV_CTRL == `EnvCtrlEnum_defaultEncoding_ECALL)))begin
      _zz_81_ = 1'b1;
      _zz_82_ = (4'b1011);
    end
    if((execute_arbitration_isValid && (execute_ENV_CTRL == `EnvCtrlEnum_defaultEncoding_EBREAK)))begin
      _zz_81_ = 1'b1;
      _zz_82_ = (4'b0011);
    end
  end

  assign execute_CsrPlugin_writeInstruction = ((execute_arbitration_isValid && execute_IS_CSR) && execute_CSR_WRITE_OPCODE);
  assign execute_CsrPlugin_readInstruction = ((execute_arbitration_isValid && execute_IS_CSR) && execute_CSR_READ_OPCODE);
  assign execute_CsrPlugin_writeEnable = ((execute_CsrPlugin_writeInstruction && (! execute_CsrPlugin_blockedBySideEffects)) && (! execute_arbitration_isStuckByOthers));
  assign execute_CsrPlugin_readEnable = ((execute_CsrPlugin_readInstruction && (! execute_CsrPlugin_blockedBySideEffects)) && (! execute_arbitration_isStuckByOthers));
  always @ (*) begin
    case(_zz_203_)
      1'b0 : begin
        execute_CsrPlugin_writeData = execute_SRC1;
      end
      default : begin
        execute_CsrPlugin_writeData = (execute_INSTRUCTION[12] ? (execute_CsrPlugin_readData & (~ execute_SRC1)) : (execute_CsrPlugin_readData | execute_SRC1));
      end
    endcase
  end

  assign execute_CsrPlugin_csrAddress = execute_INSTRUCTION[31 : 20];
  assign _zz_162_ = (_zz_161_ & externalInterruptArray_regNext);
  assign externalInterrupt = (_zz_162_ != (32'b00000000000000000000000000000000));
  assign DebugPlugin_isPipBusy = (DebugPlugin_isPipActive || DebugPlugin_isPipActive_regNext);
  always @ (*) begin
    debug_bus_cmd_ready = 1'b1;
    _zz_85_ = 1'b0;
    if(debug_bus_cmd_valid)begin
      case(_zz_198_)
        6'b000000 : begin
        end
        6'b000001 : begin
          if(debug_bus_cmd_payload_wr)begin
            _zz_85_ = 1'b1;
            debug_bus_cmd_ready = _zz_86_;
          end
        end
        6'b010000 : begin
        end
        6'b010001 : begin
        end
        6'b010010 : begin
        end
        6'b010011 : begin
        end
        default : begin
        end
      endcase
    end
  end

  always @ (*) begin
    debug_bus_rsp_data = DebugPlugin_busReadDataReg;
    if((! _zz_163_))begin
      debug_bus_rsp_data[0] = DebugPlugin_resetIt;
      debug_bus_rsp_data[1] = DebugPlugin_haltIt;
      debug_bus_rsp_data[2] = DebugPlugin_isPipBusy;
      debug_bus_rsp_data[3] = DebugPlugin_haltedByBreak;
      debug_bus_rsp_data[4] = DebugPlugin_stepIt;
    end
  end

  assign _zz_21_ = ((! DebugPlugin_haltIt) && (decode_IS_EBREAK || ((((1'b0 || (DebugPlugin_hardwareBreakpoints_0_valid && (DebugPlugin_hardwareBreakpoints_0_pc == _zz_250_))) || (DebugPlugin_hardwareBreakpoints_1_valid && (DebugPlugin_hardwareBreakpoints_1_pc == _zz_251_))) || (DebugPlugin_hardwareBreakpoints_2_valid && (DebugPlugin_hardwareBreakpoints_2_pc == _zz_252_))) || (DebugPlugin_hardwareBreakpoints_3_valid && (DebugPlugin_hardwareBreakpoints_3_pc == _zz_253_)))));
  assign debug_resetOut = DebugPlugin_resetIt_regNext;
  assign _zz_20_ = decode_SRC2_CTRL;
  assign _zz_18_ = _zz_52_;
  assign _zz_34_ = decode_to_execute_SRC2_CTRL;
  assign _zz_17_ = decode_SRC1_CTRL;
  assign _zz_15_ = _zz_49_;
  assign _zz_36_ = decode_to_execute_SRC1_CTRL;
  assign _zz_14_ = decode_BRANCH_CTRL;
  assign _zz_62_ = _zz_48_;
  assign _zz_27_ = decode_to_execute_BRANCH_CTRL;
  assign _zz_12_ = decode_SHIFT_CTRL;
  assign _zz_10_ = _zz_51_;
  assign _zz_30_ = decode_to_execute_SHIFT_CTRL;
  assign _zz_9_ = decode_ALU_CTRL;
  assign _zz_7_ = _zz_53_;
  assign _zz_38_ = decode_to_execute_ALU_CTRL;
  assign _zz_6_ = decode_ALU_BITWISE_CTRL;
  assign _zz_4_ = _zz_45_;
  assign _zz_40_ = decode_to_execute_ALU_BITWISE_CTRL;
  assign _zz_3_ = decode_ENV_CTRL;
  assign _zz_1_ = _zz_50_;
  assign _zz_24_ = decode_to_execute_ENV_CTRL;
  assign decode_arbitration_isFlushed = ({execute_arbitration_flushAll,decode_arbitration_flushAll} != (2'b00));
  assign execute_arbitration_isFlushed = (execute_arbitration_flushAll != (1'b0));
  assign decode_arbitration_isStuckByOthers = (decode_arbitration_haltByOther || (1'b0 || execute_arbitration_isStuck));
  assign decode_arbitration_isStuck = (decode_arbitration_haltItself || decode_arbitration_isStuckByOthers);
  assign decode_arbitration_isMoving = ((! decode_arbitration_isStuck) && (! decode_arbitration_removeIt));
  assign decode_arbitration_isFiring = ((decode_arbitration_isValid && (! decode_arbitration_isStuck)) && (! decode_arbitration_removeIt));
  assign execute_arbitration_isStuckByOthers = (execute_arbitration_haltByOther || 1'b0);
  assign execute_arbitration_isStuck = (execute_arbitration_haltItself || execute_arbitration_isStuckByOthers);
  assign execute_arbitration_isMoving = ((! execute_arbitration_isStuck) && (! execute_arbitration_removeIt));
  assign execute_arbitration_isFiring = ((execute_arbitration_isValid && (! execute_arbitration_isStuck)) && (! execute_arbitration_removeIt));
  assign iBusWishbone_ADR = {_zz_260_,_zz_166_};
  assign iBusWishbone_CTI = ((_zz_166_ == (3'b111)) ? (3'b111) : (3'b010));
  assign iBusWishbone_BTE = (2'b00);
  assign iBusWishbone_SEL = (4'b1111);
  assign iBusWishbone_WE = 1'b0;
  assign iBusWishbone_DAT_MOSI = (32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx);
  always @ (*) begin
    iBusWishbone_CYC = 1'b0;
    iBusWishbone_STB = 1'b0;
    if(_zz_199_)begin
      iBusWishbone_CYC = 1'b1;
      iBusWishbone_STB = 1'b1;
    end
  end

  assign iBus_cmd_ready = (iBus_cmd_valid && iBusWishbone_ACK);
  assign iBus_rsp_valid = _zz_167_;
  assign iBus_rsp_payload_data = iBusWishbone_DAT_MISO_regNext;
  assign iBus_rsp_payload_error = 1'b0;
  assign dBus_cmd_halfPipe_valid = dBus_cmd_halfPipe_regs_valid;
  assign dBus_cmd_halfPipe_payload_wr = dBus_cmd_halfPipe_regs_payload_wr;
  assign dBus_cmd_halfPipe_payload_address = dBus_cmd_halfPipe_regs_payload_address;
  assign dBus_cmd_halfPipe_payload_data = dBus_cmd_halfPipe_regs_payload_data;
  assign dBus_cmd_halfPipe_payload_size = dBus_cmd_halfPipe_regs_payload_size;
  assign dBus_cmd_ready = dBus_cmd_halfPipe_regs_ready;
  assign dBusWishbone_ADR = (dBus_cmd_halfPipe_payload_address >>> 2);
  assign dBusWishbone_CTI = (3'b000);
  assign dBusWishbone_BTE = (2'b00);
  always @ (*) begin
    case(dBus_cmd_halfPipe_payload_size)
      2'b00 : begin
        _zz_168_ = (4'b0001);
      end
      2'b01 : begin
        _zz_168_ = (4'b0011);
      end
      default : begin
        _zz_168_ = (4'b1111);
      end
    endcase
  end

  always @ (*) begin
    dBusWishbone_SEL = _zz_261_[3:0];
    if((! dBus_cmd_halfPipe_payload_wr))begin
      dBusWishbone_SEL = (4'b1111);
    end
  end

  assign dBusWishbone_WE = dBus_cmd_halfPipe_payload_wr;
  assign dBusWishbone_DAT_MOSI = dBus_cmd_halfPipe_payload_data;
  assign dBus_cmd_halfPipe_ready = (dBus_cmd_halfPipe_valid && dBusWishbone_ACK);
  assign dBusWishbone_CYC = dBus_cmd_halfPipe_valid;
  assign dBusWishbone_STB = dBus_cmd_halfPipe_valid;
  assign dBus_rsp_ready = ((dBus_cmd_halfPipe_valid && (! dBusWishbone_WE)) && dBusWishbone_ACK);
  assign dBus_rsp_data = dBusWishbone_DAT_MISO;
  assign dBus_rsp_error = 1'b0;
  always @ (posedge clk) begin
    if(reset) begin
      CsrPlugin_privilege <= (2'b11);
      IBusCachedPlugin_fetchPc_pcReg <= externalResetVector;
      IBusCachedPlugin_fetchPc_inc <= 1'b0;
      _zz_93_ <= 1'b0;
      _zz_99_ <= 1'b0;
      _zz_101_ <= 1'b0;
      IBusCachedPlugin_injector_nextPcCalc_valids_0 <= 1'b0;
      IBusCachedPlugin_injector_nextPcCalc_valids_1 <= 1'b0;
      IBusCachedPlugin_injector_nextPcCalc_valids_2 <= 1'b0;
      IBusCachedPlugin_injector_decodeRemoved <= 1'b0;
      execute_DBusSimplePlugin_cmdSent <= 1'b0;
      execute_LightShifterPlugin_isActive <= 1'b0;
      CsrPlugin_mstatus_MIE <= 1'b0;
      CsrPlugin_mstatus_MPIE <= 1'b0;
      CsrPlugin_mstatus_MPP <= (2'b11);
      CsrPlugin_mip_MEIP <= 1'b0;
      CsrPlugin_mip_MTIP <= 1'b0;
      CsrPlugin_mip_MSIP <= 1'b0;
      CsrPlugin_mie_MEIE <= 1'b0;
      CsrPlugin_mie_MTIE <= 1'b0;
      CsrPlugin_mie_MSIE <= 1'b0;
      CsrPlugin_exceptionPortCtrl_exceptionValidsRegs_execute <= 1'b0;
      CsrPlugin_hadException <= 1'b0;
      _zz_161_ <= (32'b00000000000000000000000000000000);
      execute_arbitration_isValid <= 1'b0;
      _zz_164_ <= (3'b000);
      _zz_166_ <= (3'b000);
      _zz_167_ <= 1'b0;
      dBus_cmd_halfPipe_regs_valid <= 1'b0;
      dBus_cmd_halfPipe_regs_ready <= 1'b1;
    end else begin
      if(IBusCachedPlugin_fetchPc_propagatePc)begin
        IBusCachedPlugin_fetchPc_inc <= 1'b0;
      end
      if(IBusCachedPlugin_jump_pcLoad_valid)begin
        IBusCachedPlugin_fetchPc_inc <= 1'b0;
      end
      if(_zz_197_)begin
        IBusCachedPlugin_fetchPc_inc <= 1'b1;
      end
      if(IBusCachedPlugin_fetchPc_samplePcNext)begin
        IBusCachedPlugin_fetchPc_pcReg <= IBusCachedPlugin_fetchPc_pc;
      end
      _zz_93_ <= 1'b1;
      if((IBusCachedPlugin_jump_pcLoad_valid || _zz_68_))begin
        _zz_99_ <= 1'b0;
      end
      if(_zz_97_)begin
        _zz_99_ <= IBusCachedPlugin_iBusRsp_stages_0_output_valid;
      end
      if(IBusCachedPlugin_iBusRsp_stages_1_output_ready)begin
        _zz_101_ <= IBusCachedPlugin_iBusRsp_stages_1_output_valid;
      end
      if((IBusCachedPlugin_jump_pcLoad_valid || _zz_68_))begin
        _zz_101_ <= 1'b0;
      end
      if((IBusCachedPlugin_jump_pcLoad_valid || _zz_68_))begin
        IBusCachedPlugin_injector_nextPcCalc_valids_0 <= 1'b0;
      end
      if((! (! IBusCachedPlugin_iBusRsp_stages_1_input_ready)))begin
        IBusCachedPlugin_injector_nextPcCalc_valids_0 <= 1'b1;
      end
      if((IBusCachedPlugin_jump_pcLoad_valid || _zz_68_))begin
        IBusCachedPlugin_injector_nextPcCalc_valids_1 <= 1'b0;
      end
      if((! (! IBusCachedPlugin_iBusRsp_cacheRspArbitration_input_ready)))begin
        IBusCachedPlugin_injector_nextPcCalc_valids_1 <= IBusCachedPlugin_injector_nextPcCalc_valids_0;
      end
      if((IBusCachedPlugin_jump_pcLoad_valid || _zz_68_))begin
        IBusCachedPlugin_injector_nextPcCalc_valids_1 <= 1'b0;
      end
      if((IBusCachedPlugin_jump_pcLoad_valid || _zz_68_))begin
        IBusCachedPlugin_injector_nextPcCalc_valids_2 <= 1'b0;
      end
      if((! execute_arbitration_isStuck))begin
        IBusCachedPlugin_injector_nextPcCalc_valids_2 <= IBusCachedPlugin_injector_nextPcCalc_valids_1;
      end
      if((IBusCachedPlugin_jump_pcLoad_valid || _zz_68_))begin
        IBusCachedPlugin_injector_nextPcCalc_valids_2 <= 1'b0;
      end
      if(decode_arbitration_removeIt)begin
        IBusCachedPlugin_injector_decodeRemoved <= 1'b1;
      end
      if((IBusCachedPlugin_jump_pcLoad_valid || _zz_68_))begin
        IBusCachedPlugin_injector_decodeRemoved <= 1'b0;
      end
      if((dBus_cmd_valid && dBus_cmd_ready))begin
        execute_DBusSimplePlugin_cmdSent <= 1'b1;
      end
      if((! execute_arbitration_isStuck))begin
        execute_DBusSimplePlugin_cmdSent <= 1'b0;
      end
      if(_zz_190_)begin
        if(_zz_191_)begin
          execute_LightShifterPlugin_isActive <= 1'b1;
          if(execute_LightShifterPlugin_done)begin
            execute_LightShifterPlugin_isActive <= 1'b0;
          end
        end
      end
      if(execute_arbitration_removeIt)begin
        execute_LightShifterPlugin_isActive <= 1'b0;
      end
      CsrPlugin_mip_MEIP <= externalInterrupt;
      CsrPlugin_mip_MTIP <= timerInterrupt;
      if((! execute_arbitration_isStuck))begin
        CsrPlugin_exceptionPortCtrl_exceptionValidsRegs_execute <= 1'b0;
      end else begin
        CsrPlugin_exceptionPortCtrl_exceptionValidsRegs_execute <= 1'b0;
      end
      CsrPlugin_hadException <= CsrPlugin_exception;
      if(_zz_192_)begin
        CsrPlugin_privilege <= CsrPlugin_targetPrivilege;
        case(CsrPlugin_targetPrivilege)
          2'b11 : begin
            CsrPlugin_mstatus_MIE <= 1'b0;
            CsrPlugin_mstatus_MPIE <= CsrPlugin_mstatus_MIE;
            CsrPlugin_mstatus_MPP <= CsrPlugin_privilege;
          end
          default : begin
          end
        endcase
      end
      if(_zz_193_)begin
        case(_zz_202_)
          2'b11 : begin
            CsrPlugin_mstatus_MIE <= CsrPlugin_mstatus_MPIE;
            CsrPlugin_mstatus_MPP <= (2'b00);
            CsrPlugin_mstatus_MPIE <= 1'b1;
            CsrPlugin_privilege <= CsrPlugin_mstatus_MPP;
          end
          default : begin
          end
        endcase
      end
      if(((! execute_arbitration_isStuck) || execute_arbitration_removeIt))begin
        execute_arbitration_isValid <= 1'b0;
      end
      if(((! decode_arbitration_isStuck) && (! decode_arbitration_removeIt)))begin
        execute_arbitration_isValid <= decode_arbitration_isValid;
      end
      case(_zz_164_)
        3'b000 : begin
          if(_zz_85_)begin
            _zz_164_ <= (3'b001);
          end
        end
        3'b001 : begin
          _zz_164_ <= (3'b010);
        end
        3'b010 : begin
          _zz_164_ <= (3'b011);
        end
        3'b011 : begin
          if((! decode_arbitration_isStuck))begin
            _zz_164_ <= (3'b100);
          end
        end
        3'b100 : begin
          _zz_164_ <= (3'b000);
        end
        default : begin
        end
      endcase
      case(execute_CsrPlugin_csrAddress)
        12'b101111000000 : begin
          if(execute_CsrPlugin_writeEnable)begin
            _zz_161_ <= execute_CsrPlugin_writeData[31 : 0];
          end
        end
        12'b001100000000 : begin
          if(execute_CsrPlugin_writeEnable)begin
            CsrPlugin_mstatus_MPP <= execute_CsrPlugin_writeData[12 : 11];
            CsrPlugin_mstatus_MPIE <= _zz_254_[0];
            CsrPlugin_mstatus_MIE <= _zz_255_[0];
          end
        end
        12'b001101000001 : begin
        end
        12'b001100000101 : begin
        end
        12'b001101000100 : begin
          if(execute_CsrPlugin_writeEnable)begin
            CsrPlugin_mip_MSIP <= _zz_256_[0];
          end
        end
        12'b001101000011 : begin
        end
        12'b111111000000 : begin
        end
        12'b001101000000 : begin
        end
        12'b001100000100 : begin
          if(execute_CsrPlugin_writeEnable)begin
            CsrPlugin_mie_MEIE <= _zz_257_[0];
            CsrPlugin_mie_MTIE <= _zz_258_[0];
            CsrPlugin_mie_MSIE <= _zz_259_[0];
          end
        end
        12'b001101000010 : begin
        end
        default : begin
        end
      endcase
      if(_zz_199_)begin
        if(iBusWishbone_ACK)begin
          _zz_166_ <= (_zz_166_ + (3'b001));
        end
      end
      _zz_167_ <= (iBusWishbone_CYC && iBusWishbone_ACK);
      if(_zz_200_)begin
        dBus_cmd_halfPipe_regs_valid <= dBus_cmd_valid;
        dBus_cmd_halfPipe_regs_ready <= (! dBus_cmd_valid);
      end else begin
        dBus_cmd_halfPipe_regs_valid <= (! dBus_cmd_halfPipe_ready);
        dBus_cmd_halfPipe_regs_ready <= dBus_cmd_halfPipe_ready;
      end
    end
  end

  always @ (posedge clk) begin
    if(IBusCachedPlugin_iBusRsp_stages_1_output_ready)begin
      _zz_102_ <= IBusCachedPlugin_iBusRsp_stages_1_output_payload;
    end
    if(IBusCachedPlugin_iBusRsp_stages_1_input_ready)begin
      IBusCachedPlugin_s1_tightlyCoupledHit <= IBusCachedPlugin_s0_tightlyCoupledHit;
    end
    if(IBusCachedPlugin_iBusRsp_cacheRspArbitration_input_ready)begin
      IBusCachedPlugin_s2_tightlyCoupledHit <= IBusCachedPlugin_s1_tightlyCoupledHit;
    end
    if((! execute_arbitration_isStuckByOthers))begin
      execute_LightShifterPlugin_shiftReg <= _zz_58_;
    end
    if(_zz_190_)begin
      if(_zz_191_)begin
        execute_LightShifterPlugin_amplitudeReg <= (execute_LightShifterPlugin_amplitude - (5'b00001));
      end
    end
    CsrPlugin_mcycle <= (CsrPlugin_mcycle + (64'b0000000000000000000000000000000000000000000000000000000000000001));
    if(execute_arbitration_isFiring)begin
      CsrPlugin_minstret <= (CsrPlugin_minstret + (64'b0000000000000000000000000000000000000000000000000000000000000001));
    end
    if(execute_exception_agregat_valid)begin
      CsrPlugin_exceptionPortCtrl_exceptionContext_code <= execute_exception_agregat_payload_code;
      CsrPlugin_exceptionPortCtrl_exceptionContext_badAddr <= execute_exception_agregat_payload_badAddr;
    end
    if((CsrPlugin_exception || CsrPlugin_interruptJump))begin
      case(CsrPlugin_privilege)
        2'b11 : begin
          CsrPlugin_mepc <= execute_PC;
        end
        default : begin
        end
      endcase
    end
    if(_zz_192_)begin
      case(CsrPlugin_targetPrivilege)
        2'b11 : begin
          CsrPlugin_mcause_interrupt <= (! CsrPlugin_hadException);
          CsrPlugin_mcause_exceptionCode <= CsrPlugin_trapCause;
          CsrPlugin_mtval <= CsrPlugin_exceptionPortCtrl_exceptionContext_badAddr;
        end
        default : begin
        end
      endcase
    end
    externalInterruptArray_regNext <= externalInterruptArray;
    if((! execute_arbitration_isStuck))begin
      decode_to_execute_SRC_USE_SUB_LESS <= decode_SRC_USE_SUB_LESS;
    end
    if((! execute_arbitration_isStuck))begin
      decode_to_execute_SRC2_CTRL <= _zz_19_;
    end
    if((! execute_arbitration_isStuck))begin
      decode_to_execute_SRC1_CTRL <= _zz_16_;
    end
    if((! execute_arbitration_isStuck))begin
      decode_to_execute_BRANCH_CTRL <= _zz_13_;
    end
    if((! execute_arbitration_isStuck))begin
      decode_to_execute_SHIFT_CTRL <= _zz_11_;
    end
    if((! execute_arbitration_isStuck))begin
      decode_to_execute_CSR_READ_OPCODE <= decode_CSR_READ_OPCODE;
    end
    if((! execute_arbitration_isStuck))begin
      decode_to_execute_ALU_CTRL <= _zz_8_;
    end
    if((! execute_arbitration_isStuck))begin
      decode_to_execute_FLUSH_ALL <= decode_FLUSH_ALL;
    end
    if((! execute_arbitration_isStuck))begin
      decode_to_execute_MEMORY_ENABLE <= decode_MEMORY_ENABLE;
    end
    if((! execute_arbitration_isStuck))begin
      decode_to_execute_INSTRUCTION <= decode_INSTRUCTION;
    end
    if((! execute_arbitration_isStuck))begin
      decode_to_execute_IS_CSR <= decode_IS_CSR;
    end
    if((! execute_arbitration_isStuck))begin
      decode_to_execute_DO_EBREAK <= decode_DO_EBREAK;
    end
    if((! execute_arbitration_isStuck))begin
      decode_to_execute_REGFILE_WRITE_VALID <= decode_REGFILE_WRITE_VALID;
    end
    if((! execute_arbitration_isStuck))begin
      decode_to_execute_CSR_WRITE_OPCODE <= decode_CSR_WRITE_OPCODE;
    end
    if((! execute_arbitration_isStuck))begin
      decode_to_execute_PREDICTION_HAD_BRANCHED2 <= decode_PREDICTION_HAD_BRANCHED2;
    end
    if((! execute_arbitration_isStuck))begin
      decode_to_execute_ALU_BITWISE_CTRL <= _zz_5_;
    end
    if((! execute_arbitration_isStuck))begin
      decode_to_execute_ENV_CTRL <= _zz_2_;
    end
    if((! execute_arbitration_isStuck))begin
      decode_to_execute_SRC_LESS_UNSIGNED <= decode_SRC_LESS_UNSIGNED;
    end
    if((! execute_arbitration_isStuck))begin
      decode_to_execute_PC <= decode_PC;
    end
    if((! execute_arbitration_isStuck))begin
      decode_to_execute_FORMAL_PC_NEXT <= _zz_63_;
    end
    case(execute_CsrPlugin_csrAddress)
      12'b101111000000 : begin
      end
      12'b001100000000 : begin
      end
      12'b001101000001 : begin
        if(execute_CsrPlugin_writeEnable)begin
          CsrPlugin_mepc <= execute_CsrPlugin_writeData[31 : 0];
        end
      end
      12'b001100000101 : begin
        if(execute_CsrPlugin_writeEnable)begin
          CsrPlugin_mtvec_base <= execute_CsrPlugin_writeData[31 : 2];
          CsrPlugin_mtvec_mode <= execute_CsrPlugin_writeData[1 : 0];
        end
      end
      12'b001101000100 : begin
      end
      12'b001101000011 : begin
      end
      12'b111111000000 : begin
      end
      12'b001101000000 : begin
        if(execute_CsrPlugin_writeEnable)begin
          CsrPlugin_mscratch <= execute_CsrPlugin_writeData[31 : 0];
        end
      end
      12'b001100000100 : begin
      end
      12'b001101000010 : begin
      end
      default : begin
      end
    endcase
    iBusWishbone_DAT_MISO_regNext <= iBusWishbone_DAT_MISO;
    if(_zz_200_)begin
      dBus_cmd_halfPipe_regs_payload_wr <= dBus_cmd_payload_wr;
      dBus_cmd_halfPipe_regs_payload_address <= dBus_cmd_payload_address;
      dBus_cmd_halfPipe_regs_payload_data <= dBus_cmd_payload_data;
      dBus_cmd_halfPipe_regs_payload_size <= dBus_cmd_payload_size;
    end
  end

  always @ (posedge clk) begin
    DebugPlugin_firstCycle <= 1'b0;
    if(debug_bus_cmd_ready)begin
      DebugPlugin_firstCycle <= 1'b1;
    end
    DebugPlugin_secondCycle <= DebugPlugin_firstCycle;
    DebugPlugin_isPipActive <= ({execute_arbitration_isValid,decode_arbitration_isValid} != (2'b00));
    DebugPlugin_isPipActive_regNext <= DebugPlugin_isPipActive;
    if(execute_arbitration_isValid)begin
      DebugPlugin_busReadDataReg <= _zz_58_;
    end
    _zz_163_ <= debug_bus_cmd_payload_address[2];
    if(debug_bus_cmd_valid)begin
      case(_zz_198_)
        6'b000000 : begin
        end
        6'b000001 : begin
        end
        6'b010000 : begin
          if(debug_bus_cmd_payload_wr)begin
            DebugPlugin_hardwareBreakpoints_0_pc <= debug_bus_cmd_payload_data[31 : 1];
          end
        end
        6'b010001 : begin
          if(debug_bus_cmd_payload_wr)begin
            DebugPlugin_hardwareBreakpoints_1_pc <= debug_bus_cmd_payload_data[31 : 1];
          end
        end
        6'b010010 : begin
          if(debug_bus_cmd_payload_wr)begin
            DebugPlugin_hardwareBreakpoints_2_pc <= debug_bus_cmd_payload_data[31 : 1];
          end
        end
        6'b010011 : begin
          if(debug_bus_cmd_payload_wr)begin
            DebugPlugin_hardwareBreakpoints_3_pc <= debug_bus_cmd_payload_data[31 : 1];
          end
        end
        default : begin
        end
      endcase
    end
    if(_zz_194_)begin
      DebugPlugin_busReadDataReg <= execute_PC;
    end
    DebugPlugin_resetIt_regNext <= DebugPlugin_resetIt;
  end

  always @ (posedge clk) begin
    if(debugReset) begin
      DebugPlugin_resetIt <= 1'b0;
      DebugPlugin_haltIt <= 1'b0;
      DebugPlugin_stepIt <= 1'b0;
      DebugPlugin_haltedByBreak <= 1'b0;
      DebugPlugin_hardwareBreakpoints_0_valid <= 1'b0;
      DebugPlugin_hardwareBreakpoints_1_valid <= 1'b0;
      DebugPlugin_hardwareBreakpoints_2_valid <= 1'b0;
      DebugPlugin_hardwareBreakpoints_3_valid <= 1'b0;
    end else begin
      if(debug_bus_cmd_valid)begin
        case(_zz_198_)
          6'b000000 : begin
            if(debug_bus_cmd_payload_wr)begin
              DebugPlugin_stepIt <= debug_bus_cmd_payload_data[4];
              if(debug_bus_cmd_payload_data[16])begin
                DebugPlugin_resetIt <= 1'b1;
              end
              if(debug_bus_cmd_payload_data[24])begin
                DebugPlugin_resetIt <= 1'b0;
              end
              if(debug_bus_cmd_payload_data[17])begin
                DebugPlugin_haltIt <= 1'b1;
              end
              if(debug_bus_cmd_payload_data[25])begin
                DebugPlugin_haltIt <= 1'b0;
              end
              if(debug_bus_cmd_payload_data[25])begin
                DebugPlugin_haltedByBreak <= 1'b0;
              end
            end
          end
          6'b000001 : begin
          end
          6'b010000 : begin
            if(debug_bus_cmd_payload_wr)begin
              DebugPlugin_hardwareBreakpoints_0_valid <= _zz_246_[0];
            end
          end
          6'b010001 : begin
            if(debug_bus_cmd_payload_wr)begin
              DebugPlugin_hardwareBreakpoints_1_valid <= _zz_247_[0];
            end
          end
          6'b010010 : begin
            if(debug_bus_cmd_payload_wr)begin
              DebugPlugin_hardwareBreakpoints_2_valid <= _zz_248_[0];
            end
          end
          6'b010011 : begin
            if(debug_bus_cmd_payload_wr)begin
              DebugPlugin_hardwareBreakpoints_3_valid <= _zz_249_[0];
            end
          end
          default : begin
          end
        endcase
      end
      if(_zz_194_)begin
        if(_zz_195_)begin
          DebugPlugin_haltIt <= 1'b1;
          DebugPlugin_haltedByBreak <= 1'b1;
        end
      end
      if(_zz_196_)begin
        if(decode_arbitration_isValid)begin
          DebugPlugin_haltIt <= 1'b1;
        end
      end
      if((DebugPlugin_stepIt && ({execute_arbitration_redoIt,decode_arbitration_redoIt} != (2'b00))))begin
        DebugPlugin_haltIt <= 1'b0;
      end
    end
  end

  always @ (posedge clk) begin
    _zz_165_ <= debug_bus_cmd_payload_data;
  end

endmodule

