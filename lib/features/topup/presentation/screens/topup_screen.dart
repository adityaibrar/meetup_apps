import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/topup_provider.dart';
import 'topup_instruction_screen.dart';

/// Screen Top Up Poin — Bento-style package selection.
class TopUpScreen extends StatelessWidget {
  const TopUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TopUpProvider()..fetchPackages(),
      child: const _TopUpBody(),
    );
  }
}

class _TopUpBody extends StatelessWidget {
  const _TopUpBody();

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TopUpProvider>(context);
    final auth = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Top Up Poin')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Pilih Paket', style: AppTextStyles.h3),
            const SizedBox(height: 16),

            // Bento-style package grid
            if (provider.isLoadingPackages)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (provider.packages.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: Text('Tidak ada paket tersedia'),
                ),
              )
            else
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.9,
                ),
                itemCount: provider.packages.length,
                itemBuilder: (context, index) {
                  final pkg = provider.packages[index];
                  final isSelected = provider.selectedPoints == pkg['points'];
                  return GestureDetector(
                    onTap: () => provider.selectPoints(pkg['points']),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeInOut,
                      decoration: BoxDecoration(
                        gradient: isSelected ? AppColors.primaryGradient : null,
                        color: isSelected ? null : AppColors.surface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected
                              ? Colors.transparent
                              : AppColors.border,
                          width: 1.5,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: AppColors.primary.withValues(
                                    alpha: 0.25,
                                  ),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ]
                            : [
                                BoxShadow(
                                  color: AppColors.shadowLight,
                                  blurRadius: 6,
                                ),
                              ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.toll,
                            size: 28,
                            color: isSelected
                                ? Colors.amber
                                : AppColors.textTertiary,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            pkg['label'],
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: isSelected
                                  ? Colors.white
                                  : AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            AppFormatters.currency(pkg['price']),
                            style: TextStyle(
                              fontSize: 11,
                              color: isSelected
                                  ? Colors.white.withValues(alpha: 0.8)
                                  : AppColors.textTertiary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),

            const SizedBox(height: 32),
            Text('Metode Pembayaran', style: AppTextStyles.h3),
            const SizedBox(height: 16),

            // Payment methods
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: provider.paymentMethods.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final method = provider.paymentMethods[index];
                final isSelected = provider.selectedPayment == method['id'];
                return GestureDetector(
                  onTap: () => provider.selectPayment(method['id']),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.border,
                        width: isSelected ? 2 : 1,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: (method['color'] as Color).withValues(
                              alpha: 0.1,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            method['icon'] as IconData,
                            color: method['color'] as Color,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            method['name'],
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                            ),
                          ),
                        ),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: isSelected
                                ? AppColors.primaryGradient
                                : null,
                            border: isSelected
                                ? null
                                : Border.all(
                                    color: AppColors.textTertiary,
                                    width: 1.5,
                                  ),
                          ),
                          child: isSelected
                              ? const Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 14,
                                )
                              : null,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: provider.isLoading
                    ? null
                    : () async {
                        final data = await provider.processTopUp(auth.token!);
                        if (data != null && context.mounted) {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => TopUpInstructionScreen(
                                data: data,
                                selectedPayment: provider.selectedPayment!,
                                points: provider.selectedPoints!,
                              ),
                            ),
                          );
                        } else if (provider.error != null && context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(provider.error!)),
                          );
                        }
                      },
                child: provider.isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Bayar Sekarang',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
