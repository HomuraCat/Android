import 'package:flutter/material.dart';
import 'dart:convert'; // For jsonDecode
import 'package:http/http.dart' as http; // For HTTP requests
import '../../config.dart'; // Import your config file

// --- Define Knowledge Learning Item Model ---
// **IMPORTANT**: Adjust fields based on your 'mylearn.videos' table columns
class KnowledgeItem {
  final int id; // Assumes 'id' column (integer) exists
  final String title; // Assumes 'title' column (string) exists. Change if needed.

  KnowledgeItem({
    required this.id,
    required this.title,
  });

  // Factory constructor to create a KnowledgeItem from JSON
  factory KnowledgeItem.fromJson(Map<String, dynamic> json) {
    // **IMPORTANT**: Check if 'id' and 'title' keys exist in the JSON response
    if (json['id'] == null || json['title'] == null) { // Adjust 'title' if needed
      print("Error parsing JSON: $json");
      throw FormatException("Invalid KnowledgeItem JSON format: Missing 'id' or 'title' key. Check backend response and table columns.");
    }
    try {
       return KnowledgeItem(
        id: json['id'] as int,
        title: json['title'] as String, // Adjust 'title' if needed
      );
    } catch (e) {
       print("Error casting values during KnowledgeItem.fromJson: $e, JSON: $json");
       throw FormatException("Error parsing knowledge item data: $e");
    }
  }
}

// --- Manage Knowledge Learning Page Widget ---
class ManageKnowledgeLearningPage extends StatefulWidget {
  @override
  _ManageKnowledgeLearningPageState createState() => _ManageKnowledgeLearningPageState();
}

class _ManageKnowledgeLearningPageState extends State<ManageKnowledgeLearningPage> {
  List<KnowledgeItem> _items = []; // List to hold knowledge items
  bool _isLoading = true;
  String? _error;

  final String _baseUrl = Config.baseUrl; // Base URL from config

  @override
  void initState() {
    super.initState();
    _fetchKnowledgeItems(); // Fetch items when the page loads
  }

