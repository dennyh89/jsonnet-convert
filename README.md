# Kong to OpenAPI Converter

A Jsonnet utility that converts Kong Deck configuration format to valid OpenAPI 3.0 specification.

## Overview

This tool takes Kong gateway configuration (in JSON/YAML format as used by Kong Deck) and transforms it into a standard OpenAPI 3.0 specification. It's particularly useful for:

- Generating documentation from existing Kong API gateway configurations
- Creating client SDKs based on Kong routes
- Standardizing API specifications across teams using Kong

## Features

- Converts Kong services to OpenAPI servers
- Transforms Kong routes to OpenAPI paths and operations
- Handles Kong's regex-style path parameters (e.g., `(?<param>[^#?/]+)`) to OpenAPI style parameters (`{param}`)
- Preserves HTTP methods and route names
- Generates proper OpenAPI responses structure

## Usage

### Prerequisites

- [Jsonnet](https://jsonnet.org/) installed
- [jq](https://stedolan.github.io/jq/) (recommended for formatting output)

### Basic Usage

1. Save your Kong configuration to a file (e.g., `kong_config.json`)
2. Run the converter:

```bash
jsonnet -J . -e 'local converter = import "kong_to_openapi.jsonnet"; converter.convert(import "kong_config.json")' | jq > openapi_spec.json
```

Or use the included example script:

```bash
./example_usage.sh
```

## Example

Kong configuration:

```json
{
  "services": [
    {
      "host": "httpbin.local",
      "name": "httpbin-org",
      "routes": [
        {
          "methods": ["GET"],
          "name": "get-status-codes",
          "paths": ["~/status/(?<codes>[^#?/]+)$"]
        }
      ]
    }
  ]
}
```

Generated OpenAPI:

```json
{
  "openapi": "3.0.0",
  "info": {
    "title": "API generated from Kong configuration",
    "description": "This OpenAPI specification was automatically generated from Kong Deck configuration",
    "version": "1.0.0"
  },
  "servers": [{"url": "https://httpbin.local", "description": "Generated from Kong service: httpbin-org"}],
  "paths": {
    "/status/{codes}": {
      "get": {
        "operationId": "get_status_codes",
        "summary": "Operation from Kong route: get-status-codes",
        "tags": ["httpbin-org"],
        "responses": {
          "200": {
            "description": "Successful operation",
            "content": {"application/json": {"schema": {"type": "object"}}}
          }
        }
      }
    }
  }
}
```

## Limitations

- Does not yet handle Kong plugins (authentication, rate limiting, etc.)
- Complex regex patterns in paths may not convert perfectly
- Only basic OpenAPI response structures are generated

## License

MIT License