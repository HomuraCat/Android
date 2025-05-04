import 'package:flutter/material.dart';
import 'dart:convert'; // For jsonDecode, utf8.decode, Uri.encodeComponent
import 'package:http/http.dart' as http; // For HTTP requests
import '../../config.dart'; // Import your config file

// --- Define Point Shopping Item Model ---
// **MODIFIED**: Removed 'id', kept 'name'. Assumes 'name' is unique.
// **NOTE**: Added other fields from your example JSON, though only 'name' is used in this specific file.
//           You might need these fields elsewhere.
class PointShoppingItem {
  // final int id; // REMOVED
  final String name; // Assumes 'name' column (string) exists and is unique.
  final String points; // Added based on example
  final String instructions; // Added based on example
  final String image; // Added based on example

  PointShoppingItem({
    // required this.id, // REMOVED
    required this.name,
    required this.points,
    required this.instructions,
    required this.image,
  });

  // Factory constructor to create a PointShoppingItem from JSON
  factory PointShoppingItem.fromJson(Map<String, dynamic> json) {
    // **MODIFIED**: Check for 'name' key instead of 'id'.
    // **NOTE**: Added checks for the other fields from your example. Adjust if they are optional.
    if (json['name'] == null || json['points'] == null || json['instructions'] == null || json['image'] == null) {
      print("Error parsing JSON: $json");
      // Consider making some fields optional if they might be missing from the backend
      throw FormatException("Invalid PointShoppingItem JSON format: Missing required key(s). Check backend response. Required: name, points, instructions, image.");
    }
    try {
       return PointShoppingItem(
        // id: json['id'] as int, // REMOVED
        name: json['name'] as String,
        points: json['points'].toString(), // Use toString() for flexibility if backend sends number or string
        instructions: json['instructions'] as String,
        image: json['image'] as String,
      );
    } catch (e) {
       print("Error casting values during PointShoppingItem.fromJson: $e, JSON: $json");
       throw FormatException("Error parsing point shopping item data: $e");
    }
  }
}

// --- Manage Point Shopping Page Widget ---
class ManagePointShoppingPage extends StatefulWidget {
  @override
  _ManagePointShoppingPageState createState() => _ManagePointShoppingPageState();
}

class _ManagePointShoppingPageState extends State<ManagePointShoppingPage> {
  List<PointShoppingItem> _items = []; // List to hold point shopping items
  bool _isLoading = true;
  String? _error;

  final String _baseUrl = Config.baseUrl; // Base URL from config

  @override
  void initState() {
    super.initState();
    _fetchPointShoppingItems(); // Fetch items when the page loads
  }