  // --- Fetch Knowledge Items from Backend ---
  Future<void> _fetchKnowledgeItems() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });

    // **IMPORTANT: Endpoint is '/knowledge_learning'**
    final url = Uri.parse('$_baseUrl/knowledge_learning');

    try {
      final response = await http.get(url).timeout(const Duration(seconds: 15));
      if (!mounted) return;

      if (response.statusCode == 200) {
        final dynamic decodedBody = jsonDecode(utf8.decode(response.bodyBytes));

        if (decodedBody is List) {
          List<KnowledgeItem> fetchedItems = [];
          String? parsingErrorMsg;
          for (var itemJson in decodedBody) {
            if (itemJson is Map<String, dynamic>) {
              try {
                fetchedItems.add(KnowledgeItem.fromJson(itemJson));
              } catch (e) {
                print("Error parsing knowledge item: $itemJson, Error: $e");
                parsingErrorMsg = "部分知识学习数据加载失败，请检查后台数据格式。";
              }
            } else {
              print("Skipping invalid knowledge item list item: $itemJson");
            }
          }

          if (mounted) {
            setState(() {
              _items = fetchedItems;
              _isLoading = false;
              _error = parsingErrorMsg;
            });
          }
        } else {
          throw Exception('Backend did not return a List. Response type: ${decodedBody.runtimeType}');
        }
      } else {
         String errorMsg = '加载知识学习失败。状态码：${response.statusCode}';
         try {
             final errorData = jsonDecode(response.body);
             errorMsg += "\n错误: ${errorData['error'] ?? errorData['message'] ?? response.body}";
         } catch(_){}
         print(errorMsg);
         throw Exception('加载知识学习失败，请稍后重试。');
      }
    } catch (e) {
      print("Error fetching knowledge items: $e");
      if (mounted) {
        setState(() {
          _error = e is Exception ? e.toString().split(': ').last : "无法加载知识学习，请检查网络或稍后重试。";
          _isLoading = false;
        });
      }
    }
  }

  // --- Delete Knowledge Item Function ---
  Future<void> _deleteKnowledgeItem(int itemId) async {
    // **IMPORTANT: Endpoint is '/knowledge_learning/$itemId'**
    final url = Uri.parse('$_baseUrl/knowledge_learning/$itemId');

    try {
      final response = await http.delete(url).timeout(const Duration(seconds: 10));
      if (!mounted) return;

      if (response.statusCode == 200 || response.statusCode == 204) {
        setState(() {
          _items.removeWhere((item) => item.id == itemId); // Remove from local list
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('知识学习项删除成功！'), // Chinese success message
            backgroundColor: Colors.green,
          ),
        );
      } else if (response.statusCode == 404) {
         ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('服务器上未找到该知识学习项。'), // Chinese 404 message
            backgroundColor: Colors.orange,
          ),
        );
         _fetchKnowledgeItems(); // Refresh list
      } else {
         print('Failed to delete knowledge item. Status code: ${response.statusCode}');
         print('Response body: ${response.body}');
         String errorMessage = '未知错误';
         try {
            final errorData = jsonDecode(response.body);
            errorMessage = errorData['error'] ?? errorData['message'] ?? '未知错误';
         } catch(_){}
         throw Exception('删除知识学习项失败: $errorMessage');
      }
    } catch (e) {
      print("Error deleting knowledge item: $e");
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('删除知识学习项失败，请稍后重试。'), // Chinese error message
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // --- Show Confirmation Dialog for Deletion ---
  Future<void> _showDeleteConfirmationDialog(KnowledgeItem item) async {
    if (!mounted) return;
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('确认删除'), // Chinese title
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                // Use item.title here
                Text('您确定要删除知识学习 "${item.title}" 吗？'), // Chinese content
                SizedBox(height: 8),
                Text('此操作无法撤销。', style: TextStyle(color: Colors.grey[600])), // Chinese warning
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('取消'), // Chinese cancel
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            TextButton(
              child: Text('删除', style: TextStyle(color: Colors.red)), // Chinese delete
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _deleteKnowledgeItem(item.id); // Call delete function
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('管理知识学习'), // Chinese title
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _isLoading ? null : _fetchKnowledgeItems, // Disable while loading
            tooltip: '刷新', // Chinese tooltip
          ),
        ],
      ),
      body: _buildBody(), // Build the body based on state
    );
  }

  // --- Build Body Based on State ---
  Widget _buildBody() {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    // Handle error state when list is empty
    if (_error != null && _items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
             mainAxisAlignment: MainAxisAlignment.center,
             children: [
                Icon(Icons.error_outline, color: Colors.red, size: 50),
                SizedBox(height: 10),
                Text('加载数据时出错', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), // Chinese error title
                SizedBox(height: 10),
                Text(_error!, textAlign: TextAlign.center),
                SizedBox(height: 20),
                ElevatedButton(
                   onPressed: _fetchKnowledgeItems,
                   child: Text('重试'), // Chinese retry button
                )
             ]
          ),
        ),
      );
    }

    // Show Snackbar for partial errors if some data loaded
    if (_error != null && _items.isNotEmpty) {
       WidgetsBinding.instance.addPostFrameCallback((_) {
         if(mounted) {
             ScaffoldMessenger.of(context).showSnackBar(SnackBar(
               content: Text(_error!),
               backgroundColor: Colors.orange,
            ));
         }
       });
    }

    // Handle empty list state
    if (_items.isEmpty && _error == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
              Icon(Icons.menu_book_outlined, size: 60, color: Colors.grey), // Knowledge icon
              SizedBox(height: 15),
              Text('未找到任何知识学习项。'), // Chinese empty message
              SizedBox(height: 10),
              ElevatedButton(
                 onPressed: _fetchKnowledgeItems,
                 child: Text('刷新'), // Chinese refresh button
              )
          ],
        )
      );
    }

    // --- Display Knowledge Item List ---
    return ListView.builder(
      itemCount: _items.length,
      itemBuilder: (context, index) {
        final item = _items[index];
        return Card(
          margin: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          child: ListTile(
            leading: Icon(Icons.article_outlined, color: Theme.of(context).colorScheme.primary), // Leading icon
            title: Text(item.title), // Display item title
            // subtitle: Text('ID: ${item.id}'), // Optional: Display ID
            trailing: IconButton(
              icon: Icon(Icons.delete_outline, color: Colors.redAccent),
              tooltip: '删除知识学习', // Chinese tooltip
              onPressed: () {
                _showDeleteConfirmationDialog(item); // Show confirmation on delete press
              },
            ),
          ),
        );
      },
    );
  }
}
