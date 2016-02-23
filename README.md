# Archivesspace Checker

This is a small website intended to allow Harvard Archivists to check their EAD files prior to ingest by Archivesspace.

## System Requirements

* JRuby 9000
* Bundler

## Installation Instructions

```sh
git clone git@github.com:harvard-library/archivesspace-checker.git
cd archivesspace-checker
bundle
bundle exec rake assets:precompile
bundle exec rackup
```

Then direct your browser to localhost:9292, upload some EADs, and enjoy!

## Configuration

Configuration settings can be included by putting a YAML file at `config/config.yml`

Right now, the only setting checked for is `schematron`, which is the location that
the schematron file being used is located at.

### Large Finding Aids

You may find that the app fails to work over especially large finding aids with the default JVM memory settings.
It's possible to increase the amount of heap memory available to the JVM (and tune other JVM settings) by passing options
via the environment variable `JRUBY_OPTS`.  Options for the JVM are prefixed by `-J`; for example, to set the maximum memory size to 1gb:

``` shell
JRUBY_OPTS=-J-Xmx1G
```

## Schematron notes

When writing Schematron, a common source of errors is assuming that Schematron understands default xmlns namespaces.  It very much does not.  If you set something up as a default namespace, and reference elements without a prefix in Schematron tests, they will be ignored.  Always either provide an explicit prefix, or else use the wildcard prefix (e.g. `/ead:ead` or `/*:ead` instead of `/ead`).

## Developer Documentation
Documentation generated via YARD is available [here](http://harvard-library.github.io/archivesspace-checker).

## Contributors
* [Dave Mayo](https://github.com/pobocks)

## Copyright
© 2014 President and Fellows of Harvard College
