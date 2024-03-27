# setup-infer

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
  - uses: srz-zumix/setup-infer@v1
  - run: infer --version
```

### Specify infer version

```yaml
steps:
  - uses: srz-zumix/setup-infer@v1
    with:
      infer_version: v1.0.0
  - run: infer --version
```

[infer]:https://github.com/facebook/infer
