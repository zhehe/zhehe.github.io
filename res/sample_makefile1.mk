SHELL = /bin/bash

EXENAME = foo

SRCDIR = src
OBJDIR = obj

NO_COLOR=\033[0m
OK_COLOR=\033[32;01m
ERROR_COLOR=\033[31;01m
WARN_COLOR=\033[33;01m

OK_STRING=$(OK_COLOR)[OK]$(NO_COLOR)
ERROR_STRING=$(ERROR_COLOR)[ERRORS]$(NO_COLOR)
WARN_STRING=$(WARN_COLOR)[WARNINGS]$(NO_COLOR)

AWK_CMD = awk '{ printf "%-30s %-10s\n",$$1, $$2; }'
PRINT_ERROR = printf "$@ $(ERROR_STRING)\n" | $(AWK_CMD) && printf "$(CMD)\n$$LOG\n" && false
PRINT_WARNING = printf "$@ $(WARN_STRING)\n" | $(AWK_CMD) && printf "$(CMD)\n$$LOG\n"
PRINT_OK = printf "$@ $(OK_STRING)\n" | $(AWK_CMD)
BUILD_CMD = LOG=$$($(CMD) 2>&1) ; if [ $$? -eq 1 ]; then $(PRINT_ERROR); elif [ "$$LOG" != "" ] ; then $(PRINT_WARNING); else $(PRINT_OK); fi;

override CXXFLAGS += --std=c++11 -Wno-multichar
ifeq ($(shell echo "int main(){}" | $(CXX) --stdlib=libc++ -x c - -o /dev/null >& /dev/null; echo $$?), 0)
	override CXXFLAGS += --stdlib=libc++
endif

# Apple clang 5.0 requires -fcolor-diagnostics
# GCC 4.9 requires -fdiagnostics-color
ifeq ("$(shell echo "int main(){}" | $(CXX) -fdiagnostics-color -x c - -o /dev/null 2>&1)", "")
	override CXXFLAGS += -fdiagnostics-color
else ifeq ("$(shell echo "int main(){}" | $(CXX) -fcolor-diagnostics -x c - -o /dev/null 2>&1)", "")
	override CXXFLAGS += -fcolor-diagnostics
endif

SRCS := $(shell find $(SRCDIR) -name '*.c') $(shell find $(SRCDIR) -name '*.cpp')
OBJS := $(patsubst $(SRCDIR)/%.c,$(OBJDIR)/%.o,$(patsubst $(SRCDIR)/%.cpp,$(OBJDIR)/%.o,$(SRCS)))
DEPS := $(patsubst $(SRCDIR)/%.c,$(OBJDIR)/%.d,$(patsubst $(SRCDIR)/%.cpp,$(OBJDIR)/%.d,$(SRCS)))

.PHONY: clean

all: $(EXENAME)

ifeq (0, $(words $(findstring $(MAKECMDGOALS), $(NODEPS))))
-include $(DEPS)
endif

$(OBJDIR)/%.o: CMD = $(CXX) $(CXXFLAGS) -c $< -o $@ -MD -MT '$@' -MF '$(patsubst $(OBJDIR)/%.o,$(OBJDIR)/%.d,$@)'

$(OBJDIR)/%.o: $(SRCDIR)/%.cpp
	@mkdir -p $(dir $@)
	@$(BUILD_CMD)

$(EXENAME): CMD = $(CXX) $(OBJS) $(LDFLAGS) -o $@

$(EXENAME): $(OBJS)
	@mkdir -p $(dir $@)
	@$(BUILD_CMD)

clean:
	@rm -rf $(OBJDIR)
	@rm -rf $(EXENAME)
@$(PRINT_OK)
