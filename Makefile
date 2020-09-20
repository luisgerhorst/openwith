# You can override this for example using 'EMACS=emacs25 make -e test'. The '-e'
# tells make to give variables taken from the environment precedence over variables
# from makefiles.
EMACS=emacs

# alternatives: melpa
CONFIG=straight
EMACSD=example-configs/$(CONFIG)

.PHONY: all
all:
	cask build

.PHONY: clean
clean:
	cask clean-elc
	rm -rfd ./example-configs/straight/straight ./example-configs/melpa/elpa

.PHONY: test
test:
	$(EMACS) -nw --debug-init -Q \
			--eval '(setq user-emacs-directory "./$(EMACSD)/")' \
			--load $(EMACSD)/init.el \
			--visit README.md
