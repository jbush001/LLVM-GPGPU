//===-- VectorProcAsmParser.cpp - Parse VectorProc assembly to MCInst
//instructions ------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//

#include "MCTargetDesc/VectorProcMCTargetDesc.h"
#include "llvm/ADT/STLExtras.h"
#include "llvm/MC/MCParser/MCAsmLexer.h"
#include "llvm/MC/MCParser/MCParsedAsmOperand.h"
#include "llvm/MC/MCTargetAsmParser.h"
#include "llvm/MC/MCStreamer.h"
#include "llvm/MC/MCSubtargetInfo.h"
#include "llvm/MC/MCExpr.h"
#include "llvm/MC/MCInst.h"
#include "llvm/Support/TargetRegistry.h"
#include "llvm/Support/Debug.h"
using namespace llvm;

namespace {
struct VectorProcOperand;

class VectorProcAsmParser : public MCTargetAsmParser {
  MCAsmParser &Parser;
  MCAsmParser &getParser() const { return Parser; }
  MCAsmLexer &getLexer() const { return Parser.getLexer(); }
  MCSubtargetInfo &STI;

  virtual bool MatchAndEmitInstruction(SMLoc IDLoc, unsigned &Opcode,
                              	 	   OperandVector &Operands,
                                       MCStreamer &Out, uint64_t &ErrorInfo,
                                       bool MatchingInlineAsm) override;

  virtual bool ParseRegister(unsigned &RegNo, SMLoc &StartLoc, 
  						     SMLoc &EndLoc) override;

  virtual bool ParseInstruction(ParseInstructionInfo &Info, StringRef Name,
                                SMLoc NameLoc,
                                OperandVector &Operands) override;

  virtual bool ParseDirective(AsmToken DirectiveID) override;

  bool ParseImmediate(OperandVector &Ops);

  bool ParseOperand(OperandVector &Operands,
                    StringRef Name);


// Auto-generated instruction matching functions
#define GET_ASSEMBLER_HEADER
#include "VectorProcGenAsmMatcher.inc"

  OperandMatchResultTy
  ParseMemoryOperand(OperandVector &Operands);

public:
  VectorProcAsmParser(MCSubtargetInfo &sti, MCAsmParser &_Parser,
                      const MCInstrInfo &MII,
                      const MCTargetOptions &Options)
      : MCTargetAsmParser(), Parser(_Parser), STI(sti) {
    setAvailableFeatures(ComputeAvailableFeatures(STI.getFeatureBits()));
  }
};

/// VectorProcOperand - Instances of this class represented a parsed machine
/// instruction
struct VectorProcOperand : public MCParsedAsmOperand {

  enum KindTy {
    Token,
    Register,
    Immediate,
    Memory
  } Kind;

  SMLoc StartLoc, EndLoc;

  union {
    struct {
      const char *Data;
      unsigned Length;
    } Tok;
    struct {
      unsigned RegNum;
    } Reg;
    struct {
      const MCExpr *Val;
    } Imm;
    struct {
      unsigned BaseReg;
      const MCExpr *Off;
    } Mem;
  };

  VectorProcOperand(KindTy K) : MCParsedAsmOperand(), Kind(K) {}

public:
  VectorProcOperand(const VectorProcOperand &o) : MCParsedAsmOperand() {
    Kind = o.Kind;
    StartLoc = o.StartLoc;
    EndLoc = o.EndLoc;
    switch (Kind) {
    case Register:
      Reg = o.Reg;
      break;
    case Immediate:
      Imm = o.Imm;
      break;
    case Token:
      Tok = o.Tok;
      break;
    case Memory:
      Mem = o.Mem;
      break;
    }
  }

  /// getStartLoc - Gets location of the first token of this operand
  SMLoc getStartLoc() const { return StartLoc; }

  /// getEndLoc - Gets location of the last token of this operand
  SMLoc getEndLoc() const { return EndLoc; }

