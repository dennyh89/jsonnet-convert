// kong_to_openapi.jsonnet
// A jsonnet script that converts Kong Deck configuration format to valid OpenAPI 3.0 specification

// A very simplified function to extract and transform path parameters
local convertPath(path) =
  // Remove common prefixes and suffixes
  local cleanPath = std.strReplace(std.strReplace(path, "~/", ""), "$", "");
  
  // Basic check for parameter pattern
  if std.length(std.findSubstr("(?<", cleanPath)) > 0 then
    // Extract parameter name - simplified approach
    local parts = std.split(cleanPath, "(?<");
    local beforeParam = parts[0];
    local afterParamPattern = parts[1];
    
    // Extract parameter name
    local nameEndPos = std.findSubstr(">", afterParamPattern)[0];
    local paramName = std.substr(afterParamPattern, 0, nameEndPos);
    
    // Find rest of path after closing parenthesis
    local closingPos = std.findSubstr(")", afterParamPattern)[0];
    local restOfPath = std.substr(afterParamPattern, closingPos + 1, std.length(afterParamPattern));
    
    // Construct OpenAPI path
    "/" + beforeParam + "{" + paramName + "}" + restOfPath
  else
    // No parameters, return clean path
    "/" + cleanPath;

// Main conversion function
{
  convert(kongConfig):: {
    openapi: "3.0.0",
    info: {
      title: "API generated from Kong configuration",
      description: "This OpenAPI specification was automatically generated from Kong configuration",
      version: "1.0.0"
    },
    servers: [
      {
        url: "https://" + service.host,
        description: "Generated from Kong service: " + service.name
      }
      for service in kongConfig.services
    ],
    paths: std.foldl(
      function(result, service)
        std.foldl(
          function(pathObj, route)
            local openApiPath = convertPath(route.paths[0]);
            
            // Build operations object
            local operations = std.foldl(
              function(ops, method)
                ops + {
                  [std.asciiLower(method)]: {
                    operationId: std.strReplace(route.name, "-", "_"),
                    summary: "Operation from Kong route: " + route.name,
                    description: "Auto-generated from Kong route configuration",
                    tags: [service.name],
                    responses: {
                      "200": {
                        description: "Successful operation",
                        content: {
                          "application/json": {
                            schema: { type: "object" }
                          }
                        }
                      },
                      "400": { description: "Bad request" },
                      "404": { description: "Not found" },
                      "500": { description: "Internal server error" }
                    }
                  }
                },
              route.methods,
              {}
            );
            
            // Add operations to path
            pathObj + {
              [openApiPath]: operations
            },
          service.routes,
          result
        ),
      kongConfig.services,
      {}
    ),
    components: {
      schemas: {},
      securitySchemes: {}
    }
  }
}