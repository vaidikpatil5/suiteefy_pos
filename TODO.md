# TODO: Apply Theme Colors to All Elements

## Step 1: Update lib/main.dart
- [x] Fix typo: Change `Color.fomHex(#5C4C45)` to `AppTheme.bodyText`
- [x] Change import button backgroundColor from `Colors.white` to `AppTheme.lilacTaupe` (secondary button)
- [x] Change import button icon color from `Colors.black` to `Colors.white`
- [x] Change CircularProgressIndicator color from `Colors.black` to `Colors.white`

## Step 2: Update lib/new_bill_screen.dart
- [x] Change "Next" button backgroundColor from `Colors.blueAccent` to `AppTheme.roseDust`
- [x] Change QR scanner border color from `Colors.white` to `AppTheme.satinGold`
- [x] Change QR scanner backgroundColor from `Colors.black54` to `AppTheme.deepCocoa.withOpacity(0.5)`
- [x] Ensure CircularProgressIndicator color remains `Colors.white`

## Step 3: Update lib/screens/billing_screen.dart
- [x] Keep delete icon color as `Colors.red` (standard for delete actions)

## Step 4: Update lib/screens/contact_picker_screen.dart
- [x] If uncommented, change appBar backgroundColor from `Colors.deepPurple` to `AppTheme.pearlIvory`

## Step 5: Test the app
- [x] Run the app to verify all colors are applied correctly
- [x] Check if app bar needs gradient; if so, update theme.dart

## Step 6: Finalize
- [x] Ensure all elements follow the theme
- [x] Update TODO.md with completion status
