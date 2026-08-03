import 'package:flutter/material.dart';

class Translations {
  final Locale locale;
  Translations(this.locale);

  static Translations of(BuildContext context) {
    return Translations(Localizations.localeOf(context));
  }

  bool get isMs => locale.languageCode == 'ms';

  // Dashboard
  String get greeting => 'Hi Cuyaa Matcha Latte!';
  String get greetingSubtitle =>
      isMs ? 'Semoga jualan hari ini laris!' : 'Hope your sales go well today!';
  String get salesToday => isMs ? 'Jualan Hari Ini' : "Today's Sales";
  String get grossProfit => isMs ? 'Untung Kasar' : 'Gross Profit';
  String get cupsSold => isMs ? 'Cawan Terjual' : 'Cups Sold';
  String get inventoryValue => isMs ? 'Nilai Inventori' : 'Inventory Value';
  String get stockStatus => isMs ? 'STATUS STOK' : 'STOCK STATUS';
  String get viewAll => isMs ? 'Lihat Semua >' : 'View All >';
  String get nearlyOut => isMs ? 'Hampir Habis' : 'Nearly Out';
  String get low => isMs ? 'Rendah' : 'Low';
  String get recordSale => isMs ? 'Rekod Jualan' : 'Record Sale';
  String get bestSellingMenu =>
      isMs ? 'MENU TERLARIS HARI INI' : 'BEST SELLING MENU TODAY';
  String get viewReport => isMs ? 'Lihat Laporan >' : 'View Report >';

  // Bottom nav
  String get dashboard => 'Dashboard';
  String get inventory => isMs ? 'Inventori' : 'Inventory';
  String get recipe => isMs ? 'Resipi' : 'Recipe';
  String get report => isMs ? 'Laporan' : 'Report';
  String get settings => isMs ? 'Tetapan' : 'Settings';

  // Inventory
  String get inventoryTitle =>
      isMs ? 'Inventori Bahan' : 'Inventory Items';
  String get searchItem => isMs ? 'Cari barang...' : 'Search item...';
  String get addItem => isMs ? 'Tambah Barang' : 'Add Item';
  String get all => isMs ? 'Semua' : 'All';
  String get ingredients => isMs ? 'Bahan' : 'Ingredients';
  String get packaging => isMs ? 'Pembungkusan' : 'Packaging';
  String get others => isMs ? 'Lain-lain' : 'Others';
  String get stockValue => isMs ? 'Nilai Stok' : 'Stock Value';
  String get sufficient => isMs ? 'Cukup' : 'Sufficient';
  String get lowStock => isMs ? 'Stok Rendah' : 'Low Stock';
  String get restock => isMs ? 'Perlu Restok?' : 'Need to Restock?';
  String get addStock => isMs ? 'Tambah Stok' : 'Add Stock';
  String get addNewItem => isMs ? 'Tambah Barang Baru' : 'Add New Item';
  String get itemName => isMs ? 'Nama Barang' : 'Item Name';
  String get category => isMs ? 'Kategori' : 'Category';
  String get unit => isMs ? 'Unit' : 'Unit';
  String get initialStock => isMs ? 'Stok Awal' : 'Initial Stock';
  String get minStock => isMs ? 'Stok Minimum' : 'Min. Stock';
  String get costPerUnit => isMs ? 'Kos Seunit' : 'Cost Per Unit';
  String get cancel => isMs ? 'Batal' : 'Cancel';
  String get save => isMs ? 'Simpan' : 'Save';
  String get item => isMs ? 'Barang' : 'Item';
  String get addedQty => isMs ? 'Kuantiti Ditambah' : 'Added Quantity';
  String get totalCost => isMs ? 'Jumlah Kos' : 'Total Cost';
  String get note => isMs ? 'Nota / Pembekal' : 'Note / Supplier';

  // Recipe
  String get recipeTitle =>
      isMs ? 'Resipi Minuman' : 'Beverage Recipes';
  String get beverageRecipe => isMs ? 'Resipi Minuman' : 'Beverage Recipe';
  String get searchRecipe => isMs ? 'Cari resipi...' : 'Search recipe...';
  String get addRecipe => isMs ? 'Tambah Resipi' : 'Add Recipe';
  String get sellingPrice => isMs ? 'Harga Jual' : 'Selling Price';
  String get cost => isMs ? 'Kos' : 'Cost';
  String get grossProfitLabel => isMs ? 'Untung Kasar' : 'Gross Profit';
  String get ingredientsTitle => isMs ? 'Bahan-Bahan' : 'Ingredients';
  String get editRecipe => isMs ? 'Edit Resipi' : 'Edit Recipe';
  String get newRecipe => isMs ? 'Resipi Baru' : 'New Recipe';
  String get beverageName => isMs ? 'Nama Minuman' : 'Beverage Name';
  String get addIngredient => isMs ? 'Tambah Bahan' : 'Add Ingredient';
  String get deleteRecipe => isMs ? 'Padam Resipi' : 'Delete Recipe';
  String get deleteConfirm => isMs ? 'Padamkan resipi ini?' : 'Delete this recipe?';
  String get perCup => isMs ? '/cawan' : '/cup';
  String get totalCostLabel => isMs ? 'Jumlah Kos' : 'Total Cost';

