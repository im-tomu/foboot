// Generator : SpinalHDL v1.3.3    git head : 8b8cd335eecbea3b5f1f970f218a982dbdb12d99
// Date      : 25/04/2019, 15:26:42
// Component : VexRiscv


`define BranchCtrlEnum_defaultEncoding_type [1:0]
`define BranchCtrlEnum_defaultEncoding_INC 2'b00
`define BranchCtrlEnum_defaultEncoding_B 2'b01
`define BranchCtrlEnum_defaultEncoding_JAL 2'b10
`define BranchCtrlEnum_defaultEncoding_JALR 2'b11

`define ShiftCtrlEnum_defaultEncoding_type [1:0]
`define ShiftCtrlEnum_defaultEncoding_DISABLE_1 2'b00
`define ShiftCtrlEnum_defaultEncoding_SLL_1 2'b01
`define ShiftCtrlEnum_defaultEncoding_SRL_1 2'b10
`define ShiftCtrlEnum_defaultEncoding_SRA_1 2'b11

`define Src2CtrlEnum_defaultEncoding_type [1:0]
`define Src2CtrlEnum_defaultEncoding_RS 2'b00
`define Src2CtrlEnum_defaultEncoding_IMI 2'b01
`define Src2CtrlEnum_defaultEncoding_IMS 2'b10
`define Src2CtrlEnum_defaultEncoding_PC 2'b11

`define EnvCtrlEnum_defaultEncoding_type [1:0]
`define EnvCtrlEnum_defaultEncoding_NONE 2'b00
`define EnvCtrlEnum_defaultEncoding_XRET 2'b01
`define EnvCtrlEnum_defaultEncoding_ECALL 2'b10
`define EnvCtrlEnum_defaultEncoding_EBREAK 2'b11

`define AluCtrlEnum_defaultEncoding_type [1:0]
`define AluCtrlEnum_defaultEncoding_ADD_SUB 2'b00
`define AluCtrlEnum_defaultEncoding_SLT_SLTU 2'b01
`define AluCtrlEnum_defaultEncoding_BITWISE 2'b10

`define AluBitwiseCtrlEnum_defaultEncoding_type [1:0]
`define AluBitwiseCtrlEnum_defaultEncoding_XOR_1 2'b00
`define AluBitwiseCtrlEnum_defaultEncoding_OR_1 2'b01
`define AluBitwiseCtrlEnum_defaultEncoding_AND_1 2'b10

