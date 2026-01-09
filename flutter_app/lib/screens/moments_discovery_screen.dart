import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/meengle_moment.dart';
import '../widgets/widgets/moment_countdown.dart';
import '../providers/moments_provider.dart';

class MomentsDiscoveryScreen extends StatefulWidget {
  const MomentsDiscoveryScreen({super.key});

  @override
  State<MomentsDiscoveryScreen> createState() => _MomentsDiscoveryScreenState();
}

class _MomentsDiscoveryScreenState extends State<MomentsDiscoveryScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) {
        context.read<MomentsProvider>().loadMoments();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text('MEENGLE MOMENTS', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
        centerTitle: true,
        elevation: 0,
      ),
      body: Consumer<MomentsProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return Center(child: CircularProgressIndicator(color: Colors.amber.shade700));
          }

          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(provider.error!, style: const TextStyle(color: Colors.red, fontSize: 14)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => provider.loadMoments(),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.amber.shade700),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (provider.moments.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.hourglass_empty, size: 64, color: Colors.amber.shade700),
                  const SizedBox(height: 16),
                  const Text('No active moments', style: TextStyle(color: Colors.white70, fontSize: 16)),
                  const SizedBox(height: 8),
                  const Text('Check back soon for new matches!', style: TextStyle(color: Colors.white30, fontSize: 12)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: provider.moments.length,
            itemBuilder: (context, index) {
              final moment = provider.moments[index];
              return _MomentCard(
                moment: moment,
                onAccept: () => provider.acceptMoment(moment.id),
                onExtend: () => provider.extendMoment(moment.id),
              );
            },
          );
        },
      ),
    );
  }
}

class _MomentCard extends StatelessWidget {
  final MeengleMoment moment;
  final VoidCallback onAccept;
  final VoidCallback onExtend;

  const _MomentCard({
    required this.moment,
    required this.onAccept,
    required this.onExtend,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber.shade700.withValues(alpha: 0.3), width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Moment', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade700,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text('24h', style: TextStyle(color: Colors.black, fontSize: 11, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text('Someone is interested in you for the next 24 hours!', style: const TextStyle(color: Colors.white70, fontSize: 13)),
            const SizedBox(height: 12),
            MomentCountdown(expiresAt: moment.expiresAt),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: onAccept,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber.shade700,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('✨ Accept', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onExtend,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[800],
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('⏰ +6h', style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