  unsigned getReg() const {
    assert(Kind == Register && "Invalid type access!");
    return Reg.RegNum;
  }

  const MCExpr *getImm() const {
    assert(Kind == Immediate && "Invalid type access!");
    return Imm.Val;
  }

  StringRef getToken() const {
    assert(Kind == Token && "Invalid type access!");
    return StringRef(Tok.Data, Tok.Length);
  }

  unsigned getMemBase() const {
    assert((Kind == Memory) && "Invalid access!");
    return Mem.BaseReg;
  }

  const MCExpr *getMemOff() const {
    assert((Kind == Memory) && "Invalid access!");
    return Mem.Off;
  }

  // Functions for testing operand type
  bool isReg() const { return Kind == Register; }
  bool isImm() const { return Kind == Immediate; }
  bool isToken() const { return Kind == Token; }
  bool isMem() const { return Kind == Memory; }

  void addExpr(MCInst &Inst, const MCExpr *Expr) const {
    // Add as immediates where possible. Null MCExpr = 0
    if (Expr == 0)
      Inst.addOperand(MCOperand::CreateImm(0));
    else if (const MCConstantExpr *CE = dyn_cast<MCConstantExpr>(Expr))
      Inst.addOperand(MCOperand::CreateImm(CE->getValue()));
    else
      Inst.addOperand(MCOperand::CreateExpr(Expr));
  }

  void addRegOperands(MCInst &Inst, unsigned N) const {
    assert(N == 1 && "Invalid number of operands!");
    Inst.addOperand(MCOperand::CreateReg(getReg()));
  }

  void addImmOperands(MCInst &Inst, unsigned N) const {
    assert(N == 1 && "Invalid number of operands!");
    addExpr(Inst, getImm());
  }

  void addMemOperands(MCInst &Inst, unsigned N) const {
    assert(N == 2 && "Invalid number of operands!");

    Inst.addOperand(MCOperand::CreateReg(getMemBase()));
    const MCExpr *Expr = getMemOff();
    addExpr(Inst, Expr);
  }

  void print(raw_ostream &OS) const {
    switch (Kind) {
    case Token:
      OS << "Tok ";
      OS.write(Tok.Data, Tok.Length);
      break;
    case Register:
      OS << "Reg " << Reg.RegNum;
      break;
    case Immediate:
      OS << "Imm ";
      Imm.Val->print(OS);
      break;
    case Memory:
      OS << "Mem " << Mem.BaseReg << " ";
      if (Mem.Off)
        Mem.Off->print(OS);
      else
        OS << "0";

      break;
    }
  }

  static std::unique_ptr<VectorProcOperand> CreateToken(StringRef Str, SMLoc S) {
    auto Op = make_unique<VectorProcOperand>(Token);
    Op->Tok.Data = Str.data();
    Op->Tok.Length = Str.size();
    Op->StartLoc = S;
    Op->EndLoc = S;
    return Op;
  }

  static std::unique_ptr<VectorProcOperand> CreateReg(unsigned RegNo, SMLoc S, SMLoc E) {
    auto Op = make_unique<VectorProcOperand>(Register);
    Op->Reg.RegNum = RegNo;
    Op->StartLoc = S;
    Op->EndLoc = E;
    return Op;
  }

  static std::unique_ptr<VectorProcOperand> CreateImm(const MCExpr *Val, SMLoc S, SMLoc E) {
    auto Op = make_unique<VectorProcOperand>(Immediate);
    Op->Imm.Val = Val;
    Op->StartLoc = S;
    Op->EndLoc = E;
    return Op;
  }

  static std::unique_ptr<VectorProcOperand> CreateMem(unsigned BaseReg, const MCExpr *Offset,
                                      SMLoc S, SMLoc E) {
    auto Op = make_unique<VectorProcOperand>(Memory);
    Op->Mem.BaseReg = BaseReg;
    Op->Mem.Off = Offset;
    Op->StartLoc = S;
    Op->EndLoc = E;
    return Op;
  }
};
} // end anonymous namespace.

