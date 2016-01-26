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

## Contributors
* [Dave Mayo](https://github.com/pobocks)

## Copyright
© 2014 President and Fellows of Harvard College
