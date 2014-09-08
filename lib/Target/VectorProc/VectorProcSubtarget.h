//===-- VectorProcSubtarget.h - Define Subtarget for the VectorProc -----*-//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file declares the VectorProc specific subclass of TargetSubtargetInfo.
//
//===----------------------------------------------------------------------===//

#ifndef VECTORPROC_SUBTARGET_H
#define VECTORPROC_SUBTARGET_H

#include "llvm/Target/TargetSubtargetInfo.h"
#include "llvm/IR/DataLayout.h"
#include "VectorProcFrameLowering.h"
#include "VectorProcISelLowering.h"
#include "VectorProcInstrInfo.h"
#include "VectorProcSelectionDAGInfo.h"
#include <string>

#define GET_SUBTARGETINFO_HEADER
#include "VectorProcGenSubtargetInfo.inc"

namespace llvm {
class StringRef;

class VectorProcSubtarget : public VectorProcGenSubtargetInfo {
  virtual void anchor();
  const DataLayout DL; // Calculates type size & alignment
  std::unique_ptr<const VectorProcInstrInfo> InstrInfo;
  std::unique_ptr<const VectorProcTargetLowering> TLInfo;
  VectorProcSelectionDAGInfo TSInfo;
  std::unique_ptr<const VectorProcFrameLowering> FrameLowering;

public:
  VectorProcSubtarget(const std::string &TT, const std::string &CPU,
                      const std::string &FS, VectorProcTargetMachine *_TM);

  /// ParseSubtargetFeatures - Parses features string setting specified
  /// subtarget options.  Definition of function is auto generated by tblgen.
  void ParseSubtargetFeatures(StringRef CPU, StringRef FS);
  virtual const VectorProcInstrInfo *getInstrInfo() const override { return InstrInfo.get(); }
  virtual const TargetFrameLowering *getFrameLowering() const override {
    return FrameLowering.get();
  }
  virtual const VectorProcRegisterInfo *getRegisterInfo() const override {
    return &InstrInfo->getRegisterInfo();
  }
  virtual const VectorProcTargetLowering *getTargetLowering() const override {
    return TLInfo.get();
  }
  virtual const VectorProcSelectionDAGInfo *getSelectionDAGInfo() const override {
    return &TSInfo;
  }
  virtual const DataLayout *getDataLayout() const override { return &DL; }
};

} // end namespace llvm

#endif