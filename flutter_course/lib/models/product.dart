import 'package:flutter/material.dart';

import './location.dart';

class Product {
  final String id;
  final String title;
  final String description;
  final double price;
  final String image;
  final String imagePath;
  final bool isFavourite;
  final String userId;
  final String userEmail;
  final LocationData location;

  Product({
    @required this.id,
    @required this.title,
    @required this.description,
    @required this.price,
    @required this.image,
    @required this.imagePath,
    @required this.userId,
    @required this.userEmail,
    @required this.location,
    this.isFavourite = false,
  });
}