  // --- Fetch Point Shopping Items from Backend ---
  Future<void> _fetchPointShoppingItems() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });

    // Endpoint remains '/point_shopping' for fetching the list
    final url = Uri.parse('$_baseUrl/point_shopping');

    try {
      final response = await http.get(url).timeout(const Duration(seconds: 15));
      if (!mounted) return;

      if (response.statusCode == 200) {
        // Decode using utf8 for potential non-ASCII characters in names/instructions
        final dynamic decodedBody = jsonDecode(utf8.decode(response.bodyBytes));

        if (decodedBody is List) {
          List<PointShoppingItem> fetchedItems = [];
          String? parsingErrorMsg;
          for (var itemJson in decodedBody) {
            if (itemJson is Map<String, dynamic>) {
              try {
                // Uses the updated PointShoppingItem.fromJson
                fetchedItems.add(PointShoppingItem.fromJson(itemJson));
              } catch (e) {
                print("Error parsing point shopping item: $itemJson, Error: $e");
                // Keep existing partial error message logic
                parsingErrorMsg = "部分积分商城数据加载失败，请检查后台数据格式。";
              }
            } else {
              print("Skipping invalid point shopping item list item: $itemJson");
               parsingErrorMsg = "收到非预期的积分商城数据格式。"; // More specific error
            }
          }

          // Sort items alphabetically by name (optional, but good for consistency)
          fetchedItems.sort((a, b) => a.name.compareTo(b.name));

          if (mounted) {
            setState(() {
              _items = fetchedItems;
              _isLoading = false;
              _error = parsingErrorMsg; // Show partial error if occurred
            });
          }
        } else {
          // Handle cases where the backend doesn't return a list
           print("Backend response was not a List. Body: ${response.body}");
          throw Exception('服务器返回的数据格式不正确 (预期列表)。'); // Chinese error
        }
      } else {
         // Keep existing status code error handling
         String errorMsg = '加载积分商城失败。状态码：${response.statusCode}';
         try {
             final errorData = jsonDecode(response.body);
             errorMsg += "\n错误: ${errorData['error'] ?? errorData['message'] ?? response.body}";
         } catch(_){}
         print(errorMsg);
         throw Exception('加载积分商城失败，请稍后重试。'); // Chinese error
      }
    } catch (e) {
      print("Error fetching point shopping items: $e");
      if (mounted) {
        setState(() {
          // Keep existing general error handling
          _error = e is FormatException // Show format errors directly
                 ? e.message
                 : (e is Exception ? e.toString().split(': ').last : "无法加载积分商城，请检查网络或稍后重试。");
          _isLoading = false;
        });
      }
    }
  }

  // --- Delete Point Shopping Item Function ---
  // **MODIFIED**: Takes 'itemName' (String) instead of 'itemId' (int)
  // **IMPORTANT**: Assumes the backend DELETE endpoint identifies items by name in the URL path.
  //                Example: DELETE /point_shopping/Item%20Name
  //                Adjust the URL construction if your backend expects the name differently
  //                (e.g., as a query parameter: /point_shopping?name=...).
  Future<void> _deletePointShoppingItem(String itemName) async {
    // **MODIFIED**: Construct URL using the item name. Use Uri.encodeComponent for safety.
    final url = Uri.parse('$_baseUrl/point_shopping/${Uri.encodeComponent(itemName)}');
    print("Attempting to delete item at URL: $url"); // For debugging

    try {
      final response = await http.delete(url).timeout(const Duration(seconds: 10));
      if (!mounted) return;

      if (response.statusCode == 200 || response.statusCode == 204) { // 204 No Content is also common for DELETE success
        setState(() {
          // **MODIFIED**: Remove from local list based on name
          _items.removeWhere((item) => item.name == itemName);
        });
        if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('积分商城项 "${itemName}" 删除成功！'), // Include name in success message
                backgroundColor: Colors.green,
              ),
            );
        }
      } else if (response.statusCode == 404) {
          print('Item not found on server (404): $itemName');
          if(mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('服务器上未找到该积分商城项: "$itemName"'), // Include name
                  backgroundColor: Colors.orange,
                ),
              );
              // Optional: Refresh list if item not found, maybe it was deleted elsewhere
              _fetchPointShoppingItems();
          }
      } else {
         // Keep existing detailed error handling for other status codes
         print('Failed to delete point shopping item "$itemName". Status code: ${response.statusCode}');
         print('Response body: ${response.body}');
         String errorMessage = '未知错误';
         try {
            final errorData = jsonDecode(response.body);
            errorMessage = errorData['error'] ?? errorData['message'] ?? '未知错误 (${response.statusCode})';
         } catch(_){}
         throw Exception('删除积分商城项 "$itemName" 失败: $errorMessage'); // Include name in error
      }
    } catch (e) {
      print("Error deleting point shopping item '$itemName': $e");
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('删除积分商城项 "$itemName" 时出错，请稍后重试。'), // Include name in error message
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // --- Show Confirmation Dialog for Deletion ---
  // No change needed in signature, it already receives the full item object.
  Future<void> _showDeleteConfirmationDialog(PointShoppingItem item) async {
    if (!mounted) return;
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // User must tap button
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('确认删除'), // Chinese title
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                // Use item.name (already was doing this)
                Text('您确定要删除积分商品 "${item.name}" 吗？'), // Chinese content
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
                // **MODIFIED**: Call delete function with item.name
                _deletePointShoppingItem(item.name);
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
        title: Text('管理积分商城'), // Chinese title
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _isLoading ? null : _fetchPointShoppingItems,
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

    // Keep existing error display logic when list is empty
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
                Text(_error!, textAlign: TextAlign.center), // Display the specific error
                SizedBox(height: 20),
                ElevatedButton(
                   onPressed: _fetchPointShoppingItems,
                   child: Text('重试'), // Chinese retry button
                )
             ]
          ),
        ),
      );
    }

    // Keep existing logic for showing partial errors via Snackbar
    if (_error != null && _items.isNotEmpty) {
       WidgetsBinding.instance.addPostFrameCallback((_) {
         if(mounted) {
             ScaffoldMessenger.of(context).showSnackBar(SnackBar(
               content: Text(_error!),
               backgroundColor: Colors.orange,
               duration: Duration(seconds: 5), // Show a bit longer for errors
            ));
         }
       });
       // Clear the error after showing it once so it doesn't reappear on rebuilds
       _error = null;
    }

    // Keep existing empty list display logic
    if (_items.isEmpty && _error == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
              Icon(Icons.shopping_cart_outlined, size: 60, color: Colors.grey),
              SizedBox(height: 15),
              Text('未找到任何积分商城项。'), // Chinese empty message
              SizedBox(height: 10),
              ElevatedButton(
                 onPressed: _fetchPointShoppingItems,
                 child: Text('刷新'), // Chinese refresh button
              )
          ],
        )
      );
    }

    // --- Display Point Shopping Item List ---
    // No change needed here, as it already uses item.name for display
    // and passes the full 'item' object to the confirmation dialog.
    return ListView.builder(
      itemCount: _items.length,
      itemBuilder: (context, index) {
        final item = _items[index];
        return Card(
          margin: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          child: ListTile(
            // Optional: You could display the image here too using item.image and Image.network or Image.asset
            leading: Icon(Icons.storefront_outlined, color: Theme.of(context).colorScheme.secondary),
            title: Text(item.name), // Display item name
            // You could add points/instructions to the subtitle if desired:
            // subtitle: Text('积分: ${item.points}\n说明: ${item.instructions}', maxLines: 2, overflow: TextOverflow.ellipsis),
            trailing: IconButton(
              icon: Icon(Icons.delete_outline, color: Colors.redAccent),
              tooltip: '删除 "${item.name}"', // More specific tooltip
              onPressed: () {
                // This passes the correct item object
                _showDeleteConfirmationDialog(item);
              },
            ),
          ),
        );
      },
    );
  }
}