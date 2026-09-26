import 'dart:convert';

import 'package:dio/dio.dart';

import '../models/expense_transaction.dart';

class ApiClient {
  ApiClient()
      : _dio = Dio(
          BaseOptions(
            baseUrl: 'https://jsonplaceholder.typicode.com',
            connectTimeout: const Duration(seconds: 10),
            receiveTimeout: const Duration(seconds: 10),
            sendTimeout: const Duration(seconds: 10),
            headers: {'Content-Type': 'application/json'},
          ),
        );

  final Dio _dio;

  Future<int?> createTransaction(ExpenseTransaction transaction) async {
    final response = await _dio.post(
      '/posts',
      data: {
        'userId': 1,
        'title': 'expense_tracker',
        'body': jsonEncode(transaction.toApiData()),
      },
    );
    final data = response.data;
    if (data is Map && data['id'] is int) return data['id'] as int;
    return null;
  }

  Future<void> updateTransaction(ExpenseTransaction transaction) async {
    final remoteId = transaction.remoteId;
    if (remoteId == null) {
      await createTransaction(transaction);
      return;
    }
    await _dio.put(
      '/posts/$remoteId',
      data: {
        'id': remoteId,
        'userId': 1,
        'title': 'expense_tracker',
        'body': jsonEncode(transaction.toApiData()),
      },
    );
  }

  Future<void> deleteTransaction(int remoteId) async {
    await _dio.delete('/posts/$remoteId');
  }

  Future<void> readTransactions() async {
    await _dio.get('/posts', queryParameters: {'userId': 1});
  }
}
