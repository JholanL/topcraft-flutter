import '../theme/format.dart';
import 'users.dart';
import 'products.dart';
import 'orders.dart';
import 'requests.dart';
import 'materials.dart';
import 'tasks.dart';
import 'addresses.dart';
import 'activity.dart';

// Demo data so the system already looks alive on the first run.
// All demo accounts use the password: 12345678
class Seed {
  static String _ago(int days, [int hours = 0]) =>
      DateTime.now().subtract(Duration(days: days, hours: hours)).toIso8601String();

  static Map<String, dynamic> _item(String productId, int qty) {
    dynamic p = AllProducts.find(productId);
    return {"productId": productId, "name": p["name"], "price": p["price"], "qty": qty, "image": p["image"]};
  }

  static Map<String, dynamic> _order(String id, String code, String customer, List<Map<String, dynamic>> items,
      String status, String worker, int daysAgo, List<List<dynamic>> timeline) {
    int subtotal = 0;
    for (int i = 0; i < items.length; i++) {
      subtotal = subtotal + (items[i]["price"] as int) * (items[i]["qty"] as int);
    }
    dynamic address = AllAddresses.defaultOf(customer);
    return {
      "id": id,
      "code": code,
      "customer": customer,
      "type": "Shop",
      "items": items,
      "subtotal": subtotal,
      "deliveryFee": AllOrders.deliveryFee,
      "total": subtotal + AllOrders.deliveryFee,
      "payment": "Cash on Delivery",
      "recipient": address["recipient"],
      "phone": address["phone"],
      "address": AllAddresses.fullText(address),
      "status": status,
      "worker": worker,
      "notes": "",
      "qcNotes": "",
      "rated": false,
      "createdAt": _ago(daysAgo),
      "updatedAt": _ago(timeline.isEmpty ? daysAgo : timeline.last[1] as int),
      "timeline": [
        for (int i = 0; i < timeline.length; i++)
          {"status": timeline[i][0], "note": timeline[i][2], "date": _ago(timeline[i][1] as int, timeline.length - i)},
      ],
    };
  }

