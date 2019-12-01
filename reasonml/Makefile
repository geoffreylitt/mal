STEPS = step0_repl.ml

STEP_BINS = $(STEPS:%.ml=%)

all:
	yarn build

$(STEP_BINS): %: %.ml
	yarn build