// Auto-generated by TableGen
static unsigned MatchRegisterName(StringRef Name);

bool VectorProcAsmParser::MatchAndEmitInstruction(
    SMLoc IDLoc, unsigned &Opcode,
    OperandVector &Operands, MCStreamer &Out,
    uint64_t &ErrorInfo, bool MatchingInlineAsm) {
  MCInst Inst;
  SMLoc ErrorLoc;
  SmallVector<std::pair<unsigned, std::string>, 4> MapAndConstraints;

  switch (MatchInstructionImpl(Operands, Inst, ErrorInfo, MatchingInlineAsm)) {
  default:
    break;
  case Match_Success:
    Out.EmitInstruction(Inst, STI);
    return false;
  case Match_MissingFeature:
    return Error(IDLoc, "Instruction use requires option to be enabled");
  case Match_MnemonicFail:
    return Error(IDLoc, "Unrecognized instruction mnemonic");
  case Match_InvalidOperand:
    ErrorLoc = IDLoc;
    if (ErrorInfo != ~0U) {
      if (ErrorInfo >= Operands.size())
        return Error(IDLoc, "Too few operands for instruction");

      ErrorLoc = ((VectorProcOperand&)*Operands[ErrorInfo]).getStartLoc();
      if (ErrorLoc == SMLoc())
        ErrorLoc = IDLoc;
    }

    return Error(ErrorLoc, "Invalid operand for instruction");
  }

  llvm_unreachable("Unknown match type detected!");
}

bool VectorProcAsmParser::ParseRegister(unsigned &RegNo, SMLoc &StartLoc,
                                        SMLoc &EndLoc) {
  StartLoc = Parser.getTok().getLoc();
  EndLoc = Parser.getTok().getEndLoc();

  switch (getLexer().getKind()) {
  default:
    return true;
  case AsmToken::Identifier:
    RegNo = MatchRegisterName(getLexer().getTok().getIdentifier());
    if (RegNo == 0)
      return true;

    getLexer().Lex();
	return false;
  }

  return true;
}

bool VectorProcAsmParser::ParseImmediate(OperandVector &Ops) {
  SMLoc S = Parser.getTok().getLoc();
  SMLoc E = SMLoc::getFromPointer(Parser.getTok().getLoc().getPointer() - 1);

  const MCExpr *EVal;
  switch (getLexer().getKind()) {
  default:
    return true;
  case AsmToken::Plus:
  case AsmToken::Minus:
  case AsmToken::Integer:
    if (getParser().parseExpression(EVal))
		return true;

    int64_t ans;
    EVal->EvaluateAsAbsolute(ans);
    Ops.push_back(VectorProcOperand::CreateImm(EVal, S, E));
	return false;
  }
}

bool VectorProcAsmParser::ParseOperand(
    OperandVector &Operands, StringRef Mnemonic) {
  // Check if the current operand has a custom associated parser, if so, try to
  // custom parse the operand, or fallback to the general approach.
  OperandMatchResultTy ResTy = MatchOperandParserImpl(Operands, Mnemonic);
  if (ResTy == MatchOperand_Success)
    return false;

  unsigned RegNo;

  SMLoc StartLoc;
  SMLoc EndLoc;

  // Attempt to parse token as register
  if (!ParseRegister(RegNo, StartLoc, EndLoc)) {
    Operands.push_back(VectorProcOperand::CreateReg(RegNo, StartLoc, EndLoc));
    return false;
  }

  if (!ParseImmediate(Operands))
    return false;

  // Identifier
  const MCExpr *IdVal;
  SMLoc S = Parser.getTok().getLoc();
  if (!getParser().parseExpression(IdVal)) {
    SMLoc E = SMLoc::getFromPointer(Parser.getTok().getLoc().getPointer() - 1);
    Operands.push_back(VectorProcOperand::CreateImm(IdVal, S, E));
    return false;
  }

  // Error
  Error(Parser.getTok().getLoc(), "unknown operand");
  return true;
}

