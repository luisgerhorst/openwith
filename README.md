# Luis' OpenWith Fork

OpenWith is a simple but very useful package to make Emacs associate various
file types with external applications.  For example, Emacs can open PDFs, but
you may want to open them with a dedicated PDF viewer instead.  With OpenWith,
you can do this seamlessly when you use C-x C-f.  It also works with recentf and
ido.

See also http://www.emacswiki.org/emacs/OpenWith.

## Installation

After installation the command `openwith-mode`, which enables the global minor mode, is autoloaded, you can call it without any additional configuration.

### [straight.el](https://github.com/raxod502/straight.el)

Having [set up straight.el](https://github.com/raxod502/straight.el#getting-started), add the following to your `.emacs.d/init.el`, then restart your Emacs:

``` emacs-lisp
(straight-use-package
 '(openwith :fork (:host github :repo "luisgerhorst/openwith")))
```

For a complete example configuration see [`example-configs/straight/init.el`](./example-configs/straight/init.el). You can omit the parts already included in your `init.el`.

## Activation

To enable OpenWith automatically when the desktop environment is recognized, add the following to your `.emacs.d/init.el` after installing it:

``` emacs-lisp
(require 'openwith)
(when openwith-desktop-environment-open
    (openwith-mode t))
```

## Development

The following serves as documentation for contributors to easy development. If you just want to use this package as a end user this should not concern you.

Refer to the `Makefile` for additional commands that may be useful.

### Compile/Lint

Install [cask](https://github.com/cask/cask), then:

``` shell
make all
```

### Test Run

``` shell
cask emacs
```

### Test Config & Installation

Load the example configuration into a vanilla instance of Emacs, this will install straight.el to `./example-config/straight`:

``` shell
make test
```

## Future Work

- Is it a problem that we may prevent the opening of arbitrary (possibly scripted) pdf files in Emacs?
- [Fuco1/dired-hacks/dired-open.el](https://github.com/Fuco1/dired-hacks/blob/master/dired-open.el) has a nice system determining how to open files. It's tighlty integrated into the hooks he uses but if maybe we can reuse it with some work and replace `openwith-associations`.
- How does it behave over SSH?
- Call `dired-find-file` using a hook.
- Only attempt to call the chosen command when it is atually available. This way we effectively auto-disable ourself when opening likely won't work.
- Replace `openwith-desktop-environment-open` with `openwith-default-open`
