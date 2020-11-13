RTL_SRC = ../../../frontend/rtl/src/
WRAPPER = ../../tb/arith_wrapper.sv

IF = ../../tb/apb_interface.sv
RTL := $(shell find $(RTL_SRC) -name '*.sv')
REFMOD =
PKGS = ../../tb/arith_pkg.sv

SEED = 100
COVER = 100
TRANSA = 5000

RUN_ARGS_COMMON = -access +r -input shm.tcl \
        -coverage all -covoverwrite

apbTest_test:
	xrun -64bit -uvm  +incdir+$(RTL_SRC) $(PKGS) $(IF) $(RTL) $(WRAPPER) ../../tb/arith_top.sv +UVM_TESTNAME=apbTest_test -covtest apbTest_test-$(SEED) -svseed $(SEED) -defparam top.min_cover=$(COVER) -defparam top.min_transa=$(TRANSA) $(RUN_ARGS_COMMON) -xmlibdirpath ../../workspace $(RUN_ARGS)

clean:
	@rm -rf INCA_libs waves.shm rtlsim/* *.history *.log rtlsim/* *.key mdv.log imc.log imc.key ncvlog_*.err *.trn *.dsn .simvision/ xcelium.d simv.daidir *.so *.o *.err

view_waves:
	simvision waves.shm &

view_cover:
	imc &
