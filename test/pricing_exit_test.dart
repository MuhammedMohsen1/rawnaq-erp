import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:rawnaq/core/di/injection_container.dart';
import 'package:rawnaq/core/layout/main_layout.dart';
import 'package:rawnaq/core/theme/app_theme.dart';
import 'package:rawnaq/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:rawnaq/features/pricing/data/models/pricing_version_model.dart';
import 'package:rawnaq/features/pricing/presentation/cubit/pricing_cubit.dart';
import 'package:rawnaq/features/pricing/presentation/cubit/pricing_state.dart';
import 'package:rawnaq/features/pricing/presentation/pages/under_pricing_page.dart';
import 'package:rawnaq/features/pricing/presentation/widgets/pricing_drafts.dart';
import 'package:rawnaq/features/projects/presentation/cubit/project_attachments_cubit.dart';
import 'package:rawnaq/features/projects/presentation/cubit/project_attachments_state.dart';

class _TestPricingCubit extends Cubit<PricingState> implements PricingCubit {
  _TestPricingCubit()
    : super(
        PricingLoaded(
          pricingVersion: PricingVersionModel.fromJson({
            'id': '1',
            'projectId': '1',
            'status': 'DRAFT',
            'createdById': '1',
            'createdAt': '2026-11-25',
            'updatedAt': '2026-11-25',
          }),
          itemExpandedStates: const {},
          subItemExpandedStates: const {},
          subItemProfitMargins: const {},
          deductionAmount: 0,
        ),
      );

