import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/audit/models/merchant_audit_detail.dart';
import '../../features/audit/viewmodels/audit_viewmodel.dart';

class AuditSessionScreen extends ConsumerWidget {
  final String sessionId;

  const AuditSessionScreen({required this.sessionId, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;

    final detail = ref.watch(merchantAuditDetailProvider(sessionId));

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Conversation Audit',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
        ),
      ),
      body: detail.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => _ErrorState(
          colors: colors,
          onRetry: () {
            ref.invalidate(merchantAuditDetailProvider(sessionId));
          },
        ),
        data: (data) {
          final model = data.agentEvents
              .map((e) => e.modelName)
              .whereType<String>()
              .where((e) => e.isNotEmpty)
              .firstOrNull;

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(merchantAuditDetailProvider(sessionId));

              await ref.read(merchantAuditDetailProvider(sessionId).future);
            },
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
              children: [
                _OverviewCard(data: data, model: model, colors: colors),

                const SizedBox(height: 24),

                _SectionHeader(
                  title: 'Conversation',
                  icon: Icons.chat_bubble_outline_rounded,
                  colors: colors,
                ),

                const SizedBox(height: 12),

                if (data.messages.isEmpty)
                  _EmptyCard(text: 'No messages recorded.', colors: colors)
                else
                  ...data.messages.map(
                    (message) =>
                        _MessageBubble(message: message, colors: colors),
                  ),

                const SizedBox(height: 26),

                _SectionHeader(
                  title: 'Execution Trace',
                  icon: Icons.timeline_rounded,
                  colors: colors,
                ),

                const SizedBox(height: 12),

                _ExecutionTrace(data: data, colors: colors),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _OverviewCard extends StatelessWidget {
  final MerchantAuditDetail data;
  final String? model;
  final ColorScheme colors;

  const _OverviewCard({
    required this.data,
    required this.model,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 46,
                width: 46,
                decoration: BoxDecoration(
                  color: colors.primaryContainer,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(Icons.analytics_rounded, color: colors.primary),
              ),
              const SizedBox(width: 12),

              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Session Overview',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Operational view of this conversation',
                      style: TextStyle(fontSize: 11),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          _InfoBlock(
            label: 'Customer',
            value: _shorten(data.userId),
            colors: colors,
          ),

          _InfoBlock(
            label: 'Session',
            value: _shorten(data.sessionId),
            colors: colors,
          ),

          if (model != null)
            _InfoBlock(label: 'AI model', value: model!, colors: colors),

          const SizedBox(height: 14),

          Row(
            children: [
              Expanded(
                child: _CountPill(
                  icon: Icons.chat_rounded,
                  value: data.messages.length.toString(),
                  label: 'Messages',
                  colors: colors,
                ),
              ),

              const SizedBox(width: 8),

              Expanded(
                child: _CountPill(
                  icon: Icons.smart_toy_rounded,
                  value: data.agentEvents.length.toString(),
                  label: 'Agent events',
                  colors: colors,
                ),
              ),

              const SizedBox(width: 8),

              Expanded(
                child: _CountPill(
                  icon: Icons.api_rounded,
                  value: data.toolEvents.length.toString(),
                  label: 'Tool / API',
                  colors: colors,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static String _shorten(String value) {
    if (value.length <= 24) return value;

    return '${value.substring(0, 10)}...'
        '${value.substring(value.length - 8)}';
  }
}

class _InfoBlock extends StatelessWidget {
  final String label;
  final String value;
  final ColorScheme colors;

  const _InfoBlock({
    required this.label,
    required this.value,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 70,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: colors.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: SelectableText(
              value,
              style: TextStyle(
                fontSize: 12,
                color: colors.onSurface,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CountPill extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final ColorScheme colors;

  const _CountPill({
    required this.icon,
    required this.value,
    required this.label,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(13),
      ),
      child: Column(
        children: [
          Icon(icon, size: 17, color: colors.primary),
          const SizedBox(height: 5),
          Text(
            value,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: colors.onSurface,
            ),
          ),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 9,
              color: colors.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  final ColorScheme colors;

  const _SectionHeader({
    required this.title,
    required this.icon,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          height: 34,
          width: 34,
          decoration: BoxDecoration(
            color: colors.primaryContainer,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: colors.primary),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: colors.onSurface,
          ),
        ),
      ],
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final AuditChatMessage message;
  final ColorScheme colors;

  const _MessageBubble({required this.message, required this.colors});

  @override
  Widget build(BuildContext context) {
    final isUser = message.role.toUpperCase() == 'USER';

    final background = isUser ? colors.primaryContainer : colors.surface;

    final borderColor = isUser
        ? colors.primary.withAlpha(70)
        : colors.outlineVariant;

    final roleColor = colors.primary;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 390),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(17),
          border: Border.all(color: borderColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isUser ? Icons.person_rounded : Icons.auto_awesome_rounded,
                  size: 15,
                  color: roleColor,
                ),
                const SizedBox(width: 5),
                Text(
                  isUser ? 'CUSTOMER' : 'SAHAYAK',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    color: roleColor,
                    letterSpacing: 0.4,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            Text(
              message.content.isEmpty ? '(empty message)' : message.content,
              style: TextStyle(
                fontSize: 14,
                height: 1.45,
                color: colors.onSurface,
                fontWeight: FontWeight.w500,
              ),
            ),

            if (message.createdAt != null) ...[
              const SizedBox(height: 8),
              Text(
                _formatDate(message.createdAt!),
                style: TextStyle(fontSize: 9, color: colors.onSurfaceVariant),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime value) {
    final local = value.toLocal();

    final hour = local.hour.toString().padLeft(2, '0');

    final minute = local.minute.toString().padLeft(2, '0');

    return '$hour:$minute';
  }
}

class _ExecutionTrace extends StatelessWidget {
  final MerchantAuditDetail data;
  final ColorScheme colors;

  const _ExecutionTrace({required this.data, required this.colors});

  @override
  Widget build(BuildContext context) {
    final entries = <_TraceEntry>[];

    for (final event in data.agentEvents) {
      entries.add(
        _TraceEntry(
          timestamp: event.createdAt,
          title: event.eventType ?? 'AGENT EVENT',
          subtitle: event.responseType ?? 'Agent response',
          success: event.success,
          latencyMs: event.latencyMs,
          icon: Icons.smart_toy_rounded,
          detailBuilder: () => _AgentDetails(event: event, colors: colors),
        ),
      );
    }

    for (final event in data.toolEvents) {
      entries.add(
        _TraceEntry(
          timestamp: event.createdAt,
          title: event.eventType ?? 'TOOL CALL',
          subtitle: event.operation,
          success: event.success,
          latencyMs: event.latencyMs,
          icon: event.httpMethod != null
              ? Icons.api_rounded
              : Icons.build_circle_rounded,
          detailBuilder: () => _ToolDetails(event: event, colors: colors),
        ),
      );
    }

    entries.sort((a, b) {
      final aTime = a.timestamp ?? DateTime.fromMillisecondsSinceEpoch(0);

      final bTime = b.timestamp ?? DateTime.fromMillisecondsSinceEpoch(0);

      return aTime.compareTo(bTime);
    });

    if (entries.isEmpty) {
      return _EmptyCard(text: 'No execution events recorded.', colors: colors);
    }

    return Column(
      children: List.generate(entries.length, (index) {
        final entry = entries[index];

        return _TimelineItem(
          entry: entry,
          isLast: index == entries.length - 1,
          colors: colors,
        );
      }),
    );
  }
}

class _TraceEntry {
  final DateTime? timestamp;
  final String title;
  final String subtitle;
  final bool success;
  final int latencyMs;
  final IconData icon;
  final Widget Function() detailBuilder;

  _TraceEntry({
    required this.timestamp,
    required this.title,
    required this.subtitle,
    required this.success,
    required this.latencyMs,
    required this.icon,
    required this.detailBuilder,
  });
}

class _TimelineItem extends StatelessWidget {
  final _TraceEntry entry;
  final bool isLast;
  final ColorScheme colors;

  const _TimelineItem({
    required this.entry,
    required this.isLast,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 32,
          child: Column(
            children: [
              Container(
                height: 28,
                width: 28,
                decoration: BoxDecoration(
                  color: entry.success
                      ? colors.secondaryContainer
                      : colors.errorContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  entry.success ? Icons.check_rounded : Icons.close_rounded,
                  size: 16,
                  color: entry.success ? colors.secondary : colors.error,
                ),
              ),

              if (!isLast)
                Container(width: 2, height: 68, color: colors.outlineVariant),
            ],
          ),
        ),

        const SizedBox(width: 10),

        Expanded(
          child: Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: colors.outlineVariant),
            ),
            child: Theme(
              data: Theme.of(
                context,
              ).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                tilePadding: EdgeInsets.zero,
                childrenPadding: EdgeInsets.zero,
                initiallyExpanded: false,

                leading: Container(
                  height: 38,
                  width: 38,
                  decoration: BoxDecoration(
                    color: colors.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Icon(entry.icon, size: 18, color: colors.primary),
                ),

                title: Text(
                  entry.title.replaceAll('_', ' '),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: colors.onSurface,
                  ),
                ),

                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 3),
                  child: Text(
                    entry.subtitle.replaceAll('_', ' '),
                    style: TextStyle(
                      fontSize: 11,
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ),

                trailing: SizedBox(
                  width: 70,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        '${entry.latencyMs}ms',
                        style: TextStyle(
                          fontSize: 9,
                          color: colors.onSurfaceVariant,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 2),
                      Icon(
                        Icons.expand_more_rounded,
                        size: 20,
                        color: colors.onSurfaceVariant,
                      ),
                    ],
                  ),
                ),

                children: [
                  Divider(color: colors.outlineVariant),
                  entry.detailBuilder(),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _AgentDetails extends StatelessWidget {
  final AgentAuditRecord event;
  final ColorScheme colors;

  const _AgentDetails({required this.event, required this.colors});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Column(
        children: [
          if (event.modelName != null)
            _DetailRow(
              label: 'AI model',
              value: event.modelName!,
              colors: colors,
            ),

          if (event.requestMessage != null)
            _DetailRow(
              label: 'Request',
              value: event.requestMessage!,
              colors: colors,
            ),

          if (event.responseMessage != null)
            _DetailRow(
              label: 'Response',
              value: event.responseMessage!,
              colors: colors,
            ),

          _DetailRow(
            label: 'Products',
            value: event.productCount.toString(),
            colors: colors,
          ),

          _DetailRow(
            label: 'Recommendations',
            value: event.recommendationCount.toString(),
            colors: colors,
          ),

          _DetailRow(
            label: 'Actions',
            value: event.actionCount.toString(),
            colors: colors,
          ),

          _DetailRow(
            label: 'Request ID',
            value: event.requestId,
            colors: colors,
          ),

          if (event.errorMessage != null)
            _DetailRow(
              label: 'Error',
              value: event.errorMessage!,
              colors: colors,
            ),
        ],
      ),
    );
  }
}

class _ToolDetails extends StatelessWidget {
  final ToolAuditRecord event;
  final ColorScheme colors;

  const _ToolDetails({required this.event, required this.colors});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Column(
        children: [
          if (event.targetName != null)
            _DetailRow(
              label: 'Target',
              value: event.targetName!,
              colors: colors,
            ),

          if (event.httpMethod != null)
            _DetailRow(
              label: 'Method',
              value: event.httpMethod!,
              colors: colors,
            ),

          if (event.apiPath != null)
            _DetailRow(label: 'API', value: event.apiPath!, colors: colors),

          _DetailRow(
            label: 'Request ID',
            value: event.requestId,
            colors: colors,
          ),

          if (event.inputJson != null)
            _JsonSection(
              title: 'Input',
              value: event.inputJson!,
              colors: colors,
            ),

          if (event.outputJson != null)
            _JsonSection(
              title: 'Output',
              value: event.outputJson!,
              colors: colors,
            ),

          if (event.errorMessage != null)
            _DetailRow(
              label: 'Error',
              value: event.errorMessage!,
              colors: colors,
            ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final ColorScheme colors;

  const _DetailRow({
    required this.label,
    required this.value,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 7),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 9,
              color: colors.onSurfaceVariant,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 3),
          SelectableText(
            value,
            style: TextStyle(
              fontSize: 11,
              color: colors.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _JsonSection extends StatelessWidget {
  final String title;
  final String value;
  final ColorScheme colors;

  const _JsonSection({
    required this.title,
    required this.value,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    var formatted = value;

    try {
      formatted = const JsonEncoder.withIndent('  ').convert(jsonDecode(value));
    } catch (_) {
      // Keep original string.
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 10),
          childrenPadding: const EdgeInsets.all(10),
          title: Text(
            title,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: colors.onSurface,
            ),
          ),
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(8),
              ),
              child: SelectableText(
                formatted,
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 9,
                  height: 1.35,
                  color: colors.onSurface,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyCard extends StatelessWidget {
  final String text;
  final ColorScheme colors;

  const _EmptyCard({required this.text, required this.colors});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(26),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            color: colors.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final ColorScheme colors;
  final VoidCallback onRetry;

  const _ErrorState({required this.colors, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 64,
              width: 64,
              decoration: BoxDecoration(
                color: colors.errorContainer,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(
                Icons.cloud_off_rounded,
                color: colors.error,
                size: 30,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Couldn’t load audit details',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: colors.onSurface,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Check the backend connection and try again.',
              textAlign: TextAlign.center,
              style: TextStyle(color: colors.onSurfaceVariant),
            ),
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
