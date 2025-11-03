com.suiteefy.pos

# MOM Store POS App - Data Flow for Creating a New Bill

This document outlines the data flow, key variables, and functions involved in creating a new bill in the MOM Store POS Flutter app. It serves as a guide for developers to understand how data is collected, processed, and used throughout the bill creation process.

## Overview of Bill Creation Flow

The bill creation process involves multiple screens and utilities. It starts from the home screen, collects customer details and products via scanning, calculates totals with optional discounts, and generates a printable PDF bill. Note: Currently, bills are not saved to the database; only PDF generation is implemented.

### Step 1: Initiating Bill Creation (HomeScreen in main.dart)
- **Trigger**: User taps the "Create New Bill" button on the home screen.
- **Navigation**: Navigates to `NewBillScreen`.
- **Key Variables/Functions**:
  - No specific data collection here; it's just a navigation trigger.

### Step 2: Collecting Customer Details and Scanning Products (NewBillScreen)
- **Purpose**: Collect customer name, phone number, and scan products using QR codes.
- **Key Variables**:
  - `_nameController` (TextEditingController): Holds the customer name input.
  - `_phoneController` (TextEditingController): Holds the phone number input (validated to be 10 digits).
  - `scannedProducts` (List<Product>): List of products scanned and added. Each `Product` contains:
    - `productId` (String): Unique product identifier (e.g., PID001).
    - `name` (String): Product name.
    - `category` (String): Product category.
    - `price` (double): Product price.
    - `stock` (int): Current stock (not directly used in bill creation).
    - `variant` (String): Optional product variant.
- **Key Functions**:
  - `_scanProduct()`: Navigates to `QRScannerPage` to scan a QR code, retrieves the product ID, queries the database for the product, and adds it to `scannedProducts` if found.
  - `pickContact()` (from contact_picker.dart): Allows selecting a contact from the phone's contacts to auto-fill name and phone fields.
  - `_nextButtonPressed()`: Validates inputs (name, phone, at least one product), then navigates to `BillingSummaryScreen` with the collected data.
- **Data Flow**: Customer details are stored in controllers. Products are fetched from the database using `DatabaseHelper.instance.getProductById(code)` and added to the list.

### Step 3: Reviewing and Calculating Bill (BillingSummaryScreen)
- **Purpose**: Display selected items, calculate subtotals, apply discounts, and prepare for printing.
- **Key Variables**:
  - `customerName` (String): Passed from `NewBillScreen` (_nameController.text).
  - `phoneNumber` (String): Passed from `NewBillScreen` (_phoneController.text).
  - `items` (List<BillingItem>): Passed from `NewBillScreen`. Each `BillingItem` is created from `scannedProducts` with:
    - `productId` (String): Product ID.
    - `name` (String): Product name.
    - `price` (double): Product price.
    - `quantity` (int): Quantity (hardcoded to 1 in current implementation).
    - `total` (double): Calculated as price * quantity.
  - `subtotal` (double): Sum of all item totals.
  - `discount` (double): Calculated based on `_discountController.text` and `discountType` ("₹" for flat amount, "%" for percentage).
  - `finalTotal` (double): subtotal - discount (ensured not negative).
  - `_discountController` (TextEditingController): Holds discount value input.
  - `discountType` (String): "₹" or "%" selected via dropdown.
- **Key Functions**:
  - `calculateTotals()`: Recalculates subtotal, discount, and finalTotal whenever discount changes.
  - `_onDiscountChanged(String value)`: Triggers recalculation on discount input change.
  - `_onDiscountTypeChanged(String? value)`: Updates discount type and recalculates.
  - Print button's `onPressed`: Saves bill to DB, generates PDF, and prints.
- **Data Flow**: Data is passed via constructor parameters. Calculations are done in real-time. Bill is saved to DB with stock update.

### Step 4: Generating and Printing the PDF Bill (pdf_generator.dart)
- **Purpose**: Create a PDF document with bill details and print it.
- **Key Variables**:
  - `customerName` (String): Customer name.
  - `phoneNumber` (String): Phone number.
  - `items` (List<BillItem>): List of items with productId, name, quantity, price, totalPrice.
- **Key Functions**:
  - `generateBillPdf()`: Builds a PDF page using the `pdf` package, includes a table of items, totals, and store branding. Uses `Printing.layoutPdf()` to print the document.
- **Data Flow**: Receives data from `BillingSummaryScreen`. Generates PDF content dynamically based on provided items and totals.

## Database Models and Helpers
- **Models**:
  - `Product`: Inventory item with productId, name, category, price, stock, variant.
  - `Bill`: Bill with id, date, customerName, phone, subtotal, discount, total.
  - `BillItem`: Bill item with id, billId, productId, name, quantity, price, totalPrice.
  - `BillingItem`: Temp wrapper with productId, name, price, quantity, total.
- **DatabaseHelper**:
  - `insertBill(Bill bill, List<BillItem> items)`: Inserts bill and items, reduces stock.
  - Other methods: getProductById, getAllBills, etc.
- **Note**: Bills are now saved to DB on print, stock updated.

## Key Variables Across Project
- `subtotal`: Sum before discount.
- `discount`: Discount amount.
- `finalTotal`: After discount.
- `billItems`: List for DB/PDF.
- `scannedProducts`: Scanned products.
- `discountType`: "₹" or "%".
- `productId`: Unique product ID.
- `quantity`: Item quantity.
- `totalPrice`: price * quantity.

## Additional Notes
- **Validation**: Phone 10 digits, at least one product.
- **QR Scanning**: mobile_scanner package.
- **Contact Picking**: flutter_contacts.
- **PDF Generation**: pdf and printing packages.
- **Future Enhancements**: Quantity editing, bill history.

For any questions or modifications, refer to the code files mentioned.
