class ApiRoutes {
  ApiRoutes._();

  static const String _prefix = '/shopqtqt';

  // Auth
  static const String authLogin = '$_prefix/login';

  // Products
  static const String products = '$_prefix/product';
  static String productById(String id) => '$_prefix/product/$id';

  // Users
  static const String users = '$_prefix/user';
  static String userById(String id) => '$_prefix/user/$id';

  // Customers (BE: GET /customer/{sdt})
  static String customerByPhone(String phone) {
    final encoded = Uri.encodeComponent(phone);
    return '$_prefix/customer/$encoded';
  }

  // Invoices (BE: POST /invoice)
  static const String invoice = '$_prefix/invoice';

  // Product-invoice (BE: POST /product-invoice)
  static const String productInvoice = '$_prefix/product-invoice';
}
