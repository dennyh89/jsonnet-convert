// test_converter.jsonnet
// Simple test file for the Kong to OpenAPI converter

local converter = import 'kong_to_openapi.jsonnet';
local kongConfig = import 'kong_config.json';

// Convert Kong configuration to OpenAPI
converter.convert(kongConfig)