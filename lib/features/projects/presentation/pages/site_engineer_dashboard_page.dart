import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/responsive_layout.dart';

class SiteEngineerDashboardPage extends StatelessWidget {
  const SiteEngineerDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobile: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ONGOING PROJECTS Section
            _buildSectionTitle('المشاريع الجارية'),
            const SizedBox(height: 16),
            _buildOngoingProjectsMobile(),
            const SizedBox(height: 32),

            // UNDER PRICING PROJECTS Section
            _buildSectionTitle('المشاريع قيد التسعير'),
            const SizedBox(height: 16),
            _buildUnderPricingProjectsMobile(),
          ],
        ),
      ),
      tablet: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ONGOING PROJECTS Section
            _buildSectionTitle('المشاريع الجارية'),
            const SizedBox(height: 16),
            _buildOngoingProjectsTablet(),
            const SizedBox(height: 32),

            // UNDER PRICING PROJECTS Section
            _buildSectionTitle('المشاريع قيد التسعير'),
            const SizedBox(height: 16),
            _buildUnderPricingProjectsTablet(),
          ],
        ),
      ),
      desktop: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ONGOING PROJECTS Section
            _buildSectionTitle('المشاريع الجارية'),
            const SizedBox(height: 16),
            _buildOngoingProjectsDesktop(),
            const SizedBox(height: 32),

            // UNDER PRICING PROJECTS Section
            _buildSectionTitle('المشاريع قيد التسعير'),
            const SizedBox(height: 16),
            _buildUnderPricingProjectsDesktop(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTextStyles.h4.copyWith(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  // Mobile layout: Stack vertically
  Widget _buildOngoingProjectsMobile() {
    return Column(
      children: [
        _buildOngoingProjectCard('أبو خالد', 75, 'منذ 5 ساعات'),
        const SizedBox(height: 16),
        _buildOngoingProjectCard('أبو خالد', 75, 'منذ 5 ساعات'),
        const SizedBox(height: 16),
        _buildOngoingProjectCard('أبو خالد', 75, 'منذ 5 ساعات'),
        const SizedBox(height: 16),
        _buildOngoingProjectCard('أبو خالد', 75, 'منذ 5 ساعات'),
      ],
    );
  }

  // Tablet layout: 2 columns
  Widget _buildOngoingProjectsTablet() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildOngoingProjectCard('أبو خالد', 75, 'منذ 5 ساعات'),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildOngoingProjectCard('أبو خالد', 75, 'منذ 5 ساعات'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildOngoingProjectCard('أبو خالد', 75, 'منذ 5 ساعات'),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildOngoingProjectCard('أبو خالد', 75, 'منذ 5 ساعات'),
            ),
          ],
        ),
      ],
    );
  }

  // Desktop layout: 4 columns
  Widget _buildOngoingProjectsDesktop() {
    return Row(
      children: [
        Expanded(
          child: _buildOngoingProjectCard('أبو خالد', 75, 'منذ 5 ساعات'),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildOngoingProjectCard('أبو خالد', 75, 'منذ 5 ساعات'),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildOngoingProjectCard('أبو خالد', 75, 'منذ 5 ساعات'),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildOngoingProjectCard('أبو خالد', 75, 'منذ 5 ساعات'),
        ),
      ],
    );
  }

  Widget _buildOngoingProjectCard(
    String projectName,
    int progress,
    String lastUpdate,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                projectName,
                style: AppTextStyles.h6.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              _buildStatusButton('نشط', AppColors.statusActive),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Text(
                'التقدم',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const Spacer(),
              Text(
                '$progress%',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress / 100,
              backgroundColor: AppColors.progressBackground,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.statusActive),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'آخر تحديث: $lastUpdate',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textMuted,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 16),
          // Divider
          const Divider(color: AppColors.border, height: 1, thickness: 1),
          const SizedBox(height: 16),
          // Action buttons row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Open Project button (left side, no icon, dark grey)
              Expanded(
                flex: 3,
                child: SizedBox(
                  height: 44,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.cardBackground,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(color: AppColors.border, width: 1),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'فتح المشروع',
                      style: AppTextStyles.buttonSmall,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Add Expenses button (right side, wallet icon, square)
              Expanded(
                flex: 1,
                child: SizedBox(
                  width: 44,
                  height: 44,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.cardBackground,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.border, width: 1),
                    ),
                    child: IconButton(
                      onPressed: () {},
                      icon: SvgPicture.asset(
                        'assets/images/add-wallet.svg',
                        width: 24,
                        height: 24,
                      ),
                      padding: EdgeInsets.zero,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusButton(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: AppTextStyles.caption.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // Mobile layout: Stack vertically
  Widget _buildUnderPricingProjectsMobile() {
    return Column(
      children: [
        _buildPricingProjectCard(
          'تجديد المكتب',
          estimatedPrice: null,
          numberOfWalls: 12,
          actionButton: 'بدء التسعير',
          prefixIcon: const Icon(Icons.add, size: 15, weight: 700),
        ),
        const SizedBox(height: 16),
        _buildPricingProjectCard(
          'تجديد المكتب',
          estimatedPrice: '1,500',
          numberOfWalls: 12,
          actionButton: 'متابعة التسعير',
        ),
        const SizedBox(height: 16),
        _buildPricingProjectCard(
          'تجديد المكتب',
          estimatedPrice: '1500',
          numberOfWalls: 12,
          actionButton: 'تعديل السعر',
          prefixIcon: const Icon(Icons.edit, size: 16),
        ),
      ],
    );
  }

  // Tablet layout: Horizontal (same as desktop)
  Widget _buildUnderPricingProjectsTablet() {
    return _buildUnderPricingProjectsDesktop();
  }

  // Desktop layout: 3 columns horizontal
  Widget _buildUnderPricingProjectsDesktop() {
    return Row(
      children: [
        Expanded(
          child: _buildPricingProjectCard(
            'تجديد المكتب',
            estimatedPrice: null,
            numberOfWalls: 12,
            actionButton: 'بدء التسعير',
            prefixIcon: const Text(
              '+',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildPricingProjectCard(
            'تجديد المكتب',
            estimatedPrice: '1,500',
            numberOfWalls: 12,
            actionButton: 'متابعة التسعير',
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildPricingProjectCard(
            'تجديد المكتب',
            estimatedPrice: '1500',
            numberOfWalls: 12,
            actionButton: 'تعديل السعر',
            prefixIcon: const Text(
              '✔',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            suffixIcon: const Icon(Icons.edit, size: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildPricingProjectCard(
    String projectName, {
    String? estimatedPrice,
    required int numberOfWalls,
    required String actionButton,
    Widget? prefixIcon,
    Widget? suffixIcon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                projectName,
                style: AppTextStyles.h6.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFF6366F1).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Center(
                  child: SvgPicture.asset(
                    'assets/images/engineering-pencil.svg',
                    width: 20,
                    height: 20,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Two dark cards side by side
          Row(
            children: [
              // Estimated Price Card
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.inputBackground,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'السعر المقدر',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        estimatedPrice != null ? '$estimatedPrice \$' : '- \$',
                        style: AppTextStyles.h5.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Number of Walls Card
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.inputBackground,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'عدد الجدران',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.grid_view,
                            color: AppColors.textPrimary,
                            size: 18,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '$numberOfWalls',
                            style: AppTextStyles.h5.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Divider
          const Divider(color: AppColors.border, height: 1, thickness: 1),
          const SizedBox(height: 16),
          // Action button (same style as Ongoing Projects)
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.cardBackground,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(color: AppColors.border, width: 1),
                ),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (prefixIcon != null) ...[
                    prefixIcon,
                    const SizedBox(width: 4),
                  ],
                  Text(
                    actionButton,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (suffixIcon != null) ...[
                    const SizedBox(width: 8),
                    suffixIcon,
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
