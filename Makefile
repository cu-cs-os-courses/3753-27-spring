# OS Basecamp. Environment targets delegate to env/; `check` runs one lab's
# checks against your submit/ directory in the headless VM. Labs live in
# labs/ — LAB takes the bare name (LAB=00-getting-started).
LAB ?= 00-getting-started

.PHONY: setup images smoke run check

setup images smoke run:
	$(MAKE) -C env $@

check:
	scripts/check-lab.sh labs/$(LAB)
