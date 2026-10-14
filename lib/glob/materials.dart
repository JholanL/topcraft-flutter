class AllMaterials {
  //raw materials {"id","name","category","unit","stock","reorder","unitCost","supplier"}
  static List<dynamic> materialList = [];

  //stock movements {"id","materialId","materialName","type","qty","note","by","date"}
  static List<dynamic> stockLogs = [];

  //id of the material being edited ("" = new material)
  static String selectedId = "";

  static List<String> categories = ["Metal", "Wood", "Finishing", "Hardware", "Upholstery"];

  static dynamic find(String id) {
    for (int i = 0; i < materialList.length; i++) {
      if (materialList[i]["id"] == id) return materialList[i];
    }
    return null;
  }

  static bool isLow(dynamic material) => material["stock"] <= material["reorder"];

  static int lowCount() {
    int count = 0;
    for (int i = 0; i < materialList.length; i++) {
      if (isLow(materialList[i])) count++;
    }
    return count;
  }

  static num inventoryValue() {
    num total = 0;
    for (int i = 0; i < materialList.length; i++) {
      total = total + materialList[i]["stock"] * materialList[i]["unitCost"];
    }
    return total;
  }
}
