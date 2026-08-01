# OS Basecamp. Environment targets delegate to env/; `check` runs one lab's
# checks against your submit/ directory in the headless VM.
LAB ?= 00-getting-started

.PHONY: setup images smoke run check

setup images smoke run:
	$(MAKE) -C env $@

check:
	scripts/check-lab.sh $(LAB)
