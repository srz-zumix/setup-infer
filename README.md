# setup-infer

[![GitHub Actions - setup check](https://github.com/srz-zumix/setup-infer/actions/workflows/main.yml/badge.svg)](https://github.com/srz-zumix/setup-infer/actions/workflows/main.yml)
[![GitHub Actions - reviewdog](https://github.com/srz-zumix/setup-infer/actions/workflows/reviewdog.yml/badge.svg)](https://github.com/srz-zumix/setup-infer/actions/workflows/reviewdog.yml)

This action installs :blue_book: [infer][].

## Input

```yaml
inputs:
  infer_version:
    description: 'infer version. [latest,vX.Y.Z]'
    default: 'latest'
```

## Usage

### Latest

```yaml
steps:
  - uses: srzzumix/setup-infer@master
  - run: infer --version
```

### Specify infer version

NOTE: macOS always install latest

```yaml
steps:
  - uses: srzzumix/setup-infer@master
    with:
      infer_version: v1.0.0
  - run: infer --version
```

[infer]:https://github.com/facebook/infer
