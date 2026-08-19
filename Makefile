# =============================================================================
#  Simulation flow for project_reti_logiche (GHDL)
#
#    make test                     analyze + run the whole regression suite
#    make test TB=tb_empty_sequence run a single testbench
#    make wave TB=tb_single_run_01  run one testbench and dump build/<TB>.ghw
#    make syntax                   syntax-only check of every source file
#    make lint                     style check (needs vhdl-style-guide)
#    make clean                    remove the build directory
#
#  Note on exit codes: the supplied testbenches signal the end of a successful
#  simulation with `assert false ... severity failure`, so GHDL always returns
#  non-zero. The verdict is therefore taken from the TEST PASSED / TEST FAILED
#  strings in the simulation transcript, not from the exit status.
# =============================================================================

GHDL      ?= ghdl
VHDL_STD  ?= 08
WORKDIR   ?= build
STOP_TIME ?= 100ms

GHDL_FLAGS = --std=$(VHDL_STD)

RTL_SRCS := $(wildcard src/*.vhd)
TB_SRCS  := $(sort $(wildcard tests/reference/*.vhd) \
                   $(wildcard tests/edge_cases/*.vhd) \
                   $(wildcard tests/scenarios/*.vhd))

# GHDL is invoked from inside $(WORKDIR) so that every generated object file and
# elaborated binary lands there instead of polluting the repository root. Sources
# are passed as paths relative to $(WORKDIR) rather than absolute ones, so the
# flow keeps working when the repository sits under a path containing spaces.
RTL_REL := $(addprefix ../,$(RTL_SRCS))
TB_REL  := $(addprefix ../,$(TB_SRCS))

ALL_TBS := $(basename $(notdir $(TB_SRCS)))
# `make test TB=<name>` narrows the suite down to a single testbench.
TB      ?=
RUN_TBS := $(if $(TB),$(TB),$(ALL_TBS))

.PHONY: help
help:
	@echo "Targets: test, wave, syntax, lint, list, clean"
	@echo "Testbenches:"
	@$(foreach t,$(ALL_TBS),echo "  $(t)";)

.PHONY: list
list:
	@$(foreach t,$(ALL_TBS),echo "$(t)";)

.PHONY: analyze
analyze:
	@mkdir -p $(WORKDIR)
	@cd $(WORKDIR) && $(GHDL) -a $(GHDL_FLAGS) $(RTL_REL) $(TB_REL)

.PHONY: syntax
syntax:
	@$(GHDL) -s $(GHDL_FLAGS) $(RTL_SRCS) $(TB_SRCS) && echo "syntax OK"

.PHONY: test
test: analyze
	@pass=0; fail=0; \
	for tb in $(RUN_TBS); do \
	  printf '  %-26s ' "$$tb"; \
	  out=$$(cd $(WORKDIR) && $(GHDL) -e $(GHDL_FLAGS) "$$tb" >/dev/null 2>&1 \
	         && $(GHDL) -r $(GHDL_FLAGS) "$$tb" --stop-time=$(STOP_TIME) 2>&1); \
	  if printf '%s\n' "$$out" | grep -q 'TEST FAILED'; then \
	    echo "FAIL"; \
	    printf '%s\n' "$$out" | grep 'TEST FAILED' | head -3 | sed 's/^/      /'; \
	    fail=$$((fail + 1)); \
	  elif printf '%s\n' "$$out" | grep -q 'TEST PASSED'; then \
	    echo "pass"; \
	    pass=$$((pass + 1)); \
	  else \
	    echo "ERROR (no verdict reported)"; \
	    printf '%s\n' "$$out" | tail -5 | sed 's/^/      /'; \
	    fail=$$((fail + 1)); \
	  fi; \
	done; \
	echo; echo "  $$pass passed, $$fail failed"; \
	test "$$fail" -eq 0

.PHONY: wave
wave: analyze
	@test -n "$(TB)" || { echo "usage: make wave TB=<testbench>"; exit 1; }
	@cd $(WORKDIR) && $(GHDL) -e $(GHDL_FLAGS) "$(TB)" >/dev/null \
	  && $(GHDL) -r $(GHDL_FLAGS) "$(TB)" --stop-time=$(STOP_TIME) --wave="$(TB).ghw" 2>&1 \
	     | grep -E 'TEST (PASSED|FAILED)' || true
	@echo "waveform: $(WORKDIR)/$(TB).ghw   (open with: gtkwave $(WORKDIR)/$(TB).ghw)"

.PHONY: lint
lint:
	@command -v vsg >/dev/null || { echo "vhdl-style-guide not installed: pip install vsg"; exit 1; }
	@vsg -f $(RTL_SRCS)

.PHONY: clean
clean:
	@rm -rf $(WORKDIR)
	@echo "removed $(WORKDIR)/"
