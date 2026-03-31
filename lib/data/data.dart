import '../models/category_model.dart';

String apiKey = "yIvRIsrIlmhaaLeNN0q6yvBGT72teIS257YOsrhigvVKhvonN5KD6ovI";

List<CategoryModel> getCategories() {
  List<CategoryModel> categories = [];
  CategoryModel categoryModel = CategoryModel();

  //
  categoryModel.imgUrl =
      "https://images.pexels.com/photos/545008/pexels-photo-545008.jpeg?auto=compress&cs=tinysrgb&dpr=2&w=500";
  categoryModel.categoryName = "Street Art";
  categories.add(categoryModel);
  categoryModel = CategoryModel();

  //
  categoryModel.imgUrl =
      "https://images.pexels.com/photos/704320/pexels-photo-704320.jpeg?auto=compress&cs=tinysrgb&dpr=2&w=500";
  categoryModel.categoryName = "Wild Life";
  categories.add(categoryModel);
  categoryModel = CategoryModel();

  //
  categoryModel.imgUrl =
      "https://images.pexels.com/photos/34950/pexels-photo.jpg?auto=compress&cs=tinysrgb&dpr=2&w=500";
  categoryModel.categoryName = "Nature";
  categories.add(categoryModel);
  categoryModel = CategoryModel();

  //
  categoryModel.imgUrl =
      "https://images.pexels.com/photos/466685/pexels-photo-466685.jpeg?auto=compress&cs=tinysrgb&dpr=2&w=500";
  categoryModel.categoryName = "City";
  categories.add(categoryModel);
  categoryModel = CategoryModel();

  //
  categoryModel.imgUrl =
      "https://images.pexels.com/photos/1434812/pexels-photo-1434812.jpeg?auto=compress&cs=tinysrgb&dpr=2&w=500";
  categoryModel.categoryName = "Motivation";
  categories.add(categoryModel);
  categoryModel = CategoryModel();

  //
  categoryModel.imgUrl =
      "https://images.pexels.com/photos/2116475/pexels-photo-2116475.jpeg?auto=compress&cs=tinysrgb&dpr=2&w=500";
  categoryModel.categoryName = "Bikes";
  categories.add(categoryModel);
  categoryModel = CategoryModel();

  //
  categoryModel.imgUrl =
      "https://images.pexels.com/photos/1149137/pexels-photo-1149137.jpeg?auto=compress&cs=tinysrgb&dpr=2&w=500";
  categoryName: categoryModel.categoryName = "Cars";
  categories.add(categoryModel);
  categoryModel = CategoryModel();

  return categories;
}