  // Report
  String get reportTitle => isMs ? 'Laporan' : 'Reports';
  String get dailyReport => isMs ? 'Laporan Harian' : 'Daily Report';
  String get stockHistory => isMs ? 'Sejarah Stok' : 'Stock History';
  String get monthlySummary => isMs ? 'Ringkasan Bulanan' : 'Monthly Summary';
  String get dailySales => isMs ? 'Jumlah Jualan' : 'Total Sales';
  String get dailyCost => isMs ? 'Kos Bahan Modal' : 'Cost of Goods';
  String get dailyProfit => isMs ? 'Untung Kasar' : 'Gross Profit';
  String get dailyCups => isMs ? 'Cawan Terjual' : 'Cups Sold';
  String get menuRank => isMs ? 'Menu Paling Laris' : 'Best Selling Menu';
  String get rankLabel => isMs ? 'Kedudukan' : 'Rank';
  String get revenue => isMs ? 'Hasil' : 'Revenue';
  String get restockEntry => isMs ? 'Restok Masuk' : 'Restock In';
  String get deductionEntry => isMs ? 'Jualan Keluar' : 'Sales Out';
  String get monthlyRevenue => isMs ? 'Jumlah Pendapatan' : 'Total Revenue';
  String get legendRevenue => isMs ? 'Pendapatan Kasar' : 'Gross Revenue';
  String get legendCost => isMs ? 'Kos Bahan' : 'Ingredient Cost';
  String get week1 => isMs ? 'Mng 1' : 'Wk 1';
  String get week2 => isMs ? 'Mng 2' : 'Wk 2';
  String get week3 => isMs ? 'Mng 3' : 'Wk 3';
  String get week4 => isMs ? 'Mng 4' : 'Wk 4';

  // Login
  String get appTitle => 'Beverage IMS';
  String get appSubtitle =>
      isMs ? 'Sistem Pengurusan Inventori' : 'Inventory Management System';
  String get login => isMs ? 'Log Masuk' : 'Login';
  String get email => isMs ? 'Emel' : 'Email';
  String get emailHint => isMs ? 'Masukkan emel' : 'Enter email';
  String get password => isMs ? 'Kata Laluan' : 'Password';
  String get passwordHint =>
      isMs ? 'Masukkan kata laluan' : 'Enter password';
  String get forgotPassword =>
      isMs ? 'Lupa Kata Laluan?' : 'Forgot Password?';
  String get signOut => isMs ? 'Log Keluar' : 'Sign Out';
  String get registerStaff =>
      isMs ? 'Daftar Pekerja' : 'Register Staff';
  String get name => isMs ? 'Nama' : 'Name';
  String get nameHint => isMs ? 'Masukkan nama' : 'Enter name';
  String get staffRegistered =>
      isMs ? 'Pekerja berjaya didaftarkan' : 'Staff registered successfully';
  String get aboutApp =>
      isMs ? 'Tentang Aplikasi' : 'About App';
  String get viewAuditLogs =>
      isMs ? 'Lihat Log Audit' : 'View Audit Logs';
  String get edit => isMs ? 'Ubah' : 'Edit';
  String get delete => isMs ? 'Padam' : 'Delete';
  String get changePassword =>
      isMs ? 'Tukar Kata Laluan' : 'Change Password';
  String get currentPassword =>
      isMs ? 'Kata Laluan Semasa' : 'Current Password';
  String get currentPasswordHint =>
      isMs ? 'Masukkan kata laluan semasa' : 'Enter current password';
  String get newPassword =>
      isMs ? 'Kata Laluan Baru' : 'New Password';
  String get newPasswordHint =>
      isMs ? 'Masukkan kata laluan baru' : 'Enter new password';
  String get confirmPassword =>
      isMs ? 'Sahkan Kata Laluan' : 'Confirm Password';
  String get confirmPasswordHint =>
      isMs ? 'Sahkan kata laluan baru' : 'Confirm new password';
  String get passwordMismatch =>
      isMs ? 'Kata laluan tidak sepadan' : 'Passwords do not match';
  String get passwordChanged =>
      isMs ? 'Kata laluan berjaya ditukar' : 'Password changed successfully';
  String get passwordChangedMsg =>
      isMs ? 'Kata laluan anda telah berjaya ditukar.' : 'Your password has been changed successfully.';

