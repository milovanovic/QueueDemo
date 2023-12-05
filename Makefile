#########################################################################################
# Top name
#########################################################################################
TOP = GenMem

#########################################################################################
# build output directory for compilation
#########################################################################################
# output for all project builds
build_dir = $(abspath ./test_and_run)
# final generated collateral per-project
GEN_COLLATERAL_DIR ?= $(build_dir)/gen-collateral

# chisel generated outputs
FIRRTL_FILE ?= $(build_dir)/$(TOP).fir

# scala firrtl compiler (sfc) outputs
SFC_FIRRTL_BASENAME ?= $(build_dir)/$(TOP).sfc
SFC_FIRRTL_FILE ?= $(SFC_FIRRTL_BASENAME).fir
SFC_ANNO_FILE ?= $(build_dir)/$(TOP).sfc.anno.json

# firtool compiler outputs
MFC_SMEMS_CONF ?= $(build_dir)/$(TOP).mems.conf

# macrocompiler smems in/output
SFC_SMEMS_CONF ?= $(build_dir)/$(TOP).sfc.mems.conf

#########################################################################################
# create verilog files rules and variables
#########################################################################################
SFC_REPL_SEQ_MEM = --infer-rw --repl-seq-mem -c:$(TOP):-o:$(SFC_SMEMS_CONF)
MFC_LOWERING_OPTIONS = emittedLineLength=2048,noAlwaysComb,disallowLocalVariables,verifLabels,locationInfoStyle=wrapInAtSquareBracket,disallowPackedArrays
SFC_LEVEL := none
EXTRA_FIRRTL_OPTIONS += $(SFC_REPL_SEQ_MEM)

#########################################################################################
# create firrtl file rule and variables
#########################################################################################

#########################################################################################
# helper rule to just make verilog files
#########################################################################################
.PHONY: verilog
verilog:
	rm -rf $(GEN_COLLATERAL_DIR)
	sbt "project tapeout; runMain barstools.tapeout.transforms.GenerateModelStageMain \
		--no-dedup \
		--output-file $(SFC_FIRRTL_BASENAME) \
		--output-annotation-file $(SFC_ANNO_FILE) \
		--target-dir $(GEN_COLLATERAL_DIR) \
		--input-file $(FIRRTL_FILE) \
		--log-level error \
		--allow-unrecognized-annotations \
		-X $(SFC_LEVEL) \
		$(EXTRA_FIRRTL_OPTIONS)"
	-mv $(SFC_FIRRTL_BASENAME).lo.fir $(SFC_FIRRTL_FILE) 2> /dev/null # Optionally change file type when SFC generates LowFIRRTL
	firtool \
		--format=fir \
		--export-module-hierarchy \
		--verify-each=true \
		--warn-on-unprocessed-annotations \
		--disable-annotation-classless \
		--disable-annotation-unknown \
		--mlir-timing \
		--lowering-options=$(MFC_LOWERING_OPTIONS) \
		--repl-seq-mem \
		--repl-seq-mem-file=$(MFC_SMEMS_CONF) \
		--repl-seq-mem-circuit=$(TOP) \
		--annotation-file=$(SFC_ANNO_FILE) \
		--split-verilog \
		-o $(GEN_COLLATERAL_DIR) \
		$(SFC_FIRRTL_FILE)

#########################################################################################
# UInt Queue
#########################################################################################
uintQueue:
	make clean
	sbt "runMain example.QueueUIntApp"
	make verilog
#########################################################################################
# SInt Queue
#########################################################################################
sintQueue:
	make clean
	sbt "runMain example.QueueSIntApp"
	make verilog
#########################################################################################
# UInt SyncReadMem
#########################################################################################
uintSyncMem:
	make clean
	sbt "runMain example.SyncReadMemUIntApp"
	make verilog
#########################################################################################
# SInt SyncReadMem
#########################################################################################
sintSyncMem:
	make clean
	sbt "runMain example.SyncReadMemSIntApp"
	make verilog
#########################################################################################
# UInt Mem
#########################################################################################
uintMem:
	make clean
	sbt "runMain example.MemUIntApp"
	make verilog
#########################################################################################
# SInt Mem
#########################################################################################
sintMem:
	make clean
	sbt "runMain example.MemSIntApp"
	make verilog

.PHONY: clean
clean:
	rm -rf $(build_dir)
