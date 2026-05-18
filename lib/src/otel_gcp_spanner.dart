// Licensed under the Dartastic Pro Software License Agreement.
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';

import 'otel_gcp_spanner_suppression.dart';

const _tracerName = 'dartastic_otel_libs_gcp_spanner';

Tracer _tracer() => OTel.tracerProvider().getTracer(_tracerName);

class GcpSpannerResult {
  const GcpSpannerResult({
    this.project,
    this.instance,
    this.instanceConfig,
    this.database,
    this.dialect,
    this.processingUnits,
    this.nodeCount,
    this.session,
    this.transactionKind,
    this.statementKind,
    this.sql,
    this.rowCount,
    this.modifiedRows,
    this.bytesReturned,
    this.cpuMillis,
    this.requestPriority,
    this.queryOptimizer,
    this.routedFromRegion,
    this.commitTimestampUnixMicros,
    this.partitionedDml,
    this.abortRetryCount,
    this.errorCode,
    this.errorMessage,
    this.statusCode,
  });

  final String? project;

  /// Spanner instance id.
  final String? instance;

  /// Instance config (`regional-us-central1`, `nam6`, `eur5`, `nam7`, ...).
  final String? instanceConfig;

  final String? database;

  /// `GoogleStandardSQL`, `PostgreSQL`.
  final String? dialect;

  /// Processing units (1 node = 1000 PUs).
  final int? processingUnits;
  final int? nodeCount;

  /// Session pool resource.
  final String? session;

  /// `read_only`, `read_write`, `partitioned_dml`, `batch`.
  final String? transactionKind;

  /// `query`, `dml`, `read`, `batch_dml`, `partition_query`,
  /// `partition_read`, `commit`, `rollback`.
  final String? statementKind;

  /// Approx SQL byte length for rough sizing.
  final int? sql;

  final int? rowCount;
  final int? modifiedRows;
  final int? bytesReturned;
  final int? cpuMillis;

  /// `LOW`, `MEDIUM`, `HIGH`.
  final String? requestPriority;

  /// Query optimizer version (`1`, `2`, ..., `latest`).
  final String? queryOptimizer;

  /// Region the request was routed to (multi-region instances).
  final String? routedFromRegion;

  final int? commitTimestampUnixMicros;

  final bool? partitionedDml;

  /// `Aborted` retries by the client library.
  final int? abortRetryCount;

  /// `NotFound`, `PermissionDenied`, `Unauthenticated`, `ResourceExhausted`,
  /// `FailedPrecondition`, `Aborted`, `OutOfRange`, `Unimplemented`,
  /// `Internal`, `Unavailable`, `DataLoss`, `AlreadyExists`,
  /// `DeadlineExceeded`.
  final String? errorCode;
  final String? errorMessage;
  final int? statusCode;
}

class GcpSpannerCallResult<T> {
  const GcpSpannerCallResult({required this.value, this.result});
  final T value;
  final GcpSpannerResult? result;
}