  @override
  Future<void> loadPricingData(
    String projectId, {
    bool readOnly = false,
    int? version,
    bool refreshProfitMargins = false,
  }) async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _TestAttachmentsCubit extends Cubit<ProjectAttachmentsState>
    implements ProjectAttachmentsCubit {
  _TestAttachmentsCubit()
    : super(const ProjectAttachmentsLoaded(attachments: []));

  @override
  Future<void> loadAttachments(String projectId) async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _TestAuthBloc extends Bloc<AuthEvent, AuthState> implements AuthBloc {
  _TestAuthBloc() : super(AuthInitial());

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  for (final platform in [TargetPlatform.windows, TargetPlatform.macOS]) {
    testWidgets('pricing back and save shortcut on ${platform.name}', (
      tester,
    ) async {
      debugDefaultTargetPlatformOverride = platform;
      addTearDown(() => debugDefaultTargetPlatformOverride = null);
      getIt.registerFactory<PricingCubit>(_TestPricingCubit.new);
      getIt.registerFactory<ProjectAttachmentsCubit>(_TestAttachmentsCubit.new);
      addTearDown(() => getIt.unregister<ProjectAttachmentsCubit>());
      addTearDown(() => getIt.unregister<PricingCubit>());
      tester.view.physicalSize = const Size(1280, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      const home = Text('Projects');
      final router = GoRouter(
        initialLocation: '/projects',
        routes: [
          ShellRoute(
            builder: (_, _, child) => MainLayout(child: child),
            routes: [
              GoRoute(path: '/projects', builder: (_, _) => home),
              GoRoute(
                path: '/pricing/:projectId',
                onExit: UnderPricingPage.confirmExit,
                builder: (_, state) => UnderPricingPage(
                  projectId: state.pathParameters['projectId']!,
                ),
              ),
            ],
          ),
        ],
      );
      addTearDown(router.dispose);

      final mode = ValueNotifier(ThemeMode.dark);
      addTearDown(mode.dispose);
      await tester.pumpWidget(
        BlocProvider<AuthBloc>(
          create: (_) => _TestAuthBloc(),
          child: ValueListenableBuilder<ThemeMode>(
            valueListenable: mode,
            builder: (_, mode, _) => MaterialApp.router(
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: mode,
              routerConfig: router,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      router.push<void>('/pricing/1');
      await tester.pumpAndSettle();

      PricingDrafts stageDraft() {
        final editor = tester.element(
          find.byWidgetPredicate(
            (widget) => widget is BlocConsumer<PricingCubit, PricingState>,
          ),
        );
        final drafts = editor.read<PricingDrafts>();
        drafts.stage(
          (itemId: '1', subItemId: '1', field: 'description'),
          'draft',
          () async => fail('Leaving must never save a draft'),
        );
        return drafts;
      }

      final drafts = stageDraft();
      await tester.pumpAndSettle();
      final save = find.ancestor(
        of: find.text('حفظ التعديلات'),
        matching: find.byWidgetPredicate((widget) => widget is FilledButton),
      );
      expect(tester.widget<FilledButton>(save).onPressed, isNotNull);

      router.push<void>('/pricing/2');
      await tester.pumpAndSettle();
      expect(tester.widget<FilledButton>(save).onPressed, isNull);
      await tester.tap(find.byTooltip('رجوع'));
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<UnderPricingPage>(find.byType(UnderPricingPage))
            .projectId,
        '1',
      );
      expect(tester.widget<FilledButton>(save).onPressed, isNotNull);

      await tester.tap(find.byTooltip('رجوع'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('البقاء في الصفحة'));
      await tester.pumpAndSettle();
      expect(find.byType(UnderPricingPage), findsOneWidget);
      expect(drafts.hasChanges, isTrue);
      expect(tester.widget<FilledButton>(save).onPressed, isNotNull);

      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      await tester.tap(find.text('البقاء في الصفحة'));
      await tester.pumpAndSettle();
      expect(drafts.hasChanges, isTrue);

      await tester.tap(find.byTooltip('رجوع'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('مغادرة بدون حفظ'));
      await tester.pumpAndSettle();
      expect(find.byType(UnderPricingPage), findsNothing);
      expect(find.text('Projects'), findsOneWidget);

      router.go('/pricing/1');
      await tester.pumpAndSettle();
      expect(router.canPop(), isFalse);
      stageDraft();
      await tester.tap(find.byTooltip('رجوع'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('مغادرة بدون حفظ'));
      await tester.pumpAndSettle();
      expect(find.byType(UnderPricingPage), findsNothing);

      router.push<void>('/pricing/1');
      await tester.pumpAndSettle();
      var writes = 0;
      final activeDrafts = tester.element(save).read<PricingDrafts>();
      activeDrafts.stage(
        (itemId: '1', subItemId: '1', field: 'description'),
        'keyboard draft',
        () async => writes++,
      );
      var failSave = true;
      activeDrafts.stage(
        (itemId: '1', subItemId: '1', field: 'profitMargin'),
        '20',
        () async {
          if (failSave) throw StateError('Write failed');
        },
      );
      mode.value = ThemeMode.light;
      await tester.pumpAndSettle();
      expect(Theme.of(tester.element(save)).brightness, Brightness.light);
      expect(tester.element(save).read<PricingDrafts>(), same(activeDrafts));
      expect(tester.widget<FilledButton>(save).onPressed, isNotNull);

      final modifier = platform == TargetPlatform.macOS
          ? LogicalKeyboardKey.metaLeft
          : LogicalKeyboardKey.controlLeft;
      Future<void> pressSaveShortcut() async {
        await tester.sendKeyDownEvent(modifier);
        await tester.sendKeyEvent(LogicalKeyboardKey.keyS);
        await tester.sendKeyUpEvent(modifier);
        await tester.pumpAndSettle();
      }

      await pressSaveShortcut();
      expect(writes, 1);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
      expect(tester.widget<FilledButton>(save).onPressed, isNotNull);

      ScaffoldMessenger.of(tester.element(save)).removeCurrentSnackBar();
      failSave = false;
      await tester.tap(save);
      await tester.pumpAndSettle();
      expect(writes, 1);
      expect(find.text('تم حفظ التعديلات'), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(SnackBar),
          matching: find.byIcon(Icons.check_circle_outline),
        ),
        findsOneWidget,
      );
      expect(tester.widget<FilledButton>(save).onPressed, isNull);

      await tester.tap(find.byTooltip('رجوع'));
      await tester.pumpAndSettle();
      expect(find.byType(UnderPricingPage), findsNothing);
      expect(find.text('مغادرة بدون حفظ؟'), findsNothing);
      debugDefaultTargetPlatformOverride = null;
    });
  }
}
