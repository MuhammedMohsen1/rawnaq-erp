import '../../domain/entities/transaction_entity.dart';
import '../models/transaction_model.dart';

/// Mock data source for transactions
class MockTransactionsDataSource {
  /// Get all transactions for a project
  List<TransactionEntity> getTransactionsByProjectId(String projectId) {
    // Return mock transactions matching the image examples
    // Using projectId to filter, but for now returning same data for all projects
    return _mockTransactions.where((t) => t.projectId == projectId).toList()
      ..sort((a, b) => b.date.compareTo(a.date)); // Sort by date, newest first
  }

  /// Get all transactions (for testing)
  List<TransactionEntity> getAllTransactions() {
    return List.from(_mockTransactions)
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  /// Mock transactions data matching the image
  static final List<TransactionEntity> _mockTransactions = [
    // Deposits (Client Payments)
    TransactionModel(
      id: 'txn-001',
      type: TransactionType.deposit,
      description: 'دفعة العميل - دفعة المرحلة الثانية',
      amount: 20000.00,
      date: DateTime(2023, 10, 24, 14, 30),
      projectId: 'proj-1',
      metadata: TransactionMetadata(
        transferId: '#TRX-9982',
        isLocked: true,
      ),
    ),
    TransactionModel(
      id: 'txn-002',
      type: TransactionType.deposit,
      description: 'الإيداع الأولي',
      amount: 30000.00,
      date: DateTime(2023, 10, 1, 10, 0),
      projectId: 'proj-1',
      metadata: TransactionMetadata(
        notes: 'بدء المشروع',
        isLocked: true,
      ),
    ),
    TransactionModel(
      id: 'txn-003',
      type: TransactionType.deposit,
      description: 'دفعة العميل - دفعة المرحلة الثانية',
      amount: 20000.00,
      date: DateTime(2023, 10, 24, 15, 45),
      projectId: 'proj-1',
      metadata: TransactionMetadata(
        transferId: '#TRX-9982',
        isLocked: true,
      ),
    ),
    TransactionModel(
      id: 'txn-004',
      type: TransactionType.deposit,
      description: 'الإيداع الأولي',
      amount: 30000.00,
      date: DateTime(2023, 10, 1, 11, 15),
      projectId: 'proj-1',
      metadata: TransactionMetadata(
        notes: 'بدء المشروع',
        isLocked: true,
      ),
    ),
    TransactionModel(
      id: 'txn-005',
      type: TransactionType.deposit,
      description: 'الإيداع الأولي',
      amount: 30000.00,
      date: DateTime(2023, 10, 1, 9, 30),
      projectId: 'proj-1',
      metadata: TransactionMetadata(
        notes: 'بدء المشروع',
        isLocked: true,
      ),
    ),

    // Expenses
    TransactionModel(
      id: 'txn-006',
      type: TransactionType.expense,
      description: 'شراء أسمنت بكميات كبيرة (50 كيس)',
      amount: 1200.00,
      date: DateTime(2023, 10, 26, 8, 0),
      projectId: 'proj-1',
      metadata: TransactionMetadata(
        supplier: 'مواد الأمل',
        isLocked: false,
      ),
    ),
    TransactionModel(
      id: 'txn-007',
      type: TransactionType.expense,
      description: 'أجر العمال اليومي (3 عمال)',
      amount: 450.00,
      date: DateTime(2023, 10, 27, 16, 30),
      projectId: 'proj-1',
      metadata: TransactionMetadata(
        notes: 'فريق تحضير الدهان',
        isLocked: false,
      ),
    ),
    TransactionModel(
      id: 'txn-008',
      type: TransactionType.expense,
      description: 'كابلات الأسلاك الكهربائية (200م)',
      amount: 850.00,
      date: DateTime(2023, 10, 28, 12, 15),
      projectId: 'proj-1',
      metadata: TransactionMetadata(
        notes: 'شراء طارئ',
        isLocked: false,
      ),
    ),
    TransactionModel(
      id: 'txn-009',
      type: TransactionType.expense,
      description: 'شراء أسمنت بكميات كبيرة (50 كيس)',
      amount: 1200.00,
      date: DateTime(2023, 10, 26, 13, 20),
      projectId: 'proj-1',
      metadata: TransactionMetadata(
        supplier: 'مواد الأمل',
        isLocked: false,
      ),
    ),
    TransactionModel(
      id: 'txn-010',
      type: TransactionType.expense,
      description: 'أجر العمال اليومي (3 عمال)',
      amount: 450.00,
      date: DateTime(2023, 10, 27, 17, 0),
      projectId: 'proj-1',
      metadata: TransactionMetadata(
        notes: 'فريق تحضير الدهان',
        isLocked: false,
      ),
    ),
    TransactionModel(
      id: 'txn-011',
      type: TransactionType.expense,
      description: 'كابلات الأسلاك الكهربائية (200م)',
      amount: 850.00,
      date: DateTime(2023, 10, 28, 14, 45),
      projectId: 'proj-1',
      metadata: TransactionMetadata(
        notes: 'شراء طارئ',
        isLocked: false,
      ),
    ),
    TransactionModel(
      id: 'txn-012',
      type: TransactionType.expense,
      description: 'كابلات الأسلاك الكهربائية (200م)',
      amount: 850.00,
      date: DateTime(2023, 10, 28, 10, 30),
      projectId: 'proj-1',
      metadata: TransactionMetadata(
        notes: 'شراء طارئ',
        isLocked: false,
      ),
    ),

    // Additional transactions for other projects
    TransactionModel(
      id: 'txn-013',
      type: TransactionType.deposit,
      description: 'دفعة العميل - المرحلة الأولى',
      amount: 15000.00,
      date: DateTime(2023, 10, 15, 11, 0),
      projectId: 'proj-2',
      metadata: TransactionMetadata(
        transferId: '#TRX-9981',
        isLocked: true,
      ),
    ),
    TransactionModel(
      id: 'txn-014',
      type: TransactionType.expense,
      description: 'شراء حديد التسليح',
      amount: 2500.00,
      date: DateTime(2023, 10, 20, 9, 15),
      projectId: 'proj-2',
      metadata: TransactionMetadata(
        supplier: 'شركة الحديد',
        isLocked: false,
      ),
    ),
  ];
}