VectorProcAsmParser::OperandMatchResultTy
VectorProcAsmParser::ParseMemoryOperand(
    OperandVector &Operands) {
  SMLoc S = Parser.getTok().getLoc();
  if (getLexer().is(AsmToken::Identifier)) {
    // PC relative memory label memory access
    // load_32 s0, aLabel

    const MCExpr *IdVal;
    if (getParser().parseExpression(IdVal))
      return MatchOperand_ParseFail; // Bad identifier

    SMLoc E = SMLoc::getFromPointer(Parser.getTok().getLoc().getPointer() - 1);

    // This will be turned into a PC relative load.
    Operands.push_back(
        VectorProcOperand::CreateMem(MatchRegisterName("pc"), IdVal, S, E));
    return MatchOperand_Success;
  }

  const MCExpr *Offset;
  if (getLexer().is(AsmToken::Integer) || getLexer().is(AsmToken::Minus)
    || getLexer().is(AsmToken::Plus)) {
    if (getParser().parseExpression(Offset))
      return MatchOperand_ParseFail;
  } else
    Offset = NULL;

  if (!getLexer().is(AsmToken::LParen)) {
    Error(Parser.getTok().getLoc(), "bad memory operand, missing (");
    return MatchOperand_ParseFail;
  }

  getLexer().Lex();
  unsigned RegNo;
  SMLoc _S, _E;
  if (ParseRegister(RegNo, _S, _E)) {
    Error(Parser.getTok().getLoc(), "bad memory operand: invalid register");
    return MatchOperand_ParseFail;
  }

  if (getLexer().isNot(AsmToken::RParen)) {
    Error(Parser.getTok().getLoc(), "bad memory operand, missing )");
    return MatchOperand_ParseFail;
  }

  getLexer().Lex();

  SMLoc E = SMLoc::getFromPointer(Parser.getTok().getLoc().getPointer() - 1);
  Operands.push_back(VectorProcOperand::CreateMem(RegNo, Offset, S, E));

  return MatchOperand_Success;
}

bool VectorProcAsmParser::ParseInstruction(
    ParseInstructionInfo &Info, StringRef Name, SMLoc NameLoc,
    OperandVector &Operands) {
  size_t dotLoc = Name.find('.');
  StringRef stem = Name.substr(0, dotLoc);
  Operands.push_back(VectorProcOperand::CreateToken(stem, NameLoc));
  if (dotLoc < Name.size()) {
    size_t dotLoc2 = Name.rfind('.');
    if (dotLoc == dotLoc2)
      Operands.push_back(
          VectorProcOperand::CreateToken(Name.substr(dotLoc), NameLoc));
    else {
      Operands.push_back(VectorProcOperand::CreateToken(
          Name.substr(dotLoc, dotLoc2 - dotLoc), NameLoc));
      Operands.push_back(
          VectorProcOperand::CreateToken(Name.substr(dotLoc2), NameLoc));
    }
  }

  // If there are no more operands, then finish
  // XXX hash should start a comment, should the lexer just be consuming that?
  if (getLexer().is(AsmToken::EndOfStatement) || getLexer().is(AsmToken::Hash))
    return false;

  // parse operands
  for (;;) {
    if (ParseOperand(Operands, stem))
      return true;

    if (getLexer().isNot(AsmToken::Comma))
      break;

    // Consume comma token
    getLexer().Lex();
  }

  return false;
}

bool VectorProcAsmParser::ParseDirective(AsmToken DirectiveID) { return true; }

extern "C" void LLVMInitializeVectorProcAsmParser() {
  RegisterMCAsmParser<VectorProcAsmParser> X(TheVectorProcTarget);
}

#define GET_REGISTER_MATCHER
#define GET_MATCHER_IMPLEMENTATION
#include "VectorProcGenAsmMatcher.inc"
