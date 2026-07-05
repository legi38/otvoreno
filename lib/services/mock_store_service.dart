import '../models/store.dart';

class MockStoreService {
  static List<Store> nearbyStores() {
    return const [
      Store(id: '1', name: 'Lidl', address: 'Zagrebačka cesta 1', distanceMeters: 850, isOpen: true, statusText: 'Otvoreno još 2 h 17 min', category: StoreCategory.grocery, rating: 4.5),
      Store(id: '2', name: 'Konzum', address: 'Centar 12', distanceMeters: 1200, isOpen: true, statusText: 'Otvoreno do 20:00', category: StoreCategory.grocery, rating: 4.1),
      Store(id: '3', name: 'Pekara Aroma', address: 'Glavna 8', distanceMeters: 1400, isOpen: true, statusText: 'Otvoreno do 19:00', category: StoreCategory.bakery, rating: 4.7),
      Store(id: '4', name: 'Ljekarna Jadran', address: 'Ulica zdravlja 4', distanceMeters: 1500, isOpen: true, statusText: 'Otvoreno do 20:00', category: StoreCategory.pharmacy, rating: 4.4),
      Store(id: '5', name: 'Spar', address: 'Trg 3', distanceMeters: 1600, isOpen: false, statusText: 'Otvara u 08:00', category: StoreCategory.grocery, rating: 4.0),
      Store(id: '6', name: 'Plodine', address: 'Industrijska 22', distanceMeters: 2300, isOpen: true, statusText: 'Otvoreno do 22:00', category: StoreCategory.grocery, rating: 4.2),
    ];
  }
}
