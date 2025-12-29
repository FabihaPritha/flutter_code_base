# NetworkCaller Usage Guide

## ✅ Migration Complete!

The project has been successfully migrated from `ApiService` to `NetworkCaller`. All code is now using the improved `network_caller.dart`.

---

## 📁 Architecture Overview

```
UI/Widget Layer
      ↓
Controller/Provider Layer  
      ↓
Repository Layer ⭐ (You work here!)
      ↓
NetworkCaller (HTTP Layer)
```

---

## 🔥 How to Use NetworkCaller in Repositories

### Example 1: Basic GET Request

```dart
import 'package:flutter_code_base/core/services/network_caller.dart';
import 'package:flutter_code_base/core/constants/api_constants.dart';

class ProductRepository {
  final NetworkCaller _networkCaller;

  ProductRepository(this._networkCaller);

  Future<List<Product>> getProducts() async {
    final response = await _networkCaller.getRequest(
      ApiConstants.products,
      queryParameters: {'page': 1, 'limit': 10},
    );

    if (response.isSuccess && response.responseData != null) {
      final List<dynamic> data = response.responseData['products'];
      return data.map((json) => Product.fromJson(json)).toList();
    } else {
      throw Exception(response.errorMessage ?? 'Failed to load products');
    }
  }
}
```

---

### Example 2: POST Request with Body

```dart
class OrderRepository {
  final NetworkCaller _networkCaller;

  OrderRepository(this._networkCaller);

  Future<Order> createOrder(Map<String, dynamic> orderData) async {
    final response = await _networkCaller.postRequest(
      ApiConstants.createOrder,
      body: orderData,
    );

    if (response.isSuccess && response.responseData != null) {
      return Order.fromJson(response.responseData['order']);
    } else {
      throw Exception(response.errorMessage ?? 'Failed to create order');
    }
  }
}
```

---

### Example 3: PUT/PATCH Request (Update)

```dart
class ProfileRepository {
  final NetworkCaller _networkCaller;

  ProfileRepository(this._networkCaller);

  Future<User> updateProfile(String userId, Map<String, dynamic> updates) async {
    final response = await _networkCaller.patchRequest(
      '${ApiConstants.userProfile}/$userId',
      body: updates,
    );

    if (response.isSuccess && response.responseData != null) {
      return User.fromJson(response.responseData['user']);
    } else {
      throw Exception(response.errorMessage ?? 'Failed to update profile');
    }
  }
}
```

---

### Example 4: DELETE Request

```dart
class ProductRepository {
  final NetworkCaller _networkCaller;

  ProductRepository(this._networkCaller);

  Future<void> deleteProduct(String productId) async {
    final response = await _networkCaller.deleteRequest(
      ApiConstants.deleteProduct(productId),
    );

    if (!response.isSuccess) {
      throw Exception(response.errorMessage ?? 'Failed to delete product');
    }
  }
}
```

---

### Example 5: File Upload (Multipart)

```dart
class ProfileRepository {
  final NetworkCaller _networkCaller;

  ProfileRepository(this._networkCaller);

  Future<String> uploadProfilePicture(String filePath) async {
    final response = await _networkCaller.multipartRequest(
      ApiConstants.uploadAvatar,
      filePath: filePath,
      fieldName: 'profile_picture', // Field name in form data
      additionalData: {'userId': '123'}, // Optional additional fields
    );

    if (response.isSuccess && response.responseData != null) {
      return response.responseData['imageUrl'];
    } else {
      throw Exception(response.errorMessage ?? 'Failed to upload image');
    }
  }
}
```

---

### Example 6: File Download

```dart
class DocumentRepository {
  final NetworkCaller _networkCaller;

  DocumentRepository(this._networkCaller);

  Future<void> downloadInvoice(String invoiceId, String savePath) async {
    final response = await _networkCaller.downloadFile(
      '/api/v1/invoices/$invoiceId/download',
      savePath,
      onReceiveProgress: (received, total) {
        if (total != -1) {
          print('Download progress: ${(received / total * 100).toStringAsFixed(0)}%');
        }
      },
    );

    if (!response.isSuccess) {
      throw Exception(response.errorMessage ?? 'Failed to download invoice');
    }
  }
}
```

---

## 🎯 Creating a New Repository

### Step 1: Create Repository Class

