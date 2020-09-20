# openwith Development

The following serves as documentation for contributors to easy development. If you just want to use this package as a end user this should not concern you.

Refer to the `Makefile` for additional commands that may be useful.

## Compile/Lint

Install [cask](https://github.com/cask/cask), then:

``` shell
make all
```

## Testing

Load the example configuration into a vanilla instance of Emacs, this will install straight.el to `./example-config/straight`:

``` shell
make test
```
