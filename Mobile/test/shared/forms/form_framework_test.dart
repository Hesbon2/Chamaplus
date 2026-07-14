import 'package:chamaplus_mobile/shared/forms/forms.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    theme: ThemeData(useMaterial3: true),
    home: Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: child,
      ),
    ),
  );
}

void main() {
  group('AppValidators', () {
    test('required rejects empty', () {
      expect(AppValidators.required(''), isNotNull);
      expect(AppValidators.required('ok'), isNull);
    });

    test('phone accepts Kenyan formats', () {
      expect(AppValidators.phone('0712345678'), isNull);
      expect(AppValidators.phone('+254712345678'), isNull);
      expect(AppValidators.phone('0812345678'), isNotNull);
      expect(AppValidators.normalizePhone('0712345678'), '+254712345678');
    });

    test('amount requires positive number', () {
      expect(AppValidators.amount('100.50'), isNull);
      expect(AppValidators.amount('0'), isNotNull);
      expect(AppValidators.amount('abc'), isNotNull);
    });

    test('email validates format', () {
      expect(AppValidators.email('a@b.com'), isNull);
      expect(AppValidators.email('bad'), isNotNull);
      expect(AppValidators.email('', isRequired: false), isNull);
    });

    test('compose returns first error', () {
      final validator = AppValidators.compose([
        (v) => AppValidators.required(v, field: 'Name'),
        (v) => AppValidators.minLength(v, length: 3, field: 'Name'),
      ]);
      expect(validator(''), contains('required'));
      expect(validator('ab'), contains('at least'));
      expect(validator('abc'), isNull);
    });
  });

  group('AppForm + fields', () {
    testWidgets('AppTextField renders label and accepts input', (tester) async {
      final controller = TextEditingController();
      await tester.pumpWidget(
        _wrap(
          AppForm(
            child: AppTextField(
              controller: controller,
              label: 'Full name',
              hint: 'Jane Doe',
            ),
          ),
        ),
      );

      expect(find.text('Full name'), findsOneWidget);
      await tester.enterText(find.byType(TextFormField), 'Jane');
      expect(controller.text, 'Jane');
    });

    testWidgets('AppPhoneField validates invalid number', (tester) async {
      final formKey = GlobalKey<FormState>();
      await tester.pumpWidget(
        _wrap(
          AppForm(
            formKey: formKey,
            child: Column(
              children: [
                const AppPhoneField(),
                AppSubmitButton(
                  label: 'Submit',
                  formKey: formKey,
                  onSubmit: () {},
                ),
              ],
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(TextFormField), '123');
      await tester.tap(find.text('Submit'));
      await tester.pumpAndSettle();
      expect(find.text('Enter a valid Kenyan phone number'), findsOneWidget);
    });

    testWidgets('AppAmountField shows currency prefix', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const AppForm(
            child: AppAmountField(currencyCode: 'KES'),
          ),
        ),
      );
      expect(find.textContaining('KES'), findsWidgets);
    });

    testWidgets('AppCurrencyField lists currencies', (tester) async {
      String? selected;
      await tester.pumpWidget(
        _wrap(
          AppForm(
            child: AppCurrencyField(
              value: 'KES',
              onChanged: (v) => selected = v,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('USD').last);
      await tester.pumpAndSettle();
      expect(selected, 'USD');
    });

    testWidgets('AppDropdown selects value', (tester) async {
      String? selected = 'a';
      await tester.pumpWidget(
        _wrap(
          AppForm(
            child: AppDropdown<String>(
              value: selected,
              label: 'Option',
              items: const [
                DropdownMenuItem(value: 'a', child: Text('Alpha')),
                DropdownMenuItem(value: 'b', child: Text('Beta')),
              ],
              onChanged: (v) => selected = v,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Beta').last);
      await tester.pumpAndSettle();
      expect(selected, 'b');
    });

    testWidgets('AppSearchField clears text', (tester) async {
      final controller = TextEditingController(text: 'query');
      var cleared = false;
      await tester.pumpWidget(
        _wrap(
          AppSearchField(
            controller: controller,
            onClear: () => cleared = true,
          ),
        ),
      );

      expect(find.byIcon(Icons.close), findsOneWidget);
      await tester.tap(find.byIcon(Icons.close));
      await tester.pump();
      expect(controller.text, isEmpty);
      expect(cleared, isTrue);
    });

    testWidgets('AppMultilineField accepts multi-line text', (tester) async {
      final controller = TextEditingController();
      await tester.pumpWidget(
        _wrap(
          AppForm(
            child: AppMultilineField(
              controller: controller,
              label: 'Notes',
              minLines: 3,
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(TextFormField), 'Line one\nLine two');
      expect(controller.text, contains('Line two'));
    });

    testWidgets('FormSection renders title and children', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const AppForm(
            child: FormSection(
              title: 'Personal details',
              subtitle: 'Basic info',
              children: [
                AppTextField(label: 'Name'),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Personal details'), findsOneWidget);
      expect(find.text('Basic info'), findsOneWidget);
      expect(find.text('Name'), findsOneWidget);
    });

    testWidgets('AppSubmitButton validates before submit', (tester) async {
      final formKey = GlobalKey<FormState>();
      var submitted = false;
      await tester.pumpWidget(
        _wrap(
          AppForm(
            formKey: formKey,
            child: Column(
              children: [
                AppTextField(
                  label: 'Name',
                  validator: (v) => AppValidators.required(v, field: 'Name'),
                ),
                AppSubmitButton(
                  label: 'Save',
                  formKey: formKey,
                  onSubmit: () => submitted = true,
                ),
              ],
            ),
          ),
        ),
      );

      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      expect(submitted, isFalse);
      expect(find.textContaining('required'), findsOneWidget);

      await tester.enterText(find.byType(TextFormField), 'Ada');
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      expect(submitted, isTrue);
    });

    testWidgets('AppSubmitButton shows loading indicator', (tester) async {
      await tester.pumpWidget(
        _wrap(
          AppSubmitButton(
            label: 'Saving',
            isLoading: true,
            onSubmit: () {},
          ),
        ),
      );
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('AppDatePicker opens and selects date', (tester) async {
      DateTime? selected;
      await tester.pumpWidget(
        _wrap(
          AppForm(
            child: AppDatePicker(
              label: 'Meeting date',
              isRequired: false,
              onChanged: (d) => selected = d,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(InkWell));
      await tester.pumpAndSettle();
      expect(find.byType(DatePickerDialog), findsOneWidget);
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      expect(selected, isNotNull);
    });

    testWidgets('AppTimePicker opens dialog', (tester) async {
      TimeOfDay? selected;
      await tester.pumpWidget(
        _wrap(
          AppForm(
            child: AppTimePicker(
              label: 'Start time',
              isRequired: false,
              onChanged: (t) => selected = t,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(InkWell));
      await tester.pumpAndSettle();
      expect(find.byType(Dialog), findsOneWidget);
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      expect(selected, isNotNull);
    });

    testWidgets('read-only AppTextField does not edit', (tester) async {
      final controller = TextEditingController(text: 'Locked');
      await tester.pumpWidget(
        _wrap(
          AppForm(
            child: AppTextField(
              controller: controller,
              label: 'Code',
              readOnly: true,
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(TextFormField), 'Changed');
      expect(controller.text, 'Locked');
    });
  });
}
