import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

class SupabaseService {
  static final _supabase = Supabase.instance.client;

    static String? getCurrentUserId() {
  final id = _supabase.auth.currentUser?.id;
  print('🧪 getCurrentUserId: $id (type: ${id.runtimeType})');
  // Check: must be non-null and look like a UUID
  if (id == null || id.length < 10) {
    print('🔥 ERROR: userId is invalid! Must be a UUID. Got: $id');
    return null;
  }
  return id;
}


  // Fetch all categories
  static Future<List<Map<String, dynamic>>> getCategories() async {
    final data = await _supabase
        .from('categories')
        .select()
        .order('sort_order');
    if (data == null) {
      throw Exception('No categories found.');
    }
    return List<Map<String, dynamic>>.from(data);
  }

  // Fetch announcements (NEW)
  static Future<List<Map<String, dynamic>>> getAnnouncements() async {
    final data = await _supabase
        .from('announcements')
        .select()
        .eq('active', true)
        .order('sort_order');
    if (data == null) {
      throw Exception('No announcements found.');
    }
    return List<Map<String, dynamic>>.from(data);
  }

  // Fetch banners for home page (with new columns)
  static Future<List<Map<String, dynamic>>> getBanners() async {
    final now = DateTime.now().toIso8601String();
    final data = await _supabase
        .from('banners')
        .select()
        .eq('active', true)
        .lte('start_date', now)
        .or('end_date.is.null,end_date.gte.$now')
        .order('sort_order');
    if (data == null) {
      return [];
    }
    return List<Map<String, dynamic>>.from(data);
  }

  // Fetch banners for selected gender and language (from gender_carousel)
  static Future<List<Map<String, dynamic>>> getGenderBanners({
    required String gender,      // 'men', 'women', or 'kids'
    required String language,    // 'ar' or 'en'
  }) async {
    final data = await _supabase
        .from('gender_carousel')
        .select()
        .eq('active', true)
        .eq('gender', gender.toLowerCase())
        .eq('language', language.toLowerCase())
        .order('sort_order');
    if (data == null) {
      throw Exception('No banners found.');
    }
    return List<Map<String, dynamic>>.from(data);
  }

  // Fetch featured celebrities filtered by gender (for Home Page)
static Future<List<Map<String, dynamic>>> getFeaturedCelebritiesByGender(String genderKey) async {
  final data = await _supabase
      .from('celebrities')
      .select()
      .eq('featured', true)
      .eq('gender', genderKey)
      .order('sort_order')
      .order('name_en');
  if (data == null) {
    throw Exception('No celebrities found.');
  }
  return List<Map<String, dynamic>>.from(data);
}

// Fetch all celebrities by gender (for "Show All" page)
static Future<List<Map<String, dynamic>>> getAllCelebrities(String genderKey) async {
  final data = await _supabase
      .from('celebrities')
      .select()
      .eq('gender', genderKey)
      .order('name_en');
  if (data == null) {
    throw Exception('No celebrities found.');
  }
  return List<Map<String, dynamic>>.from(data);
}

  // Get products (supporting dynamic filters: gender, size, color, etc.)
  static Future<List<Map<String, dynamic>>> getProducts({
    String? categoryId,
    String? sortBy,
    String? gender,
    String? orderBy,
    bool descending = false,
    Map<String, dynamic>? filters,
  }) async {
    var query = _supabase
  .from('products')
  .select('*, brand:brands(id, name_en, name_ar, logo_url)')
  .eq('visible', true);

    if (gender != null && gender.isNotEmpty) {
      query = query.eq('gender', gender);
    }

    if (categoryId != null && categoryId.isNotEmpty) {
      query = query.eq('category_id', categoryId);
    }

    if (filters != null) {
      filters.forEach((key, value) {
        if (value != null && value.toString().isNotEmpty) {
          query = query.eq(key, value);
        }
      });
    }

    if (orderBy != null) {
      query.order(orderBy, ascending: !descending);
    } else {
      String sortColumn = 'created_at';
      bool ascending = false;
      if (sortBy != null) {
        switch (sortBy) {
          case 'oldest':
            sortColumn = 'created_at';
            ascending = true;
            break;
          case 'newest':
            sortColumn = 'created_at';
            ascending = false;
            break;
          case 'high':
            sortColumn = 'rating';
            ascending = false;
            break;
          case 'low':
            sortColumn = 'rating';
            ascending = true;
            break;
          case 'price_high':
            sortColumn = 'price';
            ascending = false;
            break;
          case 'price_low':
            sortColumn = 'price';
            ascending = true;
            break;
          default:
            sortColumn = 'created_at';
            ascending = false;
        }
      }
      query.order(sortColumn, ascending: ascending);
    }

    final data = await query;
    if (data == null) {
      throw Exception('No products found.');
    }

    return List<Map<String, dynamic>>.from(data);
  }

