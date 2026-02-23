import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/chat_provider.dart';

/// Widget status meetup dengan glow effects dan animasi.
class MeetupStatusWidget extends StatelessWidget {
  final int targetUserId;
  final String? targetUserName;
  final VoidCallback onReadyPressed;

  const MeetupStatusWidget({
    super.key,
    required this.targetUserId,
    this.targetUserName,
    required this.onReadyPressed,
  });

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final chat = Provider.of<ChatProvider>(context);
    final myId = auth.user?.id;
    final isMeReady = chat.meetupReadyUserIds.contains(myId);
    final isTargetReady = chat.meetupReadyUserIds.contains(targetUserId);
    final isBothReady = isMeReady && isTargetReady;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.border, width: 0.5)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildAvatar(auth.user?.username ?? 'You', isMeReady),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isBothReady)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.successSurface,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'MATCH!',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        color: AppColors.success,
                        letterSpacing: 1.5,
                        fontSize: 13,
                      ),
                    ),
                  )
                else ...[
                  Text(
                    isMeReady ? 'Menunggu partner...' : 'Siap bertemu?',
                    style: TextStyle(
                      color: AppColors.textTertiary,
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  GestureDetector(
                    onTap: isMeReady ? null : onReadyPressed,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        gradient: isMeReady ? null : AppColors.primaryGradient,
                        color: isMeReady ? AppColors.surfaceVariant : null,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        isMeReady ? 'READY ✓' : "I'M READY",
                        style: TextStyle(
                          color: isMeReady
                              ? AppColors.textTertiary
                              : Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          _buildAvatar(targetUserName ?? 'Partner', isTargetReady),
        ],
      ),
    );
  }

  Widget _buildAvatar(String name, bool isReady) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.surfaceVariant,
            border: Border.all(
              color: isReady ? AppColors.success : AppColors.border,
              width: isReady ? 2.5 : 1,
            ),
            boxShadow: isReady
                ? [
                    BoxShadow(
                      color: AppColors.success.withValues(alpha: 0.3),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ]
                : [],
          ),
          child: Center(
            child: Text(
              name.isNotEmpty ? name[0].toUpperCase() : '?',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 18,
                color: isReady ? AppColors.success : AppColors.textSecondary,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          name,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: isReady ? AppColors.success : AppColors.textSecondary,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