`define Src1CtrlEnum_defaultEncoding_type [1:0]
`define Src1CtrlEnum_defaultEncoding_RS 2'b00
`define Src1CtrlEnum_defaultEncoding_IMU 2'b01
`define Src1CtrlEnum_defaultEncoding_PC_INCREMENT 2'b10
`define Src1CtrlEnum_defaultEncoding_URS1 2'b11

module VexRiscv (
      input  [31:0] externalResetVector,
      input   timerInterrupt,
      input   softwareInterrupt,
      input  [31:0] externalInterruptArray,
      input   debug_bus_cmd_valid,
      output reg  debug_bus_cmd_ready,
      input   debug_bus_cmd_payload_wr,
      input  [7:0] debug_bus_cmd_payload_address,
      input  [31:0] debug_bus_cmd_payload_data,
      output reg [31:0] debug_bus_rsp_data,
      output  debug_resetOut,
      output  iBusWishbone_CYC,
      output  iBusWishbone_STB,
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
  reg [31:0] _zz_152_;
  reg [31:0] _zz_153_;
  wire  _zz_154_;
  wire  _zz_155_;
  wire  _zz_156_;
  wire  _zz_157_;
  wire  _zz_158_;
  wire [1:0] _zz_159_;
  wire  _zz_160_;
  wire  _zz_161_;
  wire  _zz_162_;
  wire  _zz_163_;
  wire [5:0] _zz_164_;
  wire  _zz_165_;
  wire  _zz_166_;
  wire [4:0] _zz_167_;
  wire [1:0] _zz_168_;
  wire [1:0] _zz_169_;
  wire [1:0] _zz_170_;
  wire  _zz_171_;
  wire [1:0] _zz_172_;
  wire [1:0] _zz_173_;
  wire [2:0] _zz_174_;
  wire [31:0] _zz_175_;
  wire [2:0] _zz_176_;
  wire [31:0] _zz_177_;
  wire [31:0] _zz_178_;
  wire [11:0] _zz_179_;
  wire [11:0] _zz_180_;
  wire [2:0] _zz_181_;
  wire [31:0] _zz_182_;
  wire [0:0] _zz_183_;
  wire [2:0] _zz_184_;
  wire [0:0] _zz_185_;
  wire [0:0] _zz_186_;
  wire [0:0] _zz_187_;
  wire [0:0] _zz_188_;
  wire [0:0] _zz_189_;
  wire [0:0] _zz_190_;
  wire [0:0] _zz_191_;
  wire [0:0] _zz_192_;
  wire [0:0] _zz_193_;
  wire [2:0] _zz_194_;
  wire [4:0] _zz_195_;
  wire [11:0] _zz_196_;
  wire [11:0] _zz_197_;
  wire [31:0] _zz_198_;
  wire [31:0] _zz_199_;
  wire [31:0] _zz_200_;
  wire [31:0] _zz_201_;
  wire [31:0] _zz_202_;
  wire [31:0] _zz_203_;
  wire [31:0] _zz_204_;
  wire [31:0] _zz_205_;
  wire [32:0] _zz_206_;
  wire [19:0] _zz_207_;
  wire [11:0] _zz_208_;
  wire [11:0] _zz_209_;
  wire [1:0] _zz_210_;
  wire [1:0] _zz_211_;
  wire [0:0] _zz_212_;
  wire [0:0] _zz_213_;
  wire [0:0] _zz_214_;
  wire [0:0] _zz_215_;
  wire [30:0] _zz_216_;
  wire [30:0] _zz_217_;
  wire [30:0] _zz_218_;
  wire [30:0] _zz_219_;
  wire [0:0] _zz_220_;
  wire [0:0] _zz_221_;
  wire [0:0] _zz_222_;
  wire [0:0] _zz_223_;
  wire [0:0] _zz_224_;
  wire [0:0] _zz_225_;
  wire [6:0] _zz_226_;
  wire  _zz_227_;
  wire  _zz_228_;
  wire [6:0] _zz_229_;
  wire [4:0] _zz_230_;
  wire  _zz_231_;
  wire [4:0] _zz_232_;
  wire [31:0] _zz_233_;
  wire  _zz_234_;
  wire  _zz_235_;
  wire [0:0] _zz_236_;
  wire [0:0] _zz_237_;
  wire [1:0] _zz_238_;
  wire [1:0] _zz_239_;
  wire  _zz_240_;
  wire [0:0] _zz_241_;
  wire [20:0] _zz_242_;
  wire [31:0] _zz_243_;
  wire [31:0] _zz_244_;
  wire [31:0] _zz_245_;
  wire  _zz_246_;
  wire [0:0] _zz_247_;
  wire [1:0] _zz_248_;
  wire [1:0] _zz_249_;
  wire [1:0] _zz_250_;
  wire  _zz_251_;
  wire [0:0] _zz_252_;
  wire [17:0] _zz_253_;
  wire [31:0] _zz_254_;
  wire [31:0] _zz_255_;
  wire [31:0] _zz_256_;
  wire [31:0] _zz_257_;
  wire [31:0] _zz_258_;
  wire [31:0] _zz_259_;
  wire [31:0] _zz_260_;
  wire [31:0] _zz_261_;
  wire [31:0] _zz_262_;
  wire  _zz_263_;
  wire  _zz_264_;
  wire  _zz_265_;
  wire [1:0] _zz_266_;
  wire [1:0] _zz_267_;
  wire  _zz_268_;
  wire [0:0] _zz_269_;
  wire [14:0] _zz_270_;
  wire [31:0] _zz_271_;
  wire [31:0] _zz_272_;
  wire  _zz_273_;
  wire  _zz_274_;
  wire  _zz_275_;
  wire [2:0] _zz_276_;
  wire [2:0] _zz_277_;
  wire  _zz_278_;
  wire [0:0] _zz_279_;
  wire [11:0] _zz_280_;
  wire [31:0] _zz_281_;
  wire [31:0] _zz_282_;
  wire  _zz_283_;
  wire  _zz_284_;
  wire [31:0] _zz_285_;
  wire [31:0] _zz_286_;
  wire  _zz_287_;
  wire [0:0] _zz_288_;
  wire [0:0] _zz_289_;
  wire  _zz_290_;
  wire [0:0] _zz_291_;
  wire [8:0] _zz_292_;
  wire  _zz_293_;
  wire [0:0] _zz_294_;
  wire [0:0] _zz_295_;
  wire [5:0] _zz_296_;
  wire [5:0] _zz_297_;
  wire  _zz_298_;
  wire [0:0] _zz_299_;
  wire [5:0] _zz_300_;
  wire [31:0] _zz_301_;
  wire  _zz_302_;
  wire [0:0] _zz_303_;
  wire [2:0] _zz_304_;
  wire  _zz_305_;
  wire  _zz_306_;
  wire [1:0] _zz_307_;
  wire [1:0] _zz_308_;
  wire  _zz_309_;
  wire [0:0] _zz_310_;
  wire [2:0] _zz_311_;
  wire [31:0] _zz_312_;
  wire  _zz_313_;
  wire  _zz_314_;
  wire [31:0] _zz_315_;
  wire [31:0] _zz_316_;
  wire [31:0] _zz_317_;
  wire [31:0] _zz_318_;
  wire [31:0] _zz_319_;
  wire [31:0] _zz_320_;
  wire  _zz_321_;
  wire [0:0] _zz_322_;
  wire [0:0] _zz_323_;
  wire  _zz_324_;
  wire  _zz_325_;
  wire [31:0] _zz_326_;
  wire [31:0] _zz_327_;
  wire [31:0] _zz_328_;
  wire [31:0] _zz_329_;
  wire [31:0] _zz_330_;
  wire [31:0] _zz_331_;
  wire [31:0] _zz_332_;
  wire [31:0] _zz_333_;
  wire  _zz_334_;
  wire [0:0] _zz_335_;
  wire [12:0] _zz_336_;
  wire [31:0] _zz_337_;
  wire [31:0] _zz_338_;
  wire [31:0] _zz_339_;
  wire  _zz_340_;
  wire [0:0] _zz_341_;
  wire [6:0] _zz_342_;
  wire [31:0] _zz_343_;
  wire [31:0] _zz_344_;
  wire [31:0] _zz_345_;
  wire  _zz_346_;
  wire [0:0] _zz_347_;
  wire [0:0] _zz_348_;
  wire  decode_CSR_WRITE_OPCODE;
  wire  decode_MEMORY_ENABLE;
  wire [31:0] execute_FORMAL_PC_NEXT;
  wire [31:0] decode_FORMAL_PC_NEXT;
  wire  decode_MEMORY_STORE;
  wire `BranchCtrlEnum_defaultEncoding_type decode_BRANCH_CTRL;
  wire `BranchCtrlEnum_defaultEncoding_type _zz_1_;
  wire `BranchCtrlEnum_defaultEncoding_type _zz_2_;
  wire `BranchCtrlEnum_defaultEncoding_type _zz_3_;
  wire  decode_CSR_READ_OPCODE;
  wire  decode_IS_CSR;
  wire  decode_SRC2_FORCE_ZERO;
  wire  decode_DO_EBREAK;
  wire `ShiftCtrlEnum_defaultEncoding_type decode_SHIFT_CTRL;
  wire `ShiftCtrlEnum_defaultEncoding_type _zz_4_;
  wire `ShiftCtrlEnum_defaultEncoding_type _zz_5_;
  wire `ShiftCtrlEnum_defaultEncoding_type _zz_6_;
  wire  decode_SRC_LESS_UNSIGNED;
  wire `Src2CtrlEnum_defaultEncoding_type decode_SRC2_CTRL;
  wire `Src2CtrlEnum_defaultEncoding_type _zz_7_;
  wire `Src2CtrlEnum_defaultEncoding_type _zz_8_;
  wire `Src2CtrlEnum_defaultEncoding_type _zz_9_;
  wire  execute_REGFILE_WRITE_VALID;
  wire `EnvCtrlEnum_defaultEncoding_type decode_ENV_CTRL;
  wire `EnvCtrlEnum_defaultEncoding_type _zz_10_;
  wire `EnvCtrlEnum_defaultEncoding_type _zz_11_;
  wire `EnvCtrlEnum_defaultEncoding_type _zz_12_;
  wire `AluCtrlEnum_defaultEncoding_type decode_ALU_CTRL;
  wire `AluCtrlEnum_defaultEncoding_type _zz_13_;
  wire `AluCtrlEnum_defaultEncoding_type _zz_14_;
  wire `AluCtrlEnum_defaultEncoding_type _zz_15_;
  wire `AluBitwiseCtrlEnum_defaultEncoding_type decode_ALU_BITWISE_CTRL;
  wire `AluBitwiseCtrlEnum_defaultEncoding_type _zz_16_;
  wire `AluBitwiseCtrlEnum_defaultEncoding_type _zz_17_;
  wire `AluBitwiseCtrlEnum_defaultEncoding_type _zz_18_;
  wire `Src1CtrlEnum_defaultEncoding_type decode_SRC1_CTRL;
  wire `Src1CtrlEnum_defaultEncoding_type _zz_19_;
  wire `Src1CtrlEnum_defaultEncoding_type _zz_20_;
  wire `Src1CtrlEnum_defaultEncoding_type _zz_21_;
  wire  execute_DO_EBREAK;
  wire  decode_IS_EBREAK;
  wire  _zz_22_;
  wire  execute_CSR_READ_OPCODE;
  wire  execute_CSR_WRITE_OPCODE;
  wire  execute_IS_CSR;
  wire  _zz_23_;
  wire  _zz_24_;
  wire `EnvCtrlEnum_defaultEncoding_type execute_ENV_CTRL;
  wire `EnvCtrlEnum_defaultEncoding_type _zz_25_;
  wire [31:0] execute_BRANCH_CALC;
  wire  execute_BRANCH_DO;
  wire [31:0] _zz_26_;
  wire [31:0] execute_PC;
  wire [31:0] execute_RS1;
  wire `BranchCtrlEnum_defaultEncoding_type execute_BRANCH_CTRL;
  wire `BranchCtrlEnum_defaultEncoding_type _zz_27_;
  wire  _zz_28_;
  wire `ShiftCtrlEnum_defaultEncoding_type execute_SHIFT_CTRL;
  wire `ShiftCtrlEnum_defaultEncoding_type _zz_29_;
  wire  _zz_30_;
  wire [31:0] _zz_31_;
  wire [31:0] _zz_32_;
  wire  execute_SRC_LESS_UNSIGNED;
  wire  execute_SRC2_FORCE_ZERO;
  wire  execute_SRC_USE_SUB_LESS;
  wire `Src2CtrlEnum_defaultEncoding_type execute_SRC2_CTRL;
  wire `Src2CtrlEnum_defaultEncoding_type _zz_33_;
  wire [31:0] _zz_34_;
  wire  execute_IS_RVC;
  wire `Src1CtrlEnum_defaultEncoding_type execute_SRC1_CTRL;
  wire `Src1CtrlEnum_defaultEncoding_type _zz_35_;
  wire [31:0] _zz_36_;
  wire  decode_SRC_USE_SUB_LESS;
  wire  decode_SRC_ADD_ZERO;
  wire  _zz_37_;
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
  wire  decode_LEGAL_INSTRUCTION;
  wire  decode_INSTRUCTION_READY;
  wire `ShiftCtrlEnum_defaultEncoding_type _zz_44_;
  wire `Src2CtrlEnum_defaultEncoding_type _zz_45_;
  wire  _zz_46_;
  wire `EnvCtrlEnum_defaultEncoding_type _zz_47_;
  wire `AluCtrlEnum_defaultEncoding_type _zz_48_;
  wire  _zz_49_;
  wire  _zz_50_;
  wire  _zz_51_;
  wire  _zz_52_;
  wire `Src1CtrlEnum_defaultEncoding_type _zz_53_;
  wire  _zz_54_;
  wire `BranchCtrlEnum_defaultEncoding_type _zz_55_;
  wire  _zz_56_;
  wire `AluBitwiseCtrlEnum_defaultEncoding_type _zz_57_;
  wire  _zz_58_;
  wire  _zz_59_;
  reg [31:0] _zz_60_;
  wire [1:0] execute_MEMORY_ADDRESS_LOW;
  wire [31:0] execute_MEMORY_READ_DATA;
  wire [31:0] execute_REGFILE_WRITE_DATA;
  wire [31:0] _zz_61_;
  wire [31:0] execute_SRC_ADD;
  wire [1:0] _zz_62_;
  wire [31:0] execute_RS2;
  wire [31:0] execute_INSTRUCTION;
  wire  execute_MEMORY_STORE;
  wire  execute_MEMORY_ENABLE;
  wire  execute_ALIGNEMENT_FAULT;
  wire  _zz_63_;
  wire [31:0] _zz_64_;
  wire  _zz_65_;
  wire [31:0] _zz_66_;
  wire [31:0] _zz_67_;
  wire  decode_IS_RVC;
  wire [31:0] decode_PC /* verilator public */ ;
  reg [31:0] decode_INSTRUCTION /* verilator public */ ;
  reg  decode_arbitration_haltItself /* verilator public */ ;
  reg  decode_arbitration_haltByOther;
  reg  decode_arbitration_removeIt;
  reg  decode_arbitration_flushAll /* verilator public */ ;
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
  reg  execute_arbitration_isValid;
  wire  execute_arbitration_isStuck;
  wire  execute_arbitration_isStuckByOthers;
  wire  execute_arbitration_isFlushed;
  wire  execute_arbitration_isMoving;
  wire  execute_arbitration_isFiring;
  reg  IBusSimplePlugin_fetcherHalt;
  reg  IBusSimplePlugin_fetcherflushIt;
  reg  IBusSimplePlugin_incomingInstruction;
  wire  IBusSimplePlugin_pcValids_0;
  wire  IBusSimplePlugin_pcValids_1;
  wire  iBus_cmd_valid;
  wire  iBus_cmd_ready;
  wire [31:0] iBus_cmd_payload_pc;
  wire  iBus_rsp_valid;
  wire  iBus_rsp_payload_error;
  wire [31:0] iBus_rsp_payload_inst;
  reg  DBusSimplePlugin_memoryExceptionPort_valid;
  reg [3:0] DBusSimplePlugin_memoryExceptionPort_payload_code;
  wire [31:0] DBusSimplePlugin_memoryExceptionPort_payload_badAddr;
  wire  decodeExceptionPort_valid;
  wire [3:0] decodeExceptionPort_payload_code;
  wire [31:0] decodeExceptionPort_payload_badAddr;
  wire  BranchPlugin_jumpInterface_valid;
  wire [31:0] BranchPlugin_jumpInterface_payload;
  reg  CsrPlugin_jumpInterface_valid;
  reg [31:0] CsrPlugin_jumpInterface_payload;
  wire  CsrPlugin_exceptionPendings_0;
  wire  CsrPlugin_exceptionPendings_1;
  wire  externalInterrupt;
  wire  contextSwitching;
  reg [1:0] CsrPlugin_privilege;
  reg  CsrPlugin_forceMachineWire;
  reg  CsrPlugin_selfException_valid;
  reg [3:0] CsrPlugin_selfException_payload_code;
  wire [31:0] CsrPlugin_selfException_payload_badAddr;
  reg  CsrPlugin_allowInterrupts;
  reg  CsrPlugin_allowException;
  reg  IBusSimplePlugin_injectionPort_valid;
  reg  IBusSimplePlugin_injectionPort_ready;
  wire [31:0] IBusSimplePlugin_injectionPort_payload;
  wire  IBusSimplePlugin_jump_pcLoad_valid;
  wire [31:0] IBusSimplePlugin_jump_pcLoad_payload;
  wire [1:0] _zz_68_;
  wire  IBusSimplePlugin_fetchPc_preOutput_valid;
  wire  IBusSimplePlugin_fetchPc_preOutput_ready;
  wire [31:0] IBusSimplePlugin_fetchPc_preOutput_payload;
  wire  _zz_69_;
  wire  IBusSimplePlugin_fetchPc_output_valid;
  wire  IBusSimplePlugin_fetchPc_output_ready;
  wire [31:0] IBusSimplePlugin_fetchPc_output_payload;
  reg [31:0] IBusSimplePlugin_fetchPc_pcReg /* verilator public */ ;
  reg  IBusSimplePlugin_fetchPc_inc;
  reg  IBusSimplePlugin_fetchPc_propagatePc;
  reg [31:0] IBusSimplePlugin_fetchPc_pc;
  reg  IBusSimplePlugin_fetchPc_samplePcNext;
  reg  _zz_70_;
  reg [31:0] IBusSimplePlugin_decodePc_pcReg /* verilator public */ ;
  wire [31:0] IBusSimplePlugin_decodePc_pcPlus;
  reg  IBusSimplePlugin_decodePc_injectedDecode;
  wire  IBusSimplePlugin_iBusRsp_stages_0_input_valid;
  wire  IBusSimplePlugin_iBusRsp_stages_0_input_ready;
  wire [31:0] IBusSimplePlugin_iBusRsp_stages_0_input_payload;
  wire  IBusSimplePlugin_iBusRsp_stages_0_output_valid;
  wire  IBusSimplePlugin_iBusRsp_stages_0_output_ready;
  wire [31:0] IBusSimplePlugin_iBusRsp_stages_0_output_payload;
  reg  IBusSimplePlugin_iBusRsp_stages_0_halt;
  wire  IBusSimplePlugin_iBusRsp_stages_0_inputSample;
  wire  IBusSimplePlugin_iBusRsp_stages_1_input_valid;
  wire  IBusSimplePlugin_iBusRsp_stages_1_input_ready;
  wire [31:0] IBusSimplePlugin_iBusRsp_stages_1_input_payload;
  wire  IBusSimplePlugin_iBusRsp_stages_1_output_valid;
  wire  IBusSimplePlugin_iBusRsp_stages_1_output_ready;
  wire [31:0] IBusSimplePlugin_iBusRsp_stages_1_output_payload;
  wire  IBusSimplePlugin_iBusRsp_stages_1_halt;
  wire  IBusSimplePlugin_iBusRsp_stages_1_inputSample;
  wire  _zz_71_;
  wire  _zz_72_;
  wire  _zz_73_;
  wire  _zz_74_;
  reg  _zz_75_;
  reg  IBusSimplePlugin_iBusRsp_readyForError;
  wire  IBusSimplePlugin_iBusRsp_output_valid;
  wire  IBusSimplePlugin_iBusRsp_output_ready;
  wire [31:0] IBusSimplePlugin_iBusRsp_output_payload_pc;
  wire  IBusSimplePlugin_iBusRsp_output_payload_rsp_error;
  wire [31:0] IBusSimplePlugin_iBusRsp_output_payload_rsp_inst;
  wire  IBusSimplePlugin_iBusRsp_output_payload_isRvc;
  wire  IBusSimplePlugin_decompressor_decodeInput_valid;
  wire  IBusSimplePlugin_decompressor_decodeInput_ready;
  wire [31:0] IBusSimplePlugin_decompressor_decodeInput_payload_pc;
  wire  IBusSimplePlugin_decompressor_decodeInput_payload_rsp_error;
  wire [31:0] IBusSimplePlugin_decompressor_decodeInput_payload_rsp_inst;
  wire  IBusSimplePlugin_decompressor_decodeInput_payload_isRvc;
  reg  IBusSimplePlugin_decompressor_bufferValid;
  reg [15:0] IBusSimplePlugin_decompressor_bufferData;
  wire [31:0] IBusSimplePlugin_decompressor_rawInDecode;
  wire  IBusSimplePlugin_decompressor_isRvc;
  wire [15:0] _zz_76_;
  reg [31:0] IBusSimplePlugin_decompressor_decompressed;
  wire [4:0] _zz_77_;
  wire [4:0] _zz_78_;
  wire [11:0] _zz_79_;
  wire  _zz_80_;
  reg [11:0] _zz_81_;
  wire  _zz_82_;
  reg [9:0] _zz_83_;
  wire [20:0] _zz_84_;
  wire  _zz_85_;
  reg [14:0] _zz_86_;
  wire  _zz_87_;
  reg [2:0] _zz_88_;
  wire  _zz_89_;
  reg [9:0] _zz_90_;
  wire [20:0] _zz_91_;
  wire  _zz_92_;
  reg [4:0] _zz_93_;
  wire [12:0] _zz_94_;
  wire [4:0] _zz_95_;
  wire [4:0] _zz_96_;
  wire [4:0] _zz_97_;
  wire  _zz_98_;
  reg [2:0] _zz_99_;
  reg [2:0] _zz_100_;
  wire  _zz_101_;
  reg [6:0] _zz_102_;
  reg  IBusSimplePlugin_injector_nextPcCalc_valids_0;
  reg  IBusSimplePlugin_injector_nextPcCalc_valids_1;
  reg  IBusSimplePlugin_injector_decodeRemoved;
  wire  IBusSimplePlugin_cmd_valid;
  wire  IBusSimplePlugin_cmd_ready;
  wire [31:0] IBusSimplePlugin_cmd_payload_pc;
  reg [0:0] IBusSimplePlugin_pendingCmd;
  wire [0:0] IBusSimplePlugin_pendingCmdNext;
  reg [0:0] IBusSimplePlugin_rspJoin_discardCounter;
  reg  IBusSimplePlugin_rspJoin_rspBufferOutput_valid;
  wire  IBusSimplePlugin_rspJoin_rspBufferOutput_ready;
  wire  IBusSimplePlugin_rspJoin_rspBufferOutput_payload_error;
  wire [31:0] IBusSimplePlugin_rspJoin_rspBufferOutput_payload_inst;
  wire  iBus_rsp_takeWhen_valid;
  wire  iBus_rsp_takeWhen_payload_error;
  wire [31:0] iBus_rsp_takeWhen_payload_inst;
  wire  IBusSimplePlugin_rspJoin_rspBuffer_rspStream_valid;
  wire  IBusSimplePlugin_rspJoin_rspBuffer_rspStream_ready;
  wire  IBusSimplePlugin_rspJoin_rspBuffer_rspStream_payload_error;
  wire [31:0] IBusSimplePlugin_rspJoin_rspBuffer_rspStream_payload_inst;
  reg  IBusSimplePlugin_rspJoin_rspBuffer_validReg;
  wire [31:0] IBusSimplePlugin_rspJoin_fetchRsp_pc;
  reg  IBusSimplePlugin_rspJoin_fetchRsp_rsp_error;
  wire [31:0] IBusSimplePlugin_rspJoin_fetchRsp_rsp_inst;
  wire  IBusSimplePlugin_rspJoin_fetchRsp_isRvc;
  wire  IBusSimplePlugin_rspJoin_join_valid;
  wire  IBusSimplePlugin_rspJoin_join_ready;
  wire [31:0] IBusSimplePlugin_rspJoin_join_payload_pc;
  wire  IBusSimplePlugin_rspJoin_join_payload_rsp_error;
  wire [31:0] IBusSimplePlugin_rspJoin_join_payload_rsp_inst;
  wire  IBusSimplePlugin_rspJoin_join_payload_isRvc;
  wire  IBusSimplePlugin_rspJoin_exceptionDetected;
  wire  IBusSimplePlugin_rspJoin_redoRequired;
  wire  _zz_103_;
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
  reg  execute_DBusSimplePlugin_skipCmd;
  reg [31:0] _zz_104_;
  reg [3:0] _zz_105_;
  wire [3:0] execute_DBusSimplePlugin_formalMask;
  reg [31:0] execute_DBusSimplePlugin_rspShifted;
  wire  _zz_106_;
  reg [31:0] _zz_107_;
  wire  _zz_108_;
  reg [31:0] _zz_109_;
  reg [31:0] execute_DBusSimplePlugin_rspFormated;
  wire [26:0] _zz_110_;
  wire  _zz_111_;
  wire  _zz_112_;
  wire  _zz_113_;
  wire  _zz_114_;
  wire  _zz_115_;
  wire `AluBitwiseCtrlEnum_defaultEncoding_type _zz_116_;
  wire `BranchCtrlEnum_defaultEncoding_type _zz_117_;
  wire `Src1CtrlEnum_defaultEncoding_type _zz_118_;
  wire `AluCtrlEnum_defaultEncoding_type _zz_119_;
  wire `EnvCtrlEnum_defaultEncoding_type _zz_120_;
  wire `Src2CtrlEnum_defaultEncoding_type _zz_121_;
  wire `ShiftCtrlEnum_defaultEncoding_type _zz_122_;
  wire [4:0] execute_RegFilePlugin_regFileReadAddress1;
  wire [4:0] execute_RegFilePlugin_regFileReadAddress2;
  wire  _zz_123_;
  wire [31:0] execute_RegFilePlugin_rs1Data;
  wire [31:0] execute_RegFilePlugin_rs2Data;
  wire  execute_RegFilePlugin_regFileWrite_valid /* verilator public */ ;
  wire [4:0] execute_RegFilePlugin_regFileWrite_payload_address /* verilator public */ ;
  wire [31:0] execute_RegFilePlugin_regFileWrite_payload_data /* verilator public */ ;
  reg [31:0] execute_IntAluPlugin_bitwise;
  reg [31:0] _zz_124_;
  reg [31:0] _zz_125_;
  wire  _zz_126_;
  reg [19:0] _zz_127_;
  wire  _zz_128_;
  reg [19:0] _zz_129_;
  reg [31:0] _zz_130_;
  reg [31:0] execute_SrcPlugin_addSub;
  wire  execute_SrcPlugin_less;
  reg  execute_LightShifterPlugin_isActive;
  wire  execute_LightShifterPlugin_isShift;
  reg [4:0] execute_LightShifterPlugin_amplitudeReg;
  wire [4:0] execute_LightShifterPlugin_amplitude;
  reg [31:0] execute_LightShifterPlugin_shiftReg;
  wire [31:0] execute_LightShifterPlugin_shiftInput;
  wire  execute_LightShifterPlugin_done;
  reg [31:0] _zz_131_;
  wire  execute_BranchPlugin_eq;
  wire [2:0] _zz_132_;
  reg  _zz_133_;
  reg  _zz_134_;
  wire [31:0] execute_BranchPlugin_branch_src1;
  wire  _zz_135_;
  reg [10:0] _zz_136_;
  wire  _zz_137_;
  reg [19:0] _zz_138_;
  wire  _zz_139_;
  reg [18:0] _zz_140_;
  reg [31:0] _zz_141_;
  wire [31:0] execute_BranchPlugin_branch_src2;
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
  reg  CsrPlugin_exceptionPortCtrl_exceptionValids_decode;
  reg  CsrPlugin_exceptionPortCtrl_exceptionValids_execute;
  reg  CsrPlugin_exceptionPortCtrl_exceptionValidsRegs_decode;
  reg  CsrPlugin_exceptionPortCtrl_exceptionValidsRegs_execute;
  reg [3:0] CsrPlugin_exceptionPortCtrl_exceptionContext_code;
  reg [31:0] CsrPlugin_exceptionPortCtrl_exceptionContext_badAddr;
  wire [1:0] CsrPlugin_exceptionPortCtrl_exceptionTargetPrivilegeUncapped;
  wire [1:0] CsrPlugin_exceptionPortCtrl_exceptionTargetPrivilege;
  wire [1:0] _zz_142_;
  wire  _zz_143_;
  reg  CsrPlugin_interrupt;
  reg [3:0] CsrPlugin_interruptCode /* verilator public */ ;
  reg [1:0] CsrPlugin_interruptTargetPrivilege;
  wire  CsrPlugin_exception;
  wire  CsrPlugin_lastStageWasWfi;
  reg  CsrPlugin_pipelineLiberator_done;
  wire  CsrPlugin_interruptJump /* verilator public */ ;
  reg  CsrPlugin_hadException;
  reg [1:0] CsrPlugin_targetPrivilege;
  reg [3:0] CsrPlugin_trapCause;
  reg [1:0] CsrPlugin_xtvec_mode;
  reg [29:0] CsrPlugin_xtvec_base;
  wire  execute_CsrPlugin_inWfi /* verilator public */ ;
  wire  execute_CsrPlugin_blockedBySideEffects;
  reg  execute_CsrPlugin_illegalAccess;
  reg  execute_CsrPlugin_illegalInstruction;
  reg [31:0] execute_CsrPlugin_readData;
  wire  execute_CsrPlugin_writeInstruction;
  wire  execute_CsrPlugin_readInstruction;
  wire  execute_CsrPlugin_writeEnable;
  wire  execute_CsrPlugin_readEnable;
  wire [31:0] execute_CsrPlugin_readToWriteData;
  reg [31:0] execute_CsrPlugin_writeData;
  wire [11:0] execute_CsrPlugin_csrAddress;
  reg [31:0] _zz_144_;
  reg [31:0] externalInterruptArray_regNext;
  wire [31:0] _zz_145_;
  reg  DebugPlugin_firstCycle;
  reg  DebugPlugin_secondCycle;
  reg  DebugPlugin_resetIt;
  reg  DebugPlugin_haltIt;
  reg  DebugPlugin_stepIt;
  reg  DebugPlugin_isPipBusy;
  reg  DebugPlugin_godmode;
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
  reg  _zz_146_;
  reg  _zz_147_;
  reg  DebugPlugin_resetIt_regNext;
  reg `Src1CtrlEnum_defaultEncoding_type decode_to_execute_SRC1_CTRL;
  reg `AluBitwiseCtrlEnum_defaultEncoding_type decode_to_execute_ALU_BITWISE_CTRL;
  reg `AluCtrlEnum_defaultEncoding_type decode_to_execute_ALU_CTRL;
  reg  decode_to_execute_SRC_USE_SUB_LESS;
  reg [31:0] decode_to_execute_PC;
  reg `EnvCtrlEnum_defaultEncoding_type decode_to_execute_ENV_CTRL;
  reg  decode_to_execute_REGFILE_WRITE_VALID;
  reg [31:0] decode_to_execute_INSTRUCTION;
  reg `Src2CtrlEnum_defaultEncoding_type decode_to_execute_SRC2_CTRL;
  reg  decode_to_execute_SRC_LESS_UNSIGNED;
  reg `ShiftCtrlEnum_defaultEncoding_type decode_to_execute_SHIFT_CTRL;
  reg  decode_to_execute_DO_EBREAK;
  reg  decode_to_execute_IS_RVC;
  reg  decode_to_execute_SRC2_FORCE_ZERO;
  reg  decode_to_execute_IS_CSR;
  reg  decode_to_execute_CSR_READ_OPCODE;
  reg `BranchCtrlEnum_defaultEncoding_type decode_to_execute_BRANCH_CTRL;
  reg  decode_to_execute_MEMORY_STORE;
  reg [31:0] decode_to_execute_FORMAL_PC_NEXT;
  reg  decode_to_execute_MEMORY_ENABLE;
  reg  decode_to_execute_CSR_WRITE_OPCODE;
  reg [2:0] _zz_148_;
  reg [31:0] IBusSimplePlugin_injectionPort_payload_regNext;
  wire  iBus_cmd_m2sPipe_valid;
  wire  iBus_cmd_m2sPipe_ready;
  wire [31:0] iBus_cmd_m2sPipe_payload_pc;
  reg  _zz_149_;
  reg [31:0] _zz_150_;
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
  reg [3:0] _zz_151_;
  `ifndef SYNTHESIS
  reg [31:0] decode_BRANCH_CTRL_string;
  reg [31:0] _zz_1__string;
  reg [31:0] _zz_2__string;
  reg [31:0] _zz_3__string;
  reg [71:0] decode_SHIFT_CTRL_string;
  reg [71:0] _zz_4__string;
  reg [71:0] _zz_5__string;
  reg [71:0] _zz_6__string;
  reg [23:0] decode_SRC2_CTRL_string;
  reg [23:0] _zz_7__string;
  reg [23:0] _zz_8__string;
  reg [23:0] _zz_9__string;
  reg [47:0] decode_ENV_CTRL_string;
  reg [47:0] _zz_10__string;
  reg [47:0] _zz_11__string;
  reg [47:0] _zz_12__string;
  reg [63:0] decode_ALU_CTRL_string;
  reg [63:0] _zz_13__string;
  reg [63:0] _zz_14__string;
  reg [63:0] _zz_15__string;
  reg [39:0] decode_ALU_BITWISE_CTRL_string;
  reg [39:0] _zz_16__string;
  reg [39:0] _zz_17__string;
  reg [39:0] _zz_18__string;
  reg [95:0] decode_SRC1_CTRL_string;
  reg [95:0] _zz_19__string;
  reg [95:0] _zz_20__string;
  reg [95:0] _zz_21__string;
  reg [47:0] execute_ENV_CTRL_string;
  reg [47:0] _zz_25__string;
  reg [31:0] execute_BRANCH_CTRL_string;
  reg [31:0] _zz_27__string;
  reg [71:0] execute_SHIFT_CTRL_string;
  reg [71:0] _zz_29__string;
  reg [23:0] execute_SRC2_CTRL_string;
  reg [23:0] _zz_33__string;
  reg [95:0] execute_SRC1_CTRL_string;
  reg [95:0] _zz_35__string;
  reg [63:0] execute_ALU_CTRL_string;
  reg [63:0] _zz_38__string;
  reg [39:0] execute_ALU_BITWISE_CTRL_string;
  reg [39:0] _zz_40__string;
  reg [71:0] _zz_44__string;
  reg [23:0] _zz_45__string;
  reg [47:0] _zz_47__string;
  reg [63:0] _zz_48__string;
  reg [95:0] _zz_53__string;
  reg [31:0] _zz_55__string;
  reg [39:0] _zz_57__string;
  reg [39:0] _zz_116__string;
  reg [31:0] _zz_117__string;
  reg [95:0] _zz_118__string;
  reg [63:0] _zz_119__string;
  reg [47:0] _zz_120__string;
  reg [23:0] _zz_121__string;
  reg [71:0] _zz_122__string;
  reg [95:0] decode_to_execute_SRC1_CTRL_string;
  reg [39:0] decode_to_execute_ALU_BITWISE_CTRL_string;
  reg [63:0] decode_to_execute_ALU_CTRL_string;
  reg [47:0] decode_to_execute_ENV_CTRL_string;
  reg [23:0] decode_to_execute_SRC2_CTRL_string;
  reg [71:0] decode_to_execute_SHIFT_CTRL_string;
  reg [31:0] decode_to_execute_BRANCH_CTRL_string;
  `endif

  reg [31:0] RegFilePlugin_regFile [0:31] /* verilator public */ ;
  assign _zz_154_ = ((execute_arbitration_isValid && execute_LightShifterPlugin_isShift) && (execute_SRC2[4 : 0] != (5'b00000)));
  assign _zz_155_ = (! execute_arbitration_isStuckByOthers);
  assign _zz_156_ = ({CsrPlugin_selfException_valid,DBusSimplePlugin_memoryExceptionPort_valid} != (2'b00));
  assign _zz_157_ = (CsrPlugin_hadException || CsrPlugin_interruptJump);
  assign _zz_158_ = (execute_arbitration_isValid && (execute_ENV_CTRL == `EnvCtrlEnum_defaultEncoding_XRET));
  assign _zz_159_ = execute_INSTRUCTION[29 : 28];
  assign _zz_160_ = (execute_arbitration_isValid && execute_DO_EBREAK);
  assign _zz_161_ = (1'b0 == 1'b0);
  assign _zz_162_ = (DebugPlugin_stepIt && IBusSimplePlugin_incomingInstruction);
  assign _zz_163_ = (IBusSimplePlugin_fetchPc_preOutput_valid && IBusSimplePlugin_fetchPc_preOutput_ready);
  assign _zz_164_ = debug_bus_cmd_payload_address[7 : 2];
  assign _zz_165_ = (IBusSimplePlugin_iBusRsp_output_valid && IBusSimplePlugin_iBusRsp_output_ready);
  assign _zz_166_ = (! dBus_cmd_halfPipe_regs_valid);
  assign _zz_167_ = {_zz_76_[1 : 0],_zz_76_[15 : 13]};
  assign _zz_168_ = _zz_76_[6 : 5];
  assign _zz_169_ = _zz_76_[11 : 10];
  assign _zz_170_ = execute_INSTRUCTION[13 : 12];
  assign _zz_171_ = execute_INSTRUCTION[13];
  assign _zz_172_ = (_zz_68_ & (~ _zz_173_));
  assign _zz_173_ = (_zz_68_ - (2'b01));
  assign _zz_174_ = {IBusSimplePlugin_fetchPc_inc,(2'b00)};
  assign _zz_175_ = {29'd0, _zz_174_};
  assign _zz_176_ = (decode_IS_RVC ? (3'b010) : (3'b100));
  assign _zz_177_ = {29'd0, _zz_176_};
  assign _zz_178_ = {{_zz_86_,_zz_76_[6 : 2]},(12'b000000000000)};
  assign _zz_179_ = {{{(4'b0000),_zz_76_[8 : 7]},_zz_76_[12 : 9]},(2'b00)};
  assign _zz_180_ = {{{(4'b0000),_zz_76_[8 : 7]},_zz_76_[12 : 9]},(2'b00)};
  assign _zz_181_ = (decode_IS_RVC ? (3'b010) : (3'b100));
  assign _zz_182_ = {29'd0, _zz_181_};
  assign _zz_183_ = (IBusSimplePlugin_pendingCmd + (IBusSimplePlugin_cmd_valid && IBusSimplePlugin_cmd_ready));
  assign _zz_184_ = (execute_MEMORY_STORE ? (3'b110) : (3'b100));
  assign _zz_185_ = _zz_110_[0 : 0];
  assign _zz_186_ = _zz_110_[5 : 5];
  assign _zz_187_ = _zz_110_[8 : 8];
  assign _zz_188_ = _zz_110_[11 : 11];
  assign _zz_189_ = _zz_110_[12 : 12];
  assign _zz_190_ = _zz_110_[13 : 13];
  assign _zz_191_ = _zz_110_[14 : 14];
  assign _zz_192_ = _zz_110_[20 : 20];
  assign _zz_193_ = execute_SRC_LESS;
  assign _zz_194_ = (execute_IS_RVC ? (3'b010) : (3'b100));
  assign _zz_195_ = execute_INSTRUCTION[19 : 15];
  assign _zz_196_ = execute_INSTRUCTION[31 : 20];
  assign _zz_197_ = {execute_INSTRUCTION[31 : 25],execute_INSTRUCTION[11 : 7]};
  assign _zz_198_ = ($signed(_zz_199_) + $signed(_zz_202_));
  assign _zz_199_ = ($signed(_zz_200_) + $signed(_zz_201_));
  assign _zz_200_ = execute_SRC1;
  assign _zz_201_ = (execute_SRC_USE_SUB_LESS ? (~ execute_SRC2) : execute_SRC2);
  assign _zz_202_ = (execute_SRC_USE_SUB_LESS ? _zz_203_ : _zz_204_);
  assign _zz_203_ = (32'b00000000000000000000000000000001);
  assign _zz_204_ = (32'b00000000000000000000000000000000);
  assign _zz_205_ = (_zz_206_ >>> 1);
  assign _zz_206_ = {((execute_SHIFT_CTRL == `ShiftCtrlEnum_defaultEncoding_SRA_1) && execute_LightShifterPlugin_shiftInput[31]),execute_LightShifterPlugin_shiftInput};
  assign _zz_207_ = {{{execute_INSTRUCTION[31],execute_INSTRUCTION[19 : 12]},execute_INSTRUCTION[20]},execute_INSTRUCTION[30 : 21]};
  assign _zz_208_ = execute_INSTRUCTION[31 : 20];
  assign _zz_209_ = {{{execute_INSTRUCTION[31],execute_INSTRUCTION[7]},execute_INSTRUCTION[30 : 25]},execute_INSTRUCTION[11 : 8]};
  assign _zz_210_ = (_zz_142_ & (~ _zz_211_));
  assign _zz_211_ = (_zz_142_ - (2'b01));
  assign _zz_212_ = debug_bus_cmd_payload_data[0 : 0];
  assign _zz_213_ = debug_bus_cmd_payload_data[0 : 0];
  assign _zz_214_ = debug_bus_cmd_payload_data[0 : 0];
  assign _zz_215_ = debug_bus_cmd_payload_data[0 : 0];
  assign _zz_216_ = (decode_PC >>> 1);
  assign _zz_217_ = (decode_PC >>> 1);
  assign _zz_218_ = (decode_PC >>> 1);
  assign _zz_219_ = (decode_PC >>> 1);
  assign _zz_220_ = execute_CsrPlugin_writeData[7 : 7];
  assign _zz_221_ = execute_CsrPlugin_writeData[3 : 3];
  assign _zz_222_ = execute_CsrPlugin_writeData[3 : 3];
  assign _zz_223_ = execute_CsrPlugin_writeData[11 : 11];
  assign _zz_224_ = execute_CsrPlugin_writeData[7 : 7];
  assign _zz_225_ = execute_CsrPlugin_writeData[3 : 3];
  assign _zz_226_ = ({3'd0,_zz_151_} <<< dBus_cmd_halfPipe_payload_address[1 : 0]);
  assign _zz_227_ = (_zz_76_[11 : 10] == (2'b01));
  assign _zz_228_ = ((_zz_76_[11 : 10] == (2'b11)) && (_zz_76_[6 : 5] == (2'b00)));
  assign _zz_229_ = (7'b0000000);
  assign _zz_230_ = _zz_76_[6 : 2];
  assign _zz_231_ = _zz_76_[12];
  assign _zz_232_ = _zz_76_[11 : 7];
  assign _zz_233_ = (32'b00000000000000000111000001010100);
  assign _zz_234_ = ((decode_INSTRUCTION & (32'b01000000000000000011000001010100)) == (32'b01000000000000000001000000010000));
  assign _zz_235_ = ((decode_INSTRUCTION & (32'b00000000000000000111000001010100)) == (32'b00000000000000000001000000010000));
  assign _zz_236_ = _zz_115_;
  assign _zz_237_ = ((decode_INSTRUCTION & _zz_243_) == (32'b00000000000000000000000000100000));
  assign _zz_238_ = {_zz_115_,(_zz_244_ == _zz_245_)};
  assign _zz_239_ = (2'b00);
  assign _zz_240_ = ({_zz_246_,{_zz_247_,_zz_248_}} != (4'b0000));
  assign _zz_241_ = (_zz_112_ != (1'b0));
  assign _zz_242_ = {(_zz_249_ != _zz_250_),{_zz_251_,{_zz_252_,_zz_253_}}};
  assign _zz_243_ = (32'b00000000000000000000000001110000);
  assign _zz_244_ = (decode_INSTRUCTION & (32'b00000000000000000000000000100000));
  assign _zz_245_ = (32'b00000000000000000000000000000000);
  assign _zz_246_ = ((decode_INSTRUCTION & (32'b00000000000000000000000001000100)) == (32'b00000000000000000000000000000000));
  assign _zz_247_ = ((decode_INSTRUCTION & _zz_254_) == (32'b00000000000000000000000000000000));
  assign _zz_248_ = {(_zz_255_ == _zz_256_),(_zz_257_ == _zz_258_)};
  assign _zz_249_ = {(_zz_259_ == _zz_260_),(_zz_261_ == _zz_262_)};
  assign _zz_250_ = (2'b00);
  assign _zz_251_ = ({_zz_263_,_zz_264_} != (2'b00));
  assign _zz_252_ = (_zz_265_ != (1'b0));
  assign _zz_253_ = {(_zz_266_ != _zz_267_),{_zz_268_,{_zz_269_,_zz_270_}}};
  assign _zz_254_ = (32'b00000000000000000000000000011000);
  assign _zz_255_ = (decode_INSTRUCTION & (32'b00000000000000000110000000000100));
  assign _zz_256_ = (32'b00000000000000000010000000000000);
  assign _zz_257_ = (decode_INSTRUCTION & (32'b00000000000000000101000000000100));
  assign _zz_258_ = (32'b00000000000000000001000000000000);
  assign _zz_259_ = (decode_INSTRUCTION & (32'b00000000000000000001000001010000));
  assign _zz_260_ = (32'b00000000000000000001000001010000);
  assign _zz_261_ = (decode_INSTRUCTION & (32'b00000000000000000010000001010000));
  assign _zz_262_ = (32'b00000000000000000010000001010000);
  assign _zz_263_ = ((decode_INSTRUCTION & (32'b00000000000000000000000000110100)) == (32'b00000000000000000000000000100000));
  assign _zz_264_ = ((decode_INSTRUCTION & (32'b00000000000000000000000001100100)) == (32'b00000000000000000000000000100000));
  assign _zz_265_ = ((decode_INSTRUCTION & (32'b00010000000000000011000001010000)) == (32'b00000000000000000000000001010000));
  assign _zz_266_ = {_zz_114_,(_zz_271_ == _zz_272_)};
  assign _zz_267_ = (2'b00);
  assign _zz_268_ = ({_zz_273_,_zz_274_} != (2'b00));
  assign _zz_269_ = (_zz_275_ != (1'b0));
  assign _zz_270_ = {(_zz_276_ != _zz_277_),{_zz_278_,{_zz_279_,_zz_280_}}};
  assign _zz_271_ = (decode_INSTRUCTION & (32'b00010000010000000011000001010000));
  assign _zz_272_ = (32'b00010000000000000000000001010000);
  assign _zz_273_ = ((decode_INSTRUCTION & (32'b00000000000000000110000000010100)) == (32'b00000000000000000110000000010000));
  assign _zz_274_ = ((decode_INSTRUCTION & (32'b00000000000000000101000000010100)) == (32'b00000000000000000100000000010000));
  assign _zz_275_ = ((decode_INSTRUCTION & (32'b00000000000000000110000000010100)) == (32'b00000000000000000010000000010000));
  assign _zz_276_ = {(_zz_281_ == _zz_282_),{_zz_283_,_zz_284_}};
  assign _zz_277_ = (3'b000);
  assign _zz_278_ = ((_zz_285_ == _zz_286_) != (1'b0));
  assign _zz_279_ = (_zz_287_ != (1'b0));
  assign _zz_280_ = {(_zz_288_ != _zz_289_),{_zz_290_,{_zz_291_,_zz_292_}}};
  assign _zz_281_ = (decode_INSTRUCTION & (32'b00000000000000000000000001000100));
  assign _zz_282_ = (32'b00000000000000000000000001000000);
  assign _zz_283_ = ((decode_INSTRUCTION & (32'b00000000000000000010000000010100)) == (32'b00000000000000000010000000010000));
  assign _zz_284_ = ((decode_INSTRUCTION & (32'b01000000000000000100000000110100)) == (32'b01000000000000000000000000110000));
  assign _zz_285_ = (decode_INSTRUCTION & (32'b00000000000000000000000000100000));
  assign _zz_286_ = (32'b00000000000000000000000000100000);
  assign _zz_287_ = ((decode_INSTRUCTION & (32'b00000000000000000000000001011000)) == (32'b00000000000000000000000000000000));
  assign _zz_288_ = _zz_114_;
  assign _zz_289_ = (1'b0);
  assign _zz_290_ = ({_zz_293_,_zz_113_} != (2'b00));
  assign _zz_291_ = ({_zz_294_,_zz_295_} != (2'b00));
  assign _zz_292_ = {(_zz_296_ != _zz_297_),{_zz_298_,{_zz_299_,_zz_300_}}};
  assign _zz_293_ = ((decode_INSTRUCTION & (32'b00000000000000000000000000010100)) == (32'b00000000000000000000000000000100));
  assign _zz_294_ = ((decode_INSTRUCTION & _zz_301_) == (32'b00000000000000000000000000000100));
  assign _zz_295_ = _zz_113_;
  assign _zz_296_ = {_zz_111_,{_zz_302_,{_zz_303_,_zz_304_}}};
  assign _zz_297_ = (6'b000000);
  assign _zz_298_ = ({_zz_111_,_zz_305_} != (2'b00));
  assign _zz_299_ = (_zz_306_ != (1'b0));
  assign _zz_300_ = {(_zz_307_ != _zz_308_),{_zz_309_,{_zz_310_,_zz_311_}}};
  assign _zz_301_ = (32'b00000000000000000000000001000100);
  assign _zz_302_ = ((decode_INSTRUCTION & (32'b00000000000000000001000000010000)) == (32'b00000000000000000001000000010000));
  assign _zz_303_ = ((decode_INSTRUCTION & _zz_312_) == (32'b00000000000000000010000000010000));
  assign _zz_304_ = {_zz_112_,{_zz_313_,_zz_314_}};
  assign _zz_305_ = ((decode_INSTRUCTION & (32'b00000000000000000000000000011100)) == (32'b00000000000000000000000000000100));
  assign _zz_306_ = ((decode_INSTRUCTION & (32'b00000000000000000000000001011000)) == (32'b00000000000000000000000001000000));
  assign _zz_307_ = {(_zz_315_ == _zz_316_),(_zz_317_ == _zz_318_)};
  assign _zz_308_ = (2'b00);
  assign _zz_309_ = ((_zz_319_ == _zz_320_) != (1'b0));
  assign _zz_310_ = (_zz_321_ != (1'b0));
  assign _zz_311_ = {(_zz_322_ != _zz_323_),{_zz_324_,_zz_325_}};
  assign _zz_312_ = (32'b00000000000000000010000000010000);
  assign _zz_313_ = ((decode_INSTRUCTION & (32'b00000000000000000000000000001100)) == (32'b00000000000000000000000000000100));
  assign _zz_314_ = ((decode_INSTRUCTION & (32'b00000000000000000000000000101000)) == (32'b00000000000000000000000000000000));
  assign _zz_315_ = (decode_INSTRUCTION & (32'b00000000000000000010000000010000));
  assign _zz_316_ = (32'b00000000000000000010000000000000);
  assign _zz_317_ = (decode_INSTRUCTION & (32'b00000000000000000101000000000000));
  assign _zz_318_ = (32'b00000000000000000001000000000000);
  assign _zz_319_ = (decode_INSTRUCTION & (32'b00000000000000000000000000010000));
  assign _zz_320_ = (32'b00000000000000000000000000010000);
  assign _zz_321_ = ((decode_INSTRUCTION & (32'b00000000000000000000000000000000)) == (32'b00000000000000000000000000000000));
  assign _zz_322_ = ((decode_INSTRUCTION & (32'b00000000000000000001000000000000)) == (32'b00000000000000000001000000000000));
  assign _zz_323_ = (1'b0);
  assign _zz_324_ = (((decode_INSTRUCTION & _zz_326_) == (32'b00000000000000000010000000000000)) != (1'b0));
  assign _zz_325_ = ({(_zz_327_ == _zz_328_),(_zz_329_ == _zz_330_)} != (2'b00));
  assign _zz_326_ = (32'b00000000000000000011000000000000);
  assign _zz_327_ = (decode_INSTRUCTION & (32'b00000000000000000000000001100100));
  assign _zz_328_ = (32'b00000000000000000000000000100100);
  assign _zz_329_ = (decode_INSTRUCTION & (32'b00000000000000000011000001010100));
  assign _zz_330_ = (32'b00000000000000000001000000010000);
  assign _zz_331_ = (32'b00000000000000000001000001111111);
  assign _zz_332_ = (decode_INSTRUCTION & (32'b00000000000000000010000001111111));
  assign _zz_333_ = (32'b00000000000000000010000001110011);
  assign _zz_334_ = ((decode_INSTRUCTION & (32'b00000000000000000100000001111111)) == (32'b00000000000000000100000001100011));
  assign _zz_335_ = ((decode_INSTRUCTION & (32'b00000000000000000010000001111111)) == (32'b00000000000000000010000000010011));
  assign _zz_336_ = {((decode_INSTRUCTION & (32'b00000000000000000110000000111111)) == (32'b00000000000000000000000000100011)),{((decode_INSTRUCTION & (32'b00000000000000000010000001111111)) == (32'b00000000000000000000000000000011)),{((decode_INSTRUCTION & _zz_337_) == (32'b00000000000000000000000000000011)),{(_zz_338_ == _zz_339_),{_zz_340_,{_zz_341_,_zz_342_}}}}}};
  assign _zz_337_ = (32'b00000000000000000101000001011111);
  assign _zz_338_ = (decode_INSTRUCTION & (32'b00000000000000000111000001111011));
  assign _zz_339_ = (32'b00000000000000000000000001100011);
  assign _zz_340_ = ((decode_INSTRUCTION & (32'b00000000000000000110000001111111)) == (32'b00000000000000000000000000001111));
  assign _zz_341_ = ((decode_INSTRUCTION & (32'b11111110000000000000000001111111)) == (32'b00000000000000000000000000110011));
  assign _zz_342_ = {((decode_INSTRUCTION & (32'b10111100000000000111000001111111)) == (32'b00000000000000000101000000010011)),{((decode_INSTRUCTION & (32'b11111100000000000011000001111111)) == (32'b00000000000000000001000000010011)),{((decode_INSTRUCTION & _zz_343_) == (32'b00000000000000000101000000110011)),{(_zz_344_ == _zz_345_),{_zz_346_,{_zz_347_,_zz_348_}}}}}};
  assign _zz_343_ = (32'b10111110000000000111000001111111);
  assign _zz_344_ = (decode_INSTRUCTION & (32'b10111110000000000111000001111111));
  assign _zz_345_ = (32'b00000000000000000000000000110011);
  assign _zz_346_ = ((decode_INSTRUCTION & (32'b11011111111111111111111111111111)) == (32'b00010000001000000000000001110011));
  assign _zz_347_ = ((decode_INSTRUCTION & (32'b11111111111011111111111111111111)) == (32'b00000000000000000000000001110011));
  assign _zz_348_ = ((decode_INSTRUCTION & (32'b11111111111111111111111111111111)) == (32'b00010000010100000000000001110011));
  initial begin
    $readmemb("2-stage-no-cache-debug.v_toplevel_RegFilePlugin_regFile.bin",RegFilePlugin_regFile);
  end
  always @ (posedge clk) begin
    if(_zz_41_) begin
      RegFilePlugin_regFile[execute_RegFilePlugin_regFileWrite_payload_address] <= execute_RegFilePlugin_regFileWrite_payload_data;
    end
  end

  always @ (posedge clk) begin
    if(_zz_123_) begin
      _zz_152_ <= RegFilePlugin_regFile[execute_RegFilePlugin_regFileReadAddress1];
    end
  end

  always @ (posedge clk) begin
    if(_zz_123_) begin
      _zz_153_ <= RegFilePlugin_regFile[execute_RegFilePlugin_regFileReadAddress2];
    end
  end

  `ifndef SYNTHESIS
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
    case(_zz_1_)
      `BranchCtrlEnum_defaultEncoding_INC : _zz_1__string = "INC ";
      `BranchCtrlEnum_defaultEncoding_B : _zz_1__string = "B   ";
      `BranchCtrlEnum_defaultEncoding_JAL : _zz_1__string = "JAL ";
      `BranchCtrlEnum_defaultEncoding_JALR : _zz_1__string = "JALR";
      default : _zz_1__string = "????";
    endcase
  end
  always @(*) begin
    case(_zz_2_)
      `BranchCtrlEnum_defaultEncoding_INC : _zz_2__string = "INC ";
      `BranchCtrlEnum_defaultEncoding_B : _zz_2__string = "B   ";
      `BranchCtrlEnum_defaultEncoding_JAL : _zz_2__string = "JAL ";
      `BranchCtrlEnum_defaultEncoding_JALR : _zz_2__string = "JALR";
      default : _zz_2__string = "????";
    endcase
  end
  always @(*) begin
    case(_zz_3_)
      `BranchCtrlEnum_defaultEncoding_INC : _zz_3__string = "INC ";
      `BranchCtrlEnum_defaultEncoding_B : _zz_3__string = "B   ";
      `BranchCtrlEnum_defaultEncoding_JAL : _zz_3__string = "JAL ";
      `BranchCtrlEnum_defaultEncoding_JALR : _zz_3__string = "JALR";
      default : _zz_3__string = "????";
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
    case(_zz_4_)
      `ShiftCtrlEnum_defaultEncoding_DISABLE_1 : _zz_4__string = "DISABLE_1";
      `ShiftCtrlEnum_defaultEncoding_SLL_1 : _zz_4__string = "SLL_1    ";
      `ShiftCtrlEnum_defaultEncoding_SRL_1 : _zz_4__string = "SRL_1    ";
      `ShiftCtrlEnum_defaultEncoding_SRA_1 : _zz_4__string = "SRA_1    ";
      default : _zz_4__string = "?????????";
    endcase
  end
  always @(*) begin
    case(_zz_5_)
      `ShiftCtrlEnum_defaultEncoding_DISABLE_1 : _zz_5__string = "DISABLE_1";
      `ShiftCtrlEnum_defaultEncoding_SLL_1 : _zz_5__string = "SLL_1    ";
      `ShiftCtrlEnum_defaultEncoding_SRL_1 : _zz_5__string = "SRL_1    ";
      `ShiftCtrlEnum_defaultEncoding_SRA_1 : _zz_5__string = "SRA_1    ";
      default : _zz_5__string = "?????????";
    endcase
  end
  always @(*) begin
    case(_zz_6_)
      `ShiftCtrlEnum_defaultEncoding_DISABLE_1 : _zz_6__string = "DISABLE_1";
      `ShiftCtrlEnum_defaultEncoding_SLL_1 : _zz_6__string = "SLL_1    ";
      `ShiftCtrlEnum_defaultEncoding_SRL_1 : _zz_6__string = "SRL_1    ";
      `ShiftCtrlEnum_defaultEncoding_SRA_1 : _zz_6__string = "SRA_1    ";
      default : _zz_6__string = "?????????";
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
    case(_zz_7_)
      `Src2CtrlEnum_defaultEncoding_RS : _zz_7__string = "RS ";
      `Src2CtrlEnum_defaultEncoding_IMI : _zz_7__string = "IMI";
      `Src2CtrlEnum_defaultEncoding_IMS : _zz_7__string = "IMS";
      `Src2CtrlEnum_defaultEncoding_PC : _zz_7__string = "PC ";
      default : _zz_7__string = "???";
    endcase
  end
  always @(*) begin
    case(_zz_8_)
      `Src2CtrlEnum_defaultEncoding_RS : _zz_8__string = "RS ";
      `Src2CtrlEnum_defaultEncoding_IMI : _zz_8__string = "IMI";
      `Src2CtrlEnum_defaultEncoding_IMS : _zz_8__string = "IMS";
      `Src2CtrlEnum_defaultEncoding_PC : _zz_8__string = "PC ";
      default : _zz_8__string = "???";
    endcase
  end
  always @(*) begin
    case(_zz_9_)
      `Src2CtrlEnum_defaultEncoding_RS : _zz_9__string = "RS ";
      `Src2CtrlEnum_defaultEncoding_IMI : _zz_9__string = "IMI";
      `Src2CtrlEnum_defaultEncoding_IMS : _zz_9__string = "IMS";
      `Src2CtrlEnum_defaultEncoding_PC : _zz_9__string = "PC ";
      default : _zz_9__string = "???";
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
    case(_zz_10_)
      `EnvCtrlEnum_defaultEncoding_NONE : _zz_10__string = "NONE  ";
      `EnvCtrlEnum_defaultEncoding_XRET : _zz_10__string = "XRET  ";
      `EnvCtrlEnum_defaultEncoding_ECALL : _zz_10__string = "ECALL ";
      `EnvCtrlEnum_defaultEncoding_EBREAK : _zz_10__string = "EBREAK";
      default : _zz_10__string = "??????";
    endcase
  end
  always @(*) begin
    case(_zz_11_)
      `EnvCtrlEnum_defaultEncoding_NONE : _zz_11__string = "NONE  ";
      `EnvCtrlEnum_defaultEncoding_XRET : _zz_11__string = "XRET  ";
      `EnvCtrlEnum_defaultEncoding_ECALL : _zz_11__string = "ECALL ";
      `EnvCtrlEnum_defaultEncoding_EBREAK : _zz_11__string = "EBREAK";
      default : _zz_11__string = "??????";
    endcase
  end
  always @(*) begin
    case(_zz_12_)
      `EnvCtrlEnum_defaultEncoding_NONE : _zz_12__string = "NONE  ";
      `EnvCtrlEnum_defaultEncoding_XRET : _zz_12__string = "XRET  ";
      `EnvCtrlEnum_defaultEncoding_ECALL : _zz_12__string = "ECALL ";
      `EnvCtrlEnum_defaultEncoding_EBREAK : _zz_12__string = "EBREAK";
      default : _zz_12__string = "??????";
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
    case(_zz_13_)
      `AluCtrlEnum_defaultEncoding_ADD_SUB : _zz_13__string = "ADD_SUB ";
      `AluCtrlEnum_defaultEncoding_SLT_SLTU : _zz_13__string = "SLT_SLTU";
      `AluCtrlEnum_defaultEncoding_BITWISE : _zz_13__string = "BITWISE ";
      default : _zz_13__string = "????????";
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
    case(decode_ALU_BITWISE_CTRL)
      `AluBitwiseCtrlEnum_defaultEncoding_XOR_1 : decode_ALU_BITWISE_CTRL_string = "XOR_1";
      `AluBitwiseCtrlEnum_defaultEncoding_OR_1 : decode_ALU_BITWISE_CTRL_string = "OR_1 ";
      `AluBitwiseCtrlEnum_defaultEncoding_AND_1 : decode_ALU_BITWISE_CTRL_string = "AND_1";
      default : decode_ALU_BITWISE_CTRL_string = "?????";
    endcase
  end
  always @(*) begin
    case(_zz_16_)
      `AluBitwiseCtrlEnum_defaultEncoding_XOR_1 : _zz_16__string = "XOR_1";
      `AluBitwiseCtrlEnum_defaultEncoding_OR_1 : _zz_16__string = "OR_1 ";
      `AluBitwiseCtrlEnum_defaultEncoding_AND_1 : _zz_16__string = "AND_1";
      default : _zz_16__string = "?????";
    endcase
  end
  always @(*) begin
    case(_zz_17_)
      `AluBitwiseCtrlEnum_defaultEncoding_XOR_1 : _zz_17__string = "XOR_1";
      `AluBitwiseCtrlEnum_defaultEncoding_OR_1 : _zz_17__string = "OR_1 ";
      `AluBitwiseCtrlEnum_defaultEncoding_AND_1 : _zz_17__string = "AND_1";
      default : _zz_17__string = "?????";
    endcase
  end
  always @(*) begin
    case(_zz_18_)
      `AluBitwiseCtrlEnum_defaultEncoding_XOR_1 : _zz_18__string = "XOR_1";
      `AluBitwiseCtrlEnum_defaultEncoding_OR_1 : _zz_18__string = "OR_1 ";
      `AluBitwiseCtrlEnum_defaultEncoding_AND_1 : _zz_18__string = "AND_1";
      default : _zz_18__string = "?????";
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
    case(execute_ENV_CTRL)
      `EnvCtrlEnum_defaultEncoding_NONE : execute_ENV_CTRL_string = "NONE  ";
      `EnvCtrlEnum_defaultEncoding_XRET : execute_ENV_CTRL_string = "XRET  ";
      `EnvCtrlEnum_defaultEncoding_ECALL : execute_ENV_CTRL_string = "ECALL ";
      `EnvCtrlEnum_defaultEncoding_EBREAK : execute_ENV_CTRL_string = "EBREAK";
      default : execute_ENV_CTRL_string = "??????";
    endcase
  end
  always @(*) begin
    case(_zz_25_)
      `EnvCtrlEnum_defaultEncoding_NONE : _zz_25__string = "NONE  ";
      `EnvCtrlEnum_defaultEncoding_XRET : _zz_25__string = "XRET  ";
      `EnvCtrlEnum_defaultEncoding_ECALL : _zz_25__string = "ECALL ";
      `EnvCtrlEnum_defaultEncoding_EBREAK : _zz_25__string = "EBREAK";
      default : _zz_25__string = "??????";
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
    case(_zz_29_)
      `ShiftCtrlEnum_defaultEncoding_DISABLE_1 : _zz_29__string = "DISABLE_1";
      `ShiftCtrlEnum_defaultEncoding_SLL_1 : _zz_29__string = "SLL_1    ";
      `ShiftCtrlEnum_defaultEncoding_SRL_1 : _zz_29__string = "SRL_1    ";
      `ShiftCtrlEnum_defaultEncoding_SRA_1 : _zz_29__string = "SRA_1    ";
      default : _zz_29__string = "?????????";
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
    case(_zz_33_)
      `Src2CtrlEnum_defaultEncoding_RS : _zz_33__string = "RS ";
      `Src2CtrlEnum_defaultEncoding_IMI : _zz_33__string = "IMI";
      `Src2CtrlEnum_defaultEncoding_IMS : _zz_33__string = "IMS";
      `Src2CtrlEnum_defaultEncoding_PC : _zz_33__string = "PC ";
      default : _zz_33__string = "???";
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
    case(_zz_35_)
      `Src1CtrlEnum_defaultEncoding_RS : _zz_35__string = "RS          ";
      `Src1CtrlEnum_defaultEncoding_IMU : _zz_35__string = "IMU         ";
      `Src1CtrlEnum_defaultEncoding_PC_INCREMENT : _zz_35__string = "PC_INCREMENT";
      `Src1CtrlEnum_defaultEncoding_URS1 : _zz_35__string = "URS1        ";
      default : _zz_35__string = "????????????";
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
      default : execute_ALU_BITWISE_CTRL_string = "?????";
    endcase
  end
  always @(*) begin
    case(_zz_40_)
      `AluBitwiseCtrlEnum_defaultEncoding_XOR_1 : _zz_40__string = "XOR_1";
      `AluBitwiseCtrlEnum_defaultEncoding_OR_1 : _zz_40__string = "OR_1 ";
      `AluBitwiseCtrlEnum_defaultEncoding_AND_1 : _zz_40__string = "AND_1";
      default : _zz_40__string = "?????";
    endcase
  end
  always @(*) begin
    case(_zz_44_)
      `ShiftCtrlEnum_defaultEncoding_DISABLE_1 : _zz_44__string = "DISABLE_1";
      `ShiftCtrlEnum_defaultEncoding_SLL_1 : _zz_44__string = "SLL_1    ";
      `ShiftCtrlEnum_defaultEncoding_SRL_1 : _zz_44__string = "SRL_1    ";
      `ShiftCtrlEnum_defaultEncoding_SRA_1 : _zz_44__string = "SRA_1    ";
      default : _zz_44__string = "?????????";
    endcase
  end
  always @(*) begin
    case(_zz_45_)
      `Src2CtrlEnum_defaultEncoding_RS : _zz_45__string = "RS ";
      `Src2CtrlEnum_defaultEncoding_IMI : _zz_45__string = "IMI";
      `Src2CtrlEnum_defaultEncoding_IMS : _zz_45__string = "IMS";
      `Src2CtrlEnum_defaultEncoding_PC : _zz_45__string = "PC ";
      default : _zz_45__string = "???";
    endcase
  end
  always @(*) begin
    case(_zz_47_)
      `EnvCtrlEnum_defaultEncoding_NONE : _zz_47__string = "NONE  ";
      `EnvCtrlEnum_defaultEncoding_XRET : _zz_47__string = "XRET  ";
      `EnvCtrlEnum_defaultEncoding_ECALL : _zz_47__string = "ECALL ";
      `EnvCtrlEnum_defaultEncoding_EBREAK : _zz_47__string = "EBREAK";
      default : _zz_47__string = "??????";
    endcase
  end
  always @(*) begin
    case(_zz_48_)
      `AluCtrlEnum_defaultEncoding_ADD_SUB : _zz_48__string = "ADD_SUB ";
      `AluCtrlEnum_defaultEncoding_SLT_SLTU : _zz_48__string = "SLT_SLTU";
      `AluCtrlEnum_defaultEncoding_BITWISE : _zz_48__string = "BITWISE ";
      default : _zz_48__string = "????????";
    endcase
  end
  always @(*) begin
    case(_zz_53_)
      `Src1CtrlEnum_defaultEncoding_RS : _zz_53__string = "RS          ";
      `Src1CtrlEnum_defaultEncoding_IMU : _zz_53__string = "IMU         ";
      `Src1CtrlEnum_defaultEncoding_PC_INCREMENT : _zz_53__string = "PC_INCREMENT";
      `Src1CtrlEnum_defaultEncoding_URS1 : _zz_53__string = "URS1        ";
      default : _zz_53__string = "????????????";
    endcase
  end
  always @(*) begin
    case(_zz_55_)
      `BranchCtrlEnum_defaultEncoding_INC : _zz_55__string = "INC ";
      `BranchCtrlEnum_defaultEncoding_B : _zz_55__string = "B   ";
      `BranchCtrlEnum_defaultEncoding_JAL : _zz_55__string = "JAL ";
      `BranchCtrlEnum_defaultEncoding_JALR : _zz_55__string = "JALR";
      default : _zz_55__string = "????";
    endcase
  end
  always @(*) begin
    case(_zz_57_)
      `AluBitwiseCtrlEnum_defaultEncoding_XOR_1 : _zz_57__string = "XOR_1";
      `AluBitwiseCtrlEnum_defaultEncoding_OR_1 : _zz_57__string = "OR_1 ";
      `AluBitwiseCtrlEnum_defaultEncoding_AND_1 : _zz_57__string = "AND_1";
      default : _zz_57__string = "?????";
    endcase
  end
  always @(*) begin
    case(_zz_116_)
      `AluBitwiseCtrlEnum_defaultEncoding_XOR_1 : _zz_116__string = "XOR_1";
      `AluBitwiseCtrlEnum_defaultEncoding_OR_1 : _zz_116__string = "OR_1 ";
      `AluBitwiseCtrlEnum_defaultEncoding_AND_1 : _zz_116__string = "AND_1";
      default : _zz_116__string = "?????";
    endcase
  end
  always @(*) begin
    case(_zz_117_)
      `BranchCtrlEnum_defaultEncoding_INC : _zz_117__string = "INC ";
      `BranchCtrlEnum_defaultEncoding_B : _zz_117__string = "B   ";
      `BranchCtrlEnum_defaultEncoding_JAL : _zz_117__string = "JAL ";
      `BranchCtrlEnum_defaultEncoding_JALR : _zz_117__string = "JALR";
      default : _zz_117__string = "????";
    endcase
  end
  always @(*) begin
    case(_zz_118_)
      `Src1CtrlEnum_defaultEncoding_RS : _zz_118__string = "RS          ";
      `Src1CtrlEnum_defaultEncoding_IMU : _zz_118__string = "IMU         ";
      `Src1CtrlEnum_defaultEncoding_PC_INCREMENT : _zz_118__string = "PC_INCREMENT";
      `Src1CtrlEnum_defaultEncoding_URS1 : _zz_118__string = "URS1        ";
      default : _zz_118__string = "????????????";
    endcase
  end
  always @(*) begin
    case(_zz_119_)
      `AluCtrlEnum_defaultEncoding_ADD_SUB : _zz_119__string = "ADD_SUB ";
      `AluCtrlEnum_defaultEncoding_SLT_SLTU : _zz_119__string = "SLT_SLTU";
      `AluCtrlEnum_defaultEncoding_BITWISE : _zz_119__string = "BITWISE ";
      default : _zz_119__string = "????????";
    endcase
  end
  always @(*) begin
    case(_zz_120_)
      `EnvCtrlEnum_defaultEncoding_NONE : _zz_120__string = "NONE  ";
      `EnvCtrlEnum_defaultEncoding_XRET : _zz_120__string = "XRET  ";
      `EnvCtrlEnum_defaultEncoding_ECALL : _zz_120__string = "ECALL ";
      `EnvCtrlEnum_defaultEncoding_EBREAK : _zz_120__string = "EBREAK";
      default : _zz_120__string = "??????";
    endcase
  end
  always @(*) begin
    case(_zz_121_)
      `Src2CtrlEnum_defaultEncoding_RS : _zz_121__string = "RS ";
      `Src2CtrlEnum_defaultEncoding_IMI : _zz_121__string = "IMI";
      `Src2CtrlEnum_defaultEncoding_IMS : _zz_121__string = "IMS";
      `Src2CtrlEnum_defaultEncoding_PC : _zz_121__string = "PC ";
      default : _zz_121__string = "???";
    endcase
  end
  always @(*) begin
    case(_zz_122_)
      `ShiftCtrlEnum_defaultEncoding_DISABLE_1 : _zz_122__string = "DISABLE_1";
      `ShiftCtrlEnum_defaultEncoding_SLL_1 : _zz_122__string = "SLL_1    ";
      `ShiftCtrlEnum_defaultEncoding_SRL_1 : _zz_122__string = "SRL_1    ";
      `ShiftCtrlEnum_defaultEncoding_SRA_1 : _zz_122__string = "SRA_1    ";
      default : _zz_122__string = "?????????";
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
    case(decode_to_execute_ALU_BITWISE_CTRL)
      `AluBitwiseCtrlEnum_defaultEncoding_XOR_1 : decode_to_execute_ALU_BITWISE_CTRL_string = "XOR_1";
      `AluBitwiseCtrlEnum_defaultEncoding_OR_1 : decode_to_execute_ALU_BITWISE_CTRL_string = "OR_1 ";
      `AluBitwiseCtrlEnum_defaultEncoding_AND_1 : decode_to_execute_ALU_BITWISE_CTRL_string = "AND_1";
      default : decode_to_execute_ALU_BITWISE_CTRL_string = "?????";
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
    case(decode_to_execute_ENV_CTRL)
      `EnvCtrlEnum_defaultEncoding_NONE : decode_to_execute_ENV_CTRL_string = "NONE  ";
      `EnvCtrlEnum_defaultEncoding_XRET : decode_to_execute_ENV_CTRL_string = "XRET  ";
      `EnvCtrlEnum_defaultEncoding_ECALL : decode_to_execute_ENV_CTRL_string = "ECALL ";
      `EnvCtrlEnum_defaultEncoding_EBREAK : decode_to_execute_ENV_CTRL_string = "EBREAK";
      default : decode_to_execute_ENV_CTRL_string = "??????";
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
    case(decode_to_execute_SHIFT_CTRL)
      `ShiftCtrlEnum_defaultEncoding_DISABLE_1 : decode_to_execute_SHIFT_CTRL_string = "DISABLE_1";
      `ShiftCtrlEnum_defaultEncoding_SLL_1 : decode_to_execute_SHIFT_CTRL_string = "SLL_1    ";
      `ShiftCtrlEnum_defaultEncoding_SRL_1 : decode_to_execute_SHIFT_CTRL_string = "SRL_1    ";
      `ShiftCtrlEnum_defaultEncoding_SRA_1 : decode_to_execute_SHIFT_CTRL_string = "SRA_1    ";
      default : decode_to_execute_SHIFT_CTRL_string = "?????????";
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
  `endif

  assign decode_CSR_WRITE_OPCODE = _zz_24_;
  assign decode_MEMORY_ENABLE = _zz_51_;
  assign execute_FORMAL_PC_NEXT = decode_to_execute_FORMAL_PC_NEXT;
  assign decode_FORMAL_PC_NEXT = _zz_64_;
  assign decode_MEMORY_STORE = _zz_50_;
  assign decode_BRANCH_CTRL = _zz_1_;
  assign _zz_2_ = _zz_3_;
  assign decode_CSR_READ_OPCODE = _zz_23_;
  assign decode_IS_CSR = _zz_46_;
  assign decode_SRC2_FORCE_ZERO = _zz_37_;
  assign decode_DO_EBREAK = _zz_22_;
  assign decode_SHIFT_CTRL = _zz_4_;
  assign _zz_5_ = _zz_6_;
  assign decode_SRC_LESS_UNSIGNED = _zz_56_;
  assign decode_SRC2_CTRL = _zz_7_;
  assign _zz_8_ = _zz_9_;
  assign execute_REGFILE_WRITE_VALID = decode_to_execute_REGFILE_WRITE_VALID;
  assign decode_ENV_CTRL = _zz_10_;
  assign _zz_11_ = _zz_12_;
  assign decode_ALU_CTRL = _zz_13_;
  assign _zz_14_ = _zz_15_;
  assign decode_ALU_BITWISE_CTRL = _zz_16_;
  assign _zz_17_ = _zz_18_;
  assign decode_SRC1_CTRL = _zz_19_;
  assign _zz_20_ = _zz_21_;
  assign execute_DO_EBREAK = decode_to_execute_DO_EBREAK;
  assign decode_IS_EBREAK = _zz_52_;
  assign execute_CSR_READ_OPCODE = decode_to_execute_CSR_READ_OPCODE;
  assign execute_CSR_WRITE_OPCODE = decode_to_execute_CSR_WRITE_OPCODE;
  assign execute_IS_CSR = decode_to_execute_IS_CSR;
  assign execute_ENV_CTRL = _zz_25_;
  assign execute_BRANCH_CALC = _zz_26_;
  assign execute_BRANCH_DO = _zz_28_;
  assign execute_PC = decode_to_execute_PC;
  assign execute_RS1 = _zz_43_;
  assign execute_BRANCH_CTRL = _zz_27_;
  assign execute_SHIFT_CTRL = _zz_29_;
  assign execute_SRC_LESS_UNSIGNED = decode_to_execute_SRC_LESS_UNSIGNED;
  assign execute_SRC2_FORCE_ZERO = decode_to_execute_SRC2_FORCE_ZERO;
  assign execute_SRC_USE_SUB_LESS = decode_to_execute_SRC_USE_SUB_LESS;
  assign execute_SRC2_CTRL = _zz_33_;
  assign execute_IS_RVC = decode_to_execute_IS_RVC;
  assign execute_SRC1_CTRL = _zz_35_;
  assign decode_SRC_USE_SUB_LESS = _zz_49_;
  assign decode_SRC_ADD_ZERO = _zz_58_;
  assign execute_SRC_ADD_SUB = _zz_32_;
  assign execute_SRC_LESS = _zz_30_;
  assign execute_ALU_CTRL = _zz_38_;
  assign execute_SRC2 = _zz_34_;
  assign execute_SRC1 = _zz_36_;
  assign execute_ALU_BITWISE_CTRL = _zz_40_;
  always @ (*) begin
    _zz_41_ = 1'b0;
    if(execute_RegFilePlugin_regFileWrite_valid)begin
      _zz_41_ = 1'b1;
    end
  end

  always @ (*) begin
    decode_REGFILE_WRITE_VALID = _zz_54_;
    if((decode_INSTRUCTION[11 : 7] == (5'b00000)))begin
      decode_REGFILE_WRITE_VALID = 1'b0;
    end
  end

  assign decode_LEGAL_INSTRUCTION = _zz_59_;
  assign decode_INSTRUCTION_READY = 1'b1;
  always @ (*) begin
    _zz_60_ = execute_REGFILE_WRITE_DATA;
    execute_arbitration_haltItself = 1'b0;
    if(((((execute_arbitration_isValid && execute_MEMORY_ENABLE) && (! dBus_cmd_ready)) && (! execute_DBusSimplePlugin_skipCmd)) && (! execute_DBusSimplePlugin_cmdSent)))begin
      execute_arbitration_haltItself = 1'b1;
    end
    if((((execute_arbitration_isValid && execute_MEMORY_ENABLE) && (! execute_MEMORY_STORE)) && (! dBus_rsp_ready)))begin
      execute_arbitration_haltItself = 1'b1;
    end
    if((execute_arbitration_isValid && execute_MEMORY_ENABLE))begin
      _zz_60_ = execute_DBusSimplePlugin_rspFormated;
    end
    if(_zz_154_)begin
      _zz_60_ = _zz_131_;
      if(_zz_155_)begin
        if(! execute_LightShifterPlugin_done) begin
          execute_arbitration_haltItself = 1'b1;
        end
      end
    end
    if((execute_arbitration_isValid && execute_IS_CSR))begin
      _zz_60_ = execute_CsrPlugin_readData;
      if(execute_CsrPlugin_blockedBySideEffects)begin
        execute_arbitration_haltItself = 1'b1;
      end
    end
  end

  assign execute_MEMORY_ADDRESS_LOW = _zz_62_;
  assign execute_MEMORY_READ_DATA = _zz_61_;
  assign execute_REGFILE_WRITE_DATA = _zz_39_;
  assign execute_SRC_ADD = _zz_31_;
  assign execute_RS2 = _zz_42_;
  assign execute_INSTRUCTION = decode_to_execute_INSTRUCTION;
  assign execute_MEMORY_STORE = decode_to_execute_MEMORY_STORE;
  assign execute_MEMORY_ENABLE = decode_to_execute_MEMORY_ENABLE;
  assign execute_ALIGNEMENT_FAULT = _zz_63_;
  assign decode_IS_RVC = _zz_65_;
  assign decode_PC = _zz_67_;
  always @ (*) begin
    decode_INSTRUCTION = _zz_66_;
    if((_zz_148_ != (3'b000)))begin
      decode_INSTRUCTION = IBusSimplePlugin_injectionPort_payload_regNext;
    end
  end

  always @ (*) begin
    decode_arbitration_haltItself = 1'b0;
    decode_arbitration_isValid = (IBusSimplePlugin_decompressor_decodeInput_valid && (! IBusSimplePlugin_injector_decodeRemoved));
    IBusSimplePlugin_injectionPort_ready = 1'b0;
    case(_zz_148_)
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
        IBusSimplePlugin_injectionPort_ready = 1'b1;
      end
      default : begin
      end
    endcase
  end

  always @ (*) begin
    decode_arbitration_haltByOther = 1'b0;
    if(CsrPlugin_interrupt)begin
      decode_arbitration_haltByOther = decode_arbitration_isValid;
    end
    if(((execute_arbitration_isValid && (execute_ENV_CTRL == `EnvCtrlEnum_defaultEncoding_XRET)) != (1'b0)))begin
      decode_arbitration_haltByOther = 1'b1;
    end
  end

  always @ (*) begin
    decode_arbitration_removeIt = 1'b0;
    if(decodeExceptionPort_valid)begin
      decode_arbitration_removeIt = 1'b1;
    end
    if(_zz_147_)begin
      decode_arbitration_removeIt = 1'b1;
    end
    if(decode_arbitration_isFlushed)begin
      decode_arbitration_removeIt = 1'b1;
    end
  end

  always @ (*) begin
    decode_arbitration_flushAll = 1'b0;
    execute_arbitration_haltByOther = 1'b0;
    execute_arbitration_removeIt = 1'b0;
    IBusSimplePlugin_fetcherHalt = 1'b0;
    IBusSimplePlugin_fetcherflushIt = 1'b0;
    CsrPlugin_jumpInterface_valid = 1'b0;
    CsrPlugin_jumpInterface_payload = (32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx);
    if(BranchPlugin_jumpInterface_valid)begin
      decode_arbitration_flushAll = 1'b1;
    end
    CsrPlugin_exceptionPortCtrl_exceptionValids_execute = CsrPlugin_exceptionPortCtrl_exceptionValidsRegs_execute;
    if(_zz_156_)begin
      decode_arbitration_flushAll = 1'b1;
      execute_arbitration_removeIt = 1'b1;
      CsrPlugin_exceptionPortCtrl_exceptionValids_execute = 1'b1;
    end
    if(execute_arbitration_isFlushed)begin
      CsrPlugin_exceptionPortCtrl_exceptionValids_execute = 1'b0;
    end
    if(({CsrPlugin_exceptionPortCtrl_exceptionValidsRegs_execute,CsrPlugin_exceptionPortCtrl_exceptionValidsRegs_decode} != (2'b00)))begin
      IBusSimplePlugin_fetcherHalt = 1'b1;
    end
    if(_zz_157_)begin
      IBusSimplePlugin_fetcherHalt = 1'b1;
      CsrPlugin_jumpInterface_valid = 1'b1;
      CsrPlugin_jumpInterface_payload = {CsrPlugin_xtvec_base,(2'b00)};
      decode_arbitration_flushAll = 1'b1;
    end
    if(_zz_158_)begin
      IBusSimplePlugin_fetcherHalt = 1'b1;
      CsrPlugin_jumpInterface_valid = 1'b1;
      decode_arbitration_flushAll = 1'b1;
      case(_zz_159_)
        2'b11 : begin
          CsrPlugin_jumpInterface_payload = CsrPlugin_mepc;
        end
        default : begin
        end
      endcase
    end
    if(_zz_160_)begin
      execute_arbitration_haltByOther = 1'b1;
      if(_zz_161_)begin
        IBusSimplePlugin_fetcherflushIt = 1'b1;
        IBusSimplePlugin_fetcherHalt = 1'b1;
      end
    end
    if(DebugPlugin_haltIt)begin
      IBusSimplePlugin_fetcherHalt = 1'b1;
    end
    if(_zz_162_)begin
      IBusSimplePlugin_fetcherHalt = 1'b1;
    end
    if(execute_arbitration_isFlushed)begin
      execute_arbitration_removeIt = 1'b1;
    end
  end

  always @ (*) begin
    execute_arbitration_flushAll = 1'b0;
    if(_zz_160_)begin
      if(_zz_161_)begin
        execute_arbitration_flushAll = 1'b1;
      end
    end
  end

  always @ (*) begin
    IBusSimplePlugin_incomingInstruction = 1'b0;
    if(IBusSimplePlugin_iBusRsp_stages_1_input_valid)begin
      IBusSimplePlugin_incomingInstruction = 1'b1;
    end
    if((IBusSimplePlugin_decompressor_bufferValid && (IBusSimplePlugin_decompressor_bufferData[1 : 0] != (2'b11))))begin
      IBusSimplePlugin_incomingInstruction = 1'b1;
    end
  end

  always @ (*) begin
    CsrPlugin_forceMachineWire = 1'b0;
    CsrPlugin_allowException = 1'b1;
    if(DebugPlugin_godmode)begin
      CsrPlugin_allowException = 1'b0;
      CsrPlugin_forceMachineWire = 1'b1;
    end
  end

  always @ (*) begin
    CsrPlugin_allowInterrupts = 1'b1;
    if((DebugPlugin_haltIt || DebugPlugin_stepIt))begin
      CsrPlugin_allowInterrupts = 1'b0;
    end
  end

  assign IBusSimplePlugin_jump_pcLoad_valid = ({CsrPlugin_jumpInterface_valid,BranchPlugin_jumpInterface_valid} != (2'b00));
  assign _zz_68_ = {CsrPlugin_jumpInterface_valid,BranchPlugin_jumpInterface_valid};
  assign IBusSimplePlugin_jump_pcLoad_payload = (_zz_172_[0] ? BranchPlugin_jumpInterface_payload : CsrPlugin_jumpInterface_payload);
  assign _zz_69_ = (! IBusSimplePlugin_fetcherHalt);
  assign IBusSimplePlugin_fetchPc_output_valid = (IBusSimplePlugin_fetchPc_preOutput_valid && _zz_69_);
  assign IBusSimplePlugin_fetchPc_preOutput_ready = (IBusSimplePlugin_fetchPc_output_ready && _zz_69_);
  assign IBusSimplePlugin_fetchPc_output_payload = IBusSimplePlugin_fetchPc_preOutput_payload;
  always @ (*) begin
    IBusSimplePlugin_fetchPc_propagatePc = 1'b0;
    if((IBusSimplePlugin_iBusRsp_stages_1_input_valid && IBusSimplePlugin_iBusRsp_stages_1_input_ready))begin
      IBusSimplePlugin_fetchPc_propagatePc = 1'b1;
    end
  end

  always @ (*) begin
    IBusSimplePlugin_fetchPc_pc = (IBusSimplePlugin_fetchPc_pcReg + _zz_175_);
    IBusSimplePlugin_fetchPc_samplePcNext = 1'b0;
    if(IBusSimplePlugin_fetchPc_inc)begin
      IBusSimplePlugin_fetchPc_pc[1] = 1'b0;
    end
    if(IBusSimplePlugin_fetchPc_propagatePc)begin
      IBusSimplePlugin_fetchPc_samplePcNext = 1'b1;
    end
    if(IBusSimplePlugin_jump_pcLoad_valid)begin
      IBusSimplePlugin_fetchPc_samplePcNext = 1'b1;
      IBusSimplePlugin_fetchPc_pc = IBusSimplePlugin_jump_pcLoad_payload;
    end
    if(_zz_163_)begin
      IBusSimplePlugin_fetchPc_samplePcNext = 1'b1;
    end
    IBusSimplePlugin_fetchPc_pc[0] = 1'b0;
  end

  assign IBusSimplePlugin_fetchPc_preOutput_valid = _zz_70_;
  assign IBusSimplePlugin_fetchPc_preOutput_payload = IBusSimplePlugin_fetchPc_pc;
  assign IBusSimplePlugin_decodePc_pcPlus = (IBusSimplePlugin_decodePc_pcReg + _zz_177_);
  always @ (*) begin
    IBusSimplePlugin_decodePc_injectedDecode = 1'b0;
    if((_zz_148_ != (3'b000)))begin
      IBusSimplePlugin_decodePc_injectedDecode = 1'b1;
    end
  end

  assign IBusSimplePlugin_iBusRsp_stages_0_input_valid = IBusSimplePlugin_fetchPc_output_valid;
  assign IBusSimplePlugin_fetchPc_output_ready = IBusSimplePlugin_iBusRsp_stages_0_input_ready;
  assign IBusSimplePlugin_iBusRsp_stages_0_input_payload = IBusSimplePlugin_fetchPc_output_payload;
  assign IBusSimplePlugin_iBusRsp_stages_0_inputSample = 1'b1;
  always @ (*) begin
    IBusSimplePlugin_iBusRsp_stages_0_halt = 1'b0;
    if((IBusSimplePlugin_iBusRsp_stages_0_input_valid && ((! IBusSimplePlugin_cmd_valid) || (! IBusSimplePlugin_cmd_ready))))begin
      IBusSimplePlugin_iBusRsp_stages_0_halt = 1'b1;
    end
  end

  assign _zz_71_ = (! IBusSimplePlugin_iBusRsp_stages_0_halt);
  assign IBusSimplePlugin_iBusRsp_stages_0_input_ready = (IBusSimplePlugin_iBusRsp_stages_0_output_ready && _zz_71_);
  assign IBusSimplePlugin_iBusRsp_stages_0_output_valid = (IBusSimplePlugin_iBusRsp_stages_0_input_valid && _zz_71_);
  assign IBusSimplePlugin_iBusRsp_stages_0_output_payload = IBusSimplePlugin_iBusRsp_stages_0_input_payload;
  assign IBusSimplePlugin_iBusRsp_stages_1_halt = 1'b0;
  assign _zz_72_ = (! IBusSimplePlugin_iBusRsp_stages_1_halt);
  assign IBusSimplePlugin_iBusRsp_stages_1_input_ready = (IBusSimplePlugin_iBusRsp_stages_1_output_ready && _zz_72_);
  assign IBusSimplePlugin_iBusRsp_stages_1_output_valid = (IBusSimplePlugin_iBusRsp_stages_1_input_valid && _zz_72_);
  assign IBusSimplePlugin_iBusRsp_stages_1_output_payload = IBusSimplePlugin_iBusRsp_stages_1_input_payload;
  assign IBusSimplePlugin_iBusRsp_stages_0_output_ready = _zz_73_;
  assign _zz_73_ = ((1'b0 && (! _zz_74_)) || IBusSimplePlugin_iBusRsp_stages_1_input_ready);
  assign _zz_74_ = _zz_75_;
  assign IBusSimplePlugin_iBusRsp_stages_1_input_valid = _zz_74_;
  assign IBusSimplePlugin_iBusRsp_stages_1_input_payload = IBusSimplePlugin_fetchPc_pcReg;
  always @ (*) begin
    IBusSimplePlugin_iBusRsp_readyForError = 1'b1;
    if((IBusSimplePlugin_decompressor_bufferValid && IBusSimplePlugin_decompressor_isRvc))begin
      IBusSimplePlugin_iBusRsp_readyForError = 1'b0;
    end
  end

  assign IBusSimplePlugin_decompressor_rawInDecode = (IBusSimplePlugin_decompressor_bufferValid ? {IBusSimplePlugin_iBusRsp_output_payload_rsp_inst[15 : 0],IBusSimplePlugin_decompressor_bufferData} : {IBusSimplePlugin_iBusRsp_output_payload_rsp_inst[31 : 16],(IBusSimplePlugin_iBusRsp_output_payload_pc[1] ? IBusSimplePlugin_iBusRsp_output_payload_rsp_inst[31 : 16] : IBusSimplePlugin_iBusRsp_output_payload_rsp_inst[15 : 0])});
  assign IBusSimplePlugin_decompressor_isRvc = (IBusSimplePlugin_decompressor_rawInDecode[1 : 0] != (2'b11));
  assign _zz_76_ = IBusSimplePlugin_decompressor_rawInDecode[15 : 0];
  always @ (*) begin
    IBusSimplePlugin_decompressor_decompressed = (32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx);
    case(_zz_167_)
      5'b00000 : begin
        IBusSimplePlugin_decompressor_decompressed = {{{{{{{{{(2'b00),_zz_76_[10 : 7]},_zz_76_[12 : 11]},_zz_76_[5]},_zz_76_[6]},(2'b00)},(5'b00010)},(3'b000)},_zz_78_},(7'b0010011)};
      end
      5'b00010 : begin
        IBusSimplePlugin_decompressor_decompressed = {{{{_zz_79_,_zz_77_},(3'b010)},_zz_78_},(7'b0000011)};
      end
      5'b00110 : begin
        IBusSimplePlugin_decompressor_decompressed = {{{{{_zz_79_[11 : 5],_zz_78_},_zz_77_},(3'b010)},_zz_79_[4 : 0]},(7'b0100011)};
      end
      5'b01000 : begin
        IBusSimplePlugin_decompressor_decompressed = {{{{_zz_81_,_zz_76_[11 : 7]},(3'b000)},_zz_76_[11 : 7]},(7'b0010011)};
      end
      5'b01001 : begin
        IBusSimplePlugin_decompressor_decompressed = {{{{{_zz_84_[20],_zz_84_[10 : 1]},_zz_84_[11]},_zz_84_[19 : 12]},_zz_96_},(7'b1101111)};
      end
      5'b01010 : begin
        IBusSimplePlugin_decompressor_decompressed = {{{{_zz_81_,(5'b00000)},(3'b000)},_zz_76_[11 : 7]},(7'b0010011)};
      end
      5'b01011 : begin
        IBusSimplePlugin_decompressor_decompressed = ((_zz_76_[11 : 7] == (5'b00010)) ? {{{{{{{{{_zz_88_,_zz_76_[4 : 3]},_zz_76_[5]},_zz_76_[2]},_zz_76_[6]},(4'b0000)},_zz_76_[11 : 7]},(3'b000)},_zz_76_[11 : 7]},(7'b0010011)} : {{_zz_178_[31 : 12],_zz_76_[11 : 7]},(7'b0110111)});
      end
      5'b01100 : begin
        IBusSimplePlugin_decompressor_decompressed = {{{{{((_zz_76_[11 : 10] == (2'b10)) ? _zz_102_ : {{(1'b0),(_zz_227_ || _zz_228_)},(5'b00000)}),(((! _zz_76_[11]) || _zz_98_) ? _zz_76_[6 : 2] : _zz_78_)},_zz_77_},_zz_100_},_zz_77_},(_zz_98_ ? (7'b0010011) : (7'b0110011))};
      end
      5'b01101 : begin
        IBusSimplePlugin_decompressor_decompressed = {{{{{_zz_91_[20],_zz_91_[10 : 1]},_zz_91_[11]},_zz_91_[19 : 12]},_zz_95_},(7'b1101111)};
      end
      5'b01110 : begin
        IBusSimplePlugin_decompressor_decompressed = {{{{{{{_zz_94_[12],_zz_94_[10 : 5]},_zz_95_},_zz_77_},(3'b000)},_zz_94_[4 : 1]},_zz_94_[11]},(7'b1100011)};
      end
      5'b01111 : begin
        IBusSimplePlugin_decompressor_decompressed = {{{{{{{_zz_94_[12],_zz_94_[10 : 5]},_zz_95_},_zz_77_},(3'b001)},_zz_94_[4 : 1]},_zz_94_[11]},(7'b1100011)};
      end
      5'b10000 : begin
        IBusSimplePlugin_decompressor_decompressed = {{{{{(7'b0000000),_zz_76_[6 : 2]},_zz_76_[11 : 7]},(3'b001)},_zz_76_[11 : 7]},(7'b0010011)};
      end
      5'b10010 : begin
        IBusSimplePlugin_decompressor_decompressed = {{{{{{{{(4'b0000),_zz_76_[3 : 2]},_zz_76_[12]},_zz_76_[6 : 4]},(2'b00)},_zz_97_},(3'b010)},_zz_76_[11 : 7]},(7'b0000011)};
      end
      5'b10100 : begin
        IBusSimplePlugin_decompressor_decompressed = ((_zz_76_[12 : 2] == (11'b10000000000)) ? (32'b00000000000100000000000001110011) : ((_zz_76_[6 : 2] == (5'b00000)) ? {{{{(12'b000000000000),_zz_76_[11 : 7]},(3'b000)},(_zz_76_[12] ? _zz_96_ : _zz_95_)},(7'b1100111)} : {{{{{_zz_229_,_zz_230_},(_zz_231_ ? _zz_232_ : _zz_95_)},(3'b000)},_zz_76_[11 : 7]},(7'b0110011)}));
      end
      5'b10110 : begin
        IBusSimplePlugin_decompressor_decompressed = {{{{{_zz_179_[11 : 5],_zz_76_[6 : 2]},_zz_97_},(3'b010)},_zz_180_[4 : 0]},(7'b0100011)};
      end
      default : begin
      end
    endcase
  end

  assign _zz_77_ = {(2'b01),_zz_76_[9 : 7]};
  assign _zz_78_ = {(2'b01),_zz_76_[4 : 2]};
  assign _zz_79_ = {{{{(5'b00000),_zz_76_[5]},_zz_76_[12 : 10]},_zz_76_[6]},(2'b00)};
  assign _zz_80_ = _zz_76_[12];
  always @ (*) begin
    _zz_81_[11] = _zz_80_;
    _zz_81_[10] = _zz_80_;
    _zz_81_[9] = _zz_80_;
    _zz_81_[8] = _zz_80_;
    _zz_81_[7] = _zz_80_;
    _zz_81_[6] = _zz_80_;
    _zz_81_[5] = _zz_80_;
    _zz_81_[4 : 0] = _zz_76_[6 : 2];
  end

  assign _zz_82_ = _zz_76_[12];
  always @ (*) begin
    _zz_83_[9] = _zz_82_;
    _zz_83_[8] = _zz_82_;
    _zz_83_[7] = _zz_82_;
    _zz_83_[6] = _zz_82_;
    _zz_83_[5] = _zz_82_;
    _zz_83_[4] = _zz_82_;
    _zz_83_[3] = _zz_82_;
    _zz_83_[2] = _zz_82_;
    _zz_83_[1] = _zz_82_;
    _zz_83_[0] = _zz_82_;
  end

  assign _zz_84_ = {{{{{{{{_zz_83_,_zz_76_[8]},_zz_76_[10 : 9]},_zz_76_[6]},_zz_76_[7]},_zz_76_[2]},_zz_76_[11]},_zz_76_[5 : 3]},(1'b0)};
  assign _zz_85_ = _zz_76_[12];
  always @ (*) begin
    _zz_86_[14] = _zz_85_;
    _zz_86_[13] = _zz_85_;
    _zz_86_[12] = _zz_85_;
    _zz_86_[11] = _zz_85_;
    _zz_86_[10] = _zz_85_;
    _zz_86_[9] = _zz_85_;
    _zz_86_[8] = _zz_85_;
    _zz_86_[7] = _zz_85_;
    _zz_86_[6] = _zz_85_;
    _zz_86_[5] = _zz_85_;
    _zz_86_[4] = _zz_85_;
    _zz_86_[3] = _zz_85_;
    _zz_86_[2] = _zz_85_;
    _zz_86_[1] = _zz_85_;
    _zz_86_[0] = _zz_85_;
  end

  assign _zz_87_ = _zz_76_[12];
  always @ (*) begin
    _zz_88_[2] = _zz_87_;
    _zz_88_[1] = _zz_87_;
    _zz_88_[0] = _zz_87_;
  end

  assign _zz_89_ = _zz_76_[12];
  always @ (*) begin
    _zz_90_[9] = _zz_89_;
    _zz_90_[8] = _zz_89_;
    _zz_90_[7] = _zz_89_;
    _zz_90_[6] = _zz_89_;
    _zz_90_[5] = _zz_89_;
    _zz_90_[4] = _zz_89_;
    _zz_90_[3] = _zz_89_;
    _zz_90_[2] = _zz_89_;
    _zz_90_[1] = _zz_89_;
    _zz_90_[0] = _zz_89_;
  end

  assign _zz_91_ = {{{{{{{{_zz_90_,_zz_76_[8]},_zz_76_[10 : 9]},_zz_76_[6]},_zz_76_[7]},_zz_76_[2]},_zz_76_[11]},_zz_76_[5 : 3]},(1'b0)};
  assign _zz_92_ = _zz_76_[12];
  always @ (*) begin
    _zz_93_[4] = _zz_92_;
    _zz_93_[3] = _zz_92_;
    _zz_93_[2] = _zz_92_;
    _zz_93_[1] = _zz_92_;
    _zz_93_[0] = _zz_92_;
  end

  assign _zz_94_ = {{{{{_zz_93_,_zz_76_[6 : 5]},_zz_76_[2]},_zz_76_[11 : 10]},_zz_76_[4 : 3]},(1'b0)};
  assign _zz_95_ = (5'b00000);
  assign _zz_96_ = (5'b00001);
  assign _zz_97_ = (5'b00010);
  assign _zz_98_ = (_zz_76_[11 : 10] != (2'b11));
  always @ (*) begin
    case(_zz_168_)
      2'b00 : begin
        _zz_99_ = (3'b000);
      end
      2'b01 : begin
        _zz_99_ = (3'b100);
      end
      2'b10 : begin
        _zz_99_ = (3'b110);
      end
      default : begin
        _zz_99_ = (3'b111);
      end
    endcase
  end

  always @ (*) begin
    case(_zz_169_)
      2'b00 : begin
        _zz_100_ = (3'b101);
      end
      2'b01 : begin
        _zz_100_ = (3'b101);
      end
      2'b10 : begin
        _zz_100_ = (3'b111);
      end
      default : begin
        _zz_100_ = _zz_99_;
      end
    endcase
  end

  assign _zz_101_ = _zz_76_[12];
  always @ (*) begin
    _zz_102_[6] = _zz_101_;
    _zz_102_[5] = _zz_101_;
    _zz_102_[4] = _zz_101_;
    _zz_102_[3] = _zz_101_;
    _zz_102_[2] = _zz_101_;
    _zz_102_[1] = _zz_101_;
    _zz_102_[0] = _zz_101_;
  end

  assign IBusSimplePlugin_decompressor_decodeInput_valid = (IBusSimplePlugin_decompressor_isRvc ? (IBusSimplePlugin_decompressor_bufferValid || IBusSimplePlugin_iBusRsp_output_valid) : (IBusSimplePlugin_iBusRsp_output_valid && (IBusSimplePlugin_decompressor_bufferValid || (! IBusSimplePlugin_iBusRsp_output_payload_pc[1]))));
  assign IBusSimplePlugin_decompressor_decodeInput_payload_pc = IBusSimplePlugin_iBusRsp_output_payload_pc;
  assign IBusSimplePlugin_decompressor_decodeInput_payload_isRvc = IBusSimplePlugin_decompressor_isRvc;
  assign IBusSimplePlugin_decompressor_decodeInput_payload_rsp_inst = (IBusSimplePlugin_decompressor_isRvc ? IBusSimplePlugin_decompressor_decompressed : IBusSimplePlugin_decompressor_rawInDecode);
  assign IBusSimplePlugin_iBusRsp_output_ready = ((! IBusSimplePlugin_decompressor_decodeInput_valid) || (! (((! IBusSimplePlugin_decompressor_decodeInput_ready) || ((IBusSimplePlugin_decompressor_isRvc && (! IBusSimplePlugin_iBusRsp_output_payload_pc[1])) && (IBusSimplePlugin_iBusRsp_output_payload_rsp_inst[17 : 16] != (2'b11)))) || (((! IBusSimplePlugin_decompressor_isRvc) && IBusSimplePlugin_decompressor_bufferValid) && (IBusSimplePlugin_iBusRsp_output_payload_rsp_inst[17 : 16] != (2'b11))))));
  assign IBusSimplePlugin_pcValids_0 = IBusSimplePlugin_injector_nextPcCalc_valids_0;
  assign IBusSimplePlugin_pcValids_1 = IBusSimplePlugin_injector_nextPcCalc_valids_1;
  assign IBusSimplePlugin_decompressor_decodeInput_ready = (! decode_arbitration_isStuck);
  assign _zz_67_ = IBusSimplePlugin_decodePc_pcReg;
  assign _zz_66_ = IBusSimplePlugin_decompressor_decodeInput_payload_rsp_inst;
  assign _zz_65_ = IBusSimplePlugin_decompressor_decodeInput_payload_isRvc;
  assign _zz_64_ = (decode_PC + _zz_182_);
  assign iBus_cmd_valid = IBusSimplePlugin_cmd_valid;
  assign IBusSimplePlugin_cmd_ready = iBus_cmd_ready;
  assign iBus_cmd_payload_pc = IBusSimplePlugin_cmd_payload_pc;
  assign IBusSimplePlugin_pendingCmdNext = (_zz_183_ - iBus_rsp_valid);
  assign IBusSimplePlugin_cmd_valid = ((IBusSimplePlugin_iBusRsp_stages_0_input_valid && (IBusSimplePlugin_pendingCmd != (1'b1))) && (! ({execute_arbitration_isValid,decode_arbitration_isValid} != (2'b00))));
  assign IBusSimplePlugin_cmd_payload_pc = {IBusSimplePlugin_iBusRsp_stages_0_input_payload[31 : 2],(2'b00)};
  assign iBus_rsp_takeWhen_valid = (iBus_rsp_valid && (! (IBusSimplePlugin_rspJoin_discardCounter != (1'b0))));
  assign iBus_rsp_takeWhen_payload_error = iBus_rsp_payload_error;
  assign iBus_rsp_takeWhen_payload_inst = iBus_rsp_payload_inst;
  assign IBusSimplePlugin_rspJoin_rspBuffer_rspStream_valid = iBus_rsp_takeWhen_valid;
  assign IBusSimplePlugin_rspJoin_rspBuffer_rspStream_payload_error = iBus_rsp_takeWhen_payload_error;
  assign IBusSimplePlugin_rspJoin_rspBuffer_rspStream_payload_inst = iBus_rsp_takeWhen_payload_inst;
  always @ (*) begin
    IBusSimplePlugin_rspJoin_rspBufferOutput_valid = IBusSimplePlugin_rspJoin_rspBuffer_rspStream_valid;
    if(IBusSimplePlugin_rspJoin_rspBuffer_validReg)begin
      IBusSimplePlugin_rspJoin_rspBufferOutput_valid = 1'b1;
    end
  end

  assign IBusSimplePlugin_rspJoin_rspBuffer_rspStream_ready = IBusSimplePlugin_rspJoin_rspBufferOutput_ready;
  assign IBusSimplePlugin_rspJoin_rspBufferOutput_payload_error = IBusSimplePlugin_rspJoin_rspBuffer_rspStream_payload_error;
  assign IBusSimplePlugin_rspJoin_rspBufferOutput_payload_inst = IBusSimplePlugin_rspJoin_rspBuffer_rspStream_payload_inst;
  assign IBusSimplePlugin_rspJoin_fetchRsp_pc = IBusSimplePlugin_iBusRsp_stages_1_output_payload;
  always @ (*) begin
    IBusSimplePlugin_rspJoin_fetchRsp_rsp_error = IBusSimplePlugin_rspJoin_rspBufferOutput_payload_error;
    if((! IBusSimplePlugin_rspJoin_rspBufferOutput_valid))begin
      IBusSimplePlugin_rspJoin_fetchRsp_rsp_error = 1'b0;
    end
  end

  assign IBusSimplePlugin_rspJoin_fetchRsp_rsp_inst = IBusSimplePlugin_rspJoin_rspBufferOutput_payload_inst;
  assign IBusSimplePlugin_rspJoin_exceptionDetected = 1'b0;
  assign IBusSimplePlugin_rspJoin_redoRequired = 1'b0;
  assign IBusSimplePlugin_rspJoin_join_valid = (IBusSimplePlugin_iBusRsp_stages_1_output_valid && IBusSimplePlugin_rspJoin_rspBufferOutput_valid);
  assign IBusSimplePlugin_rspJoin_join_payload_pc = IBusSimplePlugin_rspJoin_fetchRsp_pc;
  assign IBusSimplePlugin_rspJoin_join_payload_rsp_error = IBusSimplePlugin_rspJoin_fetchRsp_rsp_error;
  assign IBusSimplePlugin_rspJoin_join_payload_rsp_inst = IBusSimplePlugin_rspJoin_fetchRsp_rsp_inst;
  assign IBusSimplePlugin_rspJoin_join_payload_isRvc = IBusSimplePlugin_rspJoin_fetchRsp_isRvc;
  assign IBusSimplePlugin_iBusRsp_stages_1_output_ready = (IBusSimplePlugin_iBusRsp_stages_1_output_valid ? (IBusSimplePlugin_rspJoin_join_valid && IBusSimplePlugin_rspJoin_join_ready) : IBusSimplePlugin_rspJoin_join_ready);
  assign IBusSimplePlugin_rspJoin_rspBufferOutput_ready = (IBusSimplePlugin_rspJoin_join_valid && IBusSimplePlugin_rspJoin_join_ready);
  assign _zz_103_ = (! (IBusSimplePlugin_rspJoin_exceptionDetected || IBusSimplePlugin_rspJoin_redoRequired));
  assign IBusSimplePlugin_rspJoin_join_ready = (IBusSimplePlugin_iBusRsp_output_ready && _zz_103_);
  assign IBusSimplePlugin_iBusRsp_output_valid = (IBusSimplePlugin_rspJoin_join_valid && _zz_103_);
  assign IBusSimplePlugin_iBusRsp_output_payload_pc = IBusSimplePlugin_rspJoin_join_payload_pc;
  assign IBusSimplePlugin_iBusRsp_output_payload_rsp_error = IBusSimplePlugin_rspJoin_join_payload_rsp_error;
  assign IBusSimplePlugin_iBusRsp_output_payload_rsp_inst = IBusSimplePlugin_rspJoin_join_payload_rsp_inst;
  assign IBusSimplePlugin_iBusRsp_output_payload_isRvc = IBusSimplePlugin_rspJoin_join_payload_isRvc;
  assign _zz_63_ = (((dBus_cmd_payload_size == (2'b10)) && (dBus_cmd_payload_address[1 : 0] != (2'b00))) || ((dBus_cmd_payload_size == (2'b01)) && (dBus_cmd_payload_address[0 : 0] != (1'b0))));
  always @ (*) begin
    execute_DBusSimplePlugin_skipCmd = 1'b0;
    if(execute_ALIGNEMENT_FAULT)begin
      execute_DBusSimplePlugin_skipCmd = 1'b1;
    end
  end

  assign dBus_cmd_valid = (((((execute_arbitration_isValid && execute_MEMORY_ENABLE) && (! execute_arbitration_isStuckByOthers)) && (! execute_arbitration_isFlushed)) && (! execute_DBusSimplePlugin_skipCmd)) && (! execute_DBusSimplePlugin_cmdSent));
  assign dBus_cmd_payload_wr = execute_MEMORY_STORE;
  assign dBus_cmd_payload_size = execute_INSTRUCTION[13 : 12];
  always @ (*) begin
    case(dBus_cmd_payload_size)
      2'b00 : begin
        _zz_104_ = {{{execute_RS2[7 : 0],execute_RS2[7 : 0]},execute_RS2[7 : 0]},execute_RS2[7 : 0]};
      end
      2'b01 : begin
        _zz_104_ = {execute_RS2[15 : 0],execute_RS2[15 : 0]};
      end
      default : begin
        _zz_104_ = execute_RS2[31 : 0];
      end
    endcase
  end

  assign dBus_cmd_payload_data = _zz_104_;
  assign _zz_62_ = dBus_cmd_payload_address[1 : 0];
  always @ (*) begin
    case(dBus_cmd_payload_size)
      2'b00 : begin
        _zz_105_ = (4'b0001);
      end
      2'b01 : begin
        _zz_105_ = (4'b0011);
      end
      default : begin
        _zz_105_ = (4'b1111);
      end
    endcase
  end

  assign execute_DBusSimplePlugin_formalMask = (_zz_105_ <<< dBus_cmd_payload_address[1 : 0]);
  assign dBus_cmd_payload_address = execute_SRC_ADD;
  assign _zz_61_ = dBus_rsp_data;
  always @ (*) begin
    DBusSimplePlugin_memoryExceptionPort_valid = 1'b0;
    DBusSimplePlugin_memoryExceptionPort_payload_code = (4'bxxxx);
    if(execute_ALIGNEMENT_FAULT)begin
      DBusSimplePlugin_memoryExceptionPort_payload_code = {1'd0, _zz_184_};
      DBusSimplePlugin_memoryExceptionPort_valid = 1'b1;
    end
    if((! ((execute_arbitration_isValid && execute_MEMORY_ENABLE) && (1'b0 || (! execute_arbitration_isStuckByOthers)))))begin
      DBusSimplePlugin_memoryExceptionPort_valid = 1'b0;
    end
  end

  assign DBusSimplePlugin_memoryExceptionPort_payload_badAddr = execute_REGFILE_WRITE_DATA;
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

  assign _zz_106_ = (execute_DBusSimplePlugin_rspShifted[7] && (! execute_INSTRUCTION[14]));
  always @ (*) begin
    _zz_107_[31] = _zz_106_;
    _zz_107_[30] = _zz_106_;
    _zz_107_[29] = _zz_106_;
    _zz_107_[28] = _zz_106_;
    _zz_107_[27] = _zz_106_;
    _zz_107_[26] = _zz_106_;
    _zz_107_[25] = _zz_106_;
    _zz_107_[24] = _zz_106_;
    _zz_107_[23] = _zz_106_;
    _zz_107_[22] = _zz_106_;
    _zz_107_[21] = _zz_106_;
    _zz_107_[20] = _zz_106_;
    _zz_107_[19] = _zz_106_;
    _zz_107_[18] = _zz_106_;
    _zz_107_[17] = _zz_106_;
    _zz_107_[16] = _zz_106_;
    _zz_107_[15] = _zz_106_;
    _zz_107_[14] = _zz_106_;
    _zz_107_[13] = _zz_106_;
    _zz_107_[12] = _zz_106_;
    _zz_107_[11] = _zz_106_;
    _zz_107_[10] = _zz_106_;
    _zz_107_[9] = _zz_106_;
    _zz_107_[8] = _zz_106_;
    _zz_107_[7 : 0] = execute_DBusSimplePlugin_rspShifted[7 : 0];
  end

  assign _zz_108_ = (execute_DBusSimplePlugin_rspShifted[15] && (! execute_INSTRUCTION[14]));
  always @ (*) begin
    _zz_109_[31] = _zz_108_;
    _zz_109_[30] = _zz_108_;
    _zz_109_[29] = _zz_108_;
    _zz_109_[28] = _zz_108_;
    _zz_109_[27] = _zz_108_;
    _zz_109_[26] = _zz_108_;
    _zz_109_[25] = _zz_108_;
    _zz_109_[24] = _zz_108_;
    _zz_109_[23] = _zz_108_;
    _zz_109_[22] = _zz_108_;
    _zz_109_[21] = _zz_108_;
    _zz_109_[20] = _zz_108_;
    _zz_109_[19] = _zz_108_;
    _zz_109_[18] = _zz_108_;
    _zz_109_[17] = _zz_108_;
    _zz_109_[16] = _zz_108_;
    _zz_109_[15 : 0] = execute_DBusSimplePlugin_rspShifted[15 : 0];
  end

  always @ (*) begin
    case(_zz_170_)
      2'b00 : begin
        execute_DBusSimplePlugin_rspFormated = _zz_107_;
      end
      2'b01 : begin
        execute_DBusSimplePlugin_rspFormated = _zz_109_;
      end
      default : begin
        execute_DBusSimplePlugin_rspFormated = execute_DBusSimplePlugin_rspShifted;
      end
    endcase
  end

  assign _zz_111_ = ((decode_INSTRUCTION & (32'b00000000000000000000000001001000)) == (32'b00000000000000000000000001001000));
  assign _zz_112_ = ((decode_INSTRUCTION & (32'b00000000000000000000000001010000)) == (32'b00000000000000000000000000010000));
  assign _zz_113_ = ((decode_INSTRUCTION & (32'b00000000000000000100000001010000)) == (32'b00000000000000000100000001010000));
  assign _zz_114_ = ((decode_INSTRUCTION & (32'b00010000000100000011000001010000)) == (32'b00000000000100000000000001010000));
  assign _zz_115_ = ((decode_INSTRUCTION & (32'b00000000000000000000000000000100)) == (32'b00000000000000000000000000000100));
  assign _zz_110_ = {(((decode_INSTRUCTION & _zz_233_) == (32'b00000000000000000101000000010000)) != (1'b0)),{({_zz_234_,_zz_235_} != (2'b00)),{({_zz_236_,_zz_237_} != (2'b00)),{(_zz_238_ != _zz_239_),{_zz_240_,{_zz_241_,_zz_242_}}}}}};
  assign _zz_59_ = ({((decode_INSTRUCTION & (32'b00000000000000000000000001011111)) == (32'b00000000000000000000000000010111)),{((decode_INSTRUCTION & (32'b00000000000000000000000001111111)) == (32'b00000000000000000000000001101111)),{((decode_INSTRUCTION & (32'b00000000000000000001000001101111)) == (32'b00000000000000000000000000000011)),{((decode_INSTRUCTION & _zz_331_) == (32'b00000000000000000001000001110011)),{(_zz_332_ == _zz_333_),{_zz_334_,{_zz_335_,_zz_336_}}}}}}} != (20'b00000000000000000000));
  assign _zz_58_ = _zz_185_[0];
  assign _zz_116_ = _zz_110_[2 : 1];
  assign _zz_57_ = _zz_116_;
  assign _zz_56_ = _zz_186_[0];
  assign _zz_117_ = _zz_110_[7 : 6];
  assign _zz_55_ = _zz_117_;
  assign _zz_54_ = _zz_187_[0];
  assign _zz_118_ = _zz_110_[10 : 9];
  assign _zz_53_ = _zz_118_;
  assign _zz_52_ = _zz_188_[0];
  assign _zz_51_ = _zz_189_[0];
  assign _zz_50_ = _zz_190_[0];
  assign _zz_49_ = _zz_191_[0];
  assign _zz_119_ = _zz_110_[16 : 15];
  assign _zz_48_ = _zz_119_;
  assign _zz_120_ = _zz_110_[18 : 17];
  assign _zz_47_ = _zz_120_;
  assign _zz_46_ = _zz_192_[0];
  assign _zz_121_ = _zz_110_[24 : 23];
  assign _zz_45_ = _zz_121_;
  assign _zz_122_ = _zz_110_[26 : 25];
  assign _zz_44_ = _zz_122_;
  assign decodeExceptionPort_valid = ((decode_arbitration_isValid && decode_INSTRUCTION_READY) && (! decode_LEGAL_INSTRUCTION));
  assign decodeExceptionPort_payload_code = (4'b0010);
  assign decodeExceptionPort_payload_badAddr = decode_INSTRUCTION;
  assign execute_RegFilePlugin_regFileReadAddress1 = decode_INSTRUCTION[19 : 15];
  assign execute_RegFilePlugin_regFileReadAddress2 = decode_INSTRUCTION[24 : 20];
  assign _zz_123_ = (! execute_arbitration_isStuck);
  assign execute_RegFilePlugin_rs1Data = _zz_152_;
  assign execute_RegFilePlugin_rs2Data = _zz_153_;
  assign _zz_43_ = execute_RegFilePlugin_rs1Data;
  assign _zz_42_ = execute_RegFilePlugin_rs2Data;
  assign execute_RegFilePlugin_regFileWrite_valid = (execute_REGFILE_WRITE_VALID && execute_arbitration_isFiring);
  assign execute_RegFilePlugin_regFileWrite_payload_address = execute_INSTRUCTION[11 : 7];
  assign execute_RegFilePlugin_regFileWrite_payload_data = _zz_60_;
  always @ (*) begin
    case(execute_ALU_BITWISE_CTRL)
      `AluBitwiseCtrlEnum_defaultEncoding_AND_1 : begin
        execute_IntAluPlugin_bitwise = (execute_SRC1 & execute_SRC2);
      end
      `AluBitwiseCtrlEnum_defaultEncoding_OR_1 : begin
        execute_IntAluPlugin_bitwise = (execute_SRC1 | execute_SRC2);
      end
      default : begin
        execute_IntAluPlugin_bitwise = (execute_SRC1 ^ execute_SRC2);
      end
    endcase
  end

  always @ (*) begin
    case(execute_ALU_CTRL)
      `AluCtrlEnum_defaultEncoding_BITWISE : begin
        _zz_124_ = execute_IntAluPlugin_bitwise;
      end
      `AluCtrlEnum_defaultEncoding_SLT_SLTU : begin
        _zz_124_ = {31'd0, _zz_193_};
      end
      default : begin
        _zz_124_ = execute_SRC_ADD_SUB;
      end
    endcase
  end

  assign _zz_39_ = _zz_124_;
  assign _zz_37_ = (decode_SRC_ADD_ZERO && (! decode_SRC_USE_SUB_LESS));
  always @ (*) begin
    case(execute_SRC1_CTRL)
      `Src1CtrlEnum_defaultEncoding_RS : begin
        _zz_125_ = execute_RS1;
      end
      `Src1CtrlEnum_defaultEncoding_PC_INCREMENT : begin
        _zz_125_ = {29'd0, _zz_194_};
      end
      `Src1CtrlEnum_defaultEncoding_IMU : begin
        _zz_125_ = {execute_INSTRUCTION[31 : 12],(12'b000000000000)};
      end
      default : begin
        _zz_125_ = {27'd0, _zz_195_};
      end
    endcase
  end

  assign _zz_36_ = _zz_125_;
  assign _zz_126_ = _zz_196_[11];
  always @ (*) begin
    _zz_127_[19] = _zz_126_;
    _zz_127_[18] = _zz_126_;
    _zz_127_[17] = _zz_126_;
    _zz_127_[16] = _zz_126_;
    _zz_127_[15] = _zz_126_;
    _zz_127_[14] = _zz_126_;
    _zz_127_[13] = _zz_126_;
    _zz_127_[12] = _zz_126_;
    _zz_127_[11] = _zz_126_;
    _zz_127_[10] = _zz_126_;
    _zz_127_[9] = _zz_126_;
    _zz_127_[8] = _zz_126_;
    _zz_127_[7] = _zz_126_;
    _zz_127_[6] = _zz_126_;
    _zz_127_[5] = _zz_126_;
    _zz_127_[4] = _zz_126_;
    _zz_127_[3] = _zz_126_;
    _zz_127_[2] = _zz_126_;
    _zz_127_[1] = _zz_126_;
    _zz_127_[0] = _zz_126_;
  end

  assign _zz_128_ = _zz_197_[11];
  always @ (*) begin
    _zz_129_[19] = _zz_128_;
    _zz_129_[18] = _zz_128_;
    _zz_129_[17] = _zz_128_;
    _zz_129_[16] = _zz_128_;
    _zz_129_[15] = _zz_128_;
    _zz_129_[14] = _zz_128_;
    _zz_129_[13] = _zz_128_;
    _zz_129_[12] = _zz_128_;
    _zz_129_[11] = _zz_128_;
    _zz_129_[10] = _zz_128_;
    _zz_129_[9] = _zz_128_;
    _zz_129_[8] = _zz_128_;
    _zz_129_[7] = _zz_128_;
    _zz_129_[6] = _zz_128_;
    _zz_129_[5] = _zz_128_;
    _zz_129_[4] = _zz_128_;
    _zz_129_[3] = _zz_128_;
    _zz_129_[2] = _zz_128_;
    _zz_129_[1] = _zz_128_;
    _zz_129_[0] = _zz_128_;
  end

  always @ (*) begin
    case(execute_SRC2_CTRL)
      `Src2CtrlEnum_defaultEncoding_RS : begin
        _zz_130_ = execute_RS2;
      end
      `Src2CtrlEnum_defaultEncoding_IMI : begin
        _zz_130_ = {_zz_127_,execute_INSTRUCTION[31 : 20]};
      end
      `Src2CtrlEnum_defaultEncoding_IMS : begin
        _zz_130_ = {_zz_129_,{execute_INSTRUCTION[31 : 25],execute_INSTRUCTION[11 : 7]}};
      end
      default : begin
        _zz_130_ = execute_PC;
      end
    endcase
  end

  assign _zz_34_ = _zz_130_;
  always @ (*) begin
    execute_SrcPlugin_addSub = _zz_198_;
    if(execute_SRC2_FORCE_ZERO)begin
      execute_SrcPlugin_addSub = execute_SRC1;
    end
  end

  assign execute_SrcPlugin_less = ((execute_SRC1[31] == execute_SRC2[31]) ? execute_SrcPlugin_addSub[31] : (execute_SRC_LESS_UNSIGNED ? execute_SRC2[31] : execute_SRC1[31]));
  assign _zz_32_ = execute_SrcPlugin_addSub;
  assign _zz_31_ = execute_SrcPlugin_addSub;
  assign _zz_30_ = execute_SrcPlugin_less;
  assign execute_LightShifterPlugin_isShift = (execute_SHIFT_CTRL != `ShiftCtrlEnum_defaultEncoding_DISABLE_1);
  assign execute_LightShifterPlugin_amplitude = (execute_LightShifterPlugin_isActive ? execute_LightShifterPlugin_amplitudeReg : execute_SRC2[4 : 0]);
  assign execute_LightShifterPlugin_shiftInput = (execute_LightShifterPlugin_isActive ? execute_LightShifterPlugin_shiftReg : execute_SRC1);
  assign execute_LightShifterPlugin_done = (execute_LightShifterPlugin_amplitude[4 : 1] == (4'b0000));
  always @ (*) begin
    case(execute_SHIFT_CTRL)
      `ShiftCtrlEnum_defaultEncoding_SLL_1 : begin
        _zz_131_ = (execute_LightShifterPlugin_shiftInput <<< 1);
      end
      default : begin
        _zz_131_ = _zz_205_;
      end
    endcase
  end

  assign execute_BranchPlugin_eq = (execute_SRC1 == execute_SRC2);
  assign _zz_132_ = execute_INSTRUCTION[14 : 12];
  always @ (*) begin
    if((_zz_132_ == (3'b000))) begin
        _zz_133_ = execute_BranchPlugin_eq;
    end else if((_zz_132_ == (3'b001))) begin
        _zz_133_ = (! execute_BranchPlugin_eq);
    end else if((((_zz_132_ & (3'b101)) == (3'b101)))) begin
        _zz_133_ = (! execute_SRC_LESS);
    end else begin
        _zz_133_ = execute_SRC_LESS;
    end
  end

  always @ (*) begin
    case(execute_BRANCH_CTRL)
      `BranchCtrlEnum_defaultEncoding_INC : begin
        _zz_134_ = 1'b0;
      end
      `BranchCtrlEnum_defaultEncoding_JAL : begin
        _zz_134_ = 1'b1;
      end
      `BranchCtrlEnum_defaultEncoding_JALR : begin
        _zz_134_ = 1'b1;
      end
      default : begin
        _zz_134_ = _zz_133_;
      end
    endcase
  end

  assign _zz_28_ = _zz_134_;
  assign execute_BranchPlugin_branch_src1 = ((execute_BRANCH_CTRL == `BranchCtrlEnum_defaultEncoding_JALR) ? execute_RS1 : execute_PC);
  assign _zz_135_ = _zz_207_[19];
  always @ (*) begin
    _zz_136_[10] = _zz_135_;
    _zz_136_[9] = _zz_135_;
    _zz_136_[8] = _zz_135_;
    _zz_136_[7] = _zz_135_;
    _zz_136_[6] = _zz_135_;
    _zz_136_[5] = _zz_135_;
    _zz_136_[4] = _zz_135_;
    _zz_136_[3] = _zz_135_;
    _zz_136_[2] = _zz_135_;
    _zz_136_[1] = _zz_135_;
    _zz_136_[0] = _zz_135_;
  end

  assign _zz_137_ = _zz_208_[11];
  always @ (*) begin
    _zz_138_[19] = _zz_137_;
    _zz_138_[18] = _zz_137_;
    _zz_138_[17] = _zz_137_;
    _zz_138_[16] = _zz_137_;
    _zz_138_[15] = _zz_137_;
    _zz_138_[14] = _zz_137_;
    _zz_138_[13] = _zz_137_;
    _zz_138_[12] = _zz_137_;
    _zz_138_[11] = _zz_137_;
    _zz_138_[10] = _zz_137_;
    _zz_138_[9] = _zz_137_;
    _zz_138_[8] = _zz_137_;
    _zz_138_[7] = _zz_137_;
    _zz_138_[6] = _zz_137_;
    _zz_138_[5] = _zz_137_;
    _zz_138_[4] = _zz_137_;
    _zz_138_[3] = _zz_137_;
    _zz_138_[2] = _zz_137_;
    _zz_138_[1] = _zz_137_;
    _zz_138_[0] = _zz_137_;
  end

  assign _zz_139_ = _zz_209_[11];
  always @ (*) begin
    _zz_140_[18] = _zz_139_;
    _zz_140_[17] = _zz_139_;
    _zz_140_[16] = _zz_139_;
    _zz_140_[15] = _zz_139_;
    _zz_140_[14] = _zz_139_;
    _zz_140_[13] = _zz_139_;
    _zz_140_[12] = _zz_139_;
    _zz_140_[11] = _zz_139_;
    _zz_140_[10] = _zz_139_;
    _zz_140_[9] = _zz_139_;
    _zz_140_[8] = _zz_139_;
    _zz_140_[7] = _zz_139_;
    _zz_140_[6] = _zz_139_;
    _zz_140_[5] = _zz_139_;
    _zz_140_[4] = _zz_139_;
    _zz_140_[3] = _zz_139_;
    _zz_140_[2] = _zz_139_;
    _zz_140_[1] = _zz_139_;
    _zz_140_[0] = _zz_139_;
  end

  always @ (*) begin
    case(execute_BRANCH_CTRL)
      `BranchCtrlEnum_defaultEncoding_JAL : begin
        _zz_141_ = {{_zz_136_,{{{execute_INSTRUCTION[31],execute_INSTRUCTION[19 : 12]},execute_INSTRUCTION[20]},execute_INSTRUCTION[30 : 21]}},1'b0};
      end
      `BranchCtrlEnum_defaultEncoding_JALR : begin
        _zz_141_ = {_zz_138_,execute_INSTRUCTION[31 : 20]};
      end
      default : begin
        _zz_141_ = {{_zz_140_,{{{execute_INSTRUCTION[31],execute_INSTRUCTION[7]},execute_INSTRUCTION[30 : 25]},execute_INSTRUCTION[11 : 8]}},1'b0};
      end
    endcase
  end

  assign execute_BranchPlugin_branch_src2 = _zz_141_;
  assign execute_BranchPlugin_branchAdder = (execute_BranchPlugin_branch_src1 + execute_BranchPlugin_branch_src2);
  assign _zz_26_ = {execute_BranchPlugin_branchAdder[31 : 1],(1'b0)};
  assign BranchPlugin_jumpInterface_valid = ((execute_arbitration_isValid && (! execute_arbitration_isStuckByOthers)) && execute_BRANCH_DO);
  assign BranchPlugin_jumpInterface_payload = execute_BRANCH_CALC;
  always @ (*) begin
    CsrPlugin_privilege = (2'b11);
    if(CsrPlugin_forceMachineWire)begin
      CsrPlugin_privilege = (2'b11);
    end
  end

  assign CsrPlugin_misa_base = (2'b01);
  assign CsrPlugin_misa_extensions = (26'b00000000000000000000000000);
  assign CsrPlugin_exceptionPortCtrl_exceptionTargetPrivilegeUncapped = (2'b11);
  assign CsrPlugin_exceptionPortCtrl_exceptionTargetPrivilege = ((CsrPlugin_privilege < CsrPlugin_exceptionPortCtrl_exceptionTargetPrivilegeUncapped) ? CsrPlugin_exceptionPortCtrl_exceptionTargetPrivilegeUncapped : CsrPlugin_privilege);
  assign _zz_142_ = {CsrPlugin_selfException_valid,DBusSimplePlugin_memoryExceptionPort_valid};
  assign _zz_143_ = _zz_210_[0];
  always @ (*) begin
    CsrPlugin_exceptionPortCtrl_exceptionValids_decode = CsrPlugin_exceptionPortCtrl_exceptionValidsRegs_decode;
    if(decodeExceptionPort_valid)begin
      CsrPlugin_exceptionPortCtrl_exceptionValids_decode = 1'b1;
    end
    if(decode_arbitration_isFlushed)begin
      CsrPlugin_exceptionPortCtrl_exceptionValids_decode = 1'b0;
    end
  end

  assign CsrPlugin_exceptionPendings_0 = CsrPlugin_exceptionPortCtrl_exceptionValidsRegs_decode;
  assign CsrPlugin_exceptionPendings_1 = CsrPlugin_exceptionPortCtrl_exceptionValidsRegs_execute;
  always @ (*) begin
    CsrPlugin_interrupt = 1'b0;
    CsrPlugin_interruptCode = (4'bxxxx);
    CsrPlugin_interruptTargetPrivilege = (2'bxx);
    if((CsrPlugin_mstatus_MIE || (CsrPlugin_privilege < (2'b11))))begin
      if((((CsrPlugin_mip_MTIP && CsrPlugin_mie_MTIE) && 1'b1) && (! 1'b0)))begin
        CsrPlugin_interrupt = 1'b1;
        CsrPlugin_interruptCode = (4'b0111);
        CsrPlugin_interruptTargetPrivilege = (2'b11);
      end
      if((((CsrPlugin_mip_MSIP && CsrPlugin_mie_MSIE) && 1'b1) && (! 1'b0)))begin
        CsrPlugin_interrupt = 1'b1;
        CsrPlugin_interruptCode = (4'b0011);
        CsrPlugin_interruptTargetPrivilege = (2'b11);
      end
      if((((CsrPlugin_mip_MEIP && CsrPlugin_mie_MEIE) && 1'b1) && (! 1'b0)))begin
        CsrPlugin_interrupt = 1'b1;
        CsrPlugin_interruptCode = (4'b1011);
        CsrPlugin_interruptTargetPrivilege = (2'b11);
      end
    end
    if((! CsrPlugin_allowInterrupts))begin
      CsrPlugin_interrupt = 1'b0;
    end
  end

  assign CsrPlugin_exception = (CsrPlugin_exceptionPortCtrl_exceptionValids_execute && CsrPlugin_allowException);
  assign CsrPlugin_lastStageWasWfi = 1'b0;
  always @ (*) begin
    CsrPlugin_pipelineLiberator_done = ((! (execute_arbitration_isValid != (1'b0))) && IBusSimplePlugin_pcValids_1);
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

  always @ (*) begin
    CsrPlugin_xtvec_mode = (2'bxx);
    CsrPlugin_xtvec_base = (30'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx);
    case(CsrPlugin_targetPrivilege)
      2'b11 : begin
        CsrPlugin_xtvec_mode = CsrPlugin_mtvec_mode;
        CsrPlugin_xtvec_base = CsrPlugin_mtvec_base;
      end
      default : begin
      end
    endcase
  end

  assign contextSwitching = CsrPlugin_jumpInterface_valid;
  assign _zz_24_ = (! (((decode_INSTRUCTION[14 : 13] == (2'b01)) && (decode_INSTRUCTION[19 : 15] == (5'b00000))) || ((decode_INSTRUCTION[14 : 13] == (2'b11)) && (decode_INSTRUCTION[19 : 15] == (5'b00000)))));
  assign _zz_23_ = (decode_INSTRUCTION[13 : 7] != (7'b0100000));
  assign execute_CsrPlugin_inWfi = 1'b0;
  assign execute_CsrPlugin_blockedBySideEffects = 1'b0;
  always @ (*) begin
    execute_CsrPlugin_illegalAccess = 1'b1;
    execute_CsrPlugin_readData = (32'b00000000000000000000000000000000);
    case(execute_CsrPlugin_csrAddress)
      12'b101111000000 : begin
        execute_CsrPlugin_illegalAccess = 1'b0;
        execute_CsrPlugin_readData[31 : 0] = _zz_144_;
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
        execute_CsrPlugin_readData[31 : 0] = _zz_145_;
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
      if((CsrPlugin_privilege < execute_INSTRUCTION[29 : 28]))begin
        execute_CsrPlugin_illegalInstruction = 1'b1;
      end
    end
  end

  always @ (*) begin
    CsrPlugin_selfException_valid = 1'b0;
    CsrPlugin_selfException_payload_code = (4'bxxxx);
    if((execute_arbitration_isValid && (execute_ENV_CTRL == `EnvCtrlEnum_defaultEncoding_ECALL)))begin
      CsrPlugin_selfException_valid = 1'b1;
      case(CsrPlugin_privilege)
        2'b00 : begin
          CsrPlugin_selfException_payload_code = (4'b1000);
        end
        default : begin
          CsrPlugin_selfException_payload_code = (4'b1011);
        end
      endcase
    end
    if((execute_arbitration_isValid && (execute_ENV_CTRL == `EnvCtrlEnum_defaultEncoding_EBREAK)))begin
      CsrPlugin_selfException_valid = 1'b1;
      CsrPlugin_selfException_payload_code = (4'b0011);
    end
  end

  assign CsrPlugin_selfException_payload_badAddr = execute_INSTRUCTION;
  assign execute_CsrPlugin_writeInstruction = ((execute_arbitration_isValid && execute_IS_CSR) && execute_CSR_WRITE_OPCODE);
  assign execute_CsrPlugin_readInstruction = ((execute_arbitration_isValid && execute_IS_CSR) && execute_CSR_READ_OPCODE);
  assign execute_CsrPlugin_writeEnable = ((execute_CsrPlugin_writeInstruction && (! execute_CsrPlugin_blockedBySideEffects)) && (! execute_arbitration_isStuckByOthers));
  assign execute_CsrPlugin_readEnable = ((execute_CsrPlugin_readInstruction && (! execute_CsrPlugin_blockedBySideEffects)) && (! execute_arbitration_isStuckByOthers));
  assign execute_CsrPlugin_readToWriteData = execute_CsrPlugin_readData;
  always @ (*) begin
    case(_zz_171_)
      1'b0 : begin
        execute_CsrPlugin_writeData = execute_SRC1;
      end
      default : begin
        execute_CsrPlugin_writeData = (execute_INSTRUCTION[12] ? (execute_CsrPlugin_readToWriteData & (~ execute_SRC1)) : (execute_CsrPlugin_readToWriteData | execute_SRC1));
      end
    endcase
  end

  assign execute_CsrPlugin_csrAddress = execute_INSTRUCTION[31 : 20];
  assign _zz_145_ = (_zz_144_ & externalInterruptArray_regNext);
  assign externalInterrupt = (_zz_145_ != (32'b00000000000000000000000000000000));
  always @ (*) begin
    debug_bus_cmd_ready = 1'b1;
    IBusSimplePlugin_injectionPort_valid = 1'b0;
    if(debug_bus_cmd_valid)begin
      case(_zz_164_)
        6'b000000 : begin
        end
        6'b000001 : begin
          if(debug_bus_cmd_payload_wr)begin
            IBusSimplePlugin_injectionPort_valid = 1'b1;
            debug_bus_cmd_ready = IBusSimplePlugin_injectionPort_ready;
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
    if((! _zz_146_))begin
      debug_bus_rsp_data[0] = DebugPlugin_resetIt;
      debug_bus_rsp_data[1] = DebugPlugin_haltIt;
      debug_bus_rsp_data[2] = DebugPlugin_isPipBusy;
      debug_bus_rsp_data[3] = DebugPlugin_haltedByBreak;
      debug_bus_rsp_data[4] = DebugPlugin_stepIt;
    end
  end

  assign IBusSimplePlugin_injectionPort_payload = debug_bus_cmd_payload_data;
  assign _zz_22_ = ((! DebugPlugin_haltIt) && (decode_IS_EBREAK || ((((1'b0 || (DebugPlugin_hardwareBreakpoints_0_valid && (DebugPlugin_hardwareBreakpoints_0_pc == _zz_216_))) || (DebugPlugin_hardwareBreakpoints_1_valid && (DebugPlugin_hardwareBreakpoints_1_pc == _zz_217_))) || (DebugPlugin_hardwareBreakpoints_2_valid && (DebugPlugin_hardwareBreakpoints_2_pc == _zz_218_))) || (DebugPlugin_hardwareBreakpoints_3_valid && (DebugPlugin_hardwareBreakpoints_3_pc == _zz_219_)))));
  assign debug_resetOut = DebugPlugin_resetIt_regNext;
  assign _zz_21_ = decode_SRC1_CTRL;
  assign _zz_19_ = _zz_53_;
  assign _zz_35_ = decode_to_execute_SRC1_CTRL;
  assign _zz_18_ = decode_ALU_BITWISE_CTRL;
  assign _zz_16_ = _zz_57_;
  assign _zz_40_ = decode_to_execute_ALU_BITWISE_CTRL;
  assign _zz_15_ = decode_ALU_CTRL;
  assign _zz_13_ = _zz_48_;
  assign _zz_38_ = decode_to_execute_ALU_CTRL;
  assign _zz_12_ = decode_ENV_CTRL;
  assign _zz_10_ = _zz_47_;
  assign _zz_25_ = decode_to_execute_ENV_CTRL;
  assign _zz_9_ = decode_SRC2_CTRL;
  assign _zz_7_ = _zz_45_;
  assign _zz_33_ = decode_to_execute_SRC2_CTRL;
  assign _zz_6_ = decode_SHIFT_CTRL;
  assign _zz_4_ = _zz_44_;
  assign _zz_29_ = decode_to_execute_SHIFT_CTRL;
  assign _zz_3_ = decode_BRANCH_CTRL;
  assign _zz_1_ = _zz_55_;
  assign _zz_27_ = decode_to_execute_BRANCH_CTRL;
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
  assign iBus_cmd_ready = ((1'b1 && (! iBus_cmd_m2sPipe_valid)) || iBus_cmd_m2sPipe_ready);
  assign iBus_cmd_m2sPipe_valid = _zz_149_;
  assign iBus_cmd_m2sPipe_payload_pc = _zz_150_;
  assign iBusWishbone_ADR = (iBus_cmd_m2sPipe_payload_pc >>> 2);
  assign iBusWishbone_CTI = (3'b000);
  assign iBusWishbone_BTE = (2'b00);
  assign iBusWishbone_SEL = (4'b1111);
  assign iBusWishbone_WE = 1'b0;
  assign iBusWishbone_DAT_MOSI = (32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx);
  assign iBusWishbone_CYC = iBus_cmd_m2sPipe_valid;
  assign iBusWishbone_STB = iBus_cmd_m2sPipe_valid;
  assign iBus_cmd_m2sPipe_ready = (iBus_cmd_m2sPipe_valid && iBusWishbone_ACK);
  assign iBus_rsp_valid = (iBusWishbone_CYC && iBusWishbone_ACK);
  assign iBus_rsp_payload_inst = iBusWishbone_DAT_MISO;
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
        _zz_151_ = (4'b0001);
      end
      2'b01 : begin
        _zz_151_ = (4'b0011);
      end
      default : begin
        _zz_151_ = (4'b1111);
      end
    endcase
  end

  always @ (*) begin
    dBusWishbone_SEL = _zz_226_[3:0];
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
      IBusSimplePlugin_fetchPc_pcReg <= externalResetVector;
      IBusSimplePlugin_fetchPc_inc <= 1'b0;
      _zz_70_ <= 1'b0;
      IBusSimplePlugin_decodePc_pcReg <= externalResetVector;
      _zz_75_ <= 1'b0;
      IBusSimplePlugin_decompressor_bufferValid <= 1'b0;
      IBusSimplePlugin_injector_nextPcCalc_valids_0 <= 1'b0;
      IBusSimplePlugin_injector_nextPcCalc_valids_1 <= 1'b0;
      IBusSimplePlugin_injector_decodeRemoved <= 1'b0;
      IBusSimplePlugin_pendingCmd <= (1'b0);
      IBusSimplePlugin_rspJoin_discardCounter <= (1'b0);
      IBusSimplePlugin_rspJoin_rspBuffer_validReg <= 1'b0;
      execute_DBusSimplePlugin_cmdSent <= 1'b0;
      execute_LightShifterPlugin_isActive <= 1'b0;
      CsrPlugin_mstatus_MIE <= 1'b0;
      CsrPlugin_mstatus_MPIE <= 1'b0;
      CsrPlugin_mstatus_MPP <= (2'b11);
      CsrPlugin_mie_MEIE <= 1'b0;
      CsrPlugin_mie_MTIE <= 1'b0;
      CsrPlugin_mie_MSIE <= 1'b0;
      CsrPlugin_exceptionPortCtrl_exceptionValidsRegs_decode <= 1'b0;
      CsrPlugin_exceptionPortCtrl_exceptionValidsRegs_execute <= 1'b0;
      CsrPlugin_hadException <= 1'b0;
      _zz_144_ <= (32'b00000000000000000000000000000000);
      execute_arbitration_isValid <= 1'b0;
      _zz_148_ <= (3'b000);
      _zz_149_ <= 1'b0;
      dBus_cmd_halfPipe_regs_valid <= 1'b0;
      dBus_cmd_halfPipe_regs_ready <= 1'b1;
    end else begin
      if(IBusSimplePlugin_fetchPc_propagatePc)begin
        IBusSimplePlugin_fetchPc_inc <= 1'b0;
      end
      if(IBusSimplePlugin_jump_pcLoad_valid)begin
        IBusSimplePlugin_fetchPc_inc <= 1'b0;
      end
      if(_zz_163_)begin
        IBusSimplePlugin_fetchPc_inc <= 1'b1;
      end
      if(IBusSimplePlugin_fetchPc_samplePcNext)begin
        IBusSimplePlugin_fetchPc_pcReg <= IBusSimplePlugin_fetchPc_pc;
      end
      _zz_70_ <= 1'b1;
      if((decode_arbitration_isFiring && (! IBusSimplePlugin_decodePc_injectedDecode)))begin
        IBusSimplePlugin_decodePc_pcReg <= IBusSimplePlugin_decodePc_pcPlus;
      end
      if(IBusSimplePlugin_jump_pcLoad_valid)begin
        IBusSimplePlugin_decodePc_pcReg <= IBusSimplePlugin_jump_pcLoad_payload;
      end
      if((IBusSimplePlugin_jump_pcLoad_valid || IBusSimplePlugin_fetcherflushIt))begin
        _zz_75_ <= 1'b0;
      end
      if(_zz_73_)begin
        _zz_75_ <= IBusSimplePlugin_iBusRsp_stages_0_output_valid;
      end
      if((IBusSimplePlugin_decompressor_decodeInput_valid && IBusSimplePlugin_decompressor_decodeInput_ready))begin
        IBusSimplePlugin_decompressor_bufferValid <= 1'b0;
      end
      if(_zz_165_)begin
        IBusSimplePlugin_decompressor_bufferValid <= ((! (((! IBusSimplePlugin_decompressor_isRvc) && (! IBusSimplePlugin_iBusRsp_output_payload_pc[1])) && (! IBusSimplePlugin_decompressor_bufferValid))) && (! ((IBusSimplePlugin_decompressor_isRvc && IBusSimplePlugin_iBusRsp_output_payload_pc[1]) && IBusSimplePlugin_decompressor_decodeInput_ready)));
      end
      if((IBusSimplePlugin_jump_pcLoad_valid || IBusSimplePlugin_fetcherflushIt))begin
        IBusSimplePlugin_decompressor_bufferValid <= 1'b0;
      end
      if((! 1'b0))begin
        IBusSimplePlugin_injector_nextPcCalc_valids_0 <= 1'b1;
      end
      if((IBusSimplePlugin_jump_pcLoad_valid || IBusSimplePlugin_fetcherflushIt))begin
        IBusSimplePlugin_injector_nextPcCalc_valids_0 <= 1'b0;
      end
      if((! execute_arbitration_isStuck))begin
        IBusSimplePlugin_injector_nextPcCalc_valids_1 <= IBusSimplePlugin_injector_nextPcCalc_valids_0;
      end
      if((IBusSimplePlugin_jump_pcLoad_valid || IBusSimplePlugin_fetcherflushIt))begin
        IBusSimplePlugin_injector_nextPcCalc_valids_1 <= 1'b0;
      end
      if(decode_arbitration_removeIt)begin
        IBusSimplePlugin_injector_decodeRemoved <= 1'b1;
      end
      if((IBusSimplePlugin_jump_pcLoad_valid || IBusSimplePlugin_fetcherflushIt))begin
        IBusSimplePlugin_injector_decodeRemoved <= 1'b0;
      end
      IBusSimplePlugin_pendingCmd <= IBusSimplePlugin_pendingCmdNext;
      IBusSimplePlugin_rspJoin_discardCounter <= (IBusSimplePlugin_rspJoin_discardCounter - (iBus_rsp_valid && (IBusSimplePlugin_rspJoin_discardCounter != (1'b0))));
      if((IBusSimplePlugin_jump_pcLoad_valid || IBusSimplePlugin_fetcherflushIt))begin
        IBusSimplePlugin_rspJoin_discardCounter <= (IBusSimplePlugin_pendingCmd - iBus_rsp_valid);
      end
      if(IBusSimplePlugin_rspJoin_rspBuffer_rspStream_valid)begin
        IBusSimplePlugin_rspJoin_rspBuffer_validReg <= 1'b1;
      end
      if(IBusSimplePlugin_rspJoin_rspBufferOutput_ready)begin
        IBusSimplePlugin_rspJoin_rspBuffer_validReg <= 1'b0;
      end
      if((dBus_cmd_valid && dBus_cmd_ready))begin
        execute_DBusSimplePlugin_cmdSent <= 1'b1;
      end
      if((! execute_arbitration_isStuck))begin
        execute_DBusSimplePlugin_cmdSent <= 1'b0;
      end
      if(_zz_154_)begin
        if(_zz_155_)begin
          execute_LightShifterPlugin_isActive <= 1'b1;
          if(execute_LightShifterPlugin_done)begin
            execute_LightShifterPlugin_isActive <= 1'b0;
          end
        end
      end
      if(execute_arbitration_removeIt)begin
        execute_LightShifterPlugin_isActive <= 1'b0;
      end
      if((! decode_arbitration_isStuck))begin
        CsrPlugin_exceptionPortCtrl_exceptionValidsRegs_decode <= 1'b0;
      end else begin
        CsrPlugin_exceptionPortCtrl_exceptionValidsRegs_decode <= CsrPlugin_exceptionPortCtrl_exceptionValids_decode;
      end
      if((! execute_arbitration_isStuck))begin
        CsrPlugin_exceptionPortCtrl_exceptionValidsRegs_execute <= (CsrPlugin_exceptionPortCtrl_exceptionValids_decode && (! decode_arbitration_isStuck));
      end else begin
        CsrPlugin_exceptionPortCtrl_exceptionValidsRegs_execute <= 1'b0;
      end
      CsrPlugin_hadException <= CsrPlugin_exception;
      if(_zz_157_)begin
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
      if(_zz_158_)begin
        case(_zz_159_)
          2'b11 : begin
            CsrPlugin_mstatus_MPP <= (2'b00);
            CsrPlugin_mstatus_MIE <= CsrPlugin_mstatus_MPIE;
            CsrPlugin_mstatus_MPIE <= 1'b1;
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
      if((((! IBusSimplePlugin_iBusRsp_output_ready) && (IBusSimplePlugin_decompressor_decodeInput_valid && IBusSimplePlugin_decompressor_decodeInput_ready)) && (! (IBusSimplePlugin_jump_pcLoad_valid || IBusSimplePlugin_fetcherflushIt))))begin
        IBusSimplePlugin_fetchPc_pcReg[1] <= 1'b1;
      end
      case(_zz_148_)
        3'b000 : begin
          if(IBusSimplePlugin_injectionPort_valid)begin
            _zz_148_ <= (3'b001);
          end
        end
        3'b001 : begin
          _zz_148_ <= (3'b010);
        end
        3'b010 : begin
          _zz_148_ <= (3'b011);
        end
        3'b011 : begin
          if((! decode_arbitration_isStuck))begin
            _zz_148_ <= (3'b100);
          end
        end
        3'b100 : begin
          _zz_148_ <= (3'b000);
        end
        default : begin
        end
      endcase
      case(execute_CsrPlugin_csrAddress)
        12'b101111000000 : begin
          if(execute_CsrPlugin_writeEnable)begin
            _zz_144_ <= execute_CsrPlugin_writeData[31 : 0];
          end
        end
        12'b001100000000 : begin
          if(execute_CsrPlugin_writeEnable)begin
            CsrPlugin_mstatus_MPP <= execute_CsrPlugin_writeData[12 : 11];
            CsrPlugin_mstatus_MPIE <= _zz_220_[0];
            CsrPlugin_mstatus_MIE <= _zz_221_[0];
          end
        end
        12'b001101000001 : begin
        end
        12'b001100000101 : begin
        end
        12'b001101000100 : begin
        end
        12'b001101000011 : begin
        end
        12'b111111000000 : begin
        end
        12'b001101000000 : begin
        end
        12'b001100000100 : begin
          if(execute_CsrPlugin_writeEnable)begin
            CsrPlugin_mie_MEIE <= _zz_223_[0];
            CsrPlugin_mie_MTIE <= _zz_224_[0];
            CsrPlugin_mie_MSIE <= _zz_225_[0];
          end
        end
        12'b001101000010 : begin
        end
        default : begin
        end
      endcase
      if(iBus_cmd_ready)begin
        _zz_149_ <= iBus_cmd_valid;
      end
      if(_zz_166_)begin
        dBus_cmd_halfPipe_regs_valid <= dBus_cmd_valid;
        dBus_cmd_halfPipe_regs_ready <= (! dBus_cmd_valid);
      end else begin
        dBus_cmd_halfPipe_regs_valid <= (! dBus_cmd_halfPipe_ready);
        dBus_cmd_halfPipe_regs_ready <= dBus_cmd_halfPipe_ready;
      end
    end
  end

  always @ (posedge clk) begin
    if(_zz_165_)begin
      IBusSimplePlugin_decompressor_bufferData <= IBusSimplePlugin_iBusRsp_output_payload_rsp_inst[31 : 16];
    end
    if((! execute_arbitration_isStuckByOthers))begin
      execute_LightShifterPlugin_shiftReg <= _zz_60_;
    end
    if(_zz_154_)begin
      if(_zz_155_)begin
        execute_LightShifterPlugin_amplitudeReg <= (execute_LightShifterPlugin_amplitude - (5'b00001));
      end
    end
    CsrPlugin_mip_MEIP <= externalInterrupt;
    CsrPlugin_mip_MTIP <= timerInterrupt;
    CsrPlugin_mip_MSIP <= softwareInterrupt;
    CsrPlugin_mcycle <= (CsrPlugin_mcycle + (64'b0000000000000000000000000000000000000000000000000000000000000001));
    if(execute_arbitration_isFiring)begin
      CsrPlugin_minstret <= (CsrPlugin_minstret + (64'b0000000000000000000000000000000000000000000000000000000000000001));
    end
    if(decodeExceptionPort_valid)begin
      CsrPlugin_exceptionPortCtrl_exceptionContext_code <= decodeExceptionPort_payload_code;
      CsrPlugin_exceptionPortCtrl_exceptionContext_badAddr <= decodeExceptionPort_payload_badAddr;
    end
    if(_zz_156_)begin
      CsrPlugin_exceptionPortCtrl_exceptionContext_code <= (_zz_143_ ? DBusSimplePlugin_memoryExceptionPort_payload_code : CsrPlugin_selfException_payload_code);
      CsrPlugin_exceptionPortCtrl_exceptionContext_badAddr <= (_zz_143_ ? DBusSimplePlugin_memoryExceptionPort_payload_badAddr : CsrPlugin_selfException_payload_badAddr);
    end
    if(_zz_157_)begin
      case(CsrPlugin_targetPrivilege)
        2'b11 : begin
          CsrPlugin_mcause_interrupt <= (! CsrPlugin_hadException);
          CsrPlugin_mcause_exceptionCode <= CsrPlugin_trapCause;
          CsrPlugin_mepc <= execute_PC;
          if(CsrPlugin_hadException)begin
            CsrPlugin_mtval <= CsrPlugin_exceptionPortCtrl_exceptionContext_badAddr;
          end
        end
        default : begin
        end
      endcase
    end
    externalInterruptArray_regNext <= externalInterruptArray;
    if((! execute_arbitration_isStuck))begin
      decode_to_execute_SRC1_CTRL <= _zz_20_;
    end
    if((! execute_arbitration_isStuck))begin
      decode_to_execute_ALU_BITWISE_CTRL <= _zz_17_;
    end
    if((! execute_arbitration_isStuck))begin
      decode_to_execute_ALU_CTRL <= _zz_14_;
    end
    if((! execute_arbitration_isStuck))begin
      decode_to_execute_SRC_USE_SUB_LESS <= decode_SRC_USE_SUB_LESS;
    end
    if(((! execute_arbitration_isStuck) && (! CsrPlugin_exceptionPortCtrl_exceptionValids_execute)))begin
      decode_to_execute_PC <= decode_PC;
    end
    if((! execute_arbitration_isStuck))begin
      decode_to_execute_ENV_CTRL <= _zz_11_;
    end
    if((! execute_arbitration_isStuck))begin
      decode_to_execute_REGFILE_WRITE_VALID <= decode_REGFILE_WRITE_VALID;
    end
    if((! execute_arbitration_isStuck))begin
      decode_to_execute_INSTRUCTION <= decode_INSTRUCTION;
    end
    if((! execute_arbitration_isStuck))begin
      decode_to_execute_SRC2_CTRL <= _zz_8_;
    end
    if((! execute_arbitration_isStuck))begin
      decode_to_execute_SRC_LESS_UNSIGNED <= decode_SRC_LESS_UNSIGNED;
    end
    if((! execute_arbitration_isStuck))begin
      decode_to_execute_SHIFT_CTRL <= _zz_5_;
    end
    if((! execute_arbitration_isStuck))begin
      decode_to_execute_DO_EBREAK <= decode_DO_EBREAK;
    end
    if((! execute_arbitration_isStuck))begin
      decode_to_execute_IS_RVC <= decode_IS_RVC;
    end
    if((! execute_arbitration_isStuck))begin
      decode_to_execute_SRC2_FORCE_ZERO <= decode_SRC2_FORCE_ZERO;
    end
    if((! execute_arbitration_isStuck))begin
      decode_to_execute_IS_CSR <= decode_IS_CSR;
    end
    if((! execute_arbitration_isStuck))begin
      decode_to_execute_CSR_READ_OPCODE <= decode_CSR_READ_OPCODE;
    end
    if((! execute_arbitration_isStuck))begin
      decode_to_execute_BRANCH_CTRL <= _zz_2_;
    end
    if((! execute_arbitration_isStuck))begin
      decode_to_execute_MEMORY_STORE <= decode_MEMORY_STORE;
    end
    if((! execute_arbitration_isStuck))begin
      decode_to_execute_FORMAL_PC_NEXT <= decode_FORMAL_PC_NEXT;
    end
    if((! execute_arbitration_isStuck))begin
      decode_to_execute_MEMORY_ENABLE <= decode_MEMORY_ENABLE;
    end
    if((! execute_arbitration_isStuck))begin
      decode_to_execute_CSR_WRITE_OPCODE <= decode_CSR_WRITE_OPCODE;
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
        if(execute_CsrPlugin_writeEnable)begin
          CsrPlugin_mip_MSIP <= _zz_222_[0];
        end
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
    if(iBus_cmd_ready)begin
      _zz_150_ <= iBus_cmd_payload_pc;
    end
    if(_zz_166_)begin
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
    DebugPlugin_isPipBusy <= (({execute_arbitration_isValid,decode_arbitration_isValid} != (2'b00)) || IBusSimplePlugin_incomingInstruction);
    if(execute_arbitration_isValid)begin
      DebugPlugin_busReadDataReg <= _zz_60_;
    end
    _zz_146_ <= debug_bus_cmd_payload_address[2];
    if(debug_bus_cmd_valid)begin
      case(_zz_164_)
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
    if(_zz_160_)begin
      DebugPlugin_busReadDataReg <= execute_PC;
    end
    DebugPlugin_resetIt_regNext <= DebugPlugin_resetIt;
  end

  always @ (posedge clk) begin
    if(debugReset) begin
      DebugPlugin_resetIt <= 1'b0;
      DebugPlugin_haltIt <= 1'b0;
      DebugPlugin_stepIt <= 1'b0;
      DebugPlugin_godmode <= 1'b0;
      DebugPlugin_haltedByBreak <= 1'b0;
      DebugPlugin_hardwareBreakpoints_0_valid <= 1'b0;
      DebugPlugin_hardwareBreakpoints_1_valid <= 1'b0;
      DebugPlugin_hardwareBreakpoints_2_valid <= 1'b0;
      DebugPlugin_hardwareBreakpoints_3_valid <= 1'b0;
      _zz_147_ <= 1'b0;
    end else begin
      if((DebugPlugin_haltIt && (! DebugPlugin_isPipBusy)))begin
        DebugPlugin_godmode <= 1'b1;
      end
      if(debug_bus_cmd_valid)begin
        case(_zz_164_)
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
              if(debug_bus_cmd_payload_data[25])begin
                DebugPlugin_godmode <= 1'b0;
              end
            end
          end
          6'b000001 : begin
          end
          6'b010000 : begin
            if(debug_bus_cmd_payload_wr)begin
              DebugPlugin_hardwareBreakpoints_0_valid <= _zz_212_[0];
            end
          end
          6'b010001 : begin
            if(debug_bus_cmd_payload_wr)begin
              DebugPlugin_hardwareBreakpoints_1_valid <= _zz_213_[0];
            end
          end
          6'b010010 : begin
            if(debug_bus_cmd_payload_wr)begin
              DebugPlugin_hardwareBreakpoints_2_valid <= _zz_214_[0];
            end
          end
          6'b010011 : begin
            if(debug_bus_cmd_payload_wr)begin
              DebugPlugin_hardwareBreakpoints_3_valid <= _zz_215_[0];
            end
          end
          default : begin
          end
        endcase
      end
      if(_zz_160_)begin
        if(_zz_161_)begin
          DebugPlugin_haltIt <= 1'b1;
          DebugPlugin_haltedByBreak <= 1'b1;
        end
      end
      if(_zz_162_)begin
        if(decode_arbitration_isValid)begin
          DebugPlugin_haltIt <= 1'b1;
        end
      end
      _zz_147_ <= (DebugPlugin_stepIt && decode_arbitration_isFiring);
    end
  end

  always @ (posedge clk) begin
    IBusSimplePlugin_injectionPort_payload_regNext <= IBusSimplePlugin_injectionPort_payload;
  end

endmodule

