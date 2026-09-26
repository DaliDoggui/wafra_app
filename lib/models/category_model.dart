import 'package:flutter/material.dart';

class CategoryModel {
  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconBgColor;

  const CategoryModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconBgColor,
  });
}

final List<CategoryModel> categoriesList = [
  const CategoryModel(
    id: "cat_food",
    title: "Food & Beverages",
    subtitle: "Restaurants, Cafés, Groceries...",
    icon: Icons.fastfood_outlined,
    iconBgColor: Color(0xFFE0F2FE),
  ),
  const CategoryModel(
    id: "cat_fashion",
    title: "Fashion",
    subtitle: "Clothing, Shoes, Accessories...",
    icon: Icons.checkroom_outlined,
    iconBgColor: Color(0xFFFCE7F3),
  ),
  const CategoryModel(
    id: "cat_electronics",
    title: "Electronics",
    subtitle: "Phones, Laptops, Gadgets...",
    icon: Icons.devices_outlined,
    iconBgColor: Color(0xFFFEF3C7),
  ),
  const CategoryModel(
    id: "cat_beauty",
    title: "Beauty & Health",
    subtitle: "Skincare, Cosmetics, Wellness...",
    icon: Icons.spa_outlined,
    iconBgColor: Color(0xFFDCFCE7),
  ),
  const CategoryModel(
    id: "cat_travel",
    title: "Travel & Leisure",
    subtitle: "Flight, Hotels, Activities...",
    icon: Icons.flight_takeoff_outlined,
    iconBgColor: Color(0xFFE0E7FF),
  ),
  const CategoryModel(
    id: "cat_home",
    title: "Home & Living",
    subtitle: "Furniture, Decor, appliances...",
    icon: Icons.weekend_outlined,
    iconBgColor: Color(0xFFF3E8FF),
  ),
  const CategoryModel(
    id: "cat_sports",
    title: "Sports & Outdoors",
    subtitle: "Fitness, Gear, Equipment...",
    icon: Icons.sports_soccer_outlined,
    iconBgColor: Color(0xFFFFEDD5),
  ),
  const CategoryModel(
    id: "cat_services",
    title: "Services",
    subtitle: "Education, Finance, more...",
    icon: Icons.school_outlined,
    iconBgColor: Color(0xFFF1F5F9),
  ),
];
