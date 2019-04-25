// Generator : SpinalHDL v1.3.2    git head : 41815ceafff4e72c2e3a3e1ff7e9ada5202a0d26
// Date      : 26/03/2019, 08:02:39
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

`define ShiftCtrlEnum_defaultEncoding_type [1:0]
`define ShiftCtrlEnum_defaultEncoding_DISABLE_1 2'b00
`define ShiftCtrlEnum_defaultEncoding_SLL_1 2'b01
`define ShiftCtrlEnum_defaultEncoding_SRL_1 2'b10
`define ShiftCtrlEnum_defaultEncoding_SRA_1 2'b11

`define AluCtrlEnum_defaultEncoding_type [1:0]
`define AluCtrlEnum_defaultEncoding_ADD_SUB 2'b00
`define AluCtrlEnum_defaultEncoding_SLT_SLTU 2'b01
`define AluCtrlEnum_defaultEncoding_BITWISE 2'b10

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
  reg [23:0] _zz_12_;
  reg [31:0] _zz_13_;
  wire  _zz_14_;
  wire [0:0] _zz_15_;
  wire [0:0] _zz_16_;
  wire [23:0] _zz_17_;
  reg  _zz_1_;
  reg  _zz_2_;
  reg  lineLoader_fire;
  reg  lineLoader_valid;
  reg [31:0] lineLoader_address;
  reg  lineLoader_hadError;
  reg [5:0] lineLoader_flushCounter;
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
  wire [4:0] lineLoader_write_tag_0_payload_address;
  wire  lineLoader_write_tag_0_payload_data_valid;
  wire  lineLoader_write_tag_0_payload_data_error;
  wire [21:0] lineLoader_write_tag_0_payload_data_address;
  wire  lineLoader_write_data_0_valid;
  wire [7:0] lineLoader_write_data_0_payload_address;
  wire [31:0] lineLoader_write_data_0_payload_data;
  wire  _zz_5_;
  wire [4:0] _zz_6_;
  wire  _zz_7_;
  wire  fetchStage_read_waysValues_0_tag_valid;
  wire  fetchStage_read_waysValues_0_tag_error;
  wire [21:0] fetchStage_read_waysValues_0_tag_address;
  wire [23:0] _zz_8_;
  wire [7:0] _zz_9_;
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
  reg [21:0] decodeStage_hit_tags_0_address;
  wire  decodeStage_hit_hits_0;
  wire  decodeStage_hit_valid;
  wire  decodeStage_hit_error;
  reg [31:0] _zz_11_;
  wire [31:0] decodeStage_hit_data;
  reg [31:0] decodeStage_hit_word;
  reg  io_cpu_fetch_dataBypassValid_regNextWhen;
  reg [31:0] io_cpu_fetch_dataBypass_regNextWhen;
  reg [23:0] ways_0_tags [0:31];
  reg [31:0] ways_0_datas [0:255];
  assign _zz_14_ = (! lineLoader_flushCounter[5]);
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
  assign _zz_4_ = lineLoader_flushCounter[5];
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
  assign lineLoader_write_tag_0_valid = ((_zz_5_ && lineLoader_fire) || (! lineLoader_flushCounter[5]));
  assign lineLoader_write_tag_0_payload_address = (lineLoader_flushCounter[5] ? lineLoader_address[9 : 5] : lineLoader_flushCounter[4 : 0]);
  assign lineLoader_write_tag_0_payload_data_valid = lineLoader_flushCounter[5];
  assign lineLoader_write_tag_0_payload_data_error = (lineLoader_hadError || io_mem_rsp_payload_error);
  assign lineLoader_write_tag_0_payload_data_address = lineLoader_address[31 : 10];
  assign lineLoader_write_data_0_valid = (io_mem_rsp_valid && _zz_5_);
  assign lineLoader_write_data_0_payload_address = {lineLoader_address[9 : 5],lineLoader_wordIndex};
  assign lineLoader_write_data_0_payload_data = io_mem_rsp_payload_data;
  assign _zz_6_ = io_cpu_prefetch_pc[9 : 5];
  assign _zz_7_ = (! io_cpu_fetch_isStuck);
  assign _zz_8_ = _zz_12_;
  assign fetchStage_read_waysValues_0_tag_valid = _zz_15_[0];
  assign fetchStage_read_waysValues_0_tag_error = _zz_16_[0];
  assign fetchStage_read_waysValues_0_tag_address = _zz_8_[23 : 2];
  assign _zz_9_ = io_cpu_prefetch_pc[9 : 2];
  assign _zz_10_ = (! io_cpu_fetch_isStuck);
  assign fetchStage_read_waysValues_0_data = _zz_13_;
  assign io_cpu_fetch_data = (io_cpu_fetch_dataBypassValid ? io_cpu_fetch_dataBypass : fetchStage_read_waysValues_0_data[31 : 0]);
  assign io_cpu_fetch_mmuBus_cmd_isValid = io_cpu_fetch_isValid;
  assign io_cpu_fetch_mmuBus_cmd_virtualAddress = io_cpu_fetch_pc;
  assign io_cpu_fetch_mmuBus_cmd_bypassTranslation = 1'b0;
  assign io_cpu_fetch_mmuBus_end = ((! io_cpu_fetch_isStuck) || io_cpu_fetch_isRemoved);
  assign io_cpu_fetch_physicalAddress = io_cpu_fetch_mmuBus_rsp_physicalAddress;
  assign decodeStage_hit_hits_0 = (decodeStage_hit_tags_0_valid && (decodeStage_hit_tags_0_address == decodeStage_mmuRsp_physicalAddress[31 : 10]));
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
      lineLoader_flushCounter <= (6'b000000);
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
        lineLoader_flushCounter <= (lineLoader_flushCounter + (6'b000001));
      end
      if(io_flush_cmd_valid)begin
        if(io_flush_cmd_ready)begin
          lineLoader_flushCounter <= (6'b000000);
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
    _zz_3_ <= lineLoader_flushCounter[5];
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
  reg  _zz_175_;
  wire  _zz_176_;
  wire  _zz_177_;
  wire  _zz_178_;
  wire  _zz_179_;
  wire [31:0] _zz_180_;
  wire  _zz_181_;
  wire  _zz_182_;
  wire  _zz_183_;
  wire  _zz_184_;
  wire  _zz_185_;
  wire  _zz_186_;
  wire  _zz_187_;
  wire  _zz_188_;
  wire  _zz_189_;
  wire  _zz_190_;
  reg [31:0] _zz_191_;
  reg [31:0] _zz_192_;
  reg [31:0] _zz_193_;
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
  wire  _zz_194_;
  wire  _zz_195_;
  wire  _zz_196_;
  wire  _zz_197_;
  wire  _zz_198_;
  wire  _zz_199_;
  wire  _zz_200_;
  wire  _zz_201_;
  wire [5:0] _zz_202_;
  wire  _zz_203_;
  wire  _zz_204_;
  wire [1:0] _zz_205_;
  wire [1:0] _zz_206_;
  wire  _zz_207_;
  wire [3:0] _zz_208_;
  wire [2:0] _zz_209_;
  wire [31:0] _zz_210_;
  wire [11:0] _zz_211_;
  wire [31:0] _zz_212_;
  wire [19:0] _zz_213_;
  wire [11:0] _zz_214_;
  wire [2:0] _zz_215_;
  wire [0:0] _zz_216_;
  wire [0:0] _zz_217_;
  wire [0:0] _zz_218_;
  wire [0:0] _zz_219_;
  wire [0:0] _zz_220_;
  wire [0:0] _zz_221_;
  wire [0:0] _zz_222_;
  wire [0:0] _zz_223_;
  wire [2:0] _zz_224_;
  wire [4:0] _zz_225_;
  wire [11:0] _zz_226_;
  wire [11:0] _zz_227_;
  wire [31:0] _zz_228_;
  wire [31:0] _zz_229_;
  wire [31:0] _zz_230_;
  wire [31:0] _zz_231_;
  wire [1:0] _zz_232_;
  wire [31:0] _zz_233_;
  wire [1:0] _zz_234_;
  wire [1:0] _zz_235_;
  wire [31:0] _zz_236_;
  wire [32:0] _zz_237_;
  wire [11:0] _zz_238_;
  wire [19:0] _zz_239_;
  wire [11:0] _zz_240_;
  wire [31:0] _zz_241_;
  wire [31:0] _zz_242_;
  wire [31:0] _zz_243_;
  wire [11:0] _zz_244_;
  wire [19:0] _zz_245_;
  wire [11:0] _zz_246_;
  wire [2:0] _zz_247_;
  wire [1:0] _zz_248_;
  wire [1:0] _zz_249_;
  wire [0:0] _zz_250_;
  wire [0:0] _zz_251_;
  wire [0:0] _zz_252_;
  wire [0:0] _zz_253_;
  wire [30:0] _zz_254_;
  wire [30:0] _zz_255_;
  wire [30:0] _zz_256_;
  wire [30:0] _zz_257_;
  wire [0:0] _zz_258_;
  wire [0:0] _zz_259_;
  wire [0:0] _zz_260_;
  wire [0:0] _zz_261_;
  wire [0:0] _zz_262_;
  wire [0:0] _zz_263_;
  wire [26:0] _zz_264_;
  wire [6:0] _zz_265_;
  wire [1:0] _zz_266_;
  wire [0:0] _zz_267_;
  wire [7:0] _zz_268_;
  wire  _zz_269_;
  wire [0:0] _zz_270_;
  wire [0:0] _zz_271_;
  wire [31:0] _zz_272_;
  wire  _zz_273_;
  wire  _zz_274_;
  wire [1:0] _zz_275_;
  wire [1:0] _zz_276_;
  wire  _zz_277_;
  wire [0:0] _zz_278_;
  wire [19:0] _zz_279_;
  wire [31:0] _zz_280_;
  wire [31:0] _zz_281_;
  wire [0:0] _zz_282_;
  wire [0:0] _zz_283_;
  wire [0:0] _zz_284_;
  wire [2:0] _zz_285_;
  wire [0:0] _zz_286_;
  wire [0:0] _zz_287_;
  wire  _zz_288_;
  wire [0:0] _zz_289_;
  wire [16:0] _zz_290_;
  wire [31:0] _zz_291_;
  wire [31:0] _zz_292_;
  wire [31:0] _zz_293_;
  wire [31:0] _zz_294_;
  wire [31:0] _zz_295_;
  wire  _zz_296_;
  wire  _zz_297_;
  wire [31:0] _zz_298_;
  wire [0:0] _zz_299_;
  wire [3:0] _zz_300_;
  wire [0:0] _zz_301_;
  wire [0:0] _zz_302_;
  wire [0:0] _zz_303_;
  wire [0:0] _zz_304_;
  wire  _zz_305_;
  wire [0:0] _zz_306_;
  wire [13:0] _zz_307_;
  wire [31:0] _zz_308_;
  wire [31:0] _zz_309_;
  wire [31:0] _zz_310_;
  wire [31:0] _zz_311_;
  wire  _zz_312_;
  wire [0:0] _zz_313_;
  wire [1:0] _zz_314_;
  wire [31:0] _zz_315_;
  wire [31:0] _zz_316_;
  wire [31:0] _zz_317_;
  wire [31:0] _zz_318_;
  wire [0:0] _zz_319_;
  wire [0:0] _zz_320_;
  wire [1:0] _zz_321_;
  wire [1:0] _zz_322_;
  wire  _zz_323_;
  wire [0:0] _zz_324_;
  wire [11:0] _zz_325_;
  wire [31:0] _zz_326_;
  wire [31:0] _zz_327_;
  wire [31:0] _zz_328_;
  wire [31:0] _zz_329_;
  wire [31:0] _zz_330_;
  wire [31:0] _zz_331_;
  wire [31:0] _zz_332_;
  wire  _zz_333_;
  wire [1:0] _zz_334_;
  wire [1:0] _zz_335_;
  wire  _zz_336_;
  wire [0:0] _zz_337_;
  wire [8:0] _zz_338_;
  wire [31:0] _zz_339_;
  wire [31:0] _zz_340_;
  wire [31:0] _zz_341_;
  wire [31:0] _zz_342_;
  wire  _zz_343_;
  wire [0:0] _zz_344_;
  wire [0:0] _zz_345_;
  wire [2:0] _zz_346_;
  wire [2:0] _zz_347_;
  wire  _zz_348_;
  wire [0:0] _zz_349_;
  wire [5:0] _zz_350_;
  wire [31:0] _zz_351_;
  wire [31:0] _zz_352_;
  wire [31:0] _zz_353_;
  wire  _zz_354_;
  wire  _zz_355_;
  wire [31:0] _zz_356_;
  wire [31:0] _zz_357_;
  wire  _zz_358_;
  wire [0:0] _zz_359_;
  wire [0:0] _zz_360_;
  wire  _zz_361_;
  wire [0:0] _zz_362_;
  wire [2:0] _zz_363_;
  wire [31:0] _zz_364_;
  wire  _zz_365_;
  wire [0:0] _zz_366_;
  wire [1:0] _zz_367_;
  wire [0:0] _zz_368_;
  wire [0:0] _zz_369_;
  wire  _zz_370_;
  wire  _zz_371_;
  wire [31:0] _zz_372_;
  wire [31:0] _zz_373_;
  wire [31:0] _zz_374_;
  wire [31:0] _zz_375_;
  wire [31:0] _zz_376_;
  wire [31:0] _zz_377_;
  wire [31:0] _zz_378_;
  wire [31:0] _zz_379_;
  wire [31:0] _zz_380_;
  wire [31:0] _zz_381_;
  wire  _zz_382_;
  wire  _zz_383_;
  wire  _zz_384_;
  wire [31:0] writeBack_FORMAL_PC_NEXT;
  wire [31:0] memory_FORMAL_PC_NEXT;
  wire [31:0] execute_FORMAL_PC_NEXT;
  wire [31:0] decode_FORMAL_PC_NEXT;
  wire [31:0] memory_PC;
  wire  decode_PREDICTION_HAD_BRANCHED2;
  wire `EnvCtrlEnum_defaultEncoding_type _zz_1_;
  wire `EnvCtrlEnum_defaultEncoding_type _zz_2_;
  wire `EnvCtrlEnum_defaultEncoding_type _zz_3_;
  wire `EnvCtrlEnum_defaultEncoding_type _zz_4_;
  wire `EnvCtrlEnum_defaultEncoding_type decode_ENV_CTRL;
  wire `EnvCtrlEnum_defaultEncoding_type _zz_5_;
  wire `EnvCtrlEnum_defaultEncoding_type _zz_6_;
  wire `EnvCtrlEnum_defaultEncoding_type _zz_7_;
  wire `AluBitwiseCtrlEnum_defaultEncoding_type decode_ALU_BITWISE_CTRL;
  wire `AluBitwiseCtrlEnum_defaultEncoding_type _zz_8_;
  wire `AluBitwiseCtrlEnum_defaultEncoding_type _zz_9_;
  wire `AluBitwiseCtrlEnum_defaultEncoding_type _zz_10_;
  wire [1:0] memory_MEMORY_ADDRESS_LOW;
  wire [1:0] execute_MEMORY_ADDRESS_LOW;
  wire [31:0] writeBack_REGFILE_WRITE_DATA;
  wire [31:0] execute_REGFILE_WRITE_DATA;
  wire `ShiftCtrlEnum_defaultEncoding_type decode_SHIFT_CTRL;
  wire `ShiftCtrlEnum_defaultEncoding_type _zz_11_;
  wire `ShiftCtrlEnum_defaultEncoding_type _zz_12_;
  wire `ShiftCtrlEnum_defaultEncoding_type _zz_13_;
  wire  decode_DO_EBREAK;
  wire `AluCtrlEnum_defaultEncoding_type decode_ALU_CTRL;
  wire `AluCtrlEnum_defaultEncoding_type _zz_14_;
  wire `AluCtrlEnum_defaultEncoding_type _zz_15_;
  wire `AluCtrlEnum_defaultEncoding_type _zz_16_;
  wire `BranchCtrlEnum_defaultEncoding_type _zz_17_;
  wire `BranchCtrlEnum_defaultEncoding_type _zz_18_;
  wire `Src1CtrlEnum_defaultEncoding_type decode_SRC1_CTRL;
  wire `Src1CtrlEnum_defaultEncoding_type _zz_19_;
  wire `Src1CtrlEnum_defaultEncoding_type _zz_20_;
  wire `Src1CtrlEnum_defaultEncoding_type _zz_21_;
  wire  decode_CSR_READ_OPCODE;
  wire  decode_SRC_USE_SUB_LESS;
  wire  decode_CSR_WRITE_OPCODE;
  wire  execute_FLUSH_ALL;
  wire  decode_FLUSH_ALL;
  wire  decode_SRC_LESS_UNSIGNED;
  wire  writeBack_REGFILE_WRITE_VALID;
  wire  memory_REGFILE_WRITE_VALID;
  wire  execute_REGFILE_WRITE_VALID;
  wire [31:0] memory_MEMORY_READ_DATA;
  wire  decode_IS_CSR;
  wire  decode_MEMORY_ENABLE;
  wire `Src2CtrlEnum_defaultEncoding_type decode_SRC2_CTRL;
  wire `Src2CtrlEnum_defaultEncoding_type _zz_22_;
  wire `Src2CtrlEnum_defaultEncoding_type _zz_23_;
  wire `Src2CtrlEnum_defaultEncoding_type _zz_24_;
  wire  execute_DO_EBREAK;
  wire  decode_IS_EBREAK;
  wire  _zz_25_;
  wire  execute_CSR_READ_OPCODE;
  wire  execute_CSR_WRITE_OPCODE;
  wire  execute_IS_CSR;
  wire `EnvCtrlEnum_defaultEncoding_type memory_ENV_CTRL;
  wire `EnvCtrlEnum_defaultEncoding_type _zz_26_;
  wire `EnvCtrlEnum_defaultEncoding_type execute_ENV_CTRL;
  wire `EnvCtrlEnum_defaultEncoding_type _zz_27_;
  wire  _zz_28_;
  wire  _zz_29_;
  wire `EnvCtrlEnum_defaultEncoding_type writeBack_ENV_CTRL;
  wire `EnvCtrlEnum_defaultEncoding_type _zz_30_;
  wire [31:0] execute_BRANCH_CALC;
  wire  execute_BRANCH_DO;
  wire [31:0] _zz_31_;
  wire [31:0] execute_PC;
  wire  execute_PREDICTION_HAD_BRANCHED2;
  wire  _zz_32_;
  wire [31:0] execute_RS1;
  wire  execute_BRANCH_COND_RESULT;
  wire `BranchCtrlEnum_defaultEncoding_type execute_BRANCH_CTRL;
  wire `BranchCtrlEnum_defaultEncoding_type _zz_33_;
  wire  _zz_34_;
  wire  _zz_35_;
  reg [31:0] _zz_36_;
  wire `ShiftCtrlEnum_defaultEncoding_type execute_SHIFT_CTRL;
  wire `ShiftCtrlEnum_defaultEncoding_type _zz_37_;
  wire  _zz_38_;
  wire [31:0] _zz_39_;
  wire [31:0] _zz_40_;
  wire  execute_SRC_LESS_UNSIGNED;
  wire  execute_SRC_USE_SUB_LESS;
  wire [31:0] _zz_41_;
  wire `Src2CtrlEnum_defaultEncoding_type execute_SRC2_CTRL;
  wire `Src2CtrlEnum_defaultEncoding_type _zz_42_;
  wire [31:0] _zz_43_;
  wire `Src1CtrlEnum_defaultEncoding_type execute_SRC1_CTRL;
  wire `Src1CtrlEnum_defaultEncoding_type _zz_44_;
  wire [31:0] _zz_45_;
  wire [31:0] execute_SRC_ADD_SUB;
  wire  execute_SRC_LESS;
  wire `AluCtrlEnum_defaultEncoding_type execute_ALU_CTRL;
  wire `AluCtrlEnum_defaultEncoding_type _zz_46_;
  wire [31:0] _zz_47_;
  wire [31:0] execute_SRC2;
  wire [31:0] execute_SRC1;
  wire `AluBitwiseCtrlEnum_defaultEncoding_type execute_ALU_BITWISE_CTRL;
  wire `AluBitwiseCtrlEnum_defaultEncoding_type _zz_48_;
  reg  _zz_49_;
  wire [31:0] _zz_50_;
  wire [31:0] _zz_51_;
  reg  decode_REGFILE_WRITE_VALID;
  wire `BranchCtrlEnum_defaultEncoding_type _zz_52_;
  wire `AluBitwiseCtrlEnum_defaultEncoding_type _zz_53_;
  wire  _zz_54_;
  wire  _zz_55_;
  wire `Src1CtrlEnum_defaultEncoding_type _zz_56_;
  wire  _zz_57_;
  wire  _zz_58_;
  wire `Src2CtrlEnum_defaultEncoding_type _zz_59_;
  wire `AluCtrlEnum_defaultEncoding_type _zz_60_;
  wire  _zz_61_;
  wire `EnvCtrlEnum_defaultEncoding_type _zz_62_;
  wire  _zz_63_;
  wire `ShiftCtrlEnum_defaultEncoding_type _zz_64_;
  wire  _zz_65_;
  reg [31:0] _zz_66_;
  wire  writeBack_MEMORY_ENABLE;
  wire [1:0] writeBack_MEMORY_ADDRESS_LOW;
  wire [31:0] writeBack_MEMORY_READ_DATA;
  wire [31:0] memory_REGFILE_WRITE_DATA;
  wire  memory_ALIGNEMENT_FAULT;
  wire [31:0] memory_INSTRUCTION;
  wire  memory_MEMORY_ENABLE;
  wire [31:0] _zz_67_;
  wire [1:0] _zz_68_;
  wire [31:0] execute_RS2;
  wire [31:0] execute_SRC_ADD;
  wire [31:0] execute_INSTRUCTION;
  wire  execute_ALIGNEMENT_FAULT;
  wire  execute_MEMORY_ENABLE;
  wire  _zz_69_;
  wire  memory_FLUSH_ALL;
  reg  IBusCachedPlugin_rsp_issueDetected;
  wire `BranchCtrlEnum_defaultEncoding_type decode_BRANCH_CTRL;
  wire `BranchCtrlEnum_defaultEncoding_type _zz_70_;
  reg [31:0] _zz_71_;
  reg [31:0] _zz_72_;
  wire [31:0] _zz_73_;
  wire [31:0] _zz_74_;
  wire [31:0] _zz_75_;
  wire [31:0] writeBack_PC /* verilator public */ ;
  wire [31:0] writeBack_INSTRUCTION /* verilator public */ ;
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
  reg  memory_arbitration_haltItself;
  wire  memory_arbitration_haltByOther;
  reg  memory_arbitration_removeIt;
  reg  memory_arbitration_flushAll;
  wire  memory_arbitration_redoIt;
  reg  memory_arbitration_isValid;
  wire  memory_arbitration_isStuck;
  wire  memory_arbitration_isStuckByOthers;
  wire  memory_arbitration_isFlushed;
  wire  memory_arbitration_isMoving;
  wire  memory_arbitration_isFiring;
  wire  writeBack_arbitration_haltItself;
  wire  writeBack_arbitration_haltByOther;
  reg  writeBack_arbitration_removeIt;
  wire  writeBack_arbitration_flushAll;
  wire  writeBack_arbitration_redoIt;
  reg  writeBack_arbitration_isValid /* verilator public */ ;
  wire  writeBack_arbitration_isStuck;
  wire  writeBack_arbitration_isStuckByOthers;
  wire  writeBack_arbitration_isFlushed;
  wire  writeBack_arbitration_isMoving;
  wire  writeBack_arbitration_isFiring /* verilator public */ ;
  reg  _zz_76_;
  reg  _zz_77_;
  reg  _zz_78_;
  wire  _zz_79_;
  wire [31:0] _zz_80_;
  wire  _zz_81_;
  wire  _zz_82_;
  wire [31:0] _zz_83_;
  wire [31:0] _zz_84_;
  reg  memory_exception_agregat_valid;
  wire [3:0] memory_exception_agregat_payload_code;
  wire [31:0] memory_exception_agregat_payload_badAddr;
  wire  _zz_85_;
  wire [31:0] _zz_86_;
  reg  _zz_87_;
  reg  _zz_88_;
  reg [31:0] _zz_89_;
  wire  externalInterrupt;
  wire  contextSwitching;
  reg [1:0] CsrPlugin_privilege;
  reg  _zz_90_;
  reg [3:0] _zz_91_;
  reg  _zz_92_;
  reg  _zz_93_;
  reg  _zz_94_;
  reg  _zz_95_;
  wire  IBusCachedPlugin_jump_pcLoad_valid;
  wire [31:0] IBusCachedPlugin_jump_pcLoad_payload;
  wire [3:0] _zz_96_;
  wire [3:0] _zz_97_;
  wire  _zz_98_;
  wire  _zz_99_;
  wire  _zz_100_;
  wire  IBusCachedPlugin_fetchPc_preOutput_valid;
  wire  IBusCachedPlugin_fetchPc_preOutput_ready;
  wire [31:0] IBusCachedPlugin_fetchPc_preOutput_payload;
  wire  _zz_101_;
  wire  IBusCachedPlugin_fetchPc_output_valid;
  wire  IBusCachedPlugin_fetchPc_output_ready;
  wire [31:0] IBusCachedPlugin_fetchPc_output_payload;
  reg [31:0] IBusCachedPlugin_fetchPc_pcReg /* verilator public */ ;
  reg  IBusCachedPlugin_fetchPc_inc;
  reg  IBusCachedPlugin_fetchPc_propagatePc;
  reg [31:0] IBusCachedPlugin_fetchPc_pc;
  reg  IBusCachedPlugin_fetchPc_samplePcNext;
  reg  _zz_102_;
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
  wire  _zz_103_;
  wire  _zz_104_;
  wire  _zz_105_;
  wire  _zz_106_;
  wire  _zz_107_;
  reg  _zz_108_;
  wire  _zz_109_;
  reg  _zz_110_;
  reg [31:0] _zz_111_;
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
  reg  IBusCachedPlugin_injector_nextPcCalc_valids_3;
  reg  IBusCachedPlugin_injector_nextPcCalc_valids_4;
  reg  IBusCachedPlugin_injector_decodeRemoved;
  wire  _zz_112_;
  reg [18:0] _zz_113_;
  wire  _zz_114_;
  reg [10:0] _zz_115_;
  wire  _zz_116_;
  reg [18:0] _zz_117_;
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
  wire  execute_DBusSimplePlugin_cmdSent;
  reg [31:0] _zz_118_;
  reg [3:0] _zz_119_;
  wire [3:0] execute_DBusSimplePlugin_formalMask;
  reg [31:0] writeBack_DBusSimplePlugin_rspShifted;
  wire  _zz_120_;
  reg [31:0] _zz_121_;
  wire  _zz_122_;
  reg [31:0] _zz_123_;
  reg [31:0] writeBack_DBusSimplePlugin_rspFormated;
  wire [25:0] _zz_124_;
  wire  _zz_125_;
  wire  _zz_126_;
  wire  _zz_127_;
  wire  _zz_128_;
  wire  _zz_129_;
  wire `ShiftCtrlEnum_defaultEncoding_type _zz_130_;
  wire `EnvCtrlEnum_defaultEncoding_type _zz_131_;
  wire `AluCtrlEnum_defaultEncoding_type _zz_132_;
  wire `Src2CtrlEnum_defaultEncoding_type _zz_133_;
  wire `Src1CtrlEnum_defaultEncoding_type _zz_134_;
  wire `AluBitwiseCtrlEnum_defaultEncoding_type _zz_135_;
  wire `BranchCtrlEnum_defaultEncoding_type _zz_136_;
  wire [4:0] execute_RegFilePlugin_regFileReadAddress1;
  wire [4:0] execute_RegFilePlugin_regFileReadAddress2;
  wire  _zz_137_;
  wire [31:0] execute_RegFilePlugin_rs1Data;
  wire [31:0] execute_RegFilePlugin_rs2Data;
  wire  writeBack_RegFilePlugin_regFileWrite_valid /* verilator public */ ;
  wire [4:0] writeBack_RegFilePlugin_regFileWrite_payload_address /* verilator public */ ;
  wire [31:0] writeBack_RegFilePlugin_regFileWrite_payload_data /* verilator public */ ;
  reg [31:0] execute_IntAluPlugin_bitwise;
  reg [31:0] _zz_138_;
  reg [31:0] _zz_139_;
  wire  _zz_140_;
  reg [19:0] _zz_141_;
  wire  _zz_142_;
  reg [19:0] _zz_143_;
  reg [31:0] _zz_144_;
  wire [31:0] execute_SrcPlugin_addSub;
  wire  execute_SrcPlugin_less;
  reg  execute_LightShifterPlugin_isActive;
  wire  execute_LightShifterPlugin_isShift;
  reg [4:0] execute_LightShifterPlugin_amplitudeReg;
  wire [4:0] execute_LightShifterPlugin_amplitude;
  wire [31:0] execute_LightShifterPlugin_shiftInput;
  wire  execute_LightShifterPlugin_done;
  reg [31:0] _zz_145_;
  wire  execute_BranchPlugin_eq;
  wire [2:0] _zz_146_;
  reg  _zz_147_;
  reg  _zz_148_;
  wire  _zz_149_;
  reg [19:0] _zz_150_;
  wire  _zz_151_;
  reg [10:0] _zz_152_;
  wire  _zz_153_;
  reg [18:0] _zz_154_;
  reg  _zz_155_;
  wire  execute_BranchPlugin_missAlignedTarget;
  reg [31:0] execute_BranchPlugin_branch_src1;
  reg [31:0] execute_BranchPlugin_branch_src2;
  wire  _zz_156_;
  reg [19:0] _zz_157_;
  wire  _zz_158_;
  reg [10:0] _zz_159_;
  wire  _zz_160_;
  reg [18:0] _zz_161_;
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
  wire  _zz_162_;
  wire  _zz_163_;
  wire  _zz_164_;
  wire  CsrPlugin_exceptionPortCtrl_exceptionValids_decode;
  reg  CsrPlugin_exceptionPortCtrl_exceptionValids_execute;
  reg  CsrPlugin_exceptionPortCtrl_exceptionValids_memory;
  wire  CsrPlugin_exceptionPortCtrl_exceptionValids_writeBack;
  wire  CsrPlugin_exceptionPortCtrl_exceptionValidsRegs_decode;
  reg  CsrPlugin_exceptionPortCtrl_exceptionValidsRegs_execute;
  reg  CsrPlugin_exceptionPortCtrl_exceptionValidsRegs_memory;
  reg  CsrPlugin_exceptionPortCtrl_exceptionValidsRegs_writeBack;
  reg [3:0] CsrPlugin_exceptionPortCtrl_exceptionContext_code;
  reg [31:0] CsrPlugin_exceptionPortCtrl_exceptionContext_badAddr;
  wire [1:0] CsrPlugin_exceptionPortCtrl_exceptionTargetPrivilege;
  wire  execute_exception_agregat_valid;
  wire [3:0] execute_exception_agregat_payload_code;
  wire [31:0] execute_exception_agregat_payload_badAddr;
  wire [1:0] _zz_165_;
  wire  _zz_166_;
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
  reg [31:0] _zz_167_;
  reg [31:0] externalInterruptArray_regNext;
  wire [31:0] _zz_168_;
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
  reg  _zz_169_;
  reg  DebugPlugin_resetIt_regNext;
  reg `Src2CtrlEnum_defaultEncoding_type decode_to_execute_SRC2_CTRL;
  reg  decode_to_execute_MEMORY_ENABLE;
  reg  execute_to_memory_MEMORY_ENABLE;
  reg  memory_to_writeBack_MEMORY_ENABLE;
  reg  decode_to_execute_IS_CSR;
  reg [31:0] memory_to_writeBack_MEMORY_READ_DATA;
  reg  decode_to_execute_REGFILE_WRITE_VALID;
  reg  execute_to_memory_REGFILE_WRITE_VALID;
  reg  memory_to_writeBack_REGFILE_WRITE_VALID;
  reg  decode_to_execute_SRC_LESS_UNSIGNED;
  reg  decode_to_execute_FLUSH_ALL;
  reg  execute_to_memory_FLUSH_ALL;
  reg  execute_to_memory_ALIGNEMENT_FAULT;
  reg  decode_to_execute_CSR_WRITE_OPCODE;
  reg  decode_to_execute_SRC_USE_SUB_LESS;
  reg [31:0] decode_to_execute_INSTRUCTION;
  reg [31:0] execute_to_memory_INSTRUCTION;
  reg [31:0] memory_to_writeBack_INSTRUCTION;
  reg  decode_to_execute_CSR_READ_OPCODE;
  reg `Src1CtrlEnum_defaultEncoding_type decode_to_execute_SRC1_CTRL;
  reg `BranchCtrlEnum_defaultEncoding_type decode_to_execute_BRANCH_CTRL;
  reg `AluCtrlEnum_defaultEncoding_type decode_to_execute_ALU_CTRL;
  reg  decode_to_execute_DO_EBREAK;
  reg `ShiftCtrlEnum_defaultEncoding_type decode_to_execute_SHIFT_CTRL;
  reg [31:0] execute_to_memory_REGFILE_WRITE_DATA;
  reg [31:0] memory_to_writeBack_REGFILE_WRITE_DATA;
  reg [1:0] execute_to_memory_MEMORY_ADDRESS_LOW;
  reg [1:0] memory_to_writeBack_MEMORY_ADDRESS_LOW;
  reg `AluBitwiseCtrlEnum_defaultEncoding_type decode_to_execute_ALU_BITWISE_CTRL;
  reg `EnvCtrlEnum_defaultEncoding_type decode_to_execute_ENV_CTRL;
  reg `EnvCtrlEnum_defaultEncoding_type execute_to_memory_ENV_CTRL;
  reg `EnvCtrlEnum_defaultEncoding_type memory_to_writeBack_ENV_CTRL;
  reg  decode_to_execute_PREDICTION_HAD_BRANCHED2;
  reg [31:0] decode_to_execute_PC;
  reg [31:0] execute_to_memory_PC;
  reg [31:0] memory_to_writeBack_PC;
  reg [31:0] decode_to_execute_FORMAL_PC_NEXT;
  reg [31:0] execute_to_memory_FORMAL_PC_NEXT;
  reg [31:0] memory_to_writeBack_FORMAL_PC_NEXT;
  reg [2:0] _zz_170_;
  reg [31:0] _zz_171_;
  reg [2:0] _zz_172_;
  reg  _zz_173_;
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
  reg [3:0] _zz_174_;
  `ifndef SYNTHESIS
  reg [47:0] _zz_1__string;
  reg [47:0] _zz_2__string;
  reg [47:0] _zz_3__string;
  reg [47:0] _zz_4__string;
  reg [47:0] decode_ENV_CTRL_string;
  reg [47:0] _zz_5__string;
  reg [47:0] _zz_6__string;
  reg [47:0] _zz_7__string;
  reg [39:0] decode_ALU_BITWISE_CTRL_string;
  reg [39:0] _zz_8__string;
  reg [39:0] _zz_9__string;
  reg [39:0] _zz_10__string;
  reg [71:0] decode_SHIFT_CTRL_string;
  reg [71:0] _zz_11__string;
  reg [71:0] _zz_12__string;
  reg [71:0] _zz_13__string;
  reg [63:0] decode_ALU_CTRL_string;
  reg [63:0] _zz_14__string;
  reg [63:0] _zz_15__string;
  reg [63:0] _zz_16__string;
  reg [31:0] _zz_17__string;
  reg [31:0] _zz_18__string;
  reg [95:0] decode_SRC1_CTRL_string;
  reg [95:0] _zz_19__string;
  reg [95:0] _zz_20__string;
  reg [95:0] _zz_21__string;
  reg [23:0] decode_SRC2_CTRL_string;
  reg [23:0] _zz_22__string;
  reg [23:0] _zz_23__string;
  reg [23:0] _zz_24__string;
  reg [47:0] memory_ENV_CTRL_string;
  reg [47:0] _zz_26__string;
  reg [47:0] execute_ENV_CTRL_string;
  reg [47:0] _zz_27__string;
  reg [47:0] writeBack_ENV_CTRL_string;
  reg [47:0] _zz_30__string;
  reg [31:0] execute_BRANCH_CTRL_string;
  reg [31:0] _zz_33__string;
  reg [71:0] execute_SHIFT_CTRL_string;
  reg [71:0] _zz_37__string;
  reg [23:0] execute_SRC2_CTRL_string;
  reg [23:0] _zz_42__string;
  reg [95:0] execute_SRC1_CTRL_string;
  reg [95:0] _zz_44__string;
  reg [63:0] execute_ALU_CTRL_string;
  reg [63:0] _zz_46__string;
  reg [39:0] execute_ALU_BITWISE_CTRL_string;
  reg [39:0] _zz_48__string;
  reg [31:0] _zz_52__string;
  reg [39:0] _zz_53__string;
  reg [95:0] _zz_56__string;
  reg [23:0] _zz_59__string;
  reg [63:0] _zz_60__string;
  reg [47:0] _zz_62__string;
  reg [71:0] _zz_64__string;
  reg [31:0] decode_BRANCH_CTRL_string;
  reg [31:0] _zz_70__string;
  reg [71:0] _zz_130__string;
  reg [47:0] _zz_131__string;
  reg [63:0] _zz_132__string;
  reg [23:0] _zz_133__string;
  reg [95:0] _zz_134__string;
  reg [39:0] _zz_135__string;
  reg [31:0] _zz_136__string;
  reg [23:0] decode_to_execute_SRC2_CTRL_string;
  reg [95:0] decode_to_execute_SRC1_CTRL_string;
  reg [31:0] decode_to_execute_BRANCH_CTRL_string;
  reg [63:0] decode_to_execute_ALU_CTRL_string;
  reg [71:0] decode_to_execute_SHIFT_CTRL_string;
  reg [39:0] decode_to_execute_ALU_BITWISE_CTRL_string;
  reg [47:0] decode_to_execute_ENV_CTRL_string;
  reg [47:0] execute_to_memory_ENV_CTRL_string;
  reg [47:0] memory_to_writeBack_ENV_CTRL_string;
  `endif

  reg [31:0] RegFilePlugin_regFile [0:31] /* verilator public */ ;
  assign _zz_194_ = ((execute_arbitration_isValid && execute_LightShifterPlugin_isShift) && (execute_SRC2[4 : 0] != (5'b00000)));
  assign _zz_195_ = (! execute_arbitration_isStuckByOthers);
  assign _zz_196_ = (execute_arbitration_isValid && execute_DO_EBREAK);
  assign _zz_197_ = (({writeBack_arbitration_isValid,memory_arbitration_isValid} != (2'b00)) == 1'b0);
  assign _zz_198_ = (DebugPlugin_stepIt && _zz_78_);
  assign _zz_199_ = (CsrPlugin_hadException || CsrPlugin_interruptJump);
  assign _zz_200_ = (writeBack_arbitration_isValid && (writeBack_ENV_CTRL == `EnvCtrlEnum_defaultEncoding_XRET));
  assign _zz_201_ = (IBusCachedPlugin_fetchPc_preOutput_valid && IBusCachedPlugin_fetchPc_preOutput_ready);
  assign _zz_202_ = debug_bus_cmd_payload_address[7 : 2];
  assign _zz_203_ = (iBus_cmd_valid || (_zz_172_ != (3'b000)));
  assign _zz_204_ = (! dBus_cmd_halfPipe_regs_valid);
  assign _zz_205_ = writeBack_INSTRUCTION[13 : 12];
  assign _zz_206_ = writeBack_INSTRUCTION[29 : 28];
  assign _zz_207_ = execute_INSTRUCTION[13];
  assign _zz_208_ = (_zz_96_ - (4'b0001));
  assign _zz_209_ = {IBusCachedPlugin_fetchPc_inc,(2'b00)};
  assign _zz_210_ = {29'd0, _zz_209_};
  assign _zz_211_ = {{{decode_INSTRUCTION[31],decode_INSTRUCTION[7]},decode_INSTRUCTION[30 : 25]},decode_INSTRUCTION[11 : 8]};
  assign _zz_212_ = {{_zz_113_,{{{decode_INSTRUCTION[31],decode_INSTRUCTION[7]},decode_INSTRUCTION[30 : 25]},decode_INSTRUCTION[11 : 8]}},1'b0};
  assign _zz_213_ = {{{decode_INSTRUCTION[31],decode_INSTRUCTION[19 : 12]},decode_INSTRUCTION[20]},decode_INSTRUCTION[30 : 21]};
  assign _zz_214_ = {{{decode_INSTRUCTION[31],decode_INSTRUCTION[7]},decode_INSTRUCTION[30 : 25]},decode_INSTRUCTION[11 : 8]};
  assign _zz_215_ = (memory_INSTRUCTION[5] ? (3'b110) : (3'b100));
  assign _zz_216_ = _zz_124_[0 : 0];
  assign _zz_217_ = _zz_124_[3 : 3];
  assign _zz_218_ = _zz_124_[6 : 6];
  assign _zz_219_ = _zz_124_[12 : 12];
  assign _zz_220_ = _zz_124_[13 : 13];
  assign _zz_221_ = _zz_124_[17 : 17];
  assign _zz_222_ = _zz_124_[18 : 18];
  assign _zz_223_ = execute_SRC_LESS;
  assign _zz_224_ = (3'b100);
  assign _zz_225_ = execute_INSTRUCTION[19 : 15];
  assign _zz_226_ = execute_INSTRUCTION[31 : 20];
  assign _zz_227_ = {execute_INSTRUCTION[31 : 25],execute_INSTRUCTION[11 : 7]};
  assign _zz_228_ = ($signed(_zz_229_) + $signed(_zz_233_));
  assign _zz_229_ = ($signed(_zz_230_) + $signed(_zz_231_));
  assign _zz_230_ = execute_SRC1;
  assign _zz_231_ = (execute_SRC_USE_SUB_LESS ? (~ execute_SRC2) : execute_SRC2);
  assign _zz_232_ = (execute_SRC_USE_SUB_LESS ? _zz_234_ : _zz_235_);
  assign _zz_233_ = {{30{_zz_232_[1]}}, _zz_232_};
  assign _zz_234_ = (2'b01);
  assign _zz_235_ = (2'b00);
  assign _zz_236_ = (_zz_237_ >>> 1);
  assign _zz_237_ = {((execute_SHIFT_CTRL == `ShiftCtrlEnum_defaultEncoding_SRA_1) && execute_LightShifterPlugin_shiftInput[31]),execute_LightShifterPlugin_shiftInput};
  assign _zz_238_ = execute_INSTRUCTION[31 : 20];
  assign _zz_239_ = {{{execute_INSTRUCTION[31],execute_INSTRUCTION[19 : 12]},execute_INSTRUCTION[20]},execute_INSTRUCTION[30 : 21]};
  assign _zz_240_ = {{{execute_INSTRUCTION[31],execute_INSTRUCTION[7]},execute_INSTRUCTION[30 : 25]},execute_INSTRUCTION[11 : 8]};
  assign _zz_241_ = {_zz_150_,execute_INSTRUCTION[31 : 20]};
  assign _zz_242_ = {{_zz_152_,{{{execute_INSTRUCTION[31],execute_INSTRUCTION[19 : 12]},execute_INSTRUCTION[20]},execute_INSTRUCTION[30 : 21]}},1'b0};
  assign _zz_243_ = {{_zz_154_,{{{execute_INSTRUCTION[31],execute_INSTRUCTION[7]},execute_INSTRUCTION[30 : 25]},execute_INSTRUCTION[11 : 8]}},1'b0};
  assign _zz_244_ = execute_INSTRUCTION[31 : 20];
  assign _zz_245_ = {{{execute_INSTRUCTION[31],execute_INSTRUCTION[19 : 12]},execute_INSTRUCTION[20]},execute_INSTRUCTION[30 : 21]};
  assign _zz_246_ = {{{execute_INSTRUCTION[31],execute_INSTRUCTION[7]},execute_INSTRUCTION[30 : 25]},execute_INSTRUCTION[11 : 8]};
  assign _zz_247_ = (3'b100);
  assign _zz_248_ = (_zz_165_ & (~ _zz_249_));
  assign _zz_249_ = (_zz_165_ - (2'b01));
  assign _zz_250_ = debug_bus_cmd_payload_data[0 : 0];
  assign _zz_251_ = debug_bus_cmd_payload_data[0 : 0];
  assign _zz_252_ = debug_bus_cmd_payload_data[0 : 0];
  assign _zz_253_ = debug_bus_cmd_payload_data[0 : 0];
  assign _zz_254_ = (decode_PC >>> 1);
  assign _zz_255_ = (decode_PC >>> 1);
  assign _zz_256_ = (decode_PC >>> 1);
  assign _zz_257_ = (decode_PC >>> 1);
  assign _zz_258_ = execute_CsrPlugin_writeData[7 : 7];
  assign _zz_259_ = execute_CsrPlugin_writeData[3 : 3];
  assign _zz_260_ = execute_CsrPlugin_writeData[3 : 3];
  assign _zz_261_ = execute_CsrPlugin_writeData[11 : 11];
  assign _zz_262_ = execute_CsrPlugin_writeData[7 : 7];
  assign _zz_263_ = execute_CsrPlugin_writeData[3 : 3];
  assign _zz_264_ = (iBus_cmd_payload_address >>> 5);
  assign _zz_265_ = ({3'd0,_zz_174_} <<< dBus_cmd_halfPipe_payload_address[1 : 0]);
  assign _zz_266_ = {_zz_100_,_zz_99_};
  assign _zz_267_ = decode_INSTRUCTION[31];
  assign _zz_268_ = decode_INSTRUCTION[19 : 12];
  assign _zz_269_ = decode_INSTRUCTION[20];
  assign _zz_270_ = decode_INSTRUCTION[31];
  assign _zz_271_ = decode_INSTRUCTION[7];
  assign _zz_272_ = (32'b00000000000000000000000000010000);
  assign _zz_273_ = ((decode_INSTRUCTION & (32'b00000000000000000101000000010100)) == (32'b00000000000000000000000000000100));
  assign _zz_274_ = ((decode_INSTRUCTION & (32'b00000000000000000000000001011000)) == (32'b00000000000000000000000001000000));
  assign _zz_275_ = {(_zz_280_ == _zz_281_),_zz_126_};
  assign _zz_276_ = (2'b00);
  assign _zz_277_ = ({_zz_126_,{_zz_282_,_zz_283_}} != (3'b000));
  assign _zz_278_ = ({_zz_284_,_zz_285_} != (4'b0000));
  assign _zz_279_ = {(_zz_286_ != _zz_287_),{_zz_288_,{_zz_289_,_zz_290_}}};
  assign _zz_280_ = (decode_INSTRUCTION & (32'b00000000000000000001000000000000));
  assign _zz_281_ = (32'b00000000000000000001000000000000);
  assign _zz_282_ = ((decode_INSTRUCTION & _zz_291_) == (32'b00000000000000000001000000000000));
  assign _zz_283_ = ((decode_INSTRUCTION & _zz_292_) == (32'b00000000000000000010000000000000));
  assign _zz_284_ = ((decode_INSTRUCTION & _zz_293_) == (32'b00000000000000000000000000000000));
  assign _zz_285_ = {(_zz_294_ == _zz_295_),{_zz_296_,_zz_297_}};
  assign _zz_286_ = ((decode_INSTRUCTION & _zz_298_) == (32'b00000000000000000000000000000000));
  assign _zz_287_ = (1'b0);
  assign _zz_288_ = ({_zz_129_,{_zz_299_,_zz_300_}} != (6'b000000));
  assign _zz_289_ = ({_zz_301_,_zz_302_} != (2'b00));
  assign _zz_290_ = {(_zz_303_ != _zz_304_),{_zz_305_,{_zz_306_,_zz_307_}}};
  assign _zz_291_ = (32'b00000000000000000011000000000000);
  assign _zz_292_ = (32'b00000000000000000011000000000000);
  assign _zz_293_ = (32'b00000000000000000000000001000100);
  assign _zz_294_ = (decode_INSTRUCTION & (32'b00000000000000000000000000011000));
  assign _zz_295_ = (32'b00000000000000000000000000000000);
  assign _zz_296_ = ((decode_INSTRUCTION & _zz_308_) == (32'b00000000000000000010000000000000));
  assign _zz_297_ = ((decode_INSTRUCTION & _zz_309_) == (32'b00000000000000000001000000000000));
  assign _zz_298_ = (32'b00000000000000000000000000000000);
  assign _zz_299_ = (_zz_310_ == _zz_311_);
  assign _zz_300_ = {_zz_312_,{_zz_313_,_zz_314_}};
  assign _zz_301_ = (_zz_315_ == _zz_316_);
  assign _zz_302_ = (_zz_317_ == _zz_318_);
  assign _zz_303_ = _zz_128_;
  assign _zz_304_ = (1'b0);
  assign _zz_305_ = ({_zz_319_,_zz_320_} != (2'b00));
  assign _zz_306_ = (_zz_321_ != _zz_322_);
  assign _zz_307_ = {_zz_323_,{_zz_324_,_zz_325_}};
  assign _zz_308_ = (32'b00000000000000000110000000000100);
  assign _zz_309_ = (32'b00000000000000000101000000000100);
  assign _zz_310_ = (decode_INSTRUCTION & (32'b00000000000000000001000000010000));
  assign _zz_311_ = (32'b00000000000000000001000000010000);
  assign _zz_312_ = ((decode_INSTRUCTION & (32'b00000000000000000010000000010000)) == (32'b00000000000000000010000000010000));
  assign _zz_313_ = _zz_128_;
  assign _zz_314_ = {(_zz_326_ == _zz_327_),(_zz_328_ == _zz_329_)};
  assign _zz_315_ = (decode_INSTRUCTION & (32'b00000000000000000001000001010000));
  assign _zz_316_ = (32'b00000000000000000001000001010000);
  assign _zz_317_ = (decode_INSTRUCTION & (32'b00000000000000000010000001010000));
  assign _zz_318_ = (32'b00000000000000000010000001010000);
  assign _zz_319_ = ((decode_INSTRUCTION & _zz_330_) == (32'b00000000000000000000000000000100));
  assign _zz_320_ = _zz_127_;
  assign _zz_321_ = {(_zz_331_ == _zz_332_),_zz_127_};
  assign _zz_322_ = (2'b00);
  assign _zz_323_ = (_zz_125_ != (1'b0));
  assign _zz_324_ = (_zz_333_ != (1'b0));
  assign _zz_325_ = {(_zz_334_ != _zz_335_),{_zz_336_,{_zz_337_,_zz_338_}}};
  assign _zz_326_ = (decode_INSTRUCTION & (32'b00000000000000000000000000101000));
  assign _zz_327_ = (32'b00000000000000000000000000000000);
  assign _zz_328_ = (decode_INSTRUCTION & (32'b00000000000000000101000000000100));
  assign _zz_329_ = (32'b00000000000000000000000000000100);
  assign _zz_330_ = (32'b00000000000000000000000000010100);
  assign _zz_331_ = (decode_INSTRUCTION & (32'b00000000000000000000000001000100));
  assign _zz_332_ = (32'b00000000000000000000000000000100);
  assign _zz_333_ = ((decode_INSTRUCTION & (32'b00000000000000000000000001011000)) == (32'b00000000000000000000000000000000));
  assign _zz_334_ = {(_zz_339_ == _zz_340_),(_zz_341_ == _zz_342_)};
  assign _zz_335_ = (2'b00);
  assign _zz_336_ = ({_zz_126_,_zz_343_} != (2'b00));
  assign _zz_337_ = ({_zz_344_,_zz_345_} != (2'b00));
  assign _zz_338_ = {(_zz_346_ != _zz_347_),{_zz_348_,{_zz_349_,_zz_350_}}};
  assign _zz_339_ = (decode_INSTRUCTION & (32'b00000000000000000000000000110100));
  assign _zz_340_ = (32'b00000000000000000000000000100000);
  assign _zz_341_ = (decode_INSTRUCTION & (32'b00000000000000000000000001100100));
  assign _zz_342_ = (32'b00000000000000000000000000100000);
  assign _zz_343_ = ((decode_INSTRUCTION & (32'b00000000000000000000000001110000)) == (32'b00000000000000000000000000100000));
  assign _zz_344_ = _zz_126_;
  assign _zz_345_ = ((decode_INSTRUCTION & _zz_351_) == (32'b00000000000000000000000000000000));
  assign _zz_346_ = {(_zz_352_ == _zz_353_),{_zz_354_,_zz_355_}};
  assign _zz_347_ = (3'b000);
  assign _zz_348_ = ((_zz_356_ == _zz_357_) != (1'b0));
  assign _zz_349_ = (_zz_358_ != (1'b0));
  assign _zz_350_ = {(_zz_359_ != _zz_360_),{_zz_361_,{_zz_362_,_zz_363_}}};
  assign _zz_351_ = (32'b00000000000000000000000000100000);
  assign _zz_352_ = (decode_INSTRUCTION & (32'b00000000000000000000000001100100));
  assign _zz_353_ = (32'b00000000000000000000000000100100);
  assign _zz_354_ = ((decode_INSTRUCTION & (32'b00000000000000000100000000010100)) == (32'b00000000000000000100000000010000));
  assign _zz_355_ = ((decode_INSTRUCTION & (32'b00000000000000000011000000010100)) == (32'b00000000000000000001000000010000));
  assign _zz_356_ = (decode_INSTRUCTION & (32'b00000000000000000110000000010100));
  assign _zz_357_ = (32'b00000000000000000010000000010000);
  assign _zz_358_ = ((decode_INSTRUCTION & (32'b00000000000000000001000001001000)) == (32'b00000000000000000000000000001000));
  assign _zz_359_ = ((decode_INSTRUCTION & _zz_364_) == (32'b00000000000000000000000001010000));
  assign _zz_360_ = (1'b0);
  assign _zz_361_ = ({_zz_125_,_zz_365_} != (2'b00));
  assign _zz_362_ = ({_zz_366_,_zz_367_} != (3'b000));
  assign _zz_363_ = {(_zz_368_ != _zz_369_),{_zz_370_,_zz_371_}};
  assign _zz_364_ = (32'b00010000000000000011000001010000);
  assign _zz_365_ = ((decode_INSTRUCTION & (32'b00010000010000000011000001010000)) == (32'b00010000000000000000000001010000));
  assign _zz_366_ = ((decode_INSTRUCTION & (32'b00000000000000000000000001000100)) == (32'b00000000000000000000000001000000));
  assign _zz_367_ = {((decode_INSTRUCTION & _zz_372_) == (32'b01000000000000000000000000110000)),((decode_INSTRUCTION & _zz_373_) == (32'b00000000000000000010000000010000))};
  assign _zz_368_ = ((decode_INSTRUCTION & (32'b00000000000000000111000001010100)) == (32'b00000000000000000101000000010000));
  assign _zz_369_ = (1'b0);
  assign _zz_370_ = ({(_zz_374_ == _zz_375_),(_zz_376_ == _zz_377_)} != (2'b00));
  assign _zz_371_ = ({(_zz_378_ == _zz_379_),(_zz_380_ == _zz_381_)} != (2'b00));
  assign _zz_372_ = (32'b01000000000000000000000000110000);
  assign _zz_373_ = (32'b00000000000000000010000000010100);
  assign _zz_374_ = (decode_INSTRUCTION & (32'b01000000000000000011000001010100));
  assign _zz_375_ = (32'b01000000000000000001000000010000);
  assign _zz_376_ = (decode_INSTRUCTION & (32'b00000000000000000111000001010100));
  assign _zz_377_ = (32'b00000000000000000001000000010000);
  assign _zz_378_ = (decode_INSTRUCTION & (32'b00000000000000000010000000010000));
  assign _zz_379_ = (32'b00000000000000000010000000000000);
  assign _zz_380_ = (decode_INSTRUCTION & (32'b00000000000000000101000000000000));
  assign _zz_381_ = (32'b00000000000000000001000000000000);
  assign _zz_382_ = execute_INSTRUCTION[31];
  assign _zz_383_ = execute_INSTRUCTION[31];
  assign _zz_384_ = execute_INSTRUCTION[7];
  always @ (posedge clk) begin
    if(_zz_49_) begin
      RegFilePlugin_regFile[writeBack_RegFilePlugin_regFileWrite_payload_address] <= writeBack_RegFilePlugin_regFileWrite_payload_data;
    end
  end

  always @ (posedge clk) begin
    if(_zz_137_) begin
      _zz_191_ <= RegFilePlugin_regFile[execute_RegFilePlugin_regFileReadAddress1];
    end
  end

  always @ (posedge clk) begin
    if(_zz_137_) begin
      _zz_192_ <= RegFilePlugin_regFile[execute_RegFilePlugin_regFileReadAddress2];
    end
  end

  InstructionCache IBusCachedPlugin_cache ( 
    .io_flush_cmd_valid(_zz_175_),
    .io_flush_cmd_ready(IBusCachedPlugin_cache_io_flush_cmd_ready),
    .io_flush_rsp(IBusCachedPlugin_cache_io_flush_rsp),
    .io_cpu_prefetch_isValid(_zz_176_),
    .io_cpu_prefetch_haltIt(IBusCachedPlugin_cache_io_cpu_prefetch_haltIt),
    .io_cpu_prefetch_pc(IBusCachedPlugin_iBusRsp_stages_0_input_payload),
    .io_cpu_fetch_isValid(_zz_177_),
    .io_cpu_fetch_isStuck(_zz_178_),
    .io_cpu_fetch_isRemoved(_zz_179_),
    .io_cpu_fetch_pc(IBusCachedPlugin_iBusRsp_stages_1_input_payload),
    .io_cpu_fetch_data(IBusCachedPlugin_cache_io_cpu_fetch_data),
    .io_cpu_fetch_dataBypassValid(IBusCachedPlugin_s1_tightlyCoupledHit),
    .io_cpu_fetch_dataBypass(_zz_180_),
    .io_cpu_fetch_mmuBus_cmd_isValid(IBusCachedPlugin_cache_io_cpu_fetch_mmuBus_cmd_isValid),
    .io_cpu_fetch_mmuBus_cmd_virtualAddress(IBusCachedPlugin_cache_io_cpu_fetch_mmuBus_cmd_virtualAddress),
    .io_cpu_fetch_mmuBus_cmd_bypassTranslation(IBusCachedPlugin_cache_io_cpu_fetch_mmuBus_cmd_bypassTranslation),
    .io_cpu_fetch_mmuBus_rsp_physicalAddress(_zz_84_),
    .io_cpu_fetch_mmuBus_rsp_isIoAccess(_zz_181_),
    .io_cpu_fetch_mmuBus_rsp_allowRead(_zz_182_),
    .io_cpu_fetch_mmuBus_rsp_allowWrite(_zz_183_),
    .io_cpu_fetch_mmuBus_rsp_allowExecute(_zz_184_),
    .io_cpu_fetch_mmuBus_rsp_allowUser(_zz_185_),
    .io_cpu_fetch_mmuBus_rsp_miss(_zz_186_),
    .io_cpu_fetch_mmuBus_rsp_hit(_zz_187_),
    .io_cpu_fetch_mmuBus_end(IBusCachedPlugin_cache_io_cpu_fetch_mmuBus_end),
    .io_cpu_fetch_physicalAddress(IBusCachedPlugin_cache_io_cpu_fetch_physicalAddress),
    .io_cpu_decode_isValid(_zz_188_),
    .io_cpu_decode_isStuck(_zz_189_),
    .io_cpu_decode_pc(IBusCachedPlugin_iBusRsp_cacheRspArbitration_input_payload),
    .io_cpu_decode_physicalAddress(IBusCachedPlugin_cache_io_cpu_decode_physicalAddress),
    .io_cpu_decode_data(IBusCachedPlugin_cache_io_cpu_decode_data),
    .io_cpu_decode_cacheMiss(IBusCachedPlugin_cache_io_cpu_decode_cacheMiss),
    .io_cpu_decode_error(IBusCachedPlugin_cache_io_cpu_decode_error),
    .io_cpu_decode_mmuMiss(IBusCachedPlugin_cache_io_cpu_decode_mmuMiss),
    .io_cpu_decode_illegalAccess(IBusCachedPlugin_cache_io_cpu_decode_illegalAccess),
    .io_cpu_decode_isUser(_zz_190_),
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
    case(_zz_266_)
      2'b00 : begin
        _zz_193_ = _zz_89_;
      end
      2'b01 : begin
        _zz_193_ = _zz_86_;
      end
      2'b10 : begin
        _zz_193_ = _zz_83_;
      end
      default : begin
        _zz_193_ = _zz_80_;
      end
    endcase
  end

  `ifndef SYNTHESIS
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
    case(_zz_4_)
      `EnvCtrlEnum_defaultEncoding_NONE : _zz_4__string = "NONE  ";
      `EnvCtrlEnum_defaultEncoding_XRET : _zz_4__string = "XRET  ";
      `EnvCtrlEnum_defaultEncoding_ECALL : _zz_4__string = "ECALL ";
      `EnvCtrlEnum_defaultEncoding_EBREAK : _zz_4__string = "EBREAK";
      default : _zz_4__string = "??????";
    endcase
  end
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
    case(_zz_5_)
      `EnvCtrlEnum_defaultEncoding_NONE : _zz_5__string = "NONE  ";
      `EnvCtrlEnum_defaultEncoding_XRET : _zz_5__string = "XRET  ";
      `EnvCtrlEnum_defaultEncoding_ECALL : _zz_5__string = "ECALL ";
      `EnvCtrlEnum_defaultEncoding_EBREAK : _zz_5__string = "EBREAK";
      default : _zz_5__string = "??????";
    endcase
  end
  always @(*) begin
    case(_zz_6_)
      `EnvCtrlEnum_defaultEncoding_NONE : _zz_6__string = "NONE  ";
      `EnvCtrlEnum_defaultEncoding_XRET : _zz_6__string = "XRET  ";
      `EnvCtrlEnum_defaultEncoding_ECALL : _zz_6__string = "ECALL ";
      `EnvCtrlEnum_defaultEncoding_EBREAK : _zz_6__string = "EBREAK";
      default : _zz_6__string = "??????";
    endcase
  end
  always @(*) begin
    case(_zz_7_)
      `EnvCtrlEnum_defaultEncoding_NONE : _zz_7__string = "NONE  ";
      `EnvCtrlEnum_defaultEncoding_XRET : _zz_7__string = "XRET  ";
      `EnvCtrlEnum_defaultEncoding_ECALL : _zz_7__string = "ECALL ";
      `EnvCtrlEnum_defaultEncoding_EBREAK : _zz_7__string = "EBREAK";
      default : _zz_7__string = "??????";
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
    case(_zz_8_)
      `AluBitwiseCtrlEnum_defaultEncoding_XOR_1 : _zz_8__string = "XOR_1";
      `AluBitwiseCtrlEnum_defaultEncoding_OR_1 : _zz_8__string = "OR_1 ";
      `AluBitwiseCtrlEnum_defaultEncoding_AND_1 : _zz_8__string = "AND_1";
      `AluBitwiseCtrlEnum_defaultEncoding_SRC1 : _zz_8__string = "SRC1 ";
      default : _zz_8__string = "?????";
    endcase
  end
  always @(*) begin
    case(_zz_9_)
      `AluBitwiseCtrlEnum_defaultEncoding_XOR_1 : _zz_9__string = "XOR_1";
      `AluBitwiseCtrlEnum_defaultEncoding_OR_1 : _zz_9__string = "OR_1 ";
      `AluBitwiseCtrlEnum_defaultEncoding_AND_1 : _zz_9__string = "AND_1";
      `AluBitwiseCtrlEnum_defaultEncoding_SRC1 : _zz_9__string = "SRC1 ";
      default : _zz_9__string = "?????";
    endcase
  end
  always @(*) begin
    case(_zz_10_)
      `AluBitwiseCtrlEnum_defaultEncoding_XOR_1 : _zz_10__string = "XOR_1";
      `AluBitwiseCtrlEnum_defaultEncoding_OR_1 : _zz_10__string = "OR_1 ";
      `AluBitwiseCtrlEnum_defaultEncoding_AND_1 : _zz_10__string = "AND_1";
      `AluBitwiseCtrlEnum_defaultEncoding_SRC1 : _zz_10__string = "SRC1 ";
      default : _zz_10__string = "?????";
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
      `ShiftCtrlEnum_defaultEncoding_DISABLE_1 : _zz_13__string = "DISABLE_1";
      `ShiftCtrlEnum_defaultEncoding_SLL_1 : _zz_13__string = "SLL_1    ";
      `ShiftCtrlEnum_defaultEncoding_SRL_1 : _zz_13__string = "SRL_1    ";
      `ShiftCtrlEnum_defaultEncoding_SRA_1 : _zz_13__string = "SRA_1    ";
      default : _zz_13__string = "?????????";
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
    case(_zz_14_)
      `AluCtrlEnum_defaultEncoding_ADD_SUB : _zz_14__string = "ADD_SUB ";
      `AluCtrlEnum_defaultEncoding_SLT_SLTU : _zz_14__string = "SLT_SLTU";
      `AluCtrlEnum_defaultEncoding_BITWISE : _zz_14__string = "BITWISE ";
      default : _zz_14__string = "????????";
    endcase
  end
  always @(*) begin
    case(_zz_15_)
      `AluCtrlEnum_defaultEncoding_ADD_SUB : _zz_15__string = "ADD_SUB ";
      `AluCtrlEnum_defaultEncoding_SLT_SLTU : _zz_15__string = "SLT_SLTU";
      `AluCtrlEnum_defaultEncoding_BITWISE : _zz_15__string = "BITWISE ";
      default : _zz_15__string = "????????";
    endcase
  end
  always @(*) begin
    case(_zz_16_)
      `AluCtrlEnum_defaultEncoding_ADD_SUB : _zz_16__string = "ADD_SUB ";
      `AluCtrlEnum_defaultEncoding_SLT_SLTU : _zz_16__string = "SLT_SLTU";
      `AluCtrlEnum_defaultEncoding_BITWISE : _zz_16__string = "BITWISE ";
      default : _zz_16__string = "????????";
    endcase
  end
  always @(*) begin
    case(_zz_17_)
      `BranchCtrlEnum_defaultEncoding_INC : _zz_17__string = "INC ";
      `BranchCtrlEnum_defaultEncoding_B : _zz_17__string = "B   ";
      `BranchCtrlEnum_defaultEncoding_JAL : _zz_17__string = "JAL ";
      `BranchCtrlEnum_defaultEncoding_JALR : _zz_17__string = "JALR";
      default : _zz_17__string = "????";
    endcase
  end
  always @(*) begin
    case(_zz_18_)
      `BranchCtrlEnum_defaultEncoding_INC : _zz_18__string = "INC ";
      `BranchCtrlEnum_defaultEncoding_B : _zz_18__string = "B   ";
      `BranchCtrlEnum_defaultEncoding_JAL : _zz_18__string = "JAL ";
      `BranchCtrlEnum_defaultEncoding_JALR : _zz_18__string = "JALR";
      default : _zz_18__string = "????";
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
    case(_zz_19_)
      `Src1CtrlEnum_defaultEncoding_RS : _zz_19__string = "RS          ";
      `Src1CtrlEnum_defaultEncoding_IMU : _zz_19__string = "IMU         ";
      `Src1CtrlEnum_defaultEncoding_PC_INCREMENT : _zz_19__string = "PC_INCREMENT";
      `Src1CtrlEnum_defaultEncoding_URS1 : _zz_19__string = "URS1        ";
      default : _zz_19__string = "????????????";
    endcase
  end
  always @(*) begin
    case(_zz_20_)
      `Src1CtrlEnum_defaultEncoding_RS : _zz_20__string = "RS          ";
      `Src1CtrlEnum_defaultEncoding_IMU : _zz_20__string = "IMU         ";
      `Src1CtrlEnum_defaultEncoding_PC_INCREMENT : _zz_20__string = "PC_INCREMENT";
      `Src1CtrlEnum_defaultEncoding_URS1 : _zz_20__string = "URS1        ";
      default : _zz_20__string = "????????????";
    endcase
  end
  always @(*) begin
    case(_zz_21_)
      `Src1CtrlEnum_defaultEncoding_RS : _zz_21__string = "RS          ";
      `Src1CtrlEnum_defaultEncoding_IMU : _zz_21__string = "IMU         ";
      `Src1CtrlEnum_defaultEncoding_PC_INCREMENT : _zz_21__string = "PC_INCREMENT";
      `Src1CtrlEnum_defaultEncoding_URS1 : _zz_21__string = "URS1        ";
      default : _zz_21__string = "????????????";
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
    case(_zz_22_)
      `Src2CtrlEnum_defaultEncoding_RS : _zz_22__string = "RS ";
      `Src2CtrlEnum_defaultEncoding_IMI : _zz_22__string = "IMI";
      `Src2CtrlEnum_defaultEncoding_IMS : _zz_22__string = "IMS";
      `Src2CtrlEnum_defaultEncoding_PC : _zz_22__string = "PC ";
      default : _zz_22__string = "???";
    endcase
  end
  always @(*) begin
    case(_zz_23_)
      `Src2CtrlEnum_defaultEncoding_RS : _zz_23__string = "RS ";
      `Src2CtrlEnum_defaultEncoding_IMI : _zz_23__string = "IMI";
      `Src2CtrlEnum_defaultEncoding_IMS : _zz_23__string = "IMS";
      `Src2CtrlEnum_defaultEncoding_PC : _zz_23__string = "PC ";
      default : _zz_23__string = "???";
    endcase
  end
  always @(*) begin
    case(_zz_24_)
      `Src2CtrlEnum_defaultEncoding_RS : _zz_24__string = "RS ";
      `Src2CtrlEnum_defaultEncoding_IMI : _zz_24__string = "IMI";
      `Src2CtrlEnum_defaultEncoding_IMS : _zz_24__string = "IMS";
      `Src2CtrlEnum_defaultEncoding_PC : _zz_24__string = "PC ";
      default : _zz_24__string = "???";
    endcase
  end
  always @(*) begin
    case(memory_ENV_CTRL)
      `EnvCtrlEnum_defaultEncoding_NONE : memory_ENV_CTRL_string = "NONE  ";
      `EnvCtrlEnum_defaultEncoding_XRET : memory_ENV_CTRL_string = "XRET  ";
      `EnvCtrlEnum_defaultEncoding_ECALL : memory_ENV_CTRL_string = "ECALL ";
      `EnvCtrlEnum_defaultEncoding_EBREAK : memory_ENV_CTRL_string = "EBREAK";
      default : memory_ENV_CTRL_string = "??????";
    endcase
  end
  always @(*) begin
    case(_zz_26_)
      `EnvCtrlEnum_defaultEncoding_NONE : _zz_26__string = "NONE  ";
      `EnvCtrlEnum_defaultEncoding_XRET : _zz_26__string = "XRET  ";
      `EnvCtrlEnum_defaultEncoding_ECALL : _zz_26__string = "ECALL ";
      `EnvCtrlEnum_defaultEncoding_EBREAK : _zz_26__string = "EBREAK";
      default : _zz_26__string = "??????";
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
    case(_zz_27_)
      `EnvCtrlEnum_defaultEncoding_NONE : _zz_27__string = "NONE  ";
      `EnvCtrlEnum_defaultEncoding_XRET : _zz_27__string = "XRET  ";
      `EnvCtrlEnum_defaultEncoding_ECALL : _zz_27__string = "ECALL ";
      `EnvCtrlEnum_defaultEncoding_EBREAK : _zz_27__string = "EBREAK";
      default : _zz_27__string = "??????";
    endcase
  end
  always @(*) begin
    case(writeBack_ENV_CTRL)
      `EnvCtrlEnum_defaultEncoding_NONE : writeBack_ENV_CTRL_string = "NONE  ";
      `EnvCtrlEnum_defaultEncoding_XRET : writeBack_ENV_CTRL_string = "XRET  ";
      `EnvCtrlEnum_defaultEncoding_ECALL : writeBack_ENV_CTRL_string = "ECALL ";
      `EnvCtrlEnum_defaultEncoding_EBREAK : writeBack_ENV_CTRL_string = "EBREAK";
      default : writeBack_ENV_CTRL_string = "??????";
    endcase
  end
  always @(*) begin
    case(_zz_30_)
      `EnvCtrlEnum_defaultEncoding_NONE : _zz_30__string = "NONE  ";
      `EnvCtrlEnum_defaultEncoding_XRET : _zz_30__string = "XRET  ";
      `EnvCtrlEnum_defaultEncoding_ECALL : _zz_30__string = "ECALL ";
      `EnvCtrlEnum_defaultEncoding_EBREAK : _zz_30__string = "EBREAK";
      default : _zz_30__string = "??????";
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
    case(_zz_33_)
      `BranchCtrlEnum_defaultEncoding_INC : _zz_33__string = "INC ";
      `BranchCtrlEnum_defaultEncoding_B : _zz_33__string = "B   ";
      `BranchCtrlEnum_defaultEncoding_JAL : _zz_33__string = "JAL ";
      `BranchCtrlEnum_defaultEncoding_JALR : _zz_33__string = "JALR";
      default : _zz_33__string = "????";
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
    case(_zz_37_)
      `ShiftCtrlEnum_defaultEncoding_DISABLE_1 : _zz_37__string = "DISABLE_1";
      `ShiftCtrlEnum_defaultEncoding_SLL_1 : _zz_37__string = "SLL_1    ";
      `ShiftCtrlEnum_defaultEncoding_SRL_1 : _zz_37__string = "SRL_1    ";
      `ShiftCtrlEnum_defaultEncoding_SRA_1 : _zz_37__string = "SRA_1    ";
      default : _zz_37__string = "?????????";
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
    case(_zz_42_)
      `Src2CtrlEnum_defaultEncoding_RS : _zz_42__string = "RS ";
      `Src2CtrlEnum_defaultEncoding_IMI : _zz_42__string = "IMI";
      `Src2CtrlEnum_defaultEncoding_IMS : _zz_42__string = "IMS";
      `Src2CtrlEnum_defaultEncoding_PC : _zz_42__string = "PC ";
      default : _zz_42__string = "???";
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
    case(_zz_44_)
      `Src1CtrlEnum_defaultEncoding_RS : _zz_44__string = "RS          ";
      `Src1CtrlEnum_defaultEncoding_IMU : _zz_44__string = "IMU         ";
      `Src1CtrlEnum_defaultEncoding_PC_INCREMENT : _zz_44__string = "PC_INCREMENT";
      `Src1CtrlEnum_defaultEncoding_URS1 : _zz_44__string = "URS1        ";
      default : _zz_44__string = "????????????";
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
    case(_zz_46_)
      `AluCtrlEnum_defaultEncoding_ADD_SUB : _zz_46__string = "ADD_SUB ";
      `AluCtrlEnum_defaultEncoding_SLT_SLTU : _zz_46__string = "SLT_SLTU";
      `AluCtrlEnum_defaultEncoding_BITWISE : _zz_46__string = "BITWISE ";
      default : _zz_46__string = "????????";
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
    case(_zz_48_)
      `AluBitwiseCtrlEnum_defaultEncoding_XOR_1 : _zz_48__string = "XOR_1";
      `AluBitwiseCtrlEnum_defaultEncoding_OR_1 : _zz_48__string = "OR_1 ";
      `AluBitwiseCtrlEnum_defaultEncoding_AND_1 : _zz_48__string = "AND_1";
      `AluBitwiseCtrlEnum_defaultEncoding_SRC1 : _zz_48__string = "SRC1 ";
      default : _zz_48__string = "?????";
    endcase
  end
  always @(*) begin
    case(_zz_52_)
      `BranchCtrlEnum_defaultEncoding_INC : _zz_52__string = "INC ";
      `BranchCtrlEnum_defaultEncoding_B : _zz_52__string = "B   ";
      `BranchCtrlEnum_defaultEncoding_JAL : _zz_52__string = "JAL ";
      `BranchCtrlEnum_defaultEncoding_JALR : _zz_52__string = "JALR";
      default : _zz_52__string = "????";
    endcase
  end
  always @(*) begin
    case(_zz_53_)
      `AluBitwiseCtrlEnum_defaultEncoding_XOR_1 : _zz_53__string = "XOR_1";
      `AluBitwiseCtrlEnum_defaultEncoding_OR_1 : _zz_53__string = "OR_1 ";
      `AluBitwiseCtrlEnum_defaultEncoding_AND_1 : _zz_53__string = "AND_1";
      `AluBitwiseCtrlEnum_defaultEncoding_SRC1 : _zz_53__string = "SRC1 ";
      default : _zz_53__string = "?????";
    endcase
  end
  always @(*) begin
    case(_zz_56_)
      `Src1CtrlEnum_defaultEncoding_RS : _zz_56__string = "RS          ";
      `Src1CtrlEnum_defaultEncoding_IMU : _zz_56__string = "IMU         ";
      `Src1CtrlEnum_defaultEncoding_PC_INCREMENT : _zz_56__string = "PC_INCREMENT";
      `Src1CtrlEnum_defaultEncoding_URS1 : _zz_56__string = "URS1        ";
      default : _zz_56__string = "????????????";
    endcase
  end
  always @(*) begin
    case(_zz_59_)
      `Src2CtrlEnum_defaultEncoding_RS : _zz_59__string = "RS ";
      `Src2CtrlEnum_defaultEncoding_IMI : _zz_59__string = "IMI";
      `Src2CtrlEnum_defaultEncoding_IMS : _zz_59__string = "IMS";
      `Src2CtrlEnum_defaultEncoding_PC : _zz_59__string = "PC ";
      default : _zz_59__string = "???";
    endcase
  end
  always @(*) begin
    case(_zz_60_)
      `AluCtrlEnum_defaultEncoding_ADD_SUB : _zz_60__string = "ADD_SUB ";
      `AluCtrlEnum_defaultEncoding_SLT_SLTU : _zz_60__string = "SLT_SLTU";
      `AluCtrlEnum_defaultEncoding_BITWISE : _zz_60__string = "BITWISE ";
      default : _zz_60__string = "????????";
    endcase
  end
  always @(*) begin
    case(_zz_62_)
      `EnvCtrlEnum_defaultEncoding_NONE : _zz_62__string = "NONE  ";
      `EnvCtrlEnum_defaultEncoding_XRET : _zz_62__string = "XRET  ";
      `EnvCtrlEnum_defaultEncoding_ECALL : _zz_62__string = "ECALL ";
      `EnvCtrlEnum_defaultEncoding_EBREAK : _zz_62__string = "EBREAK";
      default : _zz_62__string = "??????";
    endcase
  end
  always @(*) begin
    case(_zz_64_)
      `ShiftCtrlEnum_defaultEncoding_DISABLE_1 : _zz_64__string = "DISABLE_1";
      `ShiftCtrlEnum_defaultEncoding_SLL_1 : _zz_64__string = "SLL_1    ";
      `ShiftCtrlEnum_defaultEncoding_SRL_1 : _zz_64__string = "SRL_1    ";
      `ShiftCtrlEnum_defaultEncoding_SRA_1 : _zz_64__string = "SRA_1    ";
      default : _zz_64__string = "?????????";
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
    case(_zz_70_)
      `BranchCtrlEnum_defaultEncoding_INC : _zz_70__string = "INC ";
      `BranchCtrlEnum_defaultEncoding_B : _zz_70__string = "B   ";
      `BranchCtrlEnum_defaultEncoding_JAL : _zz_70__string = "JAL ";
      `BranchCtrlEnum_defaultEncoding_JALR : _zz_70__string = "JALR";
      default : _zz_70__string = "????";
    endcase
  end
  always @(*) begin
    case(_zz_130_)
      `ShiftCtrlEnum_defaultEncoding_DISABLE_1 : _zz_130__string = "DISABLE_1";
      `ShiftCtrlEnum_defaultEncoding_SLL_1 : _zz_130__string = "SLL_1    ";
      `ShiftCtrlEnum_defaultEncoding_SRL_1 : _zz_130__string = "SRL_1    ";
      `ShiftCtrlEnum_defaultEncoding_SRA_1 : _zz_130__string = "SRA_1    ";
      default : _zz_130__string = "?????????";
    endcase
  end
  always @(*) begin
    case(_zz_131_)
      `EnvCtrlEnum_defaultEncoding_NONE : _zz_131__string = "NONE  ";
      `EnvCtrlEnum_defaultEncoding_XRET : _zz_131__string = "XRET  ";
      `EnvCtrlEnum_defaultEncoding_ECALL : _zz_131__string = "ECALL ";
      `EnvCtrlEnum_defaultEncoding_EBREAK : _zz_131__string = "EBREAK";
      default : _zz_131__string = "??????";
    endcase
  end
  always @(*) begin
    case(_zz_132_)
      `AluCtrlEnum_defaultEncoding_ADD_SUB : _zz_132__string = "ADD_SUB ";
      `AluCtrlEnum_defaultEncoding_SLT_SLTU : _zz_132__string = "SLT_SLTU";
      `AluCtrlEnum_defaultEncoding_BITWISE : _zz_132__string = "BITWISE ";
      default : _zz_132__string = "????????";
    endcase
  end
  always @(*) begin
    case(_zz_133_)
      `Src2CtrlEnum_defaultEncoding_RS : _zz_133__string = "RS ";
      `Src2CtrlEnum_defaultEncoding_IMI : _zz_133__string = "IMI";
      `Src2CtrlEnum_defaultEncoding_IMS : _zz_133__string = "IMS";
      `Src2CtrlEnum_defaultEncoding_PC : _zz_133__string = "PC ";
      default : _zz_133__string = "???";
    endcase
  end
  always @(*) begin
    case(_zz_134_)
      `Src1CtrlEnum_defaultEncoding_RS : _zz_134__string = "RS          ";
      `Src1CtrlEnum_defaultEncoding_IMU : _zz_134__string = "IMU         ";
      `Src1CtrlEnum_defaultEncoding_PC_INCREMENT : _zz_134__string = "PC_INCREMENT";
      `Src1CtrlEnum_defaultEncoding_URS1 : _zz_134__string = "URS1        ";
      default : _zz_134__string = "????????????";
    endcase
  end
  always @(*) begin
    case(_zz_135_)
      `AluBitwiseCtrlEnum_defaultEncoding_XOR_1 : _zz_135__string = "XOR_1";
      `AluBitwiseCtrlEnum_defaultEncoding_OR_1 : _zz_135__string = "OR_1 ";
      `AluBitwiseCtrlEnum_defaultEncoding_AND_1 : _zz_135__string = "AND_1";
      `AluBitwiseCtrlEnum_defaultEncoding_SRC1 : _zz_135__string = "SRC1 ";
      default : _zz_135__string = "?????";
    endcase
  end
  always @(*) begin
    case(_zz_136_)
      `BranchCtrlEnum_defaultEncoding_INC : _zz_136__string = "INC ";
      `BranchCtrlEnum_defaultEncoding_B : _zz_136__string = "B   ";
      `BranchCtrlEnum_defaultEncoding_JAL : _zz_136__string = "JAL ";
      `BranchCtrlEnum_defaultEncoding_JALR : _zz_136__string = "JALR";
      default : _zz_136__string = "????";
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
    case(decode_to_execute_ALU_CTRL)
      `AluCtrlEnum_defaultEncoding_ADD_SUB : decode_to_execute_ALU_CTRL_string = "ADD_SUB ";
      `AluCtrlEnum_defaultEncoding_SLT_SLTU : decode_to_execute_ALU_CTRL_string = "SLT_SLTU";
      `AluCtrlEnum_defaultEncoding_BITWISE : decode_to_execute_ALU_CTRL_string = "BITWISE ";
      default : decode_to_execute_ALU_CTRL_string = "????????";
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
  always @(*) begin
    case(execute_to_memory_ENV_CTRL)
      `EnvCtrlEnum_defaultEncoding_NONE : execute_to_memory_ENV_CTRL_string = "NONE  ";
      `EnvCtrlEnum_defaultEncoding_XRET : execute_to_memory_ENV_CTRL_string = "XRET  ";
      `EnvCtrlEnum_defaultEncoding_ECALL : execute_to_memory_ENV_CTRL_string = "ECALL ";
      `EnvCtrlEnum_defaultEncoding_EBREAK : execute_to_memory_ENV_CTRL_string = "EBREAK";
      default : execute_to_memory_ENV_CTRL_string = "??????";
    endcase
  end
  always @(*) begin
    case(memory_to_writeBack_ENV_CTRL)
      `EnvCtrlEnum_defaultEncoding_NONE : memory_to_writeBack_ENV_CTRL_string = "NONE  ";
      `EnvCtrlEnum_defaultEncoding_XRET : memory_to_writeBack_ENV_CTRL_string = "XRET  ";
      `EnvCtrlEnum_defaultEncoding_ECALL : memory_to_writeBack_ENV_CTRL_string = "ECALL ";
      `EnvCtrlEnum_defaultEncoding_EBREAK : memory_to_writeBack_ENV_CTRL_string = "EBREAK";
      default : memory_to_writeBack_ENV_CTRL_string = "??????";
    endcase
  end
  `endif

  assign writeBack_FORMAL_PC_NEXT = memory_to_writeBack_FORMAL_PC_NEXT;
  assign memory_FORMAL_PC_NEXT = execute_to_memory_FORMAL_PC_NEXT;
  assign execute_FORMAL_PC_NEXT = decode_to_execute_FORMAL_PC_NEXT;
  assign decode_FORMAL_PC_NEXT = _zz_73_;
  assign memory_PC = execute_to_memory_PC;
  assign decode_PREDICTION_HAD_BRANCHED2 = _zz_35_;
  assign _zz_1_ = _zz_2_;
  assign _zz_3_ = _zz_4_;
  assign decode_ENV_CTRL = _zz_5_;
  assign _zz_6_ = _zz_7_;
  assign decode_ALU_BITWISE_CTRL = _zz_8_;
  assign _zz_9_ = _zz_10_;
  assign memory_MEMORY_ADDRESS_LOW = execute_to_memory_MEMORY_ADDRESS_LOW;
  assign execute_MEMORY_ADDRESS_LOW = _zz_68_;
  assign writeBack_REGFILE_WRITE_DATA = memory_to_writeBack_REGFILE_WRITE_DATA;
  assign execute_REGFILE_WRITE_DATA = _zz_47_;
  assign decode_SHIFT_CTRL = _zz_11_;
  assign _zz_12_ = _zz_13_;
  assign decode_DO_EBREAK = _zz_25_;
  assign decode_ALU_CTRL = _zz_14_;
  assign _zz_15_ = _zz_16_;
  assign _zz_17_ = _zz_18_;
  assign decode_SRC1_CTRL = _zz_19_;
  assign _zz_20_ = _zz_21_;
  assign decode_CSR_READ_OPCODE = _zz_28_;
  assign decode_SRC_USE_SUB_LESS = _zz_63_;
  assign decode_CSR_WRITE_OPCODE = _zz_29_;
  assign execute_FLUSH_ALL = decode_to_execute_FLUSH_ALL;
  assign decode_FLUSH_ALL = _zz_61_;
  assign decode_SRC_LESS_UNSIGNED = _zz_65_;
  assign writeBack_REGFILE_WRITE_VALID = memory_to_writeBack_REGFILE_WRITE_VALID;
  assign memory_REGFILE_WRITE_VALID = execute_to_memory_REGFILE_WRITE_VALID;
  assign execute_REGFILE_WRITE_VALID = decode_to_execute_REGFILE_WRITE_VALID;
  assign memory_MEMORY_READ_DATA = _zz_67_;
  assign decode_IS_CSR = _zz_55_;
  assign decode_MEMORY_ENABLE = _zz_58_;
  assign decode_SRC2_CTRL = _zz_22_;
  assign _zz_23_ = _zz_24_;
  assign execute_DO_EBREAK = decode_to_execute_DO_EBREAK;
  assign decode_IS_EBREAK = _zz_57_;
  assign execute_CSR_READ_OPCODE = decode_to_execute_CSR_READ_OPCODE;
  assign execute_CSR_WRITE_OPCODE = decode_to_execute_CSR_WRITE_OPCODE;
  assign execute_IS_CSR = decode_to_execute_IS_CSR;
  assign memory_ENV_CTRL = _zz_26_;
  assign execute_ENV_CTRL = _zz_27_;
  assign writeBack_ENV_CTRL = _zz_30_;
  assign execute_BRANCH_CALC = _zz_31_;
  assign execute_BRANCH_DO = _zz_32_;
  assign execute_PC = decode_to_execute_PC;
  assign execute_PREDICTION_HAD_BRANCHED2 = decode_to_execute_PREDICTION_HAD_BRANCHED2;
  assign execute_RS1 = _zz_51_;
  assign execute_BRANCH_COND_RESULT = _zz_34_;
  assign execute_BRANCH_CTRL = _zz_33_;
  always @ (*) begin
    _zz_36_ = execute_REGFILE_WRITE_DATA;
    execute_arbitration_haltItself = 1'b0;
    if(((((execute_arbitration_isValid && execute_MEMORY_ENABLE) && (! dBus_cmd_ready)) && (! execute_ALIGNEMENT_FAULT)) && (! execute_DBusSimplePlugin_cmdSent)))begin
      execute_arbitration_haltItself = 1'b1;
    end
    if(_zz_194_)begin
      _zz_36_ = _zz_145_;
      if(_zz_195_)begin
        if(! execute_LightShifterPlugin_done) begin
          execute_arbitration_haltItself = 1'b1;
        end
      end
    end
    if((execute_arbitration_isValid && execute_IS_CSR))begin
      _zz_36_ = execute_CsrPlugin_readData;
      if(execute_CsrPlugin_blockedBySideEffects)begin
        execute_arbitration_haltItself = 1'b1;
      end
    end
  end

  assign execute_SHIFT_CTRL = _zz_37_;
  assign execute_SRC_LESS_UNSIGNED = decode_to_execute_SRC_LESS_UNSIGNED;
  assign execute_SRC_USE_SUB_LESS = decode_to_execute_SRC_USE_SUB_LESS;
  assign _zz_41_ = execute_PC;
  assign execute_SRC2_CTRL = _zz_42_;
  assign execute_SRC1_CTRL = _zz_44_;
  assign execute_SRC_ADD_SUB = _zz_40_;
  assign execute_SRC_LESS = _zz_38_;
  assign execute_ALU_CTRL = _zz_46_;
  assign execute_SRC2 = _zz_43_;
  assign execute_SRC1 = _zz_45_;
  assign execute_ALU_BITWISE_CTRL = _zz_48_;
  always @ (*) begin
    _zz_49_ = 1'b0;
    if(writeBack_RegFilePlugin_regFileWrite_valid)begin
      _zz_49_ = 1'b1;
    end
  end

  always @ (*) begin
    decode_REGFILE_WRITE_VALID = _zz_54_;
    if((decode_INSTRUCTION[11 : 7] == (5'b00000)))begin
      decode_REGFILE_WRITE_VALID = 1'b0;
    end
  end

  always @ (*) begin
    _zz_66_ = writeBack_REGFILE_WRITE_DATA;
    if((writeBack_arbitration_isValid && writeBack_MEMORY_ENABLE))begin
      _zz_66_ = writeBack_DBusSimplePlugin_rspFormated;
    end
  end

  assign writeBack_MEMORY_ENABLE = memory_to_writeBack_MEMORY_ENABLE;
  assign writeBack_MEMORY_ADDRESS_LOW = memory_to_writeBack_MEMORY_ADDRESS_LOW;
  assign writeBack_MEMORY_READ_DATA = memory_to_writeBack_MEMORY_READ_DATA;
  assign memory_REGFILE_WRITE_DATA = execute_to_memory_REGFILE_WRITE_DATA;
  assign memory_ALIGNEMENT_FAULT = execute_to_memory_ALIGNEMENT_FAULT;
  assign memory_INSTRUCTION = execute_to_memory_INSTRUCTION;
  assign memory_MEMORY_ENABLE = execute_to_memory_MEMORY_ENABLE;
  assign execute_RS2 = _zz_50_;
  assign execute_SRC_ADD = _zz_39_;
  assign execute_INSTRUCTION = decode_to_execute_INSTRUCTION;
  assign execute_ALIGNEMENT_FAULT = _zz_69_;
  assign execute_MEMORY_ENABLE = decode_to_execute_MEMORY_ENABLE;
  assign memory_FLUSH_ALL = execute_to_memory_FLUSH_ALL;
  always @ (*) begin
    IBusCachedPlugin_rsp_issueDetected = 1'b0;
    IBusCachedPlugin_rsp_redoFetch = 1'b0;
    if(((_zz_188_ && IBusCachedPlugin_cache_io_cpu_decode_cacheMiss) && (! 1'b0)))begin
      IBusCachedPlugin_rsp_issueDetected = 1'b1;
      IBusCachedPlugin_rsp_redoFetch = IBusCachedPlugin_iBusRsp_readyForError;
    end
  end

  assign decode_BRANCH_CTRL = _zz_70_;
  always @ (*) begin
    _zz_71_ = execute_FORMAL_PC_NEXT;
    if(_zz_85_)begin
      _zz_71_ = _zz_86_;
    end
  end

  always @ (*) begin
    _zz_72_ = decode_FORMAL_PC_NEXT;
    if(_zz_79_)begin
      _zz_72_ = _zz_80_;
    end
    if(_zz_82_)begin
      _zz_72_ = _zz_83_;
    end
  end

  assign writeBack_PC = memory_to_writeBack_PC;
  assign writeBack_INSTRUCTION = memory_to_writeBack_INSTRUCTION;
  assign decode_PC = _zz_75_;
  always @ (*) begin
    decode_INSTRUCTION = _zz_74_;
    if((_zz_170_ != (3'b000)))begin
      decode_INSTRUCTION = _zz_171_;
    end
  end

  always @ (*) begin
    decode_arbitration_haltItself = 1'b0;
    decode_arbitration_isValid = (IBusCachedPlugin_iBusRsp_decodeInput_valid && (! IBusCachedPlugin_injector_decodeRemoved));
    _zz_95_ = 1'b0;
    case(_zz_170_)
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
        _zz_95_ = 1'b1;
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
    if(({(memory_arbitration_isValid && (memory_ENV_CTRL == `EnvCtrlEnum_defaultEncoding_XRET)),(execute_arbitration_isValid && (execute_ENV_CTRL == `EnvCtrlEnum_defaultEncoding_XRET))} != (2'b00)))begin
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
    if(_zz_85_)begin
      decode_arbitration_flushAll = 1'b1;
    end
    CsrPlugin_exceptionPortCtrl_exceptionValids_execute = CsrPlugin_exceptionPortCtrl_exceptionValidsRegs_execute;
    if(execute_exception_agregat_valid)begin
      decode_arbitration_flushAll = 1'b1;
      execute_arbitration_removeIt = 1'b1;
      CsrPlugin_exceptionPortCtrl_exceptionValids_execute = 1'b1;
    end
    if(execute_arbitration_isFlushed)begin
      CsrPlugin_exceptionPortCtrl_exceptionValids_execute = 1'b0;
    end
    if(execute_arbitration_isFlushed)begin
      execute_arbitration_removeIt = 1'b1;
    end
  end

  assign decode_arbitration_redoIt = 1'b0;
  always @ (*) begin
    execute_arbitration_haltByOther = 1'b0;
    _zz_76_ = 1'b0;
    _zz_77_ = 1'b0;
    if(({CsrPlugin_exceptionPortCtrl_exceptionValidsRegs_writeBack,{CsrPlugin_exceptionPortCtrl_exceptionValidsRegs_memory,{CsrPlugin_exceptionPortCtrl_exceptionValidsRegs_execute,CsrPlugin_exceptionPortCtrl_exceptionValidsRegs_decode}}} != (4'b0000)))begin
      _zz_76_ = 1'b1;
    end
    if(_zz_196_)begin
      execute_arbitration_haltByOther = 1'b1;
      if(_zz_197_)begin
        _zz_77_ = 1'b1;
        _zz_76_ = 1'b1;
      end
    end
    if(DebugPlugin_haltIt)begin
      _zz_76_ = 1'b1;
    end
    if(_zz_198_)begin
      _zz_76_ = 1'b1;
    end
  end

  always @ (*) begin
    execute_arbitration_flushAll = 1'b0;
    if(memory_exception_agregat_valid)begin
      execute_arbitration_flushAll = 1'b1;
    end
    if(_zz_196_)begin
      if(_zz_197_)begin
        execute_arbitration_flushAll = 1'b1;
      end
    end
  end

  assign execute_arbitration_redoIt = 1'b0;
  always @ (*) begin
    memory_arbitration_haltItself = 1'b0;
    _zz_175_ = 1'b0;
    if((memory_arbitration_isValid && memory_FLUSH_ALL))begin
      _zz_175_ = 1'b1;
      if((! IBusCachedPlugin_cache_io_flush_cmd_ready))begin
        memory_arbitration_haltItself = 1'b1;
      end
    end
    if((((memory_arbitration_isValid && memory_MEMORY_ENABLE) && (! memory_INSTRUCTION[5])) && (! dBus_rsp_ready)))begin
      memory_arbitration_haltItself = 1'b1;
    end
  end

  assign memory_arbitration_haltByOther = 1'b0;
  always @ (*) begin
    memory_arbitration_removeIt = 1'b0;
    if(memory_exception_agregat_valid)begin
      memory_arbitration_removeIt = 1'b1;
    end
    if(memory_arbitration_isFlushed)begin
      memory_arbitration_removeIt = 1'b1;
    end
  end

  always @ (*) begin
    memory_arbitration_flushAll = 1'b0;
    _zz_88_ = 1'b0;
    _zz_89_ = (32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx);
    if(_zz_199_)begin
      _zz_88_ = 1'b1;
      _zz_89_ = {CsrPlugin_mtvec_base,(2'b00)};
      memory_arbitration_flushAll = 1'b1;
    end
    if(_zz_200_)begin
      _zz_89_ = CsrPlugin_mepc;
      _zz_88_ = 1'b1;
      memory_arbitration_flushAll = 1'b1;
    end
  end

  assign memory_arbitration_redoIt = 1'b0;
  assign writeBack_arbitration_haltItself = 1'b0;
  assign writeBack_arbitration_haltByOther = 1'b0;
  always @ (*) begin
    writeBack_arbitration_removeIt = 1'b0;
    if(writeBack_arbitration_isFlushed)begin
      writeBack_arbitration_removeIt = 1'b1;
    end
  end

  assign writeBack_arbitration_flushAll = 1'b0;
  assign writeBack_arbitration_redoIt = 1'b0;
  always @ (*) begin
    _zz_78_ = 1'b0;
    if((IBusCachedPlugin_iBusRsp_stages_1_input_valid || IBusCachedPlugin_iBusRsp_cacheRspArbitration_input_valid))begin
      _zz_78_ = 1'b1;
    end
  end

  always @ (*) begin
    _zz_92_ = 1'b1;
    if((DebugPlugin_haltIt || DebugPlugin_stepIt))begin
      _zz_92_ = 1'b0;
    end
  end

  always @ (*) begin
    _zz_93_ = 1'b1;
    if(DebugPlugin_haltIt)begin
      _zz_93_ = 1'b0;
    end
  end

  assign IBusCachedPlugin_jump_pcLoad_valid = ({_zz_88_,{_zz_85_,{_zz_82_,_zz_79_}}} != (4'b0000));
  assign _zz_96_ = {_zz_79_,{_zz_82_,{_zz_85_,_zz_88_}}};
  assign _zz_97_ = (_zz_96_ & (~ _zz_208_));
  assign _zz_98_ = _zz_97_[3];
  assign _zz_99_ = (_zz_97_[1] || _zz_98_);
  assign _zz_100_ = (_zz_97_[2] || _zz_98_);
  assign IBusCachedPlugin_jump_pcLoad_payload = _zz_193_;
  assign _zz_101_ = (! _zz_76_);
  assign IBusCachedPlugin_fetchPc_output_valid = (IBusCachedPlugin_fetchPc_preOutput_valid && _zz_101_);
  assign IBusCachedPlugin_fetchPc_preOutput_ready = (IBusCachedPlugin_fetchPc_output_ready && _zz_101_);
  assign IBusCachedPlugin_fetchPc_output_payload = IBusCachedPlugin_fetchPc_preOutput_payload;
  always @ (*) begin
    IBusCachedPlugin_fetchPc_propagatePc = 1'b0;
    if((IBusCachedPlugin_iBusRsp_stages_1_input_valid && IBusCachedPlugin_iBusRsp_stages_1_input_ready))begin
      IBusCachedPlugin_fetchPc_propagatePc = 1'b1;
    end
  end

  always @ (*) begin
    IBusCachedPlugin_fetchPc_pc = (IBusCachedPlugin_fetchPc_pcReg + _zz_210_);
    IBusCachedPlugin_fetchPc_samplePcNext = 1'b0;
    if(IBusCachedPlugin_fetchPc_propagatePc)begin
      IBusCachedPlugin_fetchPc_samplePcNext = 1'b1;
    end
    if(IBusCachedPlugin_jump_pcLoad_valid)begin
      IBusCachedPlugin_fetchPc_samplePcNext = 1'b1;
      IBusCachedPlugin_fetchPc_pc = IBusCachedPlugin_jump_pcLoad_payload;
    end
    if(_zz_201_)begin
      IBusCachedPlugin_fetchPc_samplePcNext = 1'b1;
    end
    IBusCachedPlugin_fetchPc_pc[0] = 1'b0;
    IBusCachedPlugin_fetchPc_pc[1] = 1'b0;
  end

  assign IBusCachedPlugin_fetchPc_preOutput_valid = _zz_102_;
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

  assign _zz_103_ = (! IBusCachedPlugin_iBusRsp_stages_0_halt);
  assign IBusCachedPlugin_iBusRsp_stages_0_input_ready = (IBusCachedPlugin_iBusRsp_stages_0_output_ready && _zz_103_);
  assign IBusCachedPlugin_iBusRsp_stages_0_output_valid = (IBusCachedPlugin_iBusRsp_stages_0_input_valid && _zz_103_);
  assign IBusCachedPlugin_iBusRsp_stages_0_output_payload = IBusCachedPlugin_iBusRsp_stages_0_input_payload;
  always @ (*) begin
    IBusCachedPlugin_iBusRsp_stages_1_halt = 1'b0;
    if(((IBusCachedPlugin_cache_io_cpu_fetch_mmuBus_cmd_isValid && (! 1'b1)) && (! 1'b0)))begin
      IBusCachedPlugin_iBusRsp_stages_1_halt = 1'b1;
    end
  end

  assign _zz_104_ = (! IBusCachedPlugin_iBusRsp_stages_1_halt);
  assign IBusCachedPlugin_iBusRsp_stages_1_input_ready = (IBusCachedPlugin_iBusRsp_stages_1_output_ready && _zz_104_);
  assign IBusCachedPlugin_iBusRsp_stages_1_output_valid = (IBusCachedPlugin_iBusRsp_stages_1_input_valid && _zz_104_);
  assign IBusCachedPlugin_iBusRsp_stages_1_output_payload = IBusCachedPlugin_iBusRsp_stages_1_input_payload;
  always @ (*) begin
    IBusCachedPlugin_iBusRsp_cacheRspArbitration_halt = 1'b0;
    if((IBusCachedPlugin_rsp_issueDetected || IBusCachedPlugin_rsp_iBusRspOutputHalt))begin
      IBusCachedPlugin_iBusRsp_cacheRspArbitration_halt = 1'b1;
    end
  end

  assign _zz_105_ = (! IBusCachedPlugin_iBusRsp_cacheRspArbitration_halt);
  assign IBusCachedPlugin_iBusRsp_cacheRspArbitration_input_ready = (IBusCachedPlugin_iBusRsp_cacheRspArbitration_output_ready && _zz_105_);
  assign IBusCachedPlugin_iBusRsp_cacheRspArbitration_output_valid = (IBusCachedPlugin_iBusRsp_cacheRspArbitration_input_valid && _zz_105_);
  assign IBusCachedPlugin_iBusRsp_cacheRspArbitration_output_payload = IBusCachedPlugin_iBusRsp_cacheRspArbitration_input_payload;
  assign IBusCachedPlugin_iBusRsp_stages_0_output_ready = _zz_106_;
  assign _zz_106_ = ((1'b0 && (! _zz_107_)) || IBusCachedPlugin_iBusRsp_stages_1_input_ready);
  assign _zz_107_ = _zz_108_;
  assign IBusCachedPlugin_iBusRsp_stages_1_input_valid = _zz_107_;
  assign IBusCachedPlugin_iBusRsp_stages_1_input_payload = IBusCachedPlugin_fetchPc_pcReg;
  assign IBusCachedPlugin_iBusRsp_stages_1_output_ready = ((1'b0 && (! _zz_109_)) || IBusCachedPlugin_iBusRsp_cacheRspArbitration_input_ready);
  assign _zz_109_ = _zz_110_;
  assign IBusCachedPlugin_iBusRsp_cacheRspArbitration_input_valid = _zz_109_;
  assign IBusCachedPlugin_iBusRsp_cacheRspArbitration_input_payload = _zz_111_;
  assign IBusCachedPlugin_iBusRsp_readyForError = 1'b1;
  assign IBusCachedPlugin_iBusRsp_decodeInput_ready = (! decode_arbitration_isStuck);
  assign _zz_75_ = IBusCachedPlugin_iBusRsp_decodeInput_payload_pc;
  assign _zz_74_ = IBusCachedPlugin_iBusRsp_decodeInput_payload_rsp_inst;
  assign _zz_73_ = (decode_PC + (32'b00000000000000000000000000000100));
  assign _zz_112_ = _zz_211_[11];
  always @ (*) begin
    _zz_113_[18] = _zz_112_;
    _zz_113_[17] = _zz_112_;
    _zz_113_[16] = _zz_112_;
    _zz_113_[15] = _zz_112_;
    _zz_113_[14] = _zz_112_;
    _zz_113_[13] = _zz_112_;
    _zz_113_[12] = _zz_112_;
    _zz_113_[11] = _zz_112_;
    _zz_113_[10] = _zz_112_;
    _zz_113_[9] = _zz_112_;
    _zz_113_[8] = _zz_112_;
    _zz_113_[7] = _zz_112_;
    _zz_113_[6] = _zz_112_;
    _zz_113_[5] = _zz_112_;
    _zz_113_[4] = _zz_112_;
    _zz_113_[3] = _zz_112_;
    _zz_113_[2] = _zz_112_;
    _zz_113_[1] = _zz_112_;
    _zz_113_[0] = _zz_112_;
  end

  assign _zz_81_ = ((decode_BRANCH_CTRL == `BranchCtrlEnum_defaultEncoding_JAL) || ((decode_BRANCH_CTRL == `BranchCtrlEnum_defaultEncoding_B) && _zz_212_[31]));
  assign _zz_79_ = (_zz_81_ && decode_arbitration_isFiring);
  assign _zz_114_ = _zz_213_[19];
  always @ (*) begin
    _zz_115_[10] = _zz_114_;
    _zz_115_[9] = _zz_114_;
    _zz_115_[8] = _zz_114_;
    _zz_115_[7] = _zz_114_;
    _zz_115_[6] = _zz_114_;
    _zz_115_[5] = _zz_114_;
    _zz_115_[4] = _zz_114_;
    _zz_115_[3] = _zz_114_;
    _zz_115_[2] = _zz_114_;
    _zz_115_[1] = _zz_114_;
    _zz_115_[0] = _zz_114_;
  end

  assign _zz_116_ = _zz_214_[11];
  always @ (*) begin
    _zz_117_[18] = _zz_116_;
    _zz_117_[17] = _zz_116_;
    _zz_117_[16] = _zz_116_;
    _zz_117_[15] = _zz_116_;
    _zz_117_[14] = _zz_116_;
    _zz_117_[13] = _zz_116_;
    _zz_117_[12] = _zz_116_;
    _zz_117_[11] = _zz_116_;
    _zz_117_[10] = _zz_116_;
    _zz_117_[9] = _zz_116_;
    _zz_117_[8] = _zz_116_;
    _zz_117_[7] = _zz_116_;
    _zz_117_[6] = _zz_116_;
    _zz_117_[5] = _zz_116_;
    _zz_117_[4] = _zz_116_;
    _zz_117_[3] = _zz_116_;
    _zz_117_[2] = _zz_116_;
    _zz_117_[1] = _zz_116_;
    _zz_117_[0] = _zz_116_;
  end

  assign _zz_80_ = (decode_PC + ((decode_BRANCH_CTRL == `BranchCtrlEnum_defaultEncoding_JAL) ? {{_zz_115_,{{{_zz_267_,_zz_268_},_zz_269_},decode_INSTRUCTION[30 : 21]}},1'b0} : {{_zz_117_,{{{_zz_270_,_zz_271_},decode_INSTRUCTION[30 : 25]},decode_INSTRUCTION[11 : 8]}},1'b0}));
  assign iBus_cmd_valid = IBusCachedPlugin_cache_io_mem_cmd_valid;
  always @ (*) begin
    iBus_cmd_payload_address = IBusCachedPlugin_cache_io_mem_cmd_payload_address;
    iBus_cmd_payload_address = IBusCachedPlugin_cache_io_mem_cmd_payload_address;
  end

  assign iBus_cmd_payload_size = IBusCachedPlugin_cache_io_mem_cmd_payload_size;
  assign IBusCachedPlugin_s0_tightlyCoupledHit = 1'b0;
  assign _zz_176_ = (IBusCachedPlugin_iBusRsp_stages_0_input_valid && (! IBusCachedPlugin_s0_tightlyCoupledHit));
  assign _zz_179_ = (IBusCachedPlugin_jump_pcLoad_valid || _zz_77_);
  assign _zz_180_ = (32'b00000000000000000000000000000000);
  assign _zz_177_ = (IBusCachedPlugin_iBusRsp_stages_1_input_valid && (! IBusCachedPlugin_s1_tightlyCoupledHit));
  assign _zz_178_ = (! IBusCachedPlugin_iBusRsp_stages_1_input_ready);
  assign _zz_188_ = (IBusCachedPlugin_iBusRsp_cacheRspArbitration_input_valid && (! IBusCachedPlugin_s2_tightlyCoupledHit));
  assign _zz_189_ = (! IBusCachedPlugin_iBusRsp_cacheRspArbitration_input_ready);
  assign _zz_190_ = (CsrPlugin_privilege == (2'b00));
  assign IBusCachedPlugin_rsp_iBusRspOutputHalt = 1'b0;
  assign _zz_82_ = IBusCachedPlugin_rsp_redoFetch;
  assign _zz_83_ = IBusCachedPlugin_iBusRsp_cacheRspArbitration_input_payload;
  assign IBusCachedPlugin_iBusRsp_decodeInput_valid = IBusCachedPlugin_iBusRsp_cacheRspArbitration_output_valid;
  assign IBusCachedPlugin_iBusRsp_cacheRspArbitration_output_ready = IBusCachedPlugin_iBusRsp_decodeInput_ready;
  assign IBusCachedPlugin_iBusRsp_decodeInput_payload_rsp_inst = IBusCachedPlugin_cache_io_cpu_decode_data;
  assign IBusCachedPlugin_iBusRsp_decodeInput_payload_pc = IBusCachedPlugin_iBusRsp_cacheRspArbitration_output_payload;
  assign _zz_181_ = _zz_84_[31];
  assign _zz_182_ = 1'b1;
  assign _zz_183_ = 1'b1;
  assign _zz_184_ = 1'b1;
  assign _zz_185_ = 1'b1;
  assign _zz_186_ = 1'b0;
  assign _zz_187_ = 1'b1;
  assign execute_DBusSimplePlugin_cmdSent = 1'b0;
  assign _zz_69_ = (((dBus_cmd_payload_size == (2'b10)) && (dBus_cmd_payload_address[1 : 0] != (2'b00))) || ((dBus_cmd_payload_size == (2'b01)) && (dBus_cmd_payload_address[0 : 0] != (1'b0))));
  assign dBus_cmd_valid = (((((execute_arbitration_isValid && execute_MEMORY_ENABLE) && (! execute_arbitration_isStuckByOthers)) && (! execute_arbitration_isFlushed)) && (! execute_ALIGNEMENT_FAULT)) && (! execute_DBusSimplePlugin_cmdSent));
  assign dBus_cmd_payload_wr = execute_INSTRUCTION[5];
  assign dBus_cmd_payload_address = execute_SRC_ADD;
  assign dBus_cmd_payload_size = execute_INSTRUCTION[13 : 12];
  always @ (*) begin
    case(dBus_cmd_payload_size)
      2'b00 : begin
        _zz_118_ = {{{execute_RS2[7 : 0],execute_RS2[7 : 0]},execute_RS2[7 : 0]},execute_RS2[7 : 0]};
      end
      2'b01 : begin
        _zz_118_ = {execute_RS2[15 : 0],execute_RS2[15 : 0]};
      end
      default : begin
        _zz_118_ = execute_RS2[31 : 0];
      end
    endcase
  end

  assign dBus_cmd_payload_data = _zz_118_;
  assign _zz_68_ = dBus_cmd_payload_address[1 : 0];
  always @ (*) begin
    case(dBus_cmd_payload_size)
      2'b00 : begin
        _zz_119_ = (4'b0001);
      end
      2'b01 : begin
        _zz_119_ = (4'b0011);
      end
      default : begin
        _zz_119_ = (4'b1111);
      end
    endcase
  end

  assign execute_DBusSimplePlugin_formalMask = (_zz_119_ <<< dBus_cmd_payload_address[1 : 0]);
  assign _zz_67_ = dBus_rsp_data;
  assign memory_exception_agregat_payload_code = {1'd0, _zz_215_};
  always @ (*) begin
    memory_exception_agregat_valid = memory_ALIGNEMENT_FAULT;
    if((! ((memory_arbitration_isValid && memory_MEMORY_ENABLE) && 1'b1)))begin
      memory_exception_agregat_valid = 1'b0;
    end
  end

  assign memory_exception_agregat_payload_badAddr = memory_REGFILE_WRITE_DATA;
  always @ (*) begin
    writeBack_DBusSimplePlugin_rspShifted = writeBack_MEMORY_READ_DATA;
    case(writeBack_MEMORY_ADDRESS_LOW)
      2'b01 : begin
        writeBack_DBusSimplePlugin_rspShifted[7 : 0] = writeBack_MEMORY_READ_DATA[15 : 8];
      end
      2'b10 : begin
        writeBack_DBusSimplePlugin_rspShifted[15 : 0] = writeBack_MEMORY_READ_DATA[31 : 16];
      end
      2'b11 : begin
        writeBack_DBusSimplePlugin_rspShifted[7 : 0] = writeBack_MEMORY_READ_DATA[31 : 24];
      end
      default : begin
      end
    endcase
  end

  assign _zz_120_ = (writeBack_DBusSimplePlugin_rspShifted[7] && (! writeBack_INSTRUCTION[14]));
  always @ (*) begin
    _zz_121_[31] = _zz_120_;
    _zz_121_[30] = _zz_120_;
    _zz_121_[29] = _zz_120_;
    _zz_121_[28] = _zz_120_;
    _zz_121_[27] = _zz_120_;
    _zz_121_[26] = _zz_120_;
    _zz_121_[25] = _zz_120_;
    _zz_121_[24] = _zz_120_;
    _zz_121_[23] = _zz_120_;
    _zz_121_[22] = _zz_120_;
    _zz_121_[21] = _zz_120_;
    _zz_121_[20] = _zz_120_;
    _zz_121_[19] = _zz_120_;
    _zz_121_[18] = _zz_120_;
    _zz_121_[17] = _zz_120_;
    _zz_121_[16] = _zz_120_;
    _zz_121_[15] = _zz_120_;
    _zz_121_[14] = _zz_120_;
    _zz_121_[13] = _zz_120_;
    _zz_121_[12] = _zz_120_;
    _zz_121_[11] = _zz_120_;
    _zz_121_[10] = _zz_120_;
    _zz_121_[9] = _zz_120_;
    _zz_121_[8] = _zz_120_;
    _zz_121_[7 : 0] = writeBack_DBusSimplePlugin_rspShifted[7 : 0];
  end

  assign _zz_122_ = (writeBack_DBusSimplePlugin_rspShifted[15] && (! writeBack_INSTRUCTION[14]));
  always @ (*) begin
    _zz_123_[31] = _zz_122_;
    _zz_123_[30] = _zz_122_;
    _zz_123_[29] = _zz_122_;
    _zz_123_[28] = _zz_122_;
    _zz_123_[27] = _zz_122_;
    _zz_123_[26] = _zz_122_;
    _zz_123_[25] = _zz_122_;
    _zz_123_[24] = _zz_122_;
    _zz_123_[23] = _zz_122_;
    _zz_123_[22] = _zz_122_;
    _zz_123_[21] = _zz_122_;
    _zz_123_[20] = _zz_122_;
    _zz_123_[19] = _zz_122_;
    _zz_123_[18] = _zz_122_;
    _zz_123_[17] = _zz_122_;
    _zz_123_[16] = _zz_122_;
    _zz_123_[15 : 0] = writeBack_DBusSimplePlugin_rspShifted[15 : 0];
  end

  always @ (*) begin
    case(_zz_205_)
      2'b00 : begin
        writeBack_DBusSimplePlugin_rspFormated = _zz_121_;
      end
      2'b01 : begin
        writeBack_DBusSimplePlugin_rspFormated = _zz_123_;
      end
      default : begin
        writeBack_DBusSimplePlugin_rspFormated = writeBack_DBusSimplePlugin_rspShifted;
      end
    endcase
  end

  assign _zz_84_ = IBusCachedPlugin_cache_io_cpu_fetch_mmuBus_cmd_virtualAddress;
  assign _zz_125_ = ((decode_INSTRUCTION & (32'b00010000000100000011000001010000)) == (32'b00000000000100000000000001010000));
  assign _zz_126_ = ((decode_INSTRUCTION & (32'b00000000000000000000000000000100)) == (32'b00000000000000000000000000000100));
  assign _zz_127_ = ((decode_INSTRUCTION & (32'b00000000000000000100000001010000)) == (32'b00000000000000000100000001010000));
  assign _zz_128_ = ((decode_INSTRUCTION & (32'b00000000000000000000000001010000)) == (32'b00000000000000000000000000010000));
  assign _zz_129_ = ((decode_INSTRUCTION & (32'b00000000000000000000000001001000)) == (32'b00000000000000000000000001001000));
  assign _zz_124_ = {(((decode_INSTRUCTION & _zz_272_) == (32'b00000000000000000000000000010000)) != (1'b0)),{({_zz_129_,_zz_273_} != (2'b00)),{(_zz_274_ != (1'b0)),{(_zz_275_ != _zz_276_),{_zz_277_,{_zz_278_,_zz_279_}}}}}};
  assign _zz_65_ = _zz_216_[0];
  assign _zz_130_ = _zz_124_[2 : 1];
  assign _zz_64_ = _zz_130_;
  assign _zz_63_ = _zz_217_[0];
  assign _zz_131_ = _zz_124_[5 : 4];
  assign _zz_62_ = _zz_131_;
  assign _zz_61_ = _zz_218_[0];
  assign _zz_132_ = _zz_124_[8 : 7];
  assign _zz_60_ = _zz_132_;
  assign _zz_133_ = _zz_124_[10 : 9];
  assign _zz_59_ = _zz_133_;
  assign _zz_58_ = _zz_219_[0];
  assign _zz_57_ = _zz_220_[0];
  assign _zz_134_ = _zz_124_[15 : 14];
  assign _zz_56_ = _zz_134_;
  assign _zz_55_ = _zz_221_[0];
  assign _zz_54_ = _zz_222_[0];
  assign _zz_135_ = _zz_124_[22 : 21];
  assign _zz_53_ = _zz_135_;
  assign _zz_136_ = _zz_124_[24 : 23];
  assign _zz_52_ = _zz_136_;
  assign execute_RegFilePlugin_regFileReadAddress1 = decode_INSTRUCTION[19 : 15];
  assign execute_RegFilePlugin_regFileReadAddress2 = decode_INSTRUCTION[24 : 20];
  assign _zz_137_ = (! execute_arbitration_isStuck);
  assign execute_RegFilePlugin_rs1Data = _zz_191_;
  assign execute_RegFilePlugin_rs2Data = _zz_192_;
  assign _zz_51_ = execute_RegFilePlugin_rs1Data;
  assign _zz_50_ = execute_RegFilePlugin_rs2Data;
  assign writeBack_RegFilePlugin_regFileWrite_valid = (writeBack_REGFILE_WRITE_VALID && writeBack_arbitration_isFiring);
  assign writeBack_RegFilePlugin_regFileWrite_payload_address = writeBack_INSTRUCTION[11 : 7];
  assign writeBack_RegFilePlugin_regFileWrite_payload_data = _zz_66_;
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
        _zz_138_ = execute_IntAluPlugin_bitwise;
      end
      `AluCtrlEnum_defaultEncoding_SLT_SLTU : begin
        _zz_138_ = {31'd0, _zz_223_};
      end
      default : begin
        _zz_138_ = execute_SRC_ADD_SUB;
      end
    endcase
  end

  assign _zz_47_ = _zz_138_;
  always @ (*) begin
    case(execute_SRC1_CTRL)
      `Src1CtrlEnum_defaultEncoding_RS : begin
        _zz_139_ = execute_RS1;
      end
      `Src1CtrlEnum_defaultEncoding_PC_INCREMENT : begin
        _zz_139_ = {29'd0, _zz_224_};
      end
      `Src1CtrlEnum_defaultEncoding_IMU : begin
        _zz_139_ = {execute_INSTRUCTION[31 : 12],(12'b000000000000)};
      end
      default : begin
        _zz_139_ = {27'd0, _zz_225_};
      end
    endcase
  end

  assign _zz_45_ = _zz_139_;
  assign _zz_140_ = _zz_226_[11];
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

  assign _zz_142_ = _zz_227_[11];
  always @ (*) begin
    _zz_143_[19] = _zz_142_;
    _zz_143_[18] = _zz_142_;
    _zz_143_[17] = _zz_142_;
    _zz_143_[16] = _zz_142_;
    _zz_143_[15] = _zz_142_;
    _zz_143_[14] = _zz_142_;
    _zz_143_[13] = _zz_142_;
    _zz_143_[12] = _zz_142_;
    _zz_143_[11] = _zz_142_;
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

  always @ (*) begin
    case(execute_SRC2_CTRL)
      `Src2CtrlEnum_defaultEncoding_RS : begin
        _zz_144_ = execute_RS2;
      end
      `Src2CtrlEnum_defaultEncoding_IMI : begin
        _zz_144_ = {_zz_141_,execute_INSTRUCTION[31 : 20]};
      end
      `Src2CtrlEnum_defaultEncoding_IMS : begin
        _zz_144_ = {_zz_143_,{execute_INSTRUCTION[31 : 25],execute_INSTRUCTION[11 : 7]}};
      end
      default : begin
        _zz_144_ = _zz_41_;
      end
    endcase
  end

  assign _zz_43_ = _zz_144_;
  assign execute_SrcPlugin_addSub = _zz_228_;
  assign execute_SrcPlugin_less = ((execute_SRC1[31] == execute_SRC2[31]) ? execute_SrcPlugin_addSub[31] : (execute_SRC_LESS_UNSIGNED ? execute_SRC2[31] : execute_SRC1[31]));
  assign _zz_40_ = execute_SrcPlugin_addSub;
  assign _zz_39_ = execute_SrcPlugin_addSub;
  assign _zz_38_ = execute_SrcPlugin_less;
  assign execute_LightShifterPlugin_isShift = (execute_SHIFT_CTRL != `ShiftCtrlEnum_defaultEncoding_DISABLE_1);
  assign execute_LightShifterPlugin_amplitude = (execute_LightShifterPlugin_isActive ? execute_LightShifterPlugin_amplitudeReg : execute_SRC2[4 : 0]);
  assign execute_LightShifterPlugin_shiftInput = (execute_LightShifterPlugin_isActive ? memory_REGFILE_WRITE_DATA : execute_SRC1);
  assign execute_LightShifterPlugin_done = (execute_LightShifterPlugin_amplitude[4 : 1] == (4'b0000));
  always @ (*) begin
    case(execute_SHIFT_CTRL)
      `ShiftCtrlEnum_defaultEncoding_SLL_1 : begin
        _zz_145_ = (execute_LightShifterPlugin_shiftInput <<< 1);
      end
      default : begin
        _zz_145_ = _zz_236_;
      end
    endcase
  end

  assign _zz_35_ = _zz_81_;
  assign execute_BranchPlugin_eq = (execute_SRC1 == execute_SRC2);
  assign _zz_146_ = execute_INSTRUCTION[14 : 12];
  always @ (*) begin
    if((_zz_146_ == (3'b000))) begin
        _zz_147_ = execute_BranchPlugin_eq;
    end else if((_zz_146_ == (3'b001))) begin
        _zz_147_ = (! execute_BranchPlugin_eq);
    end else if((((_zz_146_ & (3'b101)) == (3'b101)))) begin
        _zz_147_ = (! execute_SRC_LESS);
    end else begin
        _zz_147_ = execute_SRC_LESS;
    end
  end

  always @ (*) begin
    case(execute_BRANCH_CTRL)
      `BranchCtrlEnum_defaultEncoding_INC : begin
        _zz_148_ = 1'b0;
      end
      `BranchCtrlEnum_defaultEncoding_JAL : begin
        _zz_148_ = 1'b1;
      end
      `BranchCtrlEnum_defaultEncoding_JALR : begin
        _zz_148_ = 1'b1;
      end
      default : begin
        _zz_148_ = _zz_147_;
      end
    endcase
  end

  assign _zz_34_ = _zz_148_;
  assign _zz_149_ = _zz_238_[11];
  always @ (*) begin
    _zz_150_[19] = _zz_149_;
    _zz_150_[18] = _zz_149_;
    _zz_150_[17] = _zz_149_;
    _zz_150_[16] = _zz_149_;
    _zz_150_[15] = _zz_149_;
    _zz_150_[14] = _zz_149_;
    _zz_150_[13] = _zz_149_;
    _zz_150_[12] = _zz_149_;
    _zz_150_[11] = _zz_149_;
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

  assign _zz_151_ = _zz_239_[19];
  always @ (*) begin
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

  assign _zz_153_ = _zz_240_[11];
  always @ (*) begin
    _zz_154_[18] = _zz_153_;
    _zz_154_[17] = _zz_153_;
    _zz_154_[16] = _zz_153_;
    _zz_154_[15] = _zz_153_;
    _zz_154_[14] = _zz_153_;
    _zz_154_[13] = _zz_153_;
    _zz_154_[12] = _zz_153_;
    _zz_154_[11] = _zz_153_;
    _zz_154_[10] = _zz_153_;
    _zz_154_[9] = _zz_153_;
    _zz_154_[8] = _zz_153_;
    _zz_154_[7] = _zz_153_;
    _zz_154_[6] = _zz_153_;
    _zz_154_[5] = _zz_153_;
    _zz_154_[4] = _zz_153_;
    _zz_154_[3] = _zz_153_;
    _zz_154_[2] = _zz_153_;
    _zz_154_[1] = _zz_153_;
    _zz_154_[0] = _zz_153_;
  end

  always @ (*) begin
    case(execute_BRANCH_CTRL)
      `BranchCtrlEnum_defaultEncoding_JALR : begin
        _zz_155_ = (_zz_241_[1] ^ execute_RS1[1]);
      end
      `BranchCtrlEnum_defaultEncoding_JAL : begin
        _zz_155_ = _zz_242_[1];
      end
      default : begin
        _zz_155_ = _zz_243_[1];
      end
    endcase
  end

  assign execute_BranchPlugin_missAlignedTarget = (execute_BRANCH_COND_RESULT && _zz_155_);
  assign _zz_32_ = ((execute_PREDICTION_HAD_BRANCHED2 != execute_BRANCH_COND_RESULT) || execute_BranchPlugin_missAlignedTarget);
  always @ (*) begin
    case(execute_BRANCH_CTRL)
      `BranchCtrlEnum_defaultEncoding_JALR : begin
        execute_BranchPlugin_branch_src1 = execute_RS1;
        execute_BranchPlugin_branch_src2 = {_zz_157_,execute_INSTRUCTION[31 : 20]};
      end
      default : begin
        execute_BranchPlugin_branch_src1 = execute_PC;
        execute_BranchPlugin_branch_src2 = ((execute_BRANCH_CTRL == `BranchCtrlEnum_defaultEncoding_JAL) ? {{_zz_159_,{{{_zz_382_,execute_INSTRUCTION[19 : 12]},execute_INSTRUCTION[20]},execute_INSTRUCTION[30 : 21]}},1'b0} : {{_zz_161_,{{{_zz_383_,_zz_384_},execute_INSTRUCTION[30 : 25]},execute_INSTRUCTION[11 : 8]}},1'b0});
        if((execute_PREDICTION_HAD_BRANCHED2 && (! execute_BranchPlugin_missAlignedTarget)))begin
          execute_BranchPlugin_branch_src2 = {29'd0, _zz_247_};
        end
      end
    endcase
  end

  assign _zz_156_ = _zz_244_[11];
  always @ (*) begin
    _zz_157_[19] = _zz_156_;
    _zz_157_[18] = _zz_156_;
    _zz_157_[17] = _zz_156_;
    _zz_157_[16] = _zz_156_;
    _zz_157_[15] = _zz_156_;
    _zz_157_[14] = _zz_156_;
    _zz_157_[13] = _zz_156_;
    _zz_157_[12] = _zz_156_;
    _zz_157_[11] = _zz_156_;
    _zz_157_[10] = _zz_156_;
    _zz_157_[9] = _zz_156_;
    _zz_157_[8] = _zz_156_;
    _zz_157_[7] = _zz_156_;
    _zz_157_[6] = _zz_156_;
    _zz_157_[5] = _zz_156_;
    _zz_157_[4] = _zz_156_;
    _zz_157_[3] = _zz_156_;
    _zz_157_[2] = _zz_156_;
    _zz_157_[1] = _zz_156_;
    _zz_157_[0] = _zz_156_;
  end

  assign _zz_158_ = _zz_245_[19];
  always @ (*) begin
    _zz_159_[10] = _zz_158_;
    _zz_159_[9] = _zz_158_;
    _zz_159_[8] = _zz_158_;
    _zz_159_[7] = _zz_158_;
    _zz_159_[6] = _zz_158_;
    _zz_159_[5] = _zz_158_;
    _zz_159_[4] = _zz_158_;
    _zz_159_[3] = _zz_158_;
    _zz_159_[2] = _zz_158_;
    _zz_159_[1] = _zz_158_;
    _zz_159_[0] = _zz_158_;
  end

  assign _zz_160_ = _zz_246_[11];
  always @ (*) begin
    _zz_161_[18] = _zz_160_;
    _zz_161_[17] = _zz_160_;
    _zz_161_[16] = _zz_160_;
    _zz_161_[15] = _zz_160_;
    _zz_161_[14] = _zz_160_;
    _zz_161_[13] = _zz_160_;
    _zz_161_[12] = _zz_160_;
    _zz_161_[11] = _zz_160_;
    _zz_161_[10] = _zz_160_;
    _zz_161_[9] = _zz_160_;
    _zz_161_[8] = _zz_160_;
    _zz_161_[7] = _zz_160_;
    _zz_161_[6] = _zz_160_;
    _zz_161_[5] = _zz_160_;
    _zz_161_[4] = _zz_160_;
    _zz_161_[3] = _zz_160_;
    _zz_161_[2] = _zz_160_;
    _zz_161_[1] = _zz_160_;
    _zz_161_[0] = _zz_160_;
  end

  assign execute_BranchPlugin_branchAdder = (execute_BranchPlugin_branch_src1 + execute_BranchPlugin_branch_src2);
  assign _zz_31_ = {execute_BranchPlugin_branchAdder[31 : 1],(1'b0)};
  assign _zz_85_ = ((execute_arbitration_isValid && (! execute_arbitration_isStuckByOthers)) && execute_BRANCH_DO);
  assign _zz_86_ = execute_BRANCH_CALC;
  always @ (*) begin
    _zz_87_ = (execute_arbitration_isValid && (execute_BRANCH_DO && execute_BRANCH_CALC[1]));
    if(1'b0)begin
      _zz_87_ = 1'b0;
    end
  end

  assign CsrPlugin_misa_base = (2'b01);
  assign CsrPlugin_misa_extensions = (26'b00000000000000000000000000);
  assign CsrPlugin_medeleg = (32'b00000000000000000000000000000000);
  assign CsrPlugin_mideleg = (32'b00000000000000000000000000000000);
  assign _zz_162_ = (CsrPlugin_mip_MTIP && CsrPlugin_mie_MTIE);
  assign _zz_163_ = (CsrPlugin_mip_MSIP && CsrPlugin_mie_MSIE);
  assign _zz_164_ = (CsrPlugin_mip_MEIP && CsrPlugin_mie_MEIE);
  assign CsrPlugin_exceptionPortCtrl_exceptionValidsRegs_decode = 1'b0;
  assign CsrPlugin_exceptionPortCtrl_exceptionTargetPrivilege = (2'b11);
  assign execute_exception_agregat_valid = ({_zz_90_,_zz_87_} != (2'b00));
  assign _zz_165_ = {_zz_90_,_zz_87_};
  assign _zz_166_ = _zz_248_[0];
  assign execute_exception_agregat_payload_code = (_zz_166_ ? (4'b0000) : _zz_91_);
  assign execute_exception_agregat_payload_badAddr = (_zz_166_ ? execute_BRANCH_CALC : (32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx));
  assign CsrPlugin_exceptionPortCtrl_exceptionValids_decode = CsrPlugin_exceptionPortCtrl_exceptionValidsRegs_decode;
  always @ (*) begin
    CsrPlugin_exceptionPortCtrl_exceptionValids_memory = CsrPlugin_exceptionPortCtrl_exceptionValidsRegs_memory;
    if(memory_exception_agregat_valid)begin
      CsrPlugin_exceptionPortCtrl_exceptionValids_memory = 1'b1;
    end
    if(memory_arbitration_isFlushed)begin
      CsrPlugin_exceptionPortCtrl_exceptionValids_memory = 1'b0;
    end
  end

  assign CsrPlugin_exceptionPortCtrl_exceptionValids_writeBack = CsrPlugin_exceptionPortCtrl_exceptionValidsRegs_writeBack;
  always @ (*) begin
    CsrPlugin_interrupt = 1'b0;
    CsrPlugin_interruptCode = (4'bxxxx);
    if(CsrPlugin_mstatus_MIE)begin
      if(({_zz_164_,{_zz_163_,_zz_162_}} != (3'b000)))begin
        CsrPlugin_interrupt = 1'b1;
      end
      if(_zz_162_)begin
        CsrPlugin_interruptCode = (4'b0111);
      end
      if(_zz_163_)begin
        CsrPlugin_interruptCode = (4'b0011);
      end
      if(_zz_164_)begin
        CsrPlugin_interruptCode = (4'b1011);
      end
    end
    if((! _zz_92_))begin
      CsrPlugin_interrupt = 1'b0;
    end
  end

  assign CsrPlugin_interruptTargetPrivilege = (2'b11);
  assign CsrPlugin_exception = (CsrPlugin_exceptionPortCtrl_exceptionValids_writeBack && _zz_93_);
  assign CsrPlugin_lastStageWasWfi = 1'b0;
  always @ (*) begin
    CsrPlugin_pipelineLiberator_done = ((! ({writeBack_arbitration_isValid,{memory_arbitration_isValid,execute_arbitration_isValid}} != (3'b000))) && IBusCachedPlugin_injector_nextPcCalc_valids_4);
    if(({CsrPlugin_exceptionPortCtrl_exceptionValidsRegs_writeBack,{CsrPlugin_exceptionPortCtrl_exceptionValidsRegs_memory,CsrPlugin_exceptionPortCtrl_exceptionValidsRegs_execute}} != (3'b000)))begin
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

  assign contextSwitching = _zz_88_;
  assign _zz_29_ = (! (((decode_INSTRUCTION[14 : 13] == (2'b01)) && (decode_INSTRUCTION[19 : 15] == (5'b00000))) || ((decode_INSTRUCTION[14 : 13] == (2'b11)) && (decode_INSTRUCTION[19 : 15] == (5'b00000)))));
  assign _zz_28_ = (decode_INSTRUCTION[13 : 7] != (7'b0100000));
  assign execute_CsrPlugin_blockedBySideEffects = ({writeBack_arbitration_isValid,memory_arbitration_isValid} != (2'b00));
  always @ (*) begin
    execute_CsrPlugin_illegalAccess = 1'b1;
    execute_CsrPlugin_readData = (32'b00000000000000000000000000000000);
    case(execute_CsrPlugin_csrAddress)
      12'b101111000000 : begin
        execute_CsrPlugin_illegalAccess = 1'b0;
        execute_CsrPlugin_readData[31 : 0] = _zz_167_;
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
        execute_CsrPlugin_readData[31 : 0] = _zz_168_;
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
    _zz_90_ = 1'b0;
    _zz_91_ = (4'bxxxx);
    if((execute_arbitration_isValid && (execute_ENV_CTRL == `EnvCtrlEnum_defaultEncoding_ECALL)))begin
      _zz_90_ = 1'b1;
      _zz_91_ = (4'b1011);
    end
    if((execute_arbitration_isValid && (execute_ENV_CTRL == `EnvCtrlEnum_defaultEncoding_EBREAK)))begin
      _zz_90_ = 1'b1;
      _zz_91_ = (4'b0011);
    end
  end

  assign execute_CsrPlugin_writeInstruction = ((execute_arbitration_isValid && execute_IS_CSR) && execute_CSR_WRITE_OPCODE);
  assign execute_CsrPlugin_readInstruction = ((execute_arbitration_isValid && execute_IS_CSR) && execute_CSR_READ_OPCODE);
  assign execute_CsrPlugin_writeEnable = ((execute_CsrPlugin_writeInstruction && (! execute_CsrPlugin_blockedBySideEffects)) && (! execute_arbitration_isStuckByOthers));
  assign execute_CsrPlugin_readEnable = ((execute_CsrPlugin_readInstruction && (! execute_CsrPlugin_blockedBySideEffects)) && (! execute_arbitration_isStuckByOthers));
  always @ (*) begin
    case(_zz_207_)
      1'b0 : begin
        execute_CsrPlugin_writeData = execute_SRC1;
      end
      default : begin
        execute_CsrPlugin_writeData = (execute_INSTRUCTION[12] ? (execute_CsrPlugin_readData & (~ execute_SRC1)) : (execute_CsrPlugin_readData | execute_SRC1));
      end
    endcase
  end

  assign execute_CsrPlugin_csrAddress = execute_INSTRUCTION[31 : 20];
  assign _zz_168_ = (_zz_167_ & externalInterruptArray_regNext);
  assign externalInterrupt = (_zz_168_ != (32'b00000000000000000000000000000000));
  assign DebugPlugin_isPipBusy = (DebugPlugin_isPipActive || DebugPlugin_isPipActive_regNext);
  always @ (*) begin
    debug_bus_cmd_ready = 1'b1;
    _zz_94_ = 1'b0;
    if(debug_bus_cmd_valid)begin
      case(_zz_202_)
        6'b000000 : begin
        end
        6'b000001 : begin
          if(debug_bus_cmd_payload_wr)begin
            _zz_94_ = 1'b1;
            debug_bus_cmd_ready = _zz_95_;
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
    if((! _zz_169_))begin
      debug_bus_rsp_data[0] = DebugPlugin_resetIt;
      debug_bus_rsp_data[1] = DebugPlugin_haltIt;
      debug_bus_rsp_data[2] = DebugPlugin_isPipBusy;
      debug_bus_rsp_data[3] = DebugPlugin_haltedByBreak;
      debug_bus_rsp_data[4] = DebugPlugin_stepIt;
    end
  end

  assign _zz_25_ = ((! DebugPlugin_haltIt) && (decode_IS_EBREAK || ((((1'b0 || (DebugPlugin_hardwareBreakpoints_0_valid && (DebugPlugin_hardwareBreakpoints_0_pc == _zz_254_))) || (DebugPlugin_hardwareBreakpoints_1_valid && (DebugPlugin_hardwareBreakpoints_1_pc == _zz_255_))) || (DebugPlugin_hardwareBreakpoints_2_valid && (DebugPlugin_hardwareBreakpoints_2_pc == _zz_256_))) || (DebugPlugin_hardwareBreakpoints_3_valid && (DebugPlugin_hardwareBreakpoints_3_pc == _zz_257_)))));
  assign debug_resetOut = DebugPlugin_resetIt_regNext;
  assign _zz_24_ = decode_SRC2_CTRL;
  assign _zz_22_ = _zz_59_;
  assign _zz_42_ = decode_to_execute_SRC2_CTRL;
  assign _zz_21_ = decode_SRC1_CTRL;
  assign _zz_19_ = _zz_56_;
  assign _zz_44_ = decode_to_execute_SRC1_CTRL;
  assign _zz_18_ = decode_BRANCH_CTRL;
  assign _zz_70_ = _zz_52_;
  assign _zz_33_ = decode_to_execute_BRANCH_CTRL;
  assign _zz_16_ = decode_ALU_CTRL;
  assign _zz_14_ = _zz_60_;
  assign _zz_46_ = decode_to_execute_ALU_CTRL;
  assign _zz_13_ = decode_SHIFT_CTRL;
  assign _zz_11_ = _zz_64_;
  assign _zz_37_ = decode_to_execute_SHIFT_CTRL;
  assign _zz_10_ = decode_ALU_BITWISE_CTRL;
  assign _zz_8_ = _zz_53_;
  assign _zz_48_ = decode_to_execute_ALU_BITWISE_CTRL;
  assign _zz_7_ = decode_ENV_CTRL;
  assign _zz_4_ = execute_ENV_CTRL;
  assign _zz_2_ = memory_ENV_CTRL;
  assign _zz_5_ = _zz_62_;
  assign _zz_27_ = decode_to_execute_ENV_CTRL;
  assign _zz_26_ = execute_to_memory_ENV_CTRL;
  assign _zz_30_ = memory_to_writeBack_ENV_CTRL;
  assign decode_arbitration_isFlushed = ({writeBack_arbitration_flushAll,{memory_arbitration_flushAll,{execute_arbitration_flushAll,decode_arbitration_flushAll}}} != (4'b0000));
  assign execute_arbitration_isFlushed = ({writeBack_arbitration_flushAll,{memory_arbitration_flushAll,execute_arbitration_flushAll}} != (3'b000));
  assign memory_arbitration_isFlushed = ({writeBack_arbitration_flushAll,memory_arbitration_flushAll} != (2'b00));
  assign writeBack_arbitration_isFlushed = (writeBack_arbitration_flushAll != (1'b0));
  assign decode_arbitration_isStuckByOthers = (decode_arbitration_haltByOther || (((1'b0 || execute_arbitration_isStuck) || memory_arbitration_isStuck) || writeBack_arbitration_isStuck));
  assign decode_arbitration_isStuck = (decode_arbitration_haltItself || decode_arbitration_isStuckByOthers);
  assign decode_arbitration_isMoving = ((! decode_arbitration_isStuck) && (! decode_arbitration_removeIt));
  assign decode_arbitration_isFiring = ((decode_arbitration_isValid && (! decode_arbitration_isStuck)) && (! decode_arbitration_removeIt));
  assign execute_arbitration_isStuckByOthers = (execute_arbitration_haltByOther || ((1'b0 || memory_arbitration_isStuck) || writeBack_arbitration_isStuck));
  assign execute_arbitration_isStuck = (execute_arbitration_haltItself || execute_arbitration_isStuckByOthers);
  assign execute_arbitration_isMoving = ((! execute_arbitration_isStuck) && (! execute_arbitration_removeIt));
  assign execute_arbitration_isFiring = ((execute_arbitration_isValid && (! execute_arbitration_isStuck)) && (! execute_arbitration_removeIt));
  assign memory_arbitration_isStuckByOthers = (memory_arbitration_haltByOther || (1'b0 || writeBack_arbitration_isStuck));
  assign memory_arbitration_isStuck = (memory_arbitration_haltItself || memory_arbitration_isStuckByOthers);
  assign memory_arbitration_isMoving = ((! memory_arbitration_isStuck) && (! memory_arbitration_removeIt));
  assign memory_arbitration_isFiring = ((memory_arbitration_isValid && (! memory_arbitration_isStuck)) && (! memory_arbitration_removeIt));
  assign writeBack_arbitration_isStuckByOthers = (writeBack_arbitration_haltByOther || 1'b0);
  assign writeBack_arbitration_isStuck = (writeBack_arbitration_haltItself || writeBack_arbitration_isStuckByOthers);
  assign writeBack_arbitration_isMoving = ((! writeBack_arbitration_isStuck) && (! writeBack_arbitration_removeIt));
  assign writeBack_arbitration_isFiring = ((writeBack_arbitration_isValid && (! writeBack_arbitration_isStuck)) && (! writeBack_arbitration_removeIt));
  assign iBusWishbone_ADR = {_zz_264_,_zz_172_};
  assign iBusWishbone_CTI = ((_zz_172_ == (3'b111)) ? (3'b111) : (3'b010));
  assign iBusWishbone_BTE = (2'b00);
  assign iBusWishbone_SEL = (4'b1111);
  assign iBusWishbone_WE = 1'b0;
  assign iBusWishbone_DAT_MOSI = (32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx);
  always @ (*) begin
    iBusWishbone_CYC = 1'b0;
    iBusWishbone_STB = 1'b0;
    if(_zz_203_)begin
      iBusWishbone_CYC = 1'b1;
      iBusWishbone_STB = 1'b1;
    end
  end

  assign iBus_cmd_ready = (iBus_cmd_valid && iBusWishbone_ACK);
  assign iBus_rsp_valid = _zz_173_;
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
        _zz_174_ = (4'b0001);
      end
      2'b01 : begin
        _zz_174_ = (4'b0011);
      end
      default : begin
        _zz_174_ = (4'b1111);
      end
    endcase
  end

  always @ (*) begin
    dBusWishbone_SEL = _zz_265_[3:0];
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
      _zz_102_ <= 1'b0;
      _zz_108_ <= 1'b0;
      _zz_110_ <= 1'b0;
      IBusCachedPlugin_injector_nextPcCalc_valids_0 <= 1'b0;
      IBusCachedPlugin_injector_nextPcCalc_valids_1 <= 1'b0;
      IBusCachedPlugin_injector_nextPcCalc_valids_2 <= 1'b0;
      IBusCachedPlugin_injector_nextPcCalc_valids_3 <= 1'b0;
      IBusCachedPlugin_injector_nextPcCalc_valids_4 <= 1'b0;
      IBusCachedPlugin_injector_decodeRemoved <= 1'b0;
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
      CsrPlugin_exceptionPortCtrl_exceptionValidsRegs_memory <= 1'b0;
      CsrPlugin_exceptionPortCtrl_exceptionValidsRegs_writeBack <= 1'b0;
      CsrPlugin_hadException <= 1'b0;
      _zz_167_ <= (32'b00000000000000000000000000000000);
      execute_arbitration_isValid <= 1'b0;
      memory_arbitration_isValid <= 1'b0;
      writeBack_arbitration_isValid <= 1'b0;
      _zz_170_ <= (3'b000);
      _zz_172_ <= (3'b000);
      _zz_173_ <= 1'b0;
      dBus_cmd_halfPipe_regs_valid <= 1'b0;
      dBus_cmd_halfPipe_regs_ready <= 1'b1;
    end else begin
      if(IBusCachedPlugin_fetchPc_propagatePc)begin
        IBusCachedPlugin_fetchPc_inc <= 1'b0;
      end
      if(IBusCachedPlugin_jump_pcLoad_valid)begin
        IBusCachedPlugin_fetchPc_inc <= 1'b0;
      end
      if(_zz_201_)begin
        IBusCachedPlugin_fetchPc_inc <= 1'b1;
      end
      if(IBusCachedPlugin_fetchPc_samplePcNext)begin
        IBusCachedPlugin_fetchPc_pcReg <= IBusCachedPlugin_fetchPc_pc;
      end
      _zz_102_ <= 1'b1;
      if((IBusCachedPlugin_jump_pcLoad_valid || _zz_77_))begin
        _zz_108_ <= 1'b0;
      end
      if(_zz_106_)begin
        _zz_108_ <= IBusCachedPlugin_iBusRsp_stages_0_output_valid;
      end
      if(IBusCachedPlugin_iBusRsp_stages_1_output_ready)begin
        _zz_110_ <= IBusCachedPlugin_iBusRsp_stages_1_output_valid;
      end
      if((IBusCachedPlugin_jump_pcLoad_valid || _zz_77_))begin
        _zz_110_ <= 1'b0;
      end
      if((IBusCachedPlugin_jump_pcLoad_valid || _zz_77_))begin
        IBusCachedPlugin_injector_nextPcCalc_valids_0 <= 1'b0;
      end
      if((! (! IBusCachedPlugin_iBusRsp_stages_1_input_ready)))begin
        IBusCachedPlugin_injector_nextPcCalc_valids_0 <= 1'b1;
      end
      if((IBusCachedPlugin_jump_pcLoad_valid || _zz_77_))begin
        IBusCachedPlugin_injector_nextPcCalc_valids_1 <= 1'b0;
      end
      if((! (! IBusCachedPlugin_iBusRsp_cacheRspArbitration_input_ready)))begin
        IBusCachedPlugin_injector_nextPcCalc_valids_1 <= IBusCachedPlugin_injector_nextPcCalc_valids_0;
      end
      if((IBusCachedPlugin_jump_pcLoad_valid || _zz_77_))begin
        IBusCachedPlugin_injector_nextPcCalc_valids_1 <= 1'b0;
      end
      if((IBusCachedPlugin_jump_pcLoad_valid || _zz_77_))begin
        IBusCachedPlugin_injector_nextPcCalc_valids_2 <= 1'b0;
      end
      if((! execute_arbitration_isStuck))begin
        IBusCachedPlugin_injector_nextPcCalc_valids_2 <= IBusCachedPlugin_injector_nextPcCalc_valids_1;
      end
      if((IBusCachedPlugin_jump_pcLoad_valid || _zz_77_))begin
        IBusCachedPlugin_injector_nextPcCalc_valids_2 <= 1'b0;
      end
      if((IBusCachedPlugin_jump_pcLoad_valid || _zz_77_))begin
        IBusCachedPlugin_injector_nextPcCalc_valids_3 <= 1'b0;
      end
      if((! memory_arbitration_isStuck))begin
        IBusCachedPlugin_injector_nextPcCalc_valids_3 <= IBusCachedPlugin_injector_nextPcCalc_valids_2;
      end
      if((IBusCachedPlugin_jump_pcLoad_valid || _zz_77_))begin
        IBusCachedPlugin_injector_nextPcCalc_valids_3 <= 1'b0;
      end
      if((IBusCachedPlugin_jump_pcLoad_valid || _zz_77_))begin
        IBusCachedPlugin_injector_nextPcCalc_valids_4 <= 1'b0;
      end
      if((! writeBack_arbitration_isStuck))begin
        IBusCachedPlugin_injector_nextPcCalc_valids_4 <= IBusCachedPlugin_injector_nextPcCalc_valids_3;
      end
      if((IBusCachedPlugin_jump_pcLoad_valid || _zz_77_))begin
        IBusCachedPlugin_injector_nextPcCalc_valids_4 <= 1'b0;
      end
      if(decode_arbitration_removeIt)begin
        IBusCachedPlugin_injector_decodeRemoved <= 1'b1;
      end
      if((IBusCachedPlugin_jump_pcLoad_valid || _zz_77_))begin
        IBusCachedPlugin_injector_decodeRemoved <= 1'b0;
      end
      if(_zz_194_)begin
        if(_zz_195_)begin
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
        CsrPlugin_exceptionPortCtrl_exceptionValidsRegs_execute <= CsrPlugin_exceptionPortCtrl_exceptionValids_execute;
      end
      if((! memory_arbitration_isStuck))begin
        CsrPlugin_exceptionPortCtrl_exceptionValidsRegs_memory <= (CsrPlugin_exceptionPortCtrl_exceptionValids_execute && (! execute_arbitration_isStuck));
      end else begin
        CsrPlugin_exceptionPortCtrl_exceptionValidsRegs_memory <= CsrPlugin_exceptionPortCtrl_exceptionValids_memory;
      end
      if((! writeBack_arbitration_isStuck))begin
        CsrPlugin_exceptionPortCtrl_exceptionValidsRegs_writeBack <= (CsrPlugin_exceptionPortCtrl_exceptionValids_memory && (! memory_arbitration_isStuck));
      end else begin
        CsrPlugin_exceptionPortCtrl_exceptionValidsRegs_writeBack <= 1'b0;
      end
      CsrPlugin_hadException <= CsrPlugin_exception;
      if(_zz_199_)begin
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
      if(_zz_200_)begin
        case(_zz_206_)
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
      if(((! memory_arbitration_isStuck) || memory_arbitration_removeIt))begin
        memory_arbitration_isValid <= 1'b0;
      end
      if(((! execute_arbitration_isStuck) && (! execute_arbitration_removeIt)))begin
        memory_arbitration_isValid <= execute_arbitration_isValid;
      end
      if(((! writeBack_arbitration_isStuck) || writeBack_arbitration_removeIt))begin
        writeBack_arbitration_isValid <= 1'b0;
      end
      if(((! memory_arbitration_isStuck) && (! memory_arbitration_removeIt)))begin
        writeBack_arbitration_isValid <= memory_arbitration_isValid;
      end
      case(_zz_170_)
        3'b000 : begin
          if(_zz_94_)begin
            _zz_170_ <= (3'b001);
          end
        end
        3'b001 : begin
          _zz_170_ <= (3'b010);
        end
        3'b010 : begin
          _zz_170_ <= (3'b011);
        end
        3'b011 : begin
          if((! decode_arbitration_isStuck))begin
            _zz_170_ <= (3'b100);
          end
        end
        3'b100 : begin
          _zz_170_ <= (3'b000);
        end
        default : begin
        end
      endcase
      case(execute_CsrPlugin_csrAddress)
        12'b101111000000 : begin
          if(execute_CsrPlugin_writeEnable)begin
            _zz_167_ <= execute_CsrPlugin_writeData[31 : 0];
          end
        end
        12'b001100000000 : begin
          if(execute_CsrPlugin_writeEnable)begin
            CsrPlugin_mstatus_MPP <= execute_CsrPlugin_writeData[12 : 11];
            CsrPlugin_mstatus_MPIE <= _zz_258_[0];
            CsrPlugin_mstatus_MIE <= _zz_259_[0];
          end
        end
        12'b001101000001 : begin
        end
        12'b001100000101 : begin
        end
        12'b001101000100 : begin
          if(execute_CsrPlugin_writeEnable)begin
            CsrPlugin_mip_MSIP <= _zz_260_[0];
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
            CsrPlugin_mie_MEIE <= _zz_261_[0];
            CsrPlugin_mie_MTIE <= _zz_262_[0];
            CsrPlugin_mie_MSIE <= _zz_263_[0];
          end
        end
        12'b001101000010 : begin
        end
        default : begin
        end
      endcase
      if(_zz_203_)begin
        if(iBusWishbone_ACK)begin
          _zz_172_ <= (_zz_172_ + (3'b001));
        end
      end
      _zz_173_ <= (iBusWishbone_CYC && iBusWishbone_ACK);
      if(_zz_204_)begin
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
      _zz_111_ <= IBusCachedPlugin_iBusRsp_stages_1_output_payload;
    end
    if(IBusCachedPlugin_iBusRsp_stages_1_input_ready)begin
      IBusCachedPlugin_s1_tightlyCoupledHit <= IBusCachedPlugin_s0_tightlyCoupledHit;
    end
    if(IBusCachedPlugin_iBusRsp_cacheRspArbitration_input_ready)begin
      IBusCachedPlugin_s2_tightlyCoupledHit <= IBusCachedPlugin_s1_tightlyCoupledHit;
    end
    if(!(! (((dBus_rsp_ready && memory_MEMORY_ENABLE) && memory_arbitration_isValid) && memory_arbitration_isStuck))) begin
      $display("ERROR DBusSimplePlugin doesn't allow memory stage stall when read happend");
    end
    if(!(! (((writeBack_arbitration_isValid && writeBack_MEMORY_ENABLE) && (! writeBack_INSTRUCTION[5])) && writeBack_arbitration_isStuck))) begin
      $display("ERROR DBusSimplePlugin doesn't allow writeback stage stall when read happend");
    end
    if(_zz_194_)begin
      if(_zz_195_)begin
        execute_LightShifterPlugin_amplitudeReg <= (execute_LightShifterPlugin_amplitude - (5'b00001));
      end
    end
    CsrPlugin_mcycle <= (CsrPlugin_mcycle + (64'b0000000000000000000000000000000000000000000000000000000000000001));
    if(writeBack_arbitration_isFiring)begin
      CsrPlugin_minstret <= (CsrPlugin_minstret + (64'b0000000000000000000000000000000000000000000000000000000000000001));
    end
    if(execute_exception_agregat_valid)begin
      CsrPlugin_exceptionPortCtrl_exceptionContext_code <= execute_exception_agregat_payload_code;
      CsrPlugin_exceptionPortCtrl_exceptionContext_badAddr <= execute_exception_agregat_payload_badAddr;
    end
    if(memory_exception_agregat_valid)begin
      CsrPlugin_exceptionPortCtrl_exceptionContext_code <= memory_exception_agregat_payload_code;
      CsrPlugin_exceptionPortCtrl_exceptionContext_badAddr <= memory_exception_agregat_payload_badAddr;
    end
    if((CsrPlugin_exception || CsrPlugin_interruptJump))begin
      case(CsrPlugin_privilege)
        2'b11 : begin
          CsrPlugin_mepc <= writeBack_PC;
        end
        default : begin
        end
      endcase
    end
    if(_zz_199_)begin
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
      decode_to_execute_SRC2_CTRL <= _zz_23_;
    end
    if((! execute_arbitration_isStuck))begin
      decode_to_execute_MEMORY_ENABLE <= decode_MEMORY_ENABLE;
    end
    if((! memory_arbitration_isStuck))begin
      execute_to_memory_MEMORY_ENABLE <= execute_MEMORY_ENABLE;
    end
    if((! writeBack_arbitration_isStuck))begin
      memory_to_writeBack_MEMORY_ENABLE <= memory_MEMORY_ENABLE;
    end
    if((! execute_arbitration_isStuck))begin
      decode_to_execute_IS_CSR <= decode_IS_CSR;
    end
    if((! writeBack_arbitration_isStuck))begin
      memory_to_writeBack_MEMORY_READ_DATA <= memory_MEMORY_READ_DATA;
    end
    if((! execute_arbitration_isStuck))begin
      decode_to_execute_REGFILE_WRITE_VALID <= decode_REGFILE_WRITE_VALID;
    end
    if((! memory_arbitration_isStuck))begin
      execute_to_memory_REGFILE_WRITE_VALID <= execute_REGFILE_WRITE_VALID;
    end
    if((! writeBack_arbitration_isStuck))begin
      memory_to_writeBack_REGFILE_WRITE_VALID <= memory_REGFILE_WRITE_VALID;
    end
    if((! execute_arbitration_isStuck))begin
      decode_to_execute_SRC_LESS_UNSIGNED <= decode_SRC_LESS_UNSIGNED;
    end
    if((! execute_arbitration_isStuck))begin
      decode_to_execute_FLUSH_ALL <= decode_FLUSH_ALL;
    end
    if((! memory_arbitration_isStuck))begin
      execute_to_memory_FLUSH_ALL <= execute_FLUSH_ALL;
    end
    if((! memory_arbitration_isStuck))begin
      execute_to_memory_ALIGNEMENT_FAULT <= execute_ALIGNEMENT_FAULT;
    end
    if((! execute_arbitration_isStuck))begin
      decode_to_execute_CSR_WRITE_OPCODE <= decode_CSR_WRITE_OPCODE;
    end
    if((! execute_arbitration_isStuck))begin
      decode_to_execute_SRC_USE_SUB_LESS <= decode_SRC_USE_SUB_LESS;
    end
    if((! execute_arbitration_isStuck))begin
      decode_to_execute_INSTRUCTION <= decode_INSTRUCTION;
    end
    if((! memory_arbitration_isStuck))begin
      execute_to_memory_INSTRUCTION <= execute_INSTRUCTION;
    end
    if((! writeBack_arbitration_isStuck))begin
      memory_to_writeBack_INSTRUCTION <= memory_INSTRUCTION;
    end
    if((! execute_arbitration_isStuck))begin
      decode_to_execute_CSR_READ_OPCODE <= decode_CSR_READ_OPCODE;
    end
    if((! execute_arbitration_isStuck))begin
      decode_to_execute_SRC1_CTRL <= _zz_20_;
    end
    if((! execute_arbitration_isStuck))begin
      decode_to_execute_BRANCH_CTRL <= _zz_17_;
    end
    if((! execute_arbitration_isStuck))begin
      decode_to_execute_ALU_CTRL <= _zz_15_;
    end
    if((! execute_arbitration_isStuck))begin
      decode_to_execute_DO_EBREAK <= decode_DO_EBREAK;
    end
    if((! execute_arbitration_isStuck))begin
      decode_to_execute_SHIFT_CTRL <= _zz_12_;
    end
    if((! memory_arbitration_isStuck))begin
      execute_to_memory_REGFILE_WRITE_DATA <= _zz_36_;
    end
    if((! writeBack_arbitration_isStuck))begin
      memory_to_writeBack_REGFILE_WRITE_DATA <= memory_REGFILE_WRITE_DATA;
    end
    if((! memory_arbitration_isStuck))begin
      execute_to_memory_MEMORY_ADDRESS_LOW <= execute_MEMORY_ADDRESS_LOW;
    end
    if((! writeBack_arbitration_isStuck))begin
      memory_to_writeBack_MEMORY_ADDRESS_LOW <= memory_MEMORY_ADDRESS_LOW;
    end
    if((! execute_arbitration_isStuck))begin
      decode_to_execute_ALU_BITWISE_CTRL <= _zz_9_;
    end
    if((! execute_arbitration_isStuck))begin
      decode_to_execute_ENV_CTRL <= _zz_6_;
    end
    if((! memory_arbitration_isStuck))begin
      execute_to_memory_ENV_CTRL <= _zz_3_;
    end
    if((! writeBack_arbitration_isStuck))begin
      memory_to_writeBack_ENV_CTRL <= _zz_1_;
    end
    if((! execute_arbitration_isStuck))begin
      decode_to_execute_PREDICTION_HAD_BRANCHED2 <= decode_PREDICTION_HAD_BRANCHED2;
    end
    if((! execute_arbitration_isStuck))begin
      decode_to_execute_PC <= decode_PC;
    end
    if((! memory_arbitration_isStuck))begin
      execute_to_memory_PC <= _zz_41_;
    end
    if((! writeBack_arbitration_isStuck))begin
      memory_to_writeBack_PC <= memory_PC;
    end
    if((! execute_arbitration_isStuck))begin
      decode_to_execute_FORMAL_PC_NEXT <= _zz_72_;
    end
    if((! memory_arbitration_isStuck))begin
      execute_to_memory_FORMAL_PC_NEXT <= _zz_71_;
    end
    if((! writeBack_arbitration_isStuck))begin
      memory_to_writeBack_FORMAL_PC_NEXT <= memory_FORMAL_PC_NEXT;
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
    if(_zz_204_)begin
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
    DebugPlugin_isPipActive <= ({writeBack_arbitration_isValid,{memory_arbitration_isValid,{execute_arbitration_isValid,decode_arbitration_isValid}}} != (4'b0000));
    DebugPlugin_isPipActive_regNext <= DebugPlugin_isPipActive;
    if(writeBack_arbitration_isValid)begin
      DebugPlugin_busReadDataReg <= _zz_66_;
    end
    _zz_169_ <= debug_bus_cmd_payload_address[2];
    if(debug_bus_cmd_valid)begin
      case(_zz_202_)
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
    if(_zz_196_)begin
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
        case(_zz_202_)
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
              DebugPlugin_hardwareBreakpoints_0_valid <= _zz_250_[0];
            end
          end
          6'b010001 : begin
            if(debug_bus_cmd_payload_wr)begin
              DebugPlugin_hardwareBreakpoints_1_valid <= _zz_251_[0];
            end
          end
          6'b010010 : begin
            if(debug_bus_cmd_payload_wr)begin
              DebugPlugin_hardwareBreakpoints_2_valid <= _zz_252_[0];
            end
          end
          6'b010011 : begin
            if(debug_bus_cmd_payload_wr)begin
              DebugPlugin_hardwareBreakpoints_3_valid <= _zz_253_[0];
            end
          end
          default : begin
          end
        endcase
      end
      if(_zz_196_)begin
        if(_zz_197_)begin
          DebugPlugin_haltIt <= 1'b1;
          DebugPlugin_haltedByBreak <= 1'b1;
        end
      end
      if(_zz_198_)begin
        if(decode_arbitration_isValid)begin
          DebugPlugin_haltIt <= 1'b1;
        end
      end
      if((DebugPlugin_stepIt && ({writeBack_arbitration_redoIt,{memory_arbitration_redoIt,{execute_arbitration_redoIt,decode_arbitration_redoIt}}} != (4'b0000))))begin
        DebugPlugin_haltIt <= 1'b0;
      end
    end
  end

  always @ (posedge clk) begin
    _zz_171_ <= debug_bus_cmd_payload_data;
  end

endmodule

