import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mis_project/features/polls/poll_model.dart';

import '../../core/themes/app_theme.dart';
import '../auth/auth_provider.dart';


class PollDetailPage extends ConsumerStatefulWidget {
  final String pollId;
  const PollDetailPage({super.key, required this.pollId});

  @override
  ConsumerState<PollDetailPage> createState() => _PollDetailPageState();
}

class _PollDetailPageState extends ConsumerState<PollDetailPage> {
  String? _selectedOptionId;
  bool _voting = false;

  Future<void> _vote() async {
    final user = ref.read(currentUserProvider);
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Треба да сте најавени за да гласате')),
      );
      return;
    }
    if (_selectedOptionId == null) return;

    setState(() => _voting = true);
    try {
      await voteOnPoll(
        pollId: widget.pollId,
        optionId: _selectedOptionId!,
        uid: user.uid,
      );
      // Invalidate hasVoted cache
      ref.invalidate(hasVotedProvider(widget.pollId));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Гласот е регистриран! +5 поени 🎉')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Грешка: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _voting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final pollAsync = ref.watch(pollByIdProvider(widget.pollId));
    final hasVotedAsync = ref.watch(hasVotedProvider(widget.pollId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Гласај во Анкетата!'),
        leading: BackButton(onPressed: () => context.pop()),
      ),
      body: pollAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Грешка: $e')),
        data: (poll) {
          if (poll == null) return const Center(child: Text('Анкетата не е пронајдена'));

          final votedOptionId = hasVotedAsync.valueOrNull;
          final hasVoted = votedOptionId != null;
          final showResults = hasVoted || !poll.isActive;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Question card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppTheme.primary, AppTheme.primaryDark],
                      begin: Alignment.topLeft, end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        const Icon(Icons.how_to_vote_outlined, color: Colors.white70, size: 18),
                        const SizedBox(width: 6),
                        Text('Прашање', style: GoogleFonts.nunito(color: Colors.white70, fontSize: 12)),
                      ]),
                      const SizedBox(height: 8),
                      Text(poll.question, style: GoogleFonts.nunito(
                        fontSize: 17, fontWeight: FontWeight.w800, color: Colors.white,
                      )),
                      const SizedBox(height: 12),
                      Row(children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white24, borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text('${poll.totalVotes} гласови', style: GoogleFonts.nunito(
                            fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white,
                          )),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: poll.isActive ? Colors.greenAccent.withOpacity(0.3) : Colors.white24,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(poll.isActive ? '● Активна' : '✗ Затворена', style: GoogleFonts.nunito(
                            fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white,
                          )),
                        ),
                      ]),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                if (hasVoted)
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.successLight,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.success.withOpacity(0.3)),
                    ),
                    child: Row(children: [
                      const Icon(Icons.check_circle_outline, color: AppTheme.success, size: 18),
                      const SizedBox(width: 8),
                      Text('Веќе гласавте во оваа анкета', style: GoogleFonts.nunito(
                        fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.success,
                      )),
                    ]),
                  ),

                Text(
                  showResults ? 'Резултати' : 'Изберете одговор',
                  style: GoogleFonts.nunito(fontSize: 13, fontWeight: FontWeight.w800, color: AppTheme.textMuted),
                ),
                const SizedBox(height: 12),

                // Options / Results
                ...poll.options.map((option) {
                  final isMyVote = votedOptionId == option.id;
                  final pct = poll.totalVotes > 0 ? option.votes / poll.totalVotes : 0.0;

                  if (showResults) {
                    // Results view with bar
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isMyVote ? AppTheme.primaryLight : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isMyVote ? AppTheme.primary : const Color(0xFFCFD8DC),
                          width: isMyVote ? 2 : 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [
                            if (isMyVote)
                              const Icon(Icons.check_circle, color: AppTheme.primary, size: 16),
                            if (isMyVote) const SizedBox(width: 6),
                            Expanded(child: Text(option.text, style: GoogleFonts.nunito(
                              fontSize: 14, fontWeight: isMyVote ? FontWeight.w800 : FontWeight.w600,
                              color: isMyVote ? AppTheme.primary : AppTheme.textPrimary,
                            ))),
                            Text('${(pct * 100).round()}%', style: GoogleFonts.nunito(
                              fontSize: 13, fontWeight: FontWeight.w800,
                              color: isMyVote ? AppTheme.primary : AppTheme.textMuted,
                            )),
                          ]),
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: LinearProgressIndicator(
                              value: pct,
                              minHeight: 8,
                              backgroundColor: const Color(0xFFECEFF1),
                              valueColor: AlwaysStoppedAnimation(
                                isMyVote ? AppTheme.primary : AppTheme.secondary,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text('${option.votes} гласа', style: GoogleFonts.nunito(
                            fontSize: 11, color: AppTheme.textMuted,
                          )),
                        ],
                      ),
                    );
                  } else {
                    // Voting view
                    final isSelected = _selectedOptionId == option.id;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedOptionId = option.id),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: isSelected ? AppTheme.primaryLight : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected ? AppTheme.primary : const Color(0xFFCFD8DC),
                            width: isSelected ? 2 : 1.5,
                          ),
                        ),
                        child: Row(children: [
                          Container(
                            width: 22, height: 22,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected ? AppTheme.primary : const Color(0xFFCFD8DC),
                                width: 2,
                              ),
                              color: isSelected ? AppTheme.primary : Colors.transparent,
                            ),
                            child: isSelected ? const Icon(Icons.check, color: Colors.white, size: 14) : null,
                          ),
                          const SizedBox(width: 12),
                          Expanded(child: Text(option.text, style: GoogleFonts.nunito(
                            fontSize: 14, fontWeight: FontWeight.w700,
                            color: isSelected ? AppTheme.primary : AppTheme.textPrimary,
                          ))),
                        ]),
                      ),
                    );
                  }
                }),

                const SizedBox(height: 20),

                if (!showResults && poll.isActive)
                  ElevatedButton.icon(
                    onPressed: (_voting || _selectedOptionId == null) ? null : _vote,
                    icon: _voting
                        ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.how_to_vote_outlined, size: 18),
                    label: Text(_voting ? 'Гласање...' : 'Гласај'),
                    style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 52)),
                  ),

                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }
}