// Licensed under the Apache License, Version 2.0
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';
import 'package:otel_gcp_spanner/otel_gcp_spanner.dart';

/// Traces Cloud Spanner calls with OpenTelemetry.
///
/// `otel_gcp_spanner` depends on the OpenTelemetry API only, so the application
/// initializes an SDK once at startup. Wrap each Cloud Spanner call in
/// [tracedGcpSpanner]; the `invoke` callback makes the real call and reports what
/// came back, which is recorded on the span.
Future<void> main() async {
  await OTel.initialize(serviceName: 'gcp-spanner-example');

  // Wraps a Cloud Spanner call in a CLIENT span.
  final gcpSpannerId = await tracedGcpSpanner<String>(
    operation: 'instances.create',
    invoke: () async {
      // Make the Cloud Spanner call here, then report what it returned.
      const id = 'gcp_spanner_8f3a2c';
      return const GcpSpannerCallResult(
          value: id,
          result: GcpSpannerResult(
              project: 'example',
              instance: 'example',
              instanceConfig: 'regional-us-central1',
              database: 'example',
              dialect: 'GoogleStandardSQL',
              processingUnits: 1,
              nodeCount: 3,
              session: 'example',
              transactionKind: 'read_only',
              statementKind: 'query',
              sql: 1,
              rowCount: 3,
              modifiedRows: 1,
              bytesReturned: 512,
              cpuMillis: 1,
              requestPriority: 'LOW',
              queryOptimizer: '1',
              routedFromRegion: 'us-east-1',
              commitTimestampUnixMicros: 1,
              partitionedDml: true,
              abortRetryCount: 3,
              errorCode: 'NotFound',
              errorMessage: 'example',
              statusCode: 201));
    },
  );
  OTelLog.info('tracedGcpSpanner instances.create returned $gcpSpannerId');

  // Calls that should not be traced, such as health checks, run inside
  // runWithoutGcpSpannerInstrumentationAsync.
  await runWithoutGcpSpannerInstrumentationAsync(
    () => tracedGcpSpanner<String>(
      operation: 'instances.create',
      invoke: () async {
        const id = 'gcp_spanner_8f3a2c';
        return const GcpSpannerCallResult(
            value: id,
            result: GcpSpannerResult(
                project: 'example',
                instance: 'example',
                instanceConfig: 'regional-us-central1',
                database: 'example',
                dialect: 'GoogleStandardSQL',
                processingUnits: 1,
                nodeCount: 3,
                session: 'example',
                transactionKind: 'read_only',
                statementKind: 'query',
                sql: 1,
                rowCount: 3,
                modifiedRows: 1,
                bytesReturned: 512,
                cpuMillis: 1,
                requestPriority: 'LOW',
                queryOptimizer: '1',
                routedFromRegion: 'us-east-1',
                commitTimestampUnixMicros: 1,
                partitionedDml: true,
                abortRetryCount: 3,
                errorCode: 'NotFound',
                errorMessage: 'example',
                statusCode: 201));
      },
    ),
  );

  await OTel.shutdown();
}