  // Settings
  String get appearance => isMs ? 'Penampilan' : 'Appearance';
  String get theme => isMs ? 'Tema' : 'Theme';
  String get light => isMs ? 'Terang' : 'Light';
  String get dark => isMs ? 'Gelap' : 'Dark';
  String get language => isMs ? 'Bahasa' : 'Language';
  String get malay => 'Melayu';
  String get english => isMs ? 'Inggeris' : 'English';
  String get account => isMs ? 'Akaun' : 'Account';
  String get recordSaleTitle =>
      isMs ? 'Rekod Jualan' : 'Record Sale';
  String get selectMenu => isMs ? 'Pilih Menu' : 'Select Menu';
  String get selectMenuHint =>
      isMs ? 'Pilih menu...' : 'Select menu...';
  String get qtySold =>
      isMs ? 'Kuantiti Terjual' : 'Quantity Sold';
  String get unitPriceLabel =>
      isMs ? 'Harga Jual Seunit (RM)' : 'Unit Price (RM)';
  String get totalSalesLabel =>
      isMs ? 'Jumlah Jualan' : 'Total Sales';
  String get saveRecord =>
      isMs ? 'Simpan Rekod' : 'Save Record';
  String get autoDeductNotice =>
      isMs ? 'Stok bahan akan ditolak mengikut resipi secara automatik.' : 'Stock will be deducted automatically per recipe.';
  String get emptyInventory =>
      isMs ? 'Tiada barang dijumpai' : 'No items found';
  String get emptyRecipe =>
      isMs ? 'Tiada resipi dijumpai' : 'No recipes found';
  String get allStockSufficient =>
      isMs ? 'Semua stok mencukupi' : 'All stock sufficient';
  String get noSalesToday =>
      isMs ? 'Tiada jualan hari ini' : 'No sales today';
  String get noStockRecords =>
      isMs ? 'Tiada rekod stok' : 'No stock records';
  String get emptyAudit =>
      isMs ? 'Tiada rekod audit' : 'No audit records';
  String get chooseIngredient =>
      isMs ? 'Pilih Bahan' : 'Select Ingredient';
  String get quantity =>
      isMs ? 'Kuantiti' : 'Quantity';
  String get purchasePriceLabel =>
      isMs ? 'Harga Beli Seunit (RM)' : 'Purchase Price Per Unit (RM)';
  String get purchaseDate =>
      isMs ? 'Tarikh Beli' : 'Purchase Date';
  String get noteOptional =>
      isMs ? 'Nota (pilihan)' : 'Note (optional)';
  String get loginError =>
      isMs ? 'Emel atau kata laluan salah' : 'Invalid email or password';
  String get wrongPassword =>
      isMs ? 'Kata laluan semasa salah' : 'Current password is incorrect';
  String get fillAllFields =>
      isMs ? 'Sila isi semua ruangan' : 'Please fill all fields';
  String get emailInvalid =>
      isMs ? 'Format emel tidak sah' : 'Invalid email format';
  String get passwordTooShort =>
      isMs ? 'Kata laluan mesti sekurang-kurangnya 6 aksara' : 'Password must be at least 6 characters';
  String get staffRegisterFailed =>
      isMs ? 'Pendaftaran gagal. Emel mungkin telah digunakan.' : 'Registration failed. Email may already be in use.';
  String get cupsUnit => isMs ? 'cawan' : 'cups';
  String get cupUnit => isMs ? 'cawan' : 'cup';
  String get recordsUnit => isMs ? 'rekod' : 'records';
  String get unknownItem =>
      isMs ? 'Tidak Diketahui' : 'Unknown';
  String get recipeNote =>
      isMs ? 'Resipi ini akan digunakan setiap kali jualan direkod.' : 'This recipe will be used each time a sale is recorded.';
  String get setMeasurement =>
      isMs ? 'Tetapkan sukatan' : 'Set Measurement';
  String get selectHint =>
      isMs ? 'Pilih...' : 'Select...';
  String get manageUsers =>
      isMs ? 'Urus Pengguna' : 'Manage Users';
  String get userManagementTitle =>
      isMs ? 'Urus Pengguna' : 'User Management';
  String get roleChanged =>
      isMs ? 'Peranan berjaya ditukar' : 'Role updated successfully';
  String get statusChanged =>
      isMs ? 'Status berjaya ditukar' : 'Status updated successfully';
  String get active =>
      isMs ? 'Aktif' : 'Active';
  String get deactivated =>
      isMs ? 'Dinyahaktif' : 'Deactivated';
  String get lastOpened =>
      isMs ? 'Terakhir dibuka' : 'Last opened';
  String get never =>
      isMs ? 'Tidak pernah' : 'Never';
  String get confirmDeactivate =>
      isMs ? 'Nyahaktifkan pengguna ini? Mereka tidak boleh log masuk lagi.' : 'Deactivate this user? They will no longer be able to log in.';
  String get confirmActivate =>
      isMs ? 'Aktifkan semula pengguna ini?' : 'Reactivate this user?';
  String get deactivateUser =>
      isMs ? 'Nyahaktifkan' : 'Deactivate';
  String get activateUser =>
      isMs ? 'Aktifkan' : 'Activate';
  String get changeRole =>
      isMs ? 'Tukar Peranan' : 'Change Role';
  String get role =>
      isMs ? 'Peranan' : 'Role';
  String get status =>
      isMs ? 'Status' : 'Status';
}
