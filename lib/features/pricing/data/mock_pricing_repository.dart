import '../domain/entities/pricing_data.dart';
import '../domain/entities/pricing_item.dart';
import '../domain/entities/wall_pricing.dart';
import '../domain/entities/expense_group.dart';

class MockPricingRepository {
  PricingData getPricingData(String projectId) {
    return PricingData(
      projectId: projectId,
      projectName: 'تجديد المكتب',
      clientName: 'السيد أحمد السيد',
      startDate: 'منذ يومين',
      expenseGroups: [
        ExpenseGroup(
          id: 'group-1',
          name: 'المصروفات العامة',
          status: ExpenseGroupStatus.inProgress,
          items: [
            PricingItem(
              id: 'group-1-item-1',
              description: 'Cement Plastering (Rough)',
              quantity: 3.0,
              unitPrice: 7.456,
              total: 22.368,
            ),
            PricingItem(
              id: 'group-1-item-2',
              description: 'Base Paint Coat (Primer)',
              quantity: null,
              unitPrice: null,
              total: 0.0,
            ),
            PricingItem(
              id: 'group-1-item-3',
              description: '',
              quantity: null,
              unitPrice: null,
              total: 0.0,
            ),
          ],
          subtotal: 22.368,
          isExpanded: true,
        ),
      ],
      walls: [
        WallPricing(
          id: 'wall-1',
          name: 'Living Room - North Wall',
          status: WallStatus.inProgress,
          items: [
            PricingItem(
              id: 'wall-1-item-1',
              description: 'Cement Plastering (Rough)',
              quantity: 3.0,
              unitPrice: 7.456,
              total: 22.368,
            ),
            PricingItem(
              id: 'wall-1-item-2',
              description: 'Base Paint Coat (Primer)',
              quantity: null,
              unitPrice: null,
              total: 0.0,
            ),
            PricingItem(
              id: 'wall-1-item-3',
              description: '',
              quantity: null,
              unitPrice: null,
              total: 0.0,
            ),
          ],
          imageUrls: [
            'https://via.placeholder.com/400x300',
            'https://via.placeholder.com/400x300',
            'https://via.placeholder.com/400x300',
          ],
          subtotal: 1650.0,
          isExpanded: true,
        ),
        WallPricing(
          id: 'wall-2',
          name: 'Kitchen - Wet Wall',
          status: WallStatus.completed,
          items: [
            PricingItem(
              id: 'wall-2-item-1',
              description: 'Tile Installation',
              quantity: 15.0,
              unitPrice: 8.0,
              total: 120.0,
            ),
          ],
          imageUrls: [],
          subtotal: 120.0,
          isExpanded: false,
        ),
      ],
      grandTotal: 1650.0,
      lastSaveTime: 'الآن',
    );
  }
}

