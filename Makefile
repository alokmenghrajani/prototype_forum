
OPA=opa --parser js-like
OPAPLUGIN=opa-plugin-builder

SRC= \
  main.opa \
	utils.opa

default: run

run: prototype_forum.exe
	./prototype_forum.exe

prototype_forum.exe: $(SRC)
	$(OPA) -o prototype_forum.exe $(SRC)

clean:
	rm -Rf *~ *.exe *.log _build/ *.opp

