// To parse this JSON data, do
//
//     final productModel = productModelFromJson(jsonString);

import 'dart:convert';

List<ProductModel> productModelFromJson(String str) => List<ProductModel>.from(json.decode(str).map((x) => ProductModel.fromJson(x)));

String productModelToJson(List<ProductModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class ProductModel {
    int id;
    int categoryId;
    String name;
    String ?imagePath;
    String? note;
    String createdAt;
    String updatedAt;
    String? imageUrl;
    Category category;
    List<Price> prices;

    ProductModel({
        required this.id,
        required this.categoryId,
        required this.name,
        required this.imagePath,
        required this.note,
        required this.createdAt,
        required this.updatedAt,
        required this.imageUrl,
        required this.category,
        required this.prices,
    });

    factory ProductModel.fromJson(Map<String, dynamic> json) => ProductModel(
        id: json["id"],
        categoryId: json["category_id"],
        name: json["name"],
        imagePath: json["image_path"],
        note: json["note"],
        createdAt: json["created_at"],
        updatedAt: json["updated_at"],
        imageUrl: json["image_url"],
        category: Category.fromJson(json["category"]),
        prices: List<Price>.from(json["prices"].map((x) => Price.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "category_id": categoryId,
        "name": name,
        "image_path": imagePath,
        "note": note,
        "created_at": createdAt,
        "updated_at": updatedAt,
        "image_url": imageUrl,
        "category": category.toJson(),
        "prices": List<dynamic>.from(prices.map((x) => x.toJson())),
    };
}

class Category {
    int id;
    String name;
    String createdAt;
    String updatedAt;

    Category({
        required this.id,
        required this.name,
        required this.createdAt,
        required this.updatedAt,
    });

    factory Category.fromJson(Map<String, dynamic> json) => Category(
        id: json["id"],
        name: json["name"],
        createdAt: json["created_at"],
        updatedAt: json["updated_at"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "created_at": createdAt,
        "updated_at": updatedAt,
    };
}

class Price {
    int id;
    int productId;
    String unit;
    String price;
    String currency;
    String createdAt;
    String updatedAt;

    Price({
        required this.id,
        required this.productId,
        required this.unit,
        required this.price,
        required this.currency,
        required this.createdAt,
        required this.updatedAt,
    });

    factory Price.fromJson(Map<String, dynamic> json) => Price(
        id: json["id"],
        productId: json["product_id"],
        unit: json["unit"],
        price: json["price"],
        currency: json["currency"],
        createdAt: json["created_at"],
        updatedAt: json["updated_at"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "product_id": productId,
        "unit": unit,
        "price": price,
        "currency": currency,
        "created_at": createdAt,
        "updated_at": updatedAt,
    };
}
