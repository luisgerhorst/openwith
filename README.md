# luisgerhorst's openwith fork

Openwith is a simple but very useful package to make Emacs associate various
file types with external applications.  For example, Emacs can open PDFs, but
you may want to open them with a dedicated PDF viewer instead.  With openwith,
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

To enable `openwith` automatically when the desktop environment is recognized, add the following to your `.emacs.d/init.el` after installing it:

``` emacs-lisp
(require 'openwith)
(when openwith-desktop-environment-open
    (openwith-mode t))
```