```dart
// lib/features/products/repositories/product_repository.dart

import 'dart:developer';
import 'package:flutter_code_base/core/constants/api_constants.dart';
import 'package:flutter_code_base/core/services/network_caller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_code_base/features/products/models/product_model.dart';

class ProductRepository {
  final NetworkCaller _networkCaller;

  ProductRepository(this._networkCaller);

  /// Get all products
  Future<List<Product>> getProducts() async {
    log('ProductRepository: Fetching products');
    
    final response = await _networkCaller.getRequest(
      ApiConstants.products,
    );

    if (response.isSuccess && response.responseData != null) {
      final List<dynamic> data = response.responseData['products'];
      return data.map((json) => Product.fromJson(json)).toList();
    } else {
      throw Exception(response.errorMessage ?? 'Failed to load products');
    }
  }

  /// Get product by ID
  Future<Product> getProductById(String id) async {
    log('ProductRepository: Fetching product $id');
    
    final response = await _networkCaller.getRequest(
      ApiConstants.productDetails(id),
    );

    if (response.isSuccess && response.responseData != null) {
      return Product.fromJson(response.responseData['product']);
    } else {
      throw Exception(response.errorMessage ?? 'Failed to load product');
    }
  }

  /// Create new product
  Future<Product> createProduct(Map<String, dynamic> productData) async {
    log('ProductRepository: Creating product');
    
    final response = await _networkCaller.postRequest(
      ApiConstants.createProduct,
      body: productData,
    );

    if (response.isSuccess && response.responseData != null) {
      return Product.fromJson(response.responseData['product']);
    } else {
      throw Exception(response.errorMessage ?? 'Failed to create product');
    }
  }

  /// Update product
  Future<Product> updateProduct(String id, Map<String, dynamic> updates) async {
    log('ProductRepository: Updating product $id');
    
    final response = await _networkCaller.putRequest(
      ApiConstants.updateProduct(id),
      body: updates,
    );

    if (response.isSuccess && response.responseData != null) {
      return Product.fromJson(response.responseData['product']);
    } else {
      throw Exception(response.errorMessage ?? 'Failed to update product');
    }
  }

  /// Delete product
  Future<void> deleteProduct(String id) async {
    log('ProductRepository: Deleting product $id');
    
    final response = await _networkCaller.deleteRequest(
      ApiConstants.deleteProduct(id),
    );

    if (!response.isSuccess) {
      throw Exception(response.errorMessage ?? 'Failed to delete product');
    }
  }
}

// ========================== PROVIDER ============================ //

/// Product Repository Provider
final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return ProductRepository(NetworkCaller());
});
```

---

### Step 2: Use Repository in Provider/Controller

```dart
// lib/features/products/providers/product_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_code_base/features/products/models/product_model.dart';
import 'package:flutter_code_base/features/products/repositories/product_repository.dart';

/// Product List Provider
final productListProvider = FutureProvider<List<Product>>((ref) async {
  final repository = ref.read(productRepositoryProvider);
  return await repository.getProducts();
});

/// Product Detail Provider
final productDetailProvider = FutureProvider.family<Product, String>((ref, id) async {
  final repository = ref.read(productRepositoryProvider);
  return await repository.getProductById(id);
});
```

---

### Step 3: Use in Widget

```dart
// lib/features/products/screens/product_list_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_code_base/features/products/providers/product_provider.dart';

class ProductListScreen extends ConsumerWidget {
  const ProductListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productListAsync = ref.watch(productListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Products')),
      body: productListAsync.when(
        data: (products) => ListView.builder(
          itemCount: products.length,
          itemBuilder: (context, index) {
            final product = products[index];
            return ListTile(
              title: Text(product.name),
              subtitle: Text('\$${product.price}'),
            );
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }
}
```

---

## 🔑 Key Features of NetworkCaller

✅ **Automatic Token Management** - Tokens are automatically added to headers  
✅ **Token Refresh** - Automatically refreshes expired tokens and retries requests  
✅ **Error Handling** - Comprehensive error handling for all scenarios  
✅ **Request/Response Logging** - Detailed logs for debugging  
✅ **Timeout Management** - Configurable timeouts for requests  
✅ **File Upload/Download** - Built-in support for multipart requests  
✅ **Query Parameters** - Easy to add query parameters  
✅ **Singleton Pattern** - One instance throughout the app  

---

## 📝 NetworkCaller Methods

| Method | Description | Use Case |
|--------|-------------|----------|
| `getRequest()` | GET request | Fetch data from server |
| `postRequest()` | POST request | Create new resources |
| `putRequest()` | PUT request | Replace entire resource |
| `patchRequest()` | PATCH request | Update partial resource |
| `deleteRequest()` | DELETE request | Delete resources |
| `multipartRequest()` | Multipart POST/PATCH | Upload files/images |
| `downloadFile()` | Download files | Download PDFs, images, etc. |

---

## 🚨 Error Handling Best Practices

```dart
Future<List<Product>> getProducts() async {
  try {
    final response = await _networkCaller.getRequest(
      ApiConstants.products,
    );

    if (response.isSuccess && response.responseData != null) {
      // Success case
      final List<dynamic> data = response.responseData['products'];
      return data.map((json) => Product.fromJson(json)).toList();
    } else {
      // API returned error
      throw Exception(response.errorMessage ?? 'Failed to load products');
    }
  } catch (e) {
    // Network or parsing error
    log('ProductRepository: Error fetching products - $e');
    rethrow; // Let the UI handle the error
  }
}
```

---

## 💡 Tips

1. **Always check `response.isSuccess`** before accessing data
2. **Use `response.errorMessage`** for user-friendly error messages
3. **Log important operations** using `log()` from `dart:developer`
4. **Handle null cases** - Always check if `response.responseData` is not null
5. **Don't call NetworkCaller directly from UI** - Always use Repository pattern

---

## 🎉 Summary

You now have a fully functional `NetworkCaller` that:
- ✅ Replaces `ApiService`
- ✅ Has automatic token management
- ✅ Has automatic token refresh
- ✅ Works with your existing `AuthRepository`
- ✅ Is ready to use in new repositories

**Next Steps:**
1. Create new repositories following the examples above
2. Use repositories in your providers/controllers
3. Use providers in your widgets
4. Never call NetworkCaller directly from UI!

Happy coding! 🚀
