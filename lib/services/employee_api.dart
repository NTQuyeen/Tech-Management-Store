import '../config/api_config.dart';
import '../config/api_routes.dart';
import '../models/employee.dart';
import '../state/auth_session.dart';
import 'api_client.dart';

class EmployeeApi {
  final ApiClient _client;

  EmployeeApi({ApiClient? client})
    : _client =
          client ??
          ApiClient(
            baseUrl: ApiConfig.baseUrl,
            tokenProvider: () async => AuthSession.instance.token,
          );

  Future<List<Employee>> list({String? query}) async {
    final items = await _client.getListJson(ApiRoutes.users);

    final employees = items
        .whereType<Map>()
        .map((e) => Employee.fromJson(Map<String, dynamic>.from(e)))
        .toList();

    final q = (query ?? '').trim().toLowerCase();
    if (q.isNotEmpty) {
      return employees
          .where(
            (e) =>
                e.fullName.toLowerCase().contains(q) ||
                e.username.toLowerCase().contains(q),
          )
          .toList();
    }

    return employees;
  }

  Future<Employee> create(Employee employee) async {
    // ✅ POST /shopqtqt/user, body KHÔNG có id
    await _client.postJson(ApiRoutes.users, body: employee.toJsonForCreate());
    return employee;
  }

  Future<Employee> update(Employee employee) async {
    // ✅ PUT /shopqtqt/user/{id}
    final id = employee.id;
    if (id == null) {
      throw Exception('Thiếu id để cập nhật nhân viên');
    }

    await _client.putJson(
      ApiRoutes.userById(id.toString()),
      body: employee.toJsonForUpdate(),
    );
    return employee;
  }

  Future<void> deleteById(int id) async {
    // ✅ DELETE /shopqtqt/user/{id}
    await _client.delete(ApiRoutes.userById(id.toString()));
  }
}