/// Wraps a Cloud Spanner call in a CLIENT span. [operation] is one of
/// `instances.create`, `instances.update`, `instances.delete`,
/// `instances.list`, `databases.create`, `databases.update`,
/// `databases.delete`, `databases.updateDdl`, `databases.list`,
/// `sessions.create`, `sessions.batchCreate`, `sessions.delete`,
/// `sessions.list`, `executeSql`, `executeBatchDml`,
/// `executeStreamingSql`, `read`, `streamingRead`, `commit`,
/// `rollback`, `beginTransaction`, `partitionQuery`, `partitionRead`,
/// `batchWrite`, `restoreDatabase`, `backups.create`, `backups.list`,
/// `backups.delete`, `databaseRoles.list`.
Future<T> tracedGcpSpanner<T>({
  required String operation,
  required Future<GcpSpannerCallResult<T>> Function() invoke,
}) async {
  if (gcpSpannerInstrumentationSuppressed()) {
    final r = await invoke();
    return r.value;
  }
  final m = <String, Object>{
    'rpc.system': 'gcp_spanner',
    'rpc.method': operation,
    'gcp_spanner.operation': operation,
  };

  final span = _tracer().startSpan(
    'gcp_spanner $operation',
    kind: SpanKind.client,
    attributes: OTel.attributesFromMap(m),
  );
  try {
    final r = await invoke();
    if (r.result != null) {
      final res = r.result!;
      final extras = <Attribute<Object>>[];
      if (res.project != null) {
        extras.add(OTel.attributeString('gcp_spanner.project', res.project!));
      }
      if (res.instance != null) {
        extras.add(OTel.attributeString(
          'gcp_spanner.instance',
          res.instance!,
        ));
      }
      if (res.instanceConfig != null) {
        extras.add(OTel.attributeString(
          'gcp_spanner.instance_config',
          res.instanceConfig!,
        ));
      }
      if (res.database != null) {
        extras.add(OTel.attributeString(
          'gcp_spanner.database',
          res.database!,
        ));
      }
      if (res.dialect != null) {
        extras.add(OTel.attributeString(
          'gcp_spanner.dialect',
          res.dialect!,
        ));
      }
      if (res.processingUnits != null) {
        extras.add(OTel.attributeInt(
          'gcp_spanner.processing_units',
          res.processingUnits!,
        ));
      }
      if (res.nodeCount != null) {
        extras.add(OTel.attributeInt(
          'gcp_spanner.node_count',
          res.nodeCount!,
        ));
      }
      if (res.session != null) {
        extras.add(OTel.attributeString(
          'gcp_spanner.session',
          res.session!,
        ));
      }
      if (res.transactionKind != null) {
        extras.add(OTel.attributeString(
          'gcp_spanner.transaction.kind',
          res.transactionKind!,
        ));
      }
      if (res.statementKind != null) {
        extras.add(OTel.attributeString(
          'gcp_spanner.statement.kind',
          res.statementKind!,
        ));
      }
      if (res.sql != null) {
        extras.add(OTel.attributeInt('gcp_spanner.sql.length', res.sql!));
      }
      if (res.rowCount != null) {
        extras.add(OTel.attributeInt(
          'gcp_spanner.row_count',
          res.rowCount!,
        ));
      }
      if (res.modifiedRows != null) {
        extras.add(OTel.attributeInt(
          'gcp_spanner.modified_rows',
          res.modifiedRows!,
        ));
      }
      if (res.bytesReturned != null) {
        extras.add(OTel.attributeInt(
          'gcp_spanner.bytes_returned',
          res.bytesReturned!,
        ));
      }
      if (res.cpuMillis != null) {
        extras.add(OTel.attributeInt(
          'gcp_spanner.cpu_ms',
          res.cpuMillis!,
        ));
      }
      if (res.requestPriority != null) {
        extras.add(OTel.attributeString(
          'gcp_spanner.request_priority',
          res.requestPriority!,
        ));
      }
      if (res.queryOptimizer != null) {
        extras.add(OTel.attributeString(
          'gcp_spanner.query_optimizer',
          res.queryOptimizer!,
        ));
      }
      if (res.routedFromRegion != null) {
        extras.add(OTel.attributeString(
          'gcp_spanner.routed_from_region',
          res.routedFromRegion!,
        ));
      }
      if (res.commitTimestampUnixMicros != null) {
        extras.add(OTel.attributeInt(
          'gcp_spanner.commit_timestamp_unix_micros',
          res.commitTimestampUnixMicros!,
        ));
      }
      if (res.partitionedDml != null) {
        extras.add(OTel.attributeBool(
          'gcp_spanner.partitioned_dml',
          res.partitionedDml!,
        ));
      }
      if (res.abortRetryCount != null) {
        extras.add(OTel.attributeInt(
          'gcp_spanner.abort_retries',
          res.abortRetryCount!,
        ));
      }
      if (res.errorCode != null) {
        extras.add(OTel.attributeString(
          'gcp_spanner.error.code',
          res.errorCode!,
        ));
        span.setStatus(SpanStatusCode.Error, 'Spanner ${res.errorCode}');
      }
      if (res.errorMessage != null) {
        extras.add(OTel.attributeString(
          'gcp_spanner.error.message',
          res.errorMessage!,
        ));
      }
      if (res.statusCode != null) {
        extras.add(OTel.attributeInt(
          'http.response.status_code',
          res.statusCode!,
        ));
        if (res.statusCode! >= 400) {
          span.setStatus(
            SpanStatusCode.Error,
            'Spanner HTTP ${res.statusCode}',
          );
        }
      }
      if (extras.isNotEmpty) span.addAttributes(OTel.attributes(extras));
    }
    return r.value;
  } catch (e, st) {
    span.addAttributes(OTel.attributes([
      OTel.attributeString(
        ErrorResource.errorType.key,
        e.runtimeType.toString(),
      ),
    ]));
    span.recordException(e, stackTrace: st);
    span.setStatus(SpanStatusCode.Error, e.toString());
    rethrow;
  } finally {
    span.end();
  }
}