  static void apply() {
    AllUsers.userList = [
      {"id": "u1", "firstName": "Ramon", "lastName": "Villanueva", "email": "owner@imf.com", "phone": "09171234567", "password": "12345678", "role": "owner", "position": "Owner", "status": "Active", "createdAt": _ago(400)},
      {"id": "u2", "firstName": "Juan", "lastName": "Dela Cruz", "email": "juan@imf.com", "phone": "09181112222", "password": "12345678", "role": "worker", "position": "Welder", "status": "Active", "createdAt": _ago(300)},
      {"id": "u3", "firstName": "Pedro", "lastName": "Reyes", "email": "pedro@imf.com", "phone": "09183334444", "password": "12345678", "role": "worker", "position": "Carpenter", "status": "Active", "createdAt": _ago(250)},
      {"id": "u4", "firstName": "Ana", "lastName": "Lim", "email": "ana@imf.com", "phone": "09185556666", "password": "12345678", "role": "worker", "position": "Finisher", "status": "Active", "createdAt": _ago(120)},
      {"id": "u5", "firstName": "Maria", "lastName": "Santos", "email": "maria@gmail.com", "phone": "09191234567", "password": "12345678", "role": "customer", "position": "", "status": "Active", "createdAt": _ago(60)},
      {"id": "u6", "firstName": "Jose", "lastName": "Garcia", "email": "jose@gmail.com", "phone": "09197654321", "password": "12345678", "role": "customer", "position": "", "status": "Active", "createdAt": _ago(30)},
    ];

    AllAddresses.addressList = [
      {"id": "a1", "email": "maria@gmail.com", "label": "Home", "recipient": "Maria Santos", "phone": "09191234567", "street": "12 Mabini St.", "barangay": "Brgy. San Roque", "city": "Quezon City", "province": "Metro Manila", "isDefault": true},
      {"id": "a2", "email": "maria@gmail.com", "label": "Office", "recipient": "Maria Santos", "phone": "09191234567", "street": "5F Ayala Tower, Paseo de Roxas", "barangay": "Brgy. Bel-Air", "city": "Makati City", "province": "Metro Manila", "isDefault": false},
      {"id": "a3", "email": "jose@gmail.com", "label": "Home", "recipient": "Jose Garcia", "phone": "09197654321", "street": "88 Rizal Ave.", "barangay": "Brgy. Malanday", "city": "Marikina City", "province": "Metro Manila", "isDefault": true},
    ];

    AllProducts.productList = [
      {"id": "p1", "name": "Kyoto Dining Armchair", "category": "Chairs", "price": 6800, "stock": 14, "material": "Solid acacia wood, fabric seat", "dimensions": "52 x 50 x 78 cm", "description": "Curved backrest armchair with a padded grey seat. Built for long dinners and everyday comfort.", "image": "asset:assets/images/chair1.png", "featured": true, "createdAt": _ago(200)},
      {"id": "p2", "name": "Oak Bar Stool", "category": "Chairs", "price": 3200, "stock": 20, "material": "Solid oak", "dimensions": "38 x 38 x 75 cm", "description": "Three-legged counter height stool with a rounded seat. Perfect for kitchen islands and cafe bars.", "image": "asset:assets/images/chair2.png", "featured": false, "createdAt": _ago(180)},
      {"id": "p3", "name": "Slatted Cube Side Table", "category": "Tables", "price": 5900, "stock": 8, "material": "Teak slats, stone top", "dimensions": "50 x 50 x 50 cm", "description": "A cube of evenly spaced teak slats topped with a light stone surface. Works as a side table or night stand.", "image": "asset:assets/images/table1.png", "featured": true, "createdAt": _ago(150)},
      {"id": "p4", "name": "Round Oak Dining Table", "category": "Tables", "price": 16500, "stock": 5, "material": "Solid oak", "dimensions": "100 cm diameter x 75 cm", "description": "Round dining table with angled legs, good for 4 persons. Smooth natural oak finish.", "image": "asset:assets/images/table2.png", "featured": true, "createdAt": _ago(120)},
      {"id": "p5", "name": "Steel C-Frame Side Table", "category": "Tables", "price": 4200, "stock": 3, "material": "Black steel, walnut top", "dimensions": "48 x 30 x 62 cm", "description": "Industrial C-shaped steel frame that slides under your sofa. Great for laptops and coffee.", "image": "asset:assets/images/table3.png", "featured": false, "createdAt": _ago(90)},
    ];

    AllProducts.reviewList = [
      {"id": "r1", "productId": "p4", "orderId": "o0999", "customer": "jose@gmail.com", "rating": 5, "comment": "Solid and beautiful. Delivery was on time!", "date": _ago(4)},
      {"id": "r2", "productId": "p1", "orderId": "o1000", "customer": "maria@gmail.com", "rating": 4, "comment": "Very comfortable chair, the color matches our table.", "date": _ago(2)},
      {"id": "r3", "productId": "p3", "orderId": "o0999", "customer": "jose@gmail.com", "rating": 5, "comment": "Looks premium in person.", "date": _ago(4)},
    ];

    AllOrders.orderList = [
      _order("o0999", "ORD-0999", "jose@gmail.com", [_item("p4", 1), _item("p3", 1)], "Completed", "pedro@imf.com", 9, [
        ["Pending", 9, "Order placed by customer."],
        ["In Production", 8, "Assigned to Pedro Reyes."],
        ["Quality Check", 6, "Production finished, waiting for inspection."],
        ["Out for Delivery", 5, "Passed quality check and is on the way."],
        ["Completed", 4, "Customer confirmed receipt."],
      ]),
      _order("o1000", "ORD-1000", "maria@gmail.com", [_item("p1", 4)], "Completed", "juan@imf.com", 7, [
        ["Pending", 7, "Order placed by customer."],
        ["In Production", 6, "Assigned to Juan Dela Cruz."],
        ["Quality Check", 4, "Production finished, waiting for inspection."],
        ["Out for Delivery", 3, "Passed quality check and is on the way."],
        ["Completed", 2, "Customer confirmed receipt."],
      ]),
      _order("o1001", "ORD-1001", "maria@gmail.com", [_item("p2", 2), _item("p5", 1)], "Completed", "ana@imf.com", 6, [
        ["Pending", 6, "Order placed by customer."],
        ["In Production", 5, "Assigned to Ana Lim."],
        ["Quality Check", 3, "Production finished, waiting for inspection."],
        ["Out for Delivery", 2, "Passed quality check and is on the way."],
        ["Completed", 1, "Customer confirmed receipt."],
      ]),
      _order("o1002", "ORD-1002", "maria@gmail.com", [_item("p3", 2)], "Out for Delivery", "juan@imf.com", 4, [
        ["Pending", 4, "Order placed by customer."],
        ["In Production", 3, "Assigned to Juan Dela Cruz."],
        ["Quality Check", 1, "Production finished, waiting for inspection."],
        ["Out for Delivery", 0, "Passed quality check and is on the way."],
      ]),
      _order("o1003", "ORD-1003", "jose@gmail.com", [_item("p1", 2), _item("p4", 1)], "Quality Check", "pedro@imf.com", 3, [
        ["Pending", 3, "Order placed by customer."],
        ["In Production", 2, "Assigned to Pedro Reyes."],
        ["Quality Check", 0, "Production finished, waiting for inspection."],
      ]),
      _order("o1004", "ORD-1004", "jose@gmail.com", [_item("p2", 4)], "In Production", "juan@imf.com", 2, [
        ["Pending", 2, "Order placed by customer."],
        ["In Production", 1, "Assigned to Juan Dela Cruz."],
      ]),
      _order("o1005", "ORD-1005", "maria@gmail.com", [_item("p5", 1)], "Pending", "", 0, [
        ["Pending", 0, "Order placed by customer."],
      ]),
    ];
    AllOrders.orderList[0]["rated"] = true;
    AllOrders.orderList[1]["rated"] = true;
    AllOrders.orderList[2]["payment"] = "GCash";
    AllOrders.orderCounter = 1006;
    AllOrders.cartList = [
      {"id": "c1", "email": "maria@gmail.com", "productId": "p4", "qty": 1},
    ];

    AllTasks.taskList = [
      {"id": "t1", "orderId": "o0999", "orderCode": "ORD-0999", "worker": "pedro@imf.com", "title": "Build ORD-0999", "details": "Round Oak Dining Table x1, Slatted Cube Side Table x1", "progress": "Done", "dueDate": _ago(6), "assignedAt": _ago(8), "completedAt": _ago(6), "note": ""},
      {"id": "t2", "orderId": "o1000", "orderCode": "ORD-1000", "worker": "juan@imf.com", "title": "Build ORD-1000", "details": "Kyoto Dining Armchair x4", "progress": "Done", "dueDate": _ago(4), "assignedAt": _ago(6), "completedAt": _ago(4), "note": ""},
      {"id": "t3", "orderId": "o1001", "orderCode": "ORD-1001", "worker": "ana@imf.com", "title": "Build ORD-1001", "details": "Oak Bar Stool x2, Steel C-Frame Side Table x1", "progress": "Done", "dueDate": _ago(3), "assignedAt": _ago(5), "completedAt": _ago(3), "note": ""},
      {"id": "t4", "orderId": "o1002", "orderCode": "ORD-1002", "worker": "juan@imf.com", "title": "Build ORD-1002", "details": "Slatted Cube Side Table x2", "progress": "Done", "dueDate": _ago(1), "assignedAt": _ago(3), "completedAt": _ago(1), "note": ""},
      {"id": "t5", "orderId": "o1003", "orderCode": "ORD-1003", "worker": "pedro@imf.com", "title": "Build ORD-1003", "details": "Kyoto Dining Armchair x2, Round Oak Dining Table x1", "progress": "Done", "dueDate": _ago(0), "assignedAt": _ago(2), "completedAt": _ago(0, 3), "note": "Sanded and varnished twice."},
      {"id": "t6", "orderId": "o1004", "orderCode": "ORD-1004", "worker": "juan@imf.com", "title": "Build ORD-1004", "details": "Oak Bar Stool x4", "progress": "In Progress", "dueDate": Format.daysFromNow(3), "assignedAt": _ago(1), "completedAt": "", "note": ""},
    ];

    AllRequests.requestList = [
      {"id": "cr1", "code": "CR-2001", "customer": "maria@gmail.com", "furnitureType": "Shelf", "dimensions": "180 x 40 x 200 cm", "material": "Steel + Wood", "finish": "Matte black frame, walnut stain", "quantity": 1, "budget": 25000, "notes": "Five layer pipe bookshelf for our living room wall.", "image": "", "status": "Quoted", "quotePrice": 24500, "quoteNote": "Includes wall anchors and installation.", "leadDays": 14, "orderId": "", "createdAt": _ago(3), "updatedAt": _ago(1)},
      {"id": "cr2", "code": "CR-2002", "customer": "jose@gmail.com", "furnitureType": "Table", "dimensions": "240 x 100 x 75 cm", "material": "Narra Wood", "finish": "Natural oil finish", "quantity": 1, "budget": 45000, "notes": "Long dining table for 8 persons with steel hairpin legs.", "image": "", "status": "Submitted", "quotePrice": 0, "quoteNote": "", "leadDays": 0, "orderId": "", "createdAt": _ago(1), "updatedAt": _ago(1)},
    ];
    AllRequests.requestCounter = 2003;

    AllMaterials.materialList = [
      {"id": "m1", "name": "Black Steel Pipe 1in", "category": "Metal", "unit": "pcs", "stock": 40, "reorder": 15, "unitCost": 350, "supplier": "Manila Steel Supply"},
      {"id": "m2", "name": "Narra Wood Plank", "category": "Wood", "unit": "board ft", "stock": 25, "reorder": 30, "unitCost": 180, "supplier": "Quezon Lumber"},
      {"id": "m3", "name": "Solid Oak Board", "category": "Wood", "unit": "board ft", "stock": 60, "reorder": 20, "unitCost": 260, "supplier": "Quezon Lumber"},
      {"id": "m4", "name": "Matte Black Paint", "category": "Finishing", "unit": "gallon", "stock": 6, "reorder": 5, "unitCost": 950, "supplier": "Boysen Depot"},
      {"id": "m5", "name": "Wood Varnish", "category": "Finishing", "unit": "liter", "stock": 4, "reorder": 6, "unitCost": 420, "supplier": "Boysen Depot"},
      {"id": "m6", "name": "Floor Flange", "category": "Hardware", "unit": "pcs", "stock": 80, "reorder": 20, "unitCost": 85, "supplier": "Manila Steel Supply"},
      {"id": "m7", "name": "Grey Upholstery Fabric", "category": "Upholstery", "unit": "yard", "stock": 18, "reorder": 10, "unitCost": 300, "supplier": "Divisoria Textile"},
    ];
    AllMaterials.stockLogs = [
      {"id": "s1", "materialId": "m3", "materialName": "Solid Oak Board", "type": "Stock In", "qty": 40, "note": "Delivery from Quezon Lumber", "by": "owner@imf.com", "date": _ago(5)},
      {"id": "s2", "materialId": "m2", "materialName": "Narra Wood Plank", "type": "Stock Out", "qty": 15, "note": "Used for ORD-1003", "by": "pedro@imf.com", "date": _ago(2)},
      {"id": "s3", "materialId": "m5", "materialName": "Wood Varnish", "type": "Stock Out", "qty": 3, "note": "Finishing of ORD-1002", "by": "juan@imf.com", "date": _ago(1)},
    ];

    AllActivity.notificationList = [];
    AllActivity.logList = [];
    AllActivity.notify("maria@gmail.com", "ORD-1002 • Out for Delivery", "Your order passed quality check and is on the way.", "order");
    AllActivity.notify("maria@gmail.com", "CR-2001 • Quotation ready", "We sent a quotation of ₱24,500.00 for your custom shelf.", "request");
    AllActivity.notify("jose@gmail.com", "ORD-1003 • Quality Check", "Your order is being inspected by our team.", "order");
    AllActivity.notify("owner@imf.com", "New order ORD-1005", "Maria Santos placed an order (Steel C-Frame Side Table x1).", "order");
    AllActivity.notify("owner@imf.com", "New custom request CR-2002", "Jose Garcia requested a Narra dining table.", "request");
    AllActivity.notify("owner@imf.com", "Low stock: Narra Wood Plank", "Only 25 board ft left (reorder at 30).", "inventory");
    AllActivity.notify("juan@imf.com", "New task: ORD-1004", "Oak Bar Stool x4 is assigned to you.", "task");
    AllActivity.log("juan@imf.com", "Started task for ORD-1004");
    AllActivity.log("juan@imf.com", "Finished task for ORD-1002");
    AllActivity.log("pedro@imf.com", "Finished task for ORD-1003");
    AllActivity.log("pedro@imf.com", "Took out 15 board ft of Narra Wood Plank");
  }
}