  // Many-to-many: categories for a product
  static Future<List<Map<String, dynamic>>> getCategoriesForProduct(String productId) async {
    final data = await _supabase
        .from('product_categories')
        .select('category_id, categories(*)')
        .eq('product_id', productId);
    if (data == null) {
      throw Exception('No product categories found.');
    }
    return List<Map<String, dynamic>>.from(
      data.map((item) => item['categories'])
    );
  }

  // Many-to-many: products for a category
  static Future<List<Map<String, dynamic>>> getProductsForCategory(
    String categoryId, {
    String sortBy = 'newest',
    String? gender,
    Map<String, dynamic>? filters,
  }) async {
    final data = await _supabase
        .from('product_categories')
        .select('product_id, products(*)')
        .eq('category_id', categoryId);
    if (data == null) {
      throw Exception('No category products found.');
    }

    List<Map<String, dynamic>> products = List<Map<String, dynamic>>.from(
      data.map((item) => item['products'])
    );

    if (gender != null && gender.isNotEmpty) {
      products = products.where((prod) =>
        prod['gender']?.toString().toLowerCase() == gender.toLowerCase()
      ).toList();
    }

    if (filters != null) {
      filters.forEach((key, value) {
        if (value != null && value.toString().isNotEmpty) {
          products = products.where((prod) => prod[key]?.toString() == value.toString()).toList();
        }
      });
    }

    String sortColumn = 'created_at';
    bool ascending = false;
    switch (sortBy) {
      case 'oldest':
        sortColumn = 'created_at';
        ascending = true;
        break;
      case 'newest':
        sortColumn = 'created_at';
        ascending = false;
        break;
      case 'high':
        sortColumn = 'rating';
        ascending = false;
        break;
      case 'low':
        sortColumn = 'rating';
        ascending = true;
        break;
      case 'price_high':
        sortColumn = 'price';
        ascending = false;
        break;
      case 'price_low':
        sortColumn = 'price';
        ascending = true;
        break;
      default:
        sortColumn = 'created_at';
        ascending = false;
    }
    products.sort((a, b) {
      if (ascending) {
        return a[sortColumn]?.compareTo(b[sortColumn] ?? '') ?? 0;
      } else {
        return b[sortColumn]?.compareTo(a[sortColumn] ?? '') ?? 0;
      }
    });

    return products;
  }

