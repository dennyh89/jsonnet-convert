#!/bin/bash
# Simple example usage script for the Kong to OpenAPI converter

# Copy the sample Kong configuration if needed
# cp sample/kong_config.json kong_config.json

# Run the converter
jsonnet test_converter.jsonnet | jq > openapi_spec.json

echo "Conversion complete! OpenAPI specification saved to openapi_spec.json"
echo "Preview of the generated OpenAPI specification:"
echo "----------------------------------------------------"
head -20 openapi_spec.json
echo "..."
echo "----------------------------------------------------"
echo "Done!"