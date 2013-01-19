########################################
# USER VARIABLES
EXE = prototype_forum.exe
ifdef SystemRoot
	RUN_CMD = $(EXE)
else
	RUN_CMD = ./$(EXE)
endif

PACKNAME =
SRC =
PCKDIR = ./plugins/
PCK =
PLUGIN =
PLUGINDIR =
OTHER_DEPENDS = resources/*
CONF_FILE = opa.conf

#Compiler variables
OPACOMPILER ?= opa
FLAG = --opx-dir _build --compile-release --import-package stdlib.database.mongo -I .
PORT = 8080

RUN_OPT = -p $(PORT)

default: lib exe

lib:
	opa-plugin-builder --js-validator-off jQuery-UI/plugin/jquery-ui-1.8.24.custom.js jQuery-UI/plugin/sortable.js -o sortable.opp
	opa jQuery-UI/sortable.opa sortable.opp
	opa-plugin-builder --js-validator-off window/external_window.js -o window.opp
	opa window/window.opa window.opp

run: lib exe
	$(RUN_CMD) $(RUN_OPT) || true

include Makefile.common