 // Fetch all brands, ordered and filtered for current gender
static Future<List<Map<String, dynamic>>> getBrands({String? gender}) async {
  var query = _supabase.from('brands').select();

  if (gender != null && gender.isNotEmpty) {
    query = query.eq('gender', gender.toLowerCase());
  }

  // CHAIN .order() directly, don't reassign to query!
  final data = await query.order('sort_order');

  if (data == null) {
    throw Exception('No brands found.');
  }
  return List<Map<String, dynamic>>.from(data);
}

// Fetch featured brands for the home page (by gender)
static Future<List<Map<String, dynamic>>> getFeaturedBrands({String? gender}) async {
  var query = _supabase
      .from('brands')
      .select()
      .eq('featured', true)
      .eq('status', 'active');

  // Add gender filter if provided
  if (gender != null && gender.isNotEmpty) {
    query = query.eq('gender', gender.toLowerCase());
  }

  // .order() MUST BE LAST before await
  final data = await query.order('sort_order');

  if (data == null) throw Exception('No featured brands found.');
  return List<Map<String, dynamic>>.from(data);
}

// fetch celebrity recommendation products
static Future<List<Map<String, dynamic>>> getCelebrityRecommendedProducts({
  required String celebrityId,
  String? sortBy,
  Map<String, dynamic>? filter,
}) async {
  // Step 1: Get all product_ids for this celebrity from celebrity_products table
  final celebrityProductsResponse = await _supabase
      .from('celebrity_products')
      .select('product_id')
      .eq('celebrity_id', celebrityId);

  if (celebrityProductsResponse == null || celebrityProductsResponse.isEmpty) {
    return [];
  }

  // Step 2: Extract product IDs as a List
  final List productIds = celebrityProductsResponse
      .map((e) => e['product_id'].toString())
      .toList();

  if (productIds.isEmpty) return [];

  // Step 3: Build filter for products table
  dynamic query = _supabase
    .from('products')
    .select('*')
    .inFilter('id', productIds); // or .in_('id', productIds)

  // Add sort if needed
  if (sortBy == 'price_asc') {
    query = query.order('price', ascending: true);
  } else if (sortBy == 'price_desc') {
    query = query.order('price', ascending: false);
  } else if (sortBy == 'newest') {
    query = query.order('created_at', ascending: false);
  }

  // Add other filters if passed (e.g., price range, category, etc.)
  if (filter != null && filter.isNotEmpty) {
    filter.forEach((key, value) {
      query = query.eq(key, value);
    });
  }

  final products = await query;
  // Defensive: sometimes null is returned from supabase if nothing found
  if (products == null || products.isEmpty) {
    return [];
  }
  // Return as List<Map>
  return List<Map<String, dynamic>>.from(products);
}

  // Wishlist
  static Future<Set<String>> getWishlist() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return {};

    final data = await _supabase
        .from('wishlist')
        .select('product_id')
        .eq('user_id', userId);

    if (data == null) {
      return {};
    }

    return data.map<String>((item) => item['product_id'].toString()).toSet();
  }

  static Future<void> addToWishlist(String productId) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    await _supabase.from('wishlist').insert({
      'user_id': userId,
      'product_id': productId,
    });
  }

  static Future<void> removeFromWishlist(String productId) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    await _supabase
        .from('wishlist')
        .delete()
        .eq('user_id', userId)
        .eq('product_id', productId);
  }

  static Future<void> toggleWishlist(String productId) async {
  final userId = _supabase.auth.currentUser?.id;
  if (userId == null) return;

  final existing = await _supabase
      .from('wishlist')
      .select()
      .eq('user_id', userId)
      .eq('product_id', productId)
      .maybeSingle();

  if (existing == null) {
    await _supabase.from('wishlist').insert({
      'user_id': userId,
      'product_id': productId,
    });
  } else {
    await _supabase
        .from('wishlist')
        .delete()
        .eq('user_id', userId)
        .eq('product_id', productId);
  }
}

  // Get promo banners for a specific celebrity
static Future<List<String>> getCelebrityPromoBanners(String celebrityId) async {
  final data = await _supabase
      .from('celebrity_banners')
      .select('image_url')
      .eq('active', true)
      .eq('celebrity_id', celebrityId)
      .order('sort_order');
  if (data == null) return [];
  return List<String>.from(data.map((e) => e['image_url'].toString()));
}

static Future<List<Map<String, dynamic>>> getCelebrityBanners(String celebrityId) async {
  final data = await _supabase
      .from('celebrity_banners')
      .select()
      .eq('active', true)
      .eq('celebrity_id', celebrityId)
      .order('sort_order');
  if (data == null) return [];
  return List<Map<String, dynamic>>.from(data);
}

  // Get all cart items with product details
