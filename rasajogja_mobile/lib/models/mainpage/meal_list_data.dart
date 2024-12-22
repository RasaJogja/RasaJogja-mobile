class MealsListData {
  MealsListData({
    this.imagePath = '',
    this.titleTxt = '',
    this.startColor = '',
    this.endColor = '',
    this.meals,
    this.kacl = 0,
  });

  String imagePath;
  String titleTxt;
  String startColor;
  String endColor;
  List<String>? meals;
  int kacl;

  static List<MealsListData> tabIconsList = <MealsListData>[
    MealsListData(
      imagePath: 'assets/images/breakfast.png',
      titleTxt: 'Makanan',
      kacl: 25,
      meals: <String>['Nasi Goreng,', 'Gulai'],
      startColor: '#FA7D82',
      endColor: '#FFB295',
    ),
    MealsListData(
      imagePath: 'assets/images/lunch.png',
      titleTxt: 'Makanan Penutup',
      kacl: 45,
      meals: <String>['Buko Pandan,', 'Smores'],
      startColor: '#738AE6',
      endColor: '#5C5EDD',
    ),
    MealsListData(
      imagePath: 'assets/images/snack.png',
      titleTxt: 'Camilan',
      kacl: 15,
      meals: <String>['Yangko,', 'Bakpia'],
      startColor: '#FE95B6',
      endColor: '#FF5287',
    ),
    MealsListData(
      imagePath: 'assets/images/dinner.png',
      titleTxt: 'Minuman',
      kacl: 20,
      meals: <String>['Oolong tea,', 'Lavender'],
      startColor: '#6F72CA',
      endColor: '#1E1466',
    ),
  ];
}
