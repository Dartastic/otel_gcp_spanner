// Licensed under the Dartastic Pro Software License Agreement.
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';
import 'package:dartastic_opentelemetry/testing.dart';
import 'package:otel_gcp_spanner/otel_gcp_spanner.dart';
import 'package:test/test.dart';

void main() {
  late TestHarness harness;
  late InMemorySpanExporter spans;

  setUpAll(() async {
    harness = await maybeInitializeOtelForTest(
      serviceName: 'otel_gcp_spanner-test',
    );
    spans = harness.spans;
  });

  setUp(() => harness.clear());

  Map<String, Object> attrsOf(Span s) =>
      {for (final a in s.attributes.toList()) a.key: a.value};

  test('executeSql records dialect + tx kind + row count', () async {
    await tracedGcpSpanner<String>(
      operation: 'executeSql',
      invoke: () async => const GcpSpannerCallResult(
        value: 'ok',
        result: GcpSpannerResult(
          instance: 'prod',
          instanceConfig: 'nam6',
          database: 'app',
          dialect: 'GoogleStandardSQL',
          processingUnits: 1000,
          transactionKind: 'read_only',
          statementKind: 'query',
          rowCount: 100,
          bytesReturned: 65536,
          cpuMillis: 12,
          requestPriority: 'HIGH',
          queryOptimizer: 'latest',
        ),
      ),
    );
    final a = attrsOf(spans.findSpanByName('gcp_spanner executeSql')!);
    expect(a['gcp_spanner.dialect'], 'GoogleStandardSQL');
    expect(a['gcp_spanner.transaction.kind'], 'read_only');
    expect(a['gcp_spanner.request_priority'], 'HIGH');
  });

  test('Aborted error sets span error', () async {
    await tracedGcpSpanner<String>(
      operation: 'commit',
      invoke: () async => const GcpSpannerCallResult(
        value: 'ok',
        result: GcpSpannerResult(
          errorCode: 'Aborted',
          abortRetryCount: 3,
        ),
      ),
    );
    expect(
      spans.findSpanByName('gcp_spanner commit')!.status,
      SpanStatusCode.Error,
    );
  });

  test('partitioned DML flag', () async {
    await tracedGcpSpanner<String>(
      operation: 'executeSql',
      invoke: () async => const GcpSpannerCallResult(
        value: 'ok',
        result: GcpSpannerResult(
          statementKind: 'dml',
          partitionedDml: true,
          modifiedRows: 1000000,
        ),
      ),
    );
    final a = attrsOf(spans.findSpanByName('gcp_spanner executeSql')!);
    expect(a['gcp_spanner.partitioned_dml'], true);
    expect(a['gcp_spanner.modified_rows'], 1000000);
  });

  test('suppression skips spans', () async {
    await runWithoutGcpSpannerInstrumentationAsync(() async {
      await tracedGcpSpanner<String>(
        operation: 'sessions.list',
        invoke: () async => const GcpSpannerCallResult(value: 'v'),
      );
    });
    expect(spans.findSpansStartingWith('gcp_spanner '), isEmpty);
  });
}