static Future<List<Map<String, dynamic>>> getCartItems() async {
  final userId = getCurrentUserId();
  print('🧪 Supabase userId: $userId (type: ${userId.runtimeType})');
  if (userId == null) return [];

  final response = await supabase
      .from('user_cart_items')
      .select('''
        id,
        quantity,
        configuration_id,
        product_id,
        added_at,
        product_configurations (
          id,
          size,
          color,
          discount,
          price,
          original_price,
          products (
            id,
            name_en,
            name_ar,
            image_url,
            brand (
              name_en,
              name_ar
            )
          )
        )
      ''')
      .eq('user_id', userId);

  if (response == null) return [];
  return List<Map<String, dynamic>>.from(response);
}

// Get all configurations (variants) for a product
static Future<List<Map<String, dynamic>>> getConfigurationsForProduct(String productId) async {
  final response = await supabase
      .from('product_configurations')
      .select()
      .eq('product_id', int.parse(productId)) // because your product_id is bigint
      .order('stock_quantity', ascending: false);

  if (response == null || response.isEmpty) return [];
  return List<Map<String, dynamic>>.from(response);
}

// Add item to cart or update quantity if exists
static Future<void> addToCart({
  required int configId,
  required int productId,  
  int quantity = 1,
}) async {
  final userId = getCurrentUserId();
  if (userId == null) return;

  final existing = await supabase
      .from('user_cart_items')
      .select('id, quantity')
      .eq('user_id', userId)
      .eq('configuration_id', configId)
      .maybeSingle();

  if (existing != null) {
    final newQty = (existing['quantity'] ?? 1) + quantity;
    await supabase
        .from('user_cart_items')
        .update({'quantity': newQty})
        .eq('id', existing['id']);
  } else {
    await supabase.from('user_cart_items').insert({
      'user_id': userId,
      'configuration_id': configId, // ✅ matches int8
      'product_id': productId,      // ✅ matches int8, must remain int
      'quantity': quantity,
    });
  }
}

// Remove from cart
static Future<void> removeFromCart(String cartItemId) async {
  await supabase.from('user_cart_items').delete().eq('id', cartItemId);
}

// Update quantity directly
static Future<void> updateCartQuantity(String cartItemId, int newQty) async {
  if (newQty <= 0) {
    await removeFromCart(cartItemId);
  } else {
    await supabase.from('user_cart_items').update({'quantity': newQty}).eq('id', cartItemId);
  }
}


  // Profile
  static Future<Map<String, dynamic>?> getCurrentUserProfile() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return null;

    final data = await _supabase
        .from('profiles')
        .select()
        .eq('id', user.id)
        .maybeSingle();

    if (data == null) {
      throw Exception('Error fetching user profile.');
    }

    return Map<String, dynamic>.from(data);
  }


// ============ CATEGORY FILTER FOR BRANDS PAGE ===============

  // Get only categories for a brand & gender that have at least one product
  static Future<List<Map<String, dynamic>>> getCategoriesForBrandAndGender({
    required String brandId,
    required String gender,
  }) async {
    // 1. Get all categories for this gender
    final cats = await _supabase
        .from('categories')
        .select()
        .eq('gender', gender);

        if (cats == null || cats.isEmpty) return [];

    // 2. Only keep categories that have at least one product for this brand
    final List<Map<String, dynamic>> filtered = [];
    for (final cat in cats) {
      final prodList = await _supabase
        .from('products')
        .select('id')
        .eq('brand_id', brandId)
        .eq('gender', gender)
        .eq('category_id', cat['uuid']);

      if (prodList != null && prodList is List && prodList.isNotEmpty) {
        filtered.add(cat);
      }
    }
    return filtered;
  }


// get brand name by ID
static Future<Map<String, dynamic>> getBrandById(String id) async {
  final data = await _supabase.from('brands').select().eq('id', id).maybeSingle();
  if (data == null) throw Exception('Brand not found');
  return Map<String, dynamic>.from(data);
}


// Get category by ID
// In supabase_service.dart
static Future<Map<String, dynamic>> getCategoryById(String id) async {
  final response = await supabase
      .from('categories')
      .select()
      .eq('uuid', id)
      .single();
  return response;
}
}
