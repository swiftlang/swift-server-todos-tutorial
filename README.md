# SwiftServerTodos – a Swift server tutorial

A tutorial for building a server-side TODO management application using Swift.

## Overview

SwiftServerTodos demonstrates building an HTTP service in Swift. This repository contains a tutorial and code samples for creating a backend service using Vapor, OpenAPI, and PostgreSQL.

**Contents:**
* `SwiftServerTodos.docc`: DocC tutorial with step-by-step instructions.
* `<root directory>`: Starter code for tutorial exercises.
* `Completed`: Completed implementation for reference.

**Deploy the completed app:**

[![Deploy on Railway](https://railway.com/button.svg)](https://railway.com/deploy/swift-vapor-openapi-postgres)

## Tutorial topics

The tutorial covers these Swift server development topics:

* HTTP service implementation with Vapor.
* Code generation from an OpenAPI document.
* Database persistence using the Fluent ORM and PostgreSQL.
* Service configuration and lifecycle management.
* Observability with OpenTelemetry — exporting logs, metrics, and traces to Grafana.

## Requirements

* [Swift 6.3 or later](http://swift.org/install)
* Git
* Docker Compose

## Getting started

### Clone the repository

```bash
git clone https://github.com/swiftlang/swift-server-todos-tutorial
cd SwiftServerTodos
```

### Follow the tutorial

To preview the tutorial locally:

```bash
xcrun docc preview -p 8090
```

The tutorial is available at `http://localhost:8090/tutorials/getting-started-swift-server`.

### Working with the tutorial

1. Open the DocC tutorial to read concepts and implementation details.
2. Use the root directory as the starting package for the tutorial.
3. Reference the package in the `Completed/` directory for the final implementation.
4. Modify `Package.swift` and files in `Sources/` as you progress through the tutorial steps.

## Architecture

The application uses a three-tier architecture:

* **HTTP Layer**: Vapor web framework for HTTP request handling.
* **Business Logic**: OpenAPI-generated handlers for request processing.
* **Data Layer**: Fluent ORM for database operations with PostgreSQL.
* **Observability**: OpenTelemetry exporters ship logs, metrics, and traces over OTLP to a Grafana
  LGTM stack (Loki, Tempo, Prometheus) running in Docker Compose.

## Dependencies

### Core frameworks
* [Vapor](https://vapor.codes) – Swift web framework.
* [Fluent ORM](https://docs.vapor.codes/fluent/overview/) – Database ORM and migrations.
* [Swift OpenAPI Generator](https://github.com/apple/swift-openapi-generator) – Code generation from OpenAPI specs.

### Additional libraries
* [Swift Log](https://swiftpackageindex.com/apple/swift-log/documentation/logging) – Logging framework.
* [Swift Metrics](https://github.com/apple/swift-metrics) – Metrics API.
* [Swift Distributed Tracing](https://github.com/apple/swift-distributed-tracing) – Distributed tracing API.
* [Swift OTel](https://github.com/swift-otel/swift-otel) – OpenTelemetry exporters for logs, metrics, and traces.
* [Swift System Metrics](https://github.com/apple/swift-system-metrics) – CPU, memory, and process metrics.
* [ServiceLifecycle](https://github.com/swift-server/swift-service-lifecycle) – Service lifecycle management.
* [Swift Configuration](https://github.com/apple/swift-configuration) – Service configuration reader.

## API documentation

The service implements a RESTful API for TODO management:

* `GET /todos` – Retrieve all todos.
* `POST /todos` – Create a new todo.
* `GET /todos/{id}` – Retrieve a specific todo.
* `PUT /todos/{id}` – Update a todo.
* `DELETE /todos/{id}` – Delete a todo.

The complete API specification is available in [`Sources/SwiftServerTodos/openapi.yaml`](Completed/Sources/SwiftServerTodos/openapi.yaml).

## Related resources

### Alternative frameworks
* [Hummingbird](https://hummingbird.codes) – Alternative Swift web framework.
* [gRPC Swift](https://github.com/grpc/grpc-swift-2) – gRPC framework.

### Example projects
* [Vapor server example](https://github.com/apple/swift-openapi-generator/tree/main/Examples/hello-world-vapor-server-example)
* [Hummingbird server example](https://github.com/apple/swift-openapi-generator/tree/main/Examples/hello-world-hummingbird-server-example)
* [HTTP client example](https://github.com/apple/swift-openapi-generator/tree/main/Examples/hello-world-async-http-client-example)
* [Additional examples](https://github.com/apple/swift-openapi-generator/tree/main/Examples/)

## Contributing

### Build tutorial

Verify the tutorial builds without errors or warnings using the command:

```bash
xcrun docc convert --warnings-as-errors --analyze
```

### Preview tutorial

Preview the tutorial content. Run the following command, 
then review your updates at `http://localhost:8090/tutorials/getting-started-swift-server`:

```bash
xcrun docc preview -p 8090
```
